# Introduction

Imagine you're building a website for a new business, or you're running an existing web app on an aging on-premises server. Setting up a new server can be challenging. You need the appropriate hardware, likely a server-level operating system, and a web-hosting stack.

Once it's running, you need to maintain the server. And what happens if your website traffic increases? You might need to invest in more hardware.

Hosting your web application using Azure App Service makes deploying and managing a web app easier when compared to managing a physical server. In this module, we implement and deploy a web app to App Service.

## Learning objectives

In this module, you'll:

Use the Azure portal to create an Azure App Service web app.
Use developer tools to create the code for a starter web application.
Deploy your code to App Service.

### Prerequisites

Ability to navigate the Azure portal
Ability to use a command-line interface

## Creating a web app in Azure

In this unit, you learn how to create an Azure App Service web app using the Azure portal.

### Why use the Azure portal?

The first step in hosting your web application is to create a web app (an Azure App Service app) inside your Azure subscription.

There are several ways you can create a web app. You can use the Azure portal, the Azure Command Line Interface (CLI), a script, or an integrated development environment (IDE) like Visual Studio.

The information in this unit discusses how to use the Azure portal to create a web app, and you use this information to create a web app in the next exercise. For this module, we demonstrate using the Azure portal because it's a graphical experience, which makes it a great learning tool. The portal helps you discover available features, add other resources, and customize existing resources.

### What is Azure App Service?

Azure App Service is a fully managed web application hosting platform. This platform as a service (PaaS) offered by Azure allows you to focus on designing and building your app while Azure takes care of the infrastructure to run and scale your applications.

#### Deployment slots

Using the Azure portal, you can easily add deployment slots to an App Service web app. For instance, you can create a staging deployment slot where you can push your code to test on Azure. Once you're happy with your code, you can easily swap the staging deployment slot with the production slot. All it takes is a few mouse clicks in the Azure portal.

[Screenshot of the staging deployment slot to test the deployments.](deployment_slots.png)

#### Continuous integration/deployment support

The Azure portal provides out-of-the-box continuous integration and deployment with Azure Repos, GitHub, Bitbucket, FTP, or a local Git repository on your development machine. You can connect your web app with any of the preceding sources, and App Service does the rest for you. It automatically syncs your code and any future changes on the code into the web app. Furthermore, with Azure Repos, you can define your own build and release process. A full process that compiles your source code, runs the tests, builds a release, and finally deploys the release into your web app every time you commit the code. All that happens implicitly, without any need for you to intervene.

[Screenshot of setting up deployment options and choosing source for the deployment source code.](deployment_options.png)

#### Integrated Visual Studio publishing and FTP publishing

In addition to being able to set up continuous integration/deployment for your web app, you can always benefit from the tight integration with Visual Studio to publish your web app to Azure via Web Deploy technology. App Service also supports FTP-based publishing for more traditional workflows.

#### Built-in autoscale support (automatic scale-out based on real-world load)

The ability to scale up/down or scale out is baked into the web app. Depending on the web app's usage, you can scale your app up/down by increasing/decreasing the resources of the underlying machine that's hosting your web app. Resources can be the number of cores or the amount of RAM available. On the other hand, you can scale out your app by increasing the number of machine instances that are running your web app.

### Creating a web app

When you're ready to run a web app on Azure, you can visit the Azure portal and create a *Web App* resource. Creating a web app allocates a set of hosting resources in App Service. You can use these resources to host any web-based application Azure supports, whether it's ASP.NET Core, Node.js, Java, Python, and so on.

The Azure portal provides a wizard to create a web app. This wizard requires the following fields:

Field | Description
Subscription | A valid and active Azure subscription.
Resource group | A valid resource group.
Name | The name of the web app. This name becomes part of the app's URL, so it must be unique among all Azure App Service web apps.
Publish | You can deploy your application to App Service as code or as a ready-to-run Docker Container. Selecting Container activates the wizard's Container tab, where you provide information about the Docker registry from which App Service retrieves your image.
Runtime stack | If you choose to deploy your application as code, App Service needs to know what runtime your application uses (examples include Node.js, Python, Java, and .NET). If you deploy your application as a container, you don't need to choose a runtime stack, because your image includes it.
Operating system | App Service can host applications on Windows or Linux servers. For more information, see the Operating systems section in this unit.
Region | The Azure region from which your application is served.
Pricing Plans | See the Pricing Plans section in this unit for information about App Service plans.

#### Operating systems

If you're deploying your app as code, many of the available runtime stacks are limited to one operating system or the other. After you choose a runtime stack, the toggle will indicate whether or not you have a choice of operating system. If your target runtime stack is available on both operating systems, select the one that you use to develop and test your application.

If your application is packaged as a container, specify the operating system in your container.

#### App Service plans

An App Service plan is a set of virtual server resources that run App Service apps. A plan's size (sometimes referred to as its sku or pricing tier) determines the performance characteristics of the virtual servers that run the apps assigned to the plan, and the App Service features to which those apps have access. Every App Service web app you create must be assigned to a single App Service plan that runs it.

A single App Service plan can host multiple App Service web apps. In most cases, the number of apps you can run on a single plan is limited by the apps' performance characteristics and the plan's resource limitations.

App Service plans determine the App Service's unit of billing. The size of each App Service plan in your subscription, in addition to the bandwidth resources the apps deployed to those plans use, determines the price you pay. The number of web apps deployed to your App Service plans has no effect on your bill.

You can use any of the available Azure management tools to create an App Service plan. When you create a web app via the Azure portal, the wizard helps you to create a new plan at the same time if you don't already have one.

### Creation Steps

Sign in to the Azure portal using your Azure account.

1. On the Azure portal menu or from the *Home* page, select *Create a resource*. Everything you create on Azure is a resource. The *Create a resource* pane appears.

Here, you can search for the resource you want to create, or select one of the popular resources that people create in the Azure portal.

2. In the *Create a resource* menu, select *Web*.

3. Select *Web App*. If you don't see it, in the search box, search for and select *Web App*. The *Create Web App* pane appears.

4. On the Basics tab, enter the following values for each setting.

Setting | Value | Details
Project Details
Subscription | Select your Azure subscription | The web app you're creating must belong to a resource group. Here, you select the Azure subscription to which the resource group belongs.
Resource Group | Select *Create new* and enter a name like *myResourceGroup* | The resource group to which the web app belongs. All Azure resources must belong to a resource group.
Instance Details		
Name | Enter a name | The name of your web app. This name becomes part of the app's URL: appname-hash.region.azurewebsites.net.
Publish | Code | The method you want to use to publish your application. When publishing an application as code, you must also configure Runtime stack to prepare App Service resources to run your app.
Runtime stack | .NET 8 (LTS) | The platform on which your application is going to run. Your choice might affect whether you have a choice of operating system - for some runtime stacks, App Service supports only one operating system.
Operating System | Linux | The operating system used on the virtual servers to run your app.
Region | East US | The geographical region from which your app is hosted.
Pricing plans		
Linux Plan | Accept default | The name of the App Service plan that powers your app. By default, the wizard creates a new plan in the same region as the web app.
Pricing plan | Free F1 | The pricing tier of the service plan being created. The pricing plan determines the performance characteristics of the virtual servers that power your app and the features to which it has access. Select Free F1 in the drop-down.

[Screenshot showing web app creation details.](app_creation_details.png)

5. Leave any other settings as default. Select *Review + Create* to go to the review pane, and then select *Create*. The portal shows the deployment pane, where you can view the status of your deployment.

Note
It can take a moment for deployment to complete.

#### Preview your web app

1. When deployment is complete, select Go to resource. The portal shows the App Service Overview pane for your web app.

[Screenshot showing the App Service pane with the URL link of the overview section highlighted.](app_service_pane.png)

2. To preview your web app's default content, select the URL under Default domain at the top right. The placeholder page that loads indicates that your web app is up and running and is ready to receive deployment of your app's code.

[Screenshot showing your App Service in a browser.](app_in_browser.png)

Leave the browser tab with the new app's placeholder page open. You'll come back to it after your app is deployed.

## Prepare the web application code

In this unit, you learn how to create the code for your web application and integrate it into a source-control repository.

### Bootstrap a web application

Now that you created the resources for deploying your web application, you have to prepare the code you want to deploy. There are many ways to bootstrap a new web application, so what we learn here might be different to what you're used to. The goal is to quickly provide you a starting point to complete a full cycle up to the deployment.

> Note
> All the code and commands shown on this page are only for explanation purposes; you do not need to execute any of them. We use them in a subsequent exercise.

To create a new web application starter using a few lines of code, you can use Flask, which is a commonly used web-application framework. You can install Flask using the following command:

```bash
pip install flask
```

After Flask is available in your environment, you can create a minimal web application using this code:

```bash
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!\n"
```

This example code creates a server that answers every request with a "Hello World!" message.

### Adding your code to source control

After your web application code is ready, the next step is usually to put the code into a source-control repository such as Git. If you have Git installed on your machine, running these commands in your source-code folder initializes the repository.

```bash
git init
git add .
git commit -m "Initial commit"
```

These commands allow you to initialize a local Git repository and create a first commit with your code. You immediately gain the benefit of keeping a history of your changes with commits. Later on, you're able to synchronize your local repository with a remote repository; for example, hosted on GitHub. This synchronization allows you to set up continuous integration and continuous deployment (CI/CD). While we recommend using a source-control repository for production applications, it's not a requirement to be able to deploy an application to Azure App Service.

> Note
> Using CI/CD enables more frequent code deployment in a reliable manner by automating builds, tests, and deployments for every code change. It enables delivering new features and bug fixes for your application faster and more effectively.

### Write code to implement a web application

To create a starter web application, we use the Flask web-application framework.

1. Run the following commands in Azure Cloud Shell to set up a virtual environment and install Flask in your profile:

```bash
python3 -m venv venv
source venv/bin/activate
pip install flask
```

2. Run these commands to create and switch to your new web app directory:

```bash
mkdir ~/BestBikeApp
cd ~/BestBikeApp
```

3. Create a new file called application.py with a basic HTML response:

```bash
cat >application.py <
    return "<html><body><h1>Hello Best Bike App!</h1></body></html>\n"
EOL
```

4. To deploy your application to Azure, you need to save the list of application requirements you made for it in a requirements.txt file. To do so, run the following command:

```bash
pip freeze > requirements.txt
```

To test your app locally, you need Python 3 and Flask installed on your system.

## Deploy code to App Service

Now, let's see how we can deploy our application to App Service.

### Automated deployment

Automated deployment, or continuous integration, is a process used to push out new features and bug fixes in a fast and repetitive pattern with minimal impact on end users.

Azure supports automated deployment directly from several sources. The following options are available:

*Azure Repos*: You can push your code to Azure Repos, build your code in the cloud, run the tests, generate a release from the code, and finally push your code to an Azure Web App.
*GitHub*: Azure supports automated deployment directly from GitHub. When you connect your GitHub repository to Azure for automated deployment, any changes you push to your production branch on GitHub are automatically deployed for you.
*Bitbucket*: Due to its similarities to GitHub, you can configure an automated deployment with Bitbucket.

### Manual deployment

There are a few options that you can use to manually push your code to Azure:

*Git*: App Service web apps feature a Git URL that you can add as a remote repository. Pushing to the remote repository deploys your app.
*az webapp up*: webapp up is a feature of the az command-line interface that packages your app and deploys it. Unlike other deployment methods, az webapp up can create a new App Service web app for you if one isn't created.
*Deploy application packages*: You can use az webapp deploy to deploy a ZIP, WAR, EAR, or JAR to App Service. You can also deploy scripts and static files with the same method.
*Visual Studio*: Visual Studio features an App Service deployment wizard that walks you through the deployment process.
*FTP/S*: FTP or FTPS is a traditional way of pushing your code to many hosting environments, including App Service.

## Deployment Steps

In this unit, you deploy your web application to App Service.

### Deploy with `az webapp up`

Let's deploy our Python application with `az webapp up`. This command packages up our application and sends it to our App Service instance, where the app is built and deployed.

First, we need to gather some information about our web app resource. Run these commands to set shell variables that contain our app's name, resource group name, plan name, SKU, and location. These use different `az` commands to request the information from Azure; `az webapp up` needs these values to target our existing web app.

```bash
export APPNAME=$(az webapp list --query [0].name --output tsv)
export APPRG=$(az webapp list --query [0].resourceGroup --output tsv)
export APPPLAN=$(az appservice plan list --query [0].name --output tsv)
export APPSKU=$(az appservice plan list --query [0].sku.name --output tsv)
export APPLOCATION=$(az appservice plan list --query [0].location --output tsv)
```

Now, run `az webapp up` with the appropriate values. Make sure you're in the `BestBikeApp` directory before running this command.

```bash
cd ~/BestBikeApp
az webapp up --name $APPNAME --resource-group $APPRG --plan $APPPLAN --sku $APPSKU --location "$APPLOCATION"
```

The deployment takes a few minutes, during which time you get status output. A 202 status code means your deployment was successful.

### Verify the deployment

Let's browse to your application. In the JSON output, find the URL. Select that link to open your app in a new browser tab. The page might take a moment to load because the App Service is initializing your app for the first time.

Once your program loads, you get the greeting message from your app. You deployed successfully!

## Summary

You successfully created and deployed a web application to Azure App Service.

App Service simplifies managing and controlling your web app in comparison to traditional hosting options. Your App Service Plan can help you reduce the time and effort spent running and managing your web app, and provides advanced cloud features such as autoscaling and Azure DevOps integration.

### Clean up resources

When you're finished with the resources you created in this module, you can delete them to avoid incurring charges. In the Azure portal, navigate to your resource group and select *Delete resource group*.

### Learn More

[Continuous deployment to Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/deploy-continuous-deployment)
[Set up staging environments in Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots)
[Deployment FAQs for Web Apps in Azure](https://learn.microsoft.com/en-us/azure/app-service/faq-deployment)
[Azure App Service and Azure Functions on Azure Stack Hub overview](https://learn.microsoft.com/en-us/azure-stack/operator/azure-stack-app-service-overview)
[Configure deployment sources for App Services on Azure Stack Hub](https://learn.microsoft.com/en-us/azure-stack/operator/azure-stack-app-service-configure-deployment-sources)