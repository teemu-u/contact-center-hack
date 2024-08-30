# Challenge 1 - Resources Deployment

## Introduction
Your goal in this challenge is to create the services necessary to conduct this hackathon. You will deploy the required resources in Azure, including the Azure AI services that will be used in the subsequent challenges. By completing this challenge, you will set up the foundation for the rest of the hackathon.

## Guide
1. Navigate to the [Azure portal](https://portal.azure.com/#home) and login with your account.
2. Navigate to your resource group. In this guide, the resource group is named `rg-genai-callcenter`. At this point, it should be empty.
![Empty Resource Group](./images/rg_empty.png)
3. Let's create our Azure AI Search Service. 
    i. Click on the `Create` button.
    ii. Search for `Azure AI Search` and click `Create`.
    iii. Fill the *Service name* field (needs to be unique in the chosen region) and select the *Location*. In this guide, the resources are going to be deployed in the `Sweden Central` region. 
    iv. Choose your *Pricing Tier* for this exercise. In this guide, we will use `Basic`.
    ![AI Search](./images/aisearch.png)
    v. Click on `Review + Create` and then `Create`. 
    vi. Wait for the deployment to complete.
4. Navigate to your resource group.
5. Let's create our Cosmos DB Service.
    i. Click on the `Create` button.