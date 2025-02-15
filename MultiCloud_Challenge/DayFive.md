# MultiCloud, DevOps & AI Challenge - Day 5 (Experienced)

## **Download Updated Frontend and Backend Code**

### Backup the existing folders

```yaml
cp -R challenge-day2/ challenge-day2_bkp
cp -R terraform-project/ terraform-project_bkp
```

**💡 Automation Tip:** Automate this backup step using a script to run before deployment, ensuring no manual mistakes.

### Clean up the existing application files except the Docker and YAML files (Backend)

```bash
cd challenge-day2/backend
rm -rf $(find . -mindepth 1 -maxdepth 1 -not \( -name ".*" -o -name Dockerfile -o -name "*.yaml" \))
```

**💰 Cost Saving:** Keep previous build artifacts if rollback is needed instead of deleting everything.

### Clean up the existing application files except the Docker and YAML files (Frontend)

```bash
cd challenge-day2/frontend
rm -rf $(find . -mindepth 1 -maxdepth 1 -not \( -name ".*" -o -name Dockerfile -o -name "*.yaml" \))
```

### Download the updated source code and unzip it (Backend)

```yaml
cd challenge-day2/backend
wget  https://tcb-public-events.s3.amazonaws.com/mdac/resources/final/cloudmart-backend-final.zip
unzip cloudmart-backend-final.zip
```

**💡 Improvement:** Automate this step with a CI/CD pipeline to pull new updates automatically.

### Download the updated source code and unzip it (Frontend)

```yaml
cd challenge-day2/frontend
wget  https://tcb-public-events.s3.amazonaws.com/mdac/resources/final/cloudmart-frontend-final.zip
unzip cloudmart-frontend-final.zip
git add -A
git commit -m "final code"
git push
```

**💰 Cost Saving:** Use a caching mechanism in CI/CD to avoid unnecessary downloads, reducing bandwidth usage.

---

## **Google Cloud BigQuery Setup**

### Steps

1. **Create a Google Cloud Project**
2. **Enable BigQuery API**
3. **Create a BigQuery Dataset**
4. **Create a BigQuery Table**
5. **Create Service Account and Key**
6. **Configure Lambda Function**
7. **Update Lambda Function Environment Variables**

**💡 Improvement:** Use Terraform to automate the creation of BigQuery datasets and tables.

---

## **Terraform Steps**

### Remove the `main.tf` file and create an empty one

```bash
rm main.tf
nano main.tf
```

**💡 Automation Tip:** Use Terraform modules to separate concerns and improve maintainability.

### Add these Terraform lines to `main.tf` to create the Lambda for the BigQuery insert

```terraform
provider "aws" {
  region = "us-east-1"
}
```

**💰 Cost Saving:** Use AWS Spot Instances for compute-heavy tasks instead of on-demand instances.

---

## **Azure Text Analytics Setup**

### Steps

1. **Create an Azure Account**
2. **Create a Text Analytics Resource**
3. **Configure the Resource**
4. **Get the Endpoint and Key**

**💡 Improvement:** Use Azure CLI commands to automate provisioning rather than manually setting it up.

---

## **Deploy the Changes on Backend**

### Open the `cloudmart-backend.yaml` file

```bash
nano cloudmart-backend.yaml
```

**💡 Improvement:** Store environment variables securely in AWS Secrets Manager or Azure Key Vault.

### Build a new image

<Follow ECR steps>

**💰 Cost Saving:** Optimize Docker images by using multi-stage builds and smaller base images (e.g., `alpine`).

### Update the deployment on Kubernetes

```bash
kubectl apply -f cloudmart-backend.yaml
```

**💡 Automation Tip:** Integrate this step into a CI/CD pipeline to avoid manual errors.

---

This updated guide includes automation, cost-saving tips, and improvements to streamline the deployment process. Let me know if you need more details!

