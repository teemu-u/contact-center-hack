![3](https://github.com/user-attachments/assets/dad008f7-0112-45a9-baa0-a2461a67130b)

# Challenge 5 - Deploy the application

**Expected Duration:** 30 minutes

## Introduction
In this challenge, we will deploy our streamlit application to an Azure Web App Service to be available for usage outside of our local environment.

## Guide: Configure the Azure Web App Service to run Streamlit
1. Right click the directory `Challenge4` within Codespace and select `Deploy to Web App`. Sign-in to your Azure account if necessary.
![deploywebapp](./images/deploywebapp.png)
2. Select the Azure Web App created in [Challenge 1](../Challenge1/README.md) and deploy your Web App.
3. Wait for the deployment to complete.
4. Navigate to the [Azure portal](https://portal.azure.com/#home) and sign in with your account.
5. Navigate to the resource group created in `Challenge1` and open the App Service resource (name of the resource starts with `hackai-appservice`).
6. You can find the URL of your application in the `Overview` section, under the `Default domain` field.
![url](./images/url.png)
10. Open the URL in your browser to access the application.
11. The first time you open your application it may take a few minutes to load. Subsequent loads will be faster.

**NOTE:** This application is available to anyone with the URL. Ensure that you do not share the URL with anyone you do not want to have access to the application. In a production scenario, this application would be secured with authentication and authorization. To learn more on this topic, refer to the [Azure App Service Authentication and Authorization](https://learn.microsoft.com/en-us/azure/app-service/scenario-secure-app-authentication-app-service?tabs=workforce-configuration) documentation.

## Guide: Create CI/CD pipeline with GitHub Actions (optional)

Create GitHub Actions CI/CD pipeline to automatically deploy changes of you code to the Web App. 

**NOTE:** This challenge is optional. If you want to learn more about CI/CD pipelines, you can follow the documentation [Deploy to Azure App Service using GitHub Actions](https://learn.microsoft.com/en-us/azure/app-service/deploy-github-actions?tabs=openid%2Cpython%2Cpythonn) and setup CI/CD pipeline for your application.

## Guide: Delete your environment
1. Navigate to the [Azure portal](https://portal.azure.com/#home) and login with your account.
2. Navigate to your resource group.
3. Save all of the artifacts that you want to keep. For example, in your Prompt Flow, you can save the work done in the Prompt Flow page by downloading the files com the `Files` section.
3. Click `Delete resource group`. Follow the instructions and confirm the deletion.
4. Your resources will be deleted, along with all the resources within and, you will avoid future charges.

## Conclusion
In this challenge, you have successfully deployed your Streamlit application to an Azure Web App Service. You can now access your application from anywhere with an internet connection.