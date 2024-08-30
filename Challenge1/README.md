# Challenge 1 - Resources Deployment

## Introduction
Your goal in this challenge is to create the services necessary to conduct this hackathon. You will deploy the required resources in Azure, including the Azure AI services that will be used in the subsequent challenges. By completing this challenge, you will set up the foundation for the rest of the hackathon.

## Local Setup

## Resource Deployment Guide
1. Navigate to the [Azure portal](https://portal.azure.com/#home) and login with your account.
2. Navigate to your resource group. In this guide, the resource group is named `rg-genai-callcenter`. At this point, it should be empty.
![Empty Resource Group](./images/rg_empty.png)
3. Let's create our Azure AI Search Service. 
    * Click on the `Create` button.
    * Search for `Azure AI Search` and click `Create`.
    * Fill the *Service name* field (needs to be unique in the chosen region) and select the *Location*. In this guide, all resources are going to be deployed in the `Sweden Central` region. 
    * Choose your *Pricing Tier* for this exercise. In this guide, we will use `Basic`.
    * Click on `Review + Create` and then `Create`.
    ![AI Search](./images/aisearch.png)
    * Wait for the deployment to complete.
4. Navigate to your resource group.
5. Let's create our Cosmos DB Service.
    * Click on the `Create` button.
    * Search for `Azure Cosmos DB` and click `Create`.
    * Select `Azure Cosmos DB for NoSQL`.
    * Fill the *Account name* field and select the *Location*. Be sure to use the same *Location* for all services wherever possible.
    * In the *Capacity Mode* field, select `Serverless`.
    * Click on `Review + Create` and then `Create`.
    ![Cosmos DB](./images/cosmosdb.png)
    * Wait for the deployment to complete.
6. Navigate to your resource group.
7. Let's create our Azure AI Studio.
    * Click on the `Create` button.
    * Search for `Azure AI Studio` and click `Create`.
    * Fill the *Name* field and select the *Region*. Be sure to use the same *Location* for all services wherever possible.
    * Click on `Review + Create` and then `Create`.
    ![Cosmos DB](./images/aihub.png)
    * Wait for the deployment to complete.