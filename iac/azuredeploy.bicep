@description('Azure location where resources should be deployed (e.g., swedencentral)')
param location string = 'swedencentral'

var prefix = 'hackai'
var suffix = uniqueString(resourceGroup().id)

/*
  Create a Cosmos DB account with a database and a container
*/

var databaseAccountName = '${prefix}-cosmosdb-${suffix}'
var databaseName = 'callcenter'
var databaseContainerName = 'calls'

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: databaseAccountName
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  name: databaseName
  parent: databaseAccount
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource databaseContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  name: databaseContainerName
  parent: database
  properties: {
    resource: {
      id: databaseContainerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
    }
    options: {
      autoscaleSettings: {
        maxThroughput: 1000
      }
    }
  }
}

/*
  Create App Service
*/

var appHostingPlanName = '${prefix}-appservice-asp-${suffix}'
var appName = '${prefix}-appservice-${suffix}'
var appLogAnalyticsWorkspaceName = '${prefix}-loganalytics-${suffix}'
var appApplicationInsightsName = '${prefix}-appinsights-${suffix}'

resource appLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: appLogAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appApplicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appApplicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    DisableIpMasking: false
    DisableLocalAuth: false
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: false
    ImmediatePurgeDataOn30Days: true
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Disabled'
    Request_Source: 'rest'
    WorkspaceResourceId: appLogAnalyticsWorkspace.id
  }
}

resource appHostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appHostingPlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appHostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_CONNECTION_STRING'
          value: appApplicationInsights.properties.ConnectionString
        }
      ]
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      use32BitWorkerProcess: false
      linuxFxVersion: 'PYTHON|3.12'
    }
    httpsOnly: true
  }
}

/* 
  Create Azure AI Studio
*/

var aiCognitiveServicesName = '${prefix}-aiservices-${suffix}'
var aiContainerRegistryName = replace('${prefix}-containerregistry-${suffix}', '-', '')
var aiKeyvaultName = replace('${prefix}-kv-${suffix}', '-', '')
var aiStorageAccountName = replace('${prefix}-strg-${suffix}', '-', '')
var aiHubName = '${prefix}-aistudio-${suffix}'
var aiHubFriendlyName = 'GenAI Call Center AI Studio'
var aiHubDescription = 'This is an example AI resource for use in Azure AI Studio.'

resource aiContainerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: aiContainerRegistryName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
    dataEndpointEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSet: {
      defaultAction: 'Deny'
    }
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 7
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Disabled'
  }
}

resource aiKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: aiKeyvaultName
  location: location
  properties: {
    createMode: 'default'
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    enableRbacAuthorization: true
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
    tenantId: subscription().tenantId
  }
}

resource aiStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: aiStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource aiCognitiveServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiCognitiveServicesName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices' // or 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
  name: aiHubName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: aiKeyVault.id
    storageAccount: aiStorageAccount.id
    applicationInsights: appApplicationInsights.id
    containerRegistry: aiContainerRegistry.id
  }
  kind: 'hub'

  resource aiServicesConnection 'connections@2024-01-01-preview' = {
    name: '${aiHubName}-connection-AzureOpenAI'
    properties: {
      category: 'AzureOpenAI'
      target: aiCognitiveServices.properties.endpoint
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(aiCognitiveServices.id, '2021-10-01').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiCognitiveServices.id
      }
    }
  }
}

/*
  Create Azure AI Search
*/

var searchServiceName = '${prefix}-search-${suffix}'

resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchServiceName
  location: location
  sku: {
    name: 'basic'
  }
  properties: {
    hostingMode: 'default'
  }
  dependsOn: [
    aiCognitiveServices
  ]
}
