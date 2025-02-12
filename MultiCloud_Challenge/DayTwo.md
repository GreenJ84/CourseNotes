# MultiCloud, DevOps & AI Challenge - Day 2 - Experienced

## Part 1 - Docker

### Step 1: Install Docker on EC2

Execute the following commands:

```sh
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo docker run hello-world
sudo systemctl enable docker
docker --version
sudo usermod -a -G docker $(whoami)
newgrp docker
```

### Step 2: Create Docker image for CloudMart

#### Backend

1. Create a folder and download source code:

  ```sh
    mkdir -p challenge-day2/backend && cd challenge-day2/backend
    wget https://tcb-public-events.s3.amazonaws.com/mdac/resources/day2/cloudmart-backend.zip
    unzip cloudmart-backend.zip
  ```

2. Create `.env` file:

  ```sh
    nano .env
  ```



  ```env
    PORT=5000
    AWS_REGION=us-east-1
    BEDROCK_AGENT_ID=<your-bedrock-agent-id>
    BEDROCK_AGENT_ALIAS_ID=<your-bedrock-agent-alias-id>
    OPENAI_API_KEY=<your-openai-api-key>
    OPENAI_ASSISTANT_ID=<your-openai-assistant-id>
  ```

3. Create `Dockerfile`:

  ```sh
    nano Dockerfile
  ```

  **Content of Dockerfile:**

  ```dockerfile
    FROM node:18
    WORKDIR /usr/src/app
    COPY package*.json ./
    RUN npm install
    COPY . .
    EXPOSE 5000
    CMD ["npm", "start"]
  ```

#### Frontend

1. Create a folder and download source code:

  ```sh
  cd ..
  mkdir frontend && cd frontend
  wget https://tcb-public-events.s3.amazonaws.com/mdac/resources/day2/cloudmart-frontend.zip
  unzip cloudmart-frontend.zip
  ```

2. Create `Dockerfile`:

  ```sh
    nano Dockerfile
  ```

  **Content of Dockerfile:**

  ```dockerfile
    FROM node:16-alpine as build
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci
    COPY . .
    RUN npm run build

    FROM node:16-alpine
    WORKDIR /app
    RUN npm install -g serve
    COPY --from=build /app/dist /app
    ENV PORT=5001
    ENV NODE_ENV=production
    EXPOSE 5001
    CMD ["serve", "-s", ".", "-l", "5001"]
  ```

---

## Part 2 - Kubernetes

### Cluster Setup on AWS Elastic Kubernetes Services (EKS)

1. **Install necessary CLI tools:**

  ```sh
    aws configure
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo cp /tmp/eksctl /usr/bin
    eksctl version
  ```

2. **Install kubectl:**

  ```sh
    curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
    echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
    kubectl version --short --client
  ```

3. **Create an EKS Cluster:**

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

4. **Verify cluster connectivity:**

  ```sh
    aws eks update-kubeconfig --name cloudmart
    kubectl get svc
    kubectl get nodes
  ```

5. **Create a Role & Service Account:**

  ```sh
    eksctl create iamserviceaccount \
      --cluster=cloudmart \
      --name=cloudmart-pod-execution-role \
      --role-name CloudMartPodExecutionRole \
      --attach-policy-arn=arn:aws:iam::aws:policy/AdministratorAccess \
      --region us-east-1 \
      --approve
  ```

### Backend Deployment on Kubernetes

1. **Create an ECR repository and upload Docker image.**
2. **Create deployment file:**

  ```sh
    nano cloudmart-backend.yaml
  ```

  **Content:**

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
            env:
            - name: PORT
              value: "5000"
            - name: AWS_REGION
              value: "us-east-1"
  ```

3. **Deploy:**

  ```sh
    kubectl apply -f cloudmart-backend.yaml
    kubectl get pods
    kubectl get deployment
    kubectl get service
  ```

### Frontend Deployment on Kubernetes

1. **Update `.env` with API URL:**

  ```sh
    nano .env
  ```

**Content:**

  ```env
    VITE_API_BASE_URL=http://<your_url_kubernetes_api>:5000/api
  ```

2. **Create deployment file:**

  ```sh
    nano cloudmart-frontend.yaml
  ```

**Content:**

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
  ```

3. **Deploy:**

  ```sh
    kubectl apply -f cloudmart-frontend.yaml
    kubectl get pods
    kubectl get deployment
    kubectl get service
  ```

### Cleanup

```sh
  kubectl delete service cloudmart-frontend-app-service
  kubectl delete deployment cloudmart-frontend-app
  kubectl delete service cloudmart-backend-app-service
  kubectl delete deployment cloudmart-backend-app
  eksctl delete cluster --name cloudmart --region us-east-1
```

