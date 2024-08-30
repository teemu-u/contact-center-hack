# Challenge 1 - Resources Deployment

## Introduction
Your goal in this challenge is to create the services necessary to conduct this hackathon. You will deploy the required resources in Azure, including the Azure AI services that will be used in the subsequent challenges. By completing this challenge, you will set up the foundation for the rest of the hackathon.

## Resource Deployment Guide
1. Navigate to the [Azure portal](https://portal.azure.com/#home) and login with your account.
2. Navigate to your resource group. In this guide, the resource group is named `rg-genai-callcenter`. At this point, it should be empty.
![Empty Resource Group](./images/rg_empty.png)
3. Let's create our **Azure AI Search Service**. 
    * Click on the `Create` button.
    * Search for `Azure AI Search` and click `Create`.
    * Fill the *Service name* field (needs to be unique in the chosen region) and select the *Location*. In this guide, all resources are going to be deployed in the `Sweden Central` region. 
    * Choose your *Pricing Tier* for this exercise. In this guide, we will use `Basic`.
    * Click on `Review + Create` and then `Create`.
    ![AI Search](./images/aisearch.png)
    * Wait for the deployment to complete.
4. Navigate to your resource group.
5. Let's create our **Cosmos DB Service**.
    * Click on the `Create` button.
    * Search for `Azure Cosmos DB` and click `Create`.
    * Select `Azure Cosmos DB for NoSQL`.
    * Fill the *Account name* field and select the *Location*. Be sure to use the same *Location* for all services wherever possible.
    * In the *Capacity Mode* field, select `Serverless`.
    * Click on `Review + Create` and then `Create`.
    ![Cosmos DB](./images/cosmosdb.png)
    * Wait for the deployment to complete.
6. Navigate to your resource group.
7. Let's create our **Azure AI Studio**.
    * Click on the `Create` button.
    * Search for `Azure AI Studio` and click `Create`.
    * Fill the *Name* field and select the *Region*. Be sure to use the same *Location* for all services wherever possible.
    * Click on `Review + Create` and then `Create`.
    ![AI Hub](./images/aihub.png)
    * Wait for the deployment to complete.
8. Navigate to your resource group.
9. You should now have all the services deployed in your resource group:
    * An Azure AI Search Service
    * An Azure Cosmos DB account
    * An Azure AI Studio
    * An Azure Storage Account (deployed automatically by AI Studio)
    * An Azure Key Vault (deployed automatically by AI Studio)
    * An Azure AI Services (deployed automatically by AI Studio)
    ![Resource Group full](./images/rg_full.png)

## Setup Azure AI Studio
1. Navigate to your resource group.
2. Click on the **Azure AI Studio** resource name.
3. Click on the `Launch Azure AI Studio`.
![Launch AI Studio](./images/aistudioportal.png)
4. On the `Hub Overview` tab, click on `New connection`.
![Create project](./images/aihub_connection.png)
5. Select the `Azure AI Search`.
6. From the list of possible AI Search services, select the one you created in the previous steps and click `Add connection`.
7. Navigate to the `Hub Overview` tab.
8. From the left pane, select `Deployments`.
9. Click `+ Deploy model` and `Deploy base model`.
10. Select `gpt-4o-mini` and click `Confirm`. If you do not have `gpt-4o-mini` available in your chosen region, select `gpt-4o` or `gpt-3.5-turbo`.
11. Click on `Customize`.
12. Fill the `Deployment name`.
13. In `Deployment Type`, select either *Standard* or *Global Standard*. **DO NOT select *Provisioned* or *Global Batch***.
14. In the `Tokens per Minute Rate Limit (thousands)` select at least 200k. If this is blocked for you, there might be other resources consuming quota in your subscription. Please check with your subscription administrator.
![Create project](./images/gpt4omini.png)
15. Return to the `Deployments` page.
16. Click `+ Deploy model` and `Deploy base model`.
17. Select `text-embedding-ada-002` and click `Confirm`.
18. Click on `Customize`.
19. Fill the `Deployment name`.
20. In `Deployment Type`, select either *Standard*.
21. In the `Tokens per Minute Rate Limit (thousands)` select at least 100k. If this is blocked for you, there might be other resources consuming quota in your subscription. Please check with your subscription administrator.
![Create project](./images/textembeddings.png)
22. Return to the `Hub Overview`.
23. Click on `+ New project`.
![Create project](./images/aihub_createproject.png)
24. Give your project a name and click on `Create a project`.
![Create project 2](./images/aihub_createproject2.png)
25. Wait for the project to be created.