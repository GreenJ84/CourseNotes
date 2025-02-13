# CloudMart MultiCloud DevOps & AI Challenge - Day 3

## Overview

This guide provides a streamlined and enhanced approach to setting up a CI/CD pipeline, building and deploying Docker images, and managing Kubernetes clusters in AWS. It incorporates automation, security best practices, and cost-saving strategies to optimize your deployment process.

---

## **Part 1: CI/CD Pipeline Configuration**

### **1. Set Up a GitHub Repository**

1. Create a free GitHub account (if not already done).
2. Create a new repository called `cloudmart`.
3. Clone the repository and navigate to the CloudMart frontend project:

   ```sh
   cd challenge-day2/frontend
   git init
   git remote add origin <your-github-repo-url>
   ```

4. Push the project files to GitHub:

   ```sh
   git add -A
   git commit -m "Initial commit"
   git push -u origin main
   ```

### **2. Configure AWS CodePipeline**

1. Navigate to AWS CodePipeline and create a new pipeline:
   - **Name:** `cloudmart-cicd-pipeline`
   - **Source Provider:** GitHub
   - **Repository:** `cloudmart`
   - **Branch:** `main`
2. Add **AWS CodeBuild** as the build stage:
   - **Project Name:** `cloudmartBuild`
   - **Environment:** `amazonlinux2-x86_64-standard:4.0`
   - **Enable Docker Build Permissions**
   - **Set Environment Variable:** `ECR_REPO` with your ECR repository URI

### **3. Create Build Specification (buildspec.yml)**

```yaml
version: 0.2
phases:
  install:
    runtime-versions:
      docker: 20
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - REPOSITORY_URI=$ECR_REPO
      - aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/l4c0j8h9
  build:
    commands:
      - echo "Building Docker image..."
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
  post_build:
    commands:
      - echo "Pushing Docker image..."
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
      - printf '[{"name":"cloudmart-app","imageUri":"%s"}]' $REPOSITORY_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION > imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json
    - cloudmart-frontend.yaml
```

### **Security Enhancement:**

✅ **Use IAM roles instead of static credentials.** Attach `AmazonElasticContainerRegistryPublicFullAccess` to your CodeBuild service role.

### **Cost-Saving Enhancement:**

✅ **Use Spot Instances** for CodeBuild to reduce costs. Enable Spot in `ComputeTypeOverride`.

---

## **Part 2: Kubernetes Deployment in AWS EKS**

### **1. Install & Configure AWS CLI and EKS Tools**

```sh
aws configure
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo cp /tmp/eksctl /usr/bin
eksctl version

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
kubectl version --short --client
```

### **2. Create an EKS Cluster**

```sh
eksctl create cluster \
 --name cloudmart \
 --region us-east-1 \
 --nodegroup-name standard-workers \
 --node-type t3.medium \
 --nodes 1 \
 --with-oidc \
 --managed
```

### **3. Deploy Backend Application**

1. Create a Kubernetes YAML file for the backend:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: cloudmart-backend-app
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: cloudmart-backend-app
     template:
       metadata:
         labels:
           app: cloudmart-backend-app
       spec:
         serviceAccountName: cloudmart-pod-execution-role
         containers:
         - name: cloudmart-backend-app
           image: public.ecr.aws/l4c0j8h9/cloudmart-backend:latest
   ---
   apiVersion: v1
   kind: Service
   metadata:
     name: cloudmart-backend-app-service
   spec:
     type: LoadBalancer
     selector:
       app: cloudmart-backend-app
     ports:
       - protocol: TCP
         port: 5000
         targetPort: 5000
   ```

2. Deploy the backend:

   ```sh
   kubectl apply -f cloudmart-backend.yaml
   ```

### **4. Deploy Frontend Application**

1. Update `.env` with the backend API URL:

   ```sh
   VITE_API_BASE_URL=http://<your_kubernetes_api_url>:5000/api
   ```

2. Create a Kubernetes YAML file for the frontend:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: cloudmart-frontend-app
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: cloudmart-frontend-app
     template:
       metadata:
         labels:
           app: cloudmart-frontend-app
       spec:
         serviceAccountName: cloudmart-pod-execution-role
         containers:
         - name: cloudmart-frontend-app
           image: public.ecr.aws/l4c0j8h9/cloudmart-frontend:latest
   ---
   apiVersion: v1
   kind: Service
   metadata:
     name: cloudmart-frontend-app-service
   spec:
     type: LoadBalancer
     selector:
       app: cloudmart-frontend-app
     ports:
       - protocol: TCP
         port: 5001
         targetPort: 5001
   ```

3. Deploy the frontend:

   ```sh
   kubectl apply -f cloudmart-frontend.yaml
   ```

---

## **Cleanup to Avoid Unnecessary Costs**

```sh
kubectl delete service cloudmart-frontend-app-service
kubectl delete deployment cloudmart-frontend-app
kubectl delete service cloudmart-backend-app-service
kubectl delete deployment cloudmart-backend-app

eksctl delete cluster --name cloudmart --region us-east-1
```

✅ **Cost-Saving Tip:** Schedule automatic deletion of idle resources with AWS Lambda or AWS Cost Anomaly Detection.

---

### **Final Thoughts**

This guide improves security by leveraging IAM roles, enhances automation with scripts, and optimizes costs through spot instances and cleanup routines. Following these best practices will ensure a secure, efficient, and cost-effective cloud deployment.

