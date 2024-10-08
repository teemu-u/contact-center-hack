![3](https://github.com/user-attachments/assets/dad008f7-0112-45a9-baa0-a2461a67130b)

# Contact Center Operations using the Azure AI Platform
Welcome to the Contact Center Operations using the Azure AI Platform Hackathon! Today, you're set to dive into the transformative world of AI, with a focus on utilizing the power of Azure OpenAI services. Prepare yourself for a day of intense learning, innovation, and hands-on experience that will elevate your understanding of AI integration in application development.


## Introduction
Your quest is to innovate for the future at the fictitious enterprise, XYZ Telecommunication. Your challenge? To integrate next-generation AI capabilities into XYZ Telecommunication's ecosystem, enhancing their call center operations and customer engagement through intelligent application development.


## Learning Objectives

By participating in this hackathon, you will learn how to:
- **Extract Information from files :** Understand how to use Azure OpenAI Service to extract and transform key information from SOPs, enhancing data with AI.
- **Index and Search your Data:** Explore how to use Azure AI Search to index SOPs and enable fast, efficient data retrieval.
- **Orchestrate a RAG solution with Prompt Flow:** Learn how to orchestrate interactions between AI models and compute services using Prompt Flow for seamless automation.
- **Build a Web App for your Flow:** Build a web interface using Azure App Service, allowing users to search and interact with processed data in a user-friendly way.
  
## Architecture
In this workflow, Standard Operation Procedures (SOPs) are uploaded and stored in an Azure Storage Account. From there, the Azure AI Hub integrates various models and compute services like the Azure OpenAI Service, which are used to interact with and process these documents. SOPs are indexed using Azure AI Search and stored as vector indexes for fast retrieval. We use the Azure CosmosDB to store the call transcripts and enables further interactions with processed data, while services like Key Vault, Azure Application Insights, and Log Analytics ensure security, insights, and monitoring. Prompt Flow plays a key role in orchestrating the flow, managing interactions between all of the previously mentioned resources. The App Service then allows users, like contact center agents, to access a web front-end interface, providing a seamless user experience for searching and interacting with the indexed data.

![image](https://github.com/user-attachments/assets/63c65473-a090-4a2f-a264-ba0a64b6814f)


## Requirements
1. An active **Azure subscription** 
2. A resource group with the `Contributor` role assigned
3. 120k of available quota for the *gpt-4o-mini* model in the *Sweden Central* region
4. 20k of available quota for the *text-embedding-ada-002* model in the *Sweden Central* region 
5. Basic knowledge of Python
6. A GitHub account
7. [GitHub Codespaces](https://github.com/features/codespaces) or Visual Studio Code for local development
8. Python for local development (tested with version 3.12.5)

## Hackathon Format: Challenge-Based
This hackathon adopts a challenge-based format, offering you a unique opportunity to learn while dealing with practical problems. Each challenge includes one or more self-contained tasks designed to test and enhance your skills in specific aspects of AI app development. You will approach these challenges by:
- Analyzing the problem statement.
- Strategizing your approach to find the most effective solution.
- Leveraging the provided lab environment and Azure AI services.
- Collaborating with peers to refine and implement your solutions.

### Challenges
1. Challenge 01: **[Resources Deployment](Challenge1/README.md)**
   - Creation of the Services necessary to conduct this Hack
2. Challenge 02: **[Incorporating your data with LLM's](Challenge2/README.md)**
   - Learn how to provide your data to the LLM, so you can tailor it to your needs.
3. Challenge 03: **[Create your first LLM-Powered Endpoint](Challenge3/README.md)**
   - Create a Prompt Flow and deploy it as an API.
4. Challenge 04: **[Real-time call transcription and agent assistance](Challenge4/README.md)**
   - Develop an app which uses Azure AI Speech and the Prompt Flow endpoint to assist the call center agent.
5. Challenge 05: **[Deploy the application](Challenge5/README.md)**
   - Deploy the application in Azure App Service.
   
Each challenge comes with its own set of tasks and objectives. Feel free to explore the challenges, learn, and have fun during this hackathon! If you have any questions, don't hesitate to reach out to your coach.

Happy hacking! 
