# Automating CloudMart Deployment with Terraform, AWS Bedrock, and OpenAI

## Creating Resources Using Terraform

### Step 1: Navigate to the Terraform Project Directory

```zsh
cd challenge-day2/backend/src/lambda
cp list_products.zip ../../../../terraform-project/
cd ../../../../terraform-project
```

### Step 2: Define IAM Role and Policy for Lambda in `main.tf`

#### **Security Enhancement:** Use least-privilege IAM roles for better security

```hcl
resource "aws_iam_role" "lambda_role" {
  name = "cloudmart_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "cloudmart_lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_dynamodb_table.cloudmart_products.arn,
          aws_dynamodb_table.cloudmart_orders.arn,
          aws_dynamodb_table.cloudmart_tickets.arn,
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}
```

### Step 3: Deploy Lambda Function

```hcl
resource "aws_lambda_function" "list_products" {
  filename         = "list_products.zip"
  function_name    = "cloudmart-list-products"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = filebase64sha256("list_products.zip")

  environment {
    variables = {
      PRODUCTS_TABLE = aws_dynamodb_table.cloudmart_products.name
    }
  }
}
```

#### **Cost-Saving Strategy:** Consider using **AWS Lambda Provisioned Concurrency** to control costs for predictable traffic patterns

### Step 4: Grant Bedrock Permission to Invoke Lambda

```hcl
resource "aws_lambda_permission" "allow_bedrock" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products.function_name
  principal     = "bedrock.amazonaws.com"
}
```

---

## Configuring Amazon Bedrock Agent

### Step 1: Enable Model Access

1. Navigate to **Amazon Bedrock Console** → **Model Access**.
2. Enable **Claude 3 Sonnet** model.
3. Wait for "Access Granted" status.

### Step 2: Create the Bedrock Agent

1. Go to **Amazon Bedrock Console** → **Agents**.
2. Click **Create Agent**.
3. Name it **cloudmart-product-recommendation-agent**.
4. Select **Claude 3 Sonnet** as the model.
5. Paste the provided agent instructions.

### Step 3: Configure IAM Role

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:*:*:function:cloudmart-list-products"
    },
    {
      "Effect": "Allow",
      "Action": "bedrock:InvokeModel",
      "Resource": "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"
    }
  ]
}
```

### Step 4: Define Action Group Schema

```json
{
    "openapi": "3.0.0",
    "info": {
        "title": "Product Details API",
        "version": "1.0.0"
    },
    "paths": {
        "/products": {
            "get": {
                "summary": "Retrieve product details",
                "parameters": [{ "name": "name", "in": "query", "schema": { "type": "string" } }],
                "responses": {
                    "200": {
                        "content": { "application/json": { "schema": { "type": "array", "items": { "type": "object", "properties": { "name": { "type": "string" }, "description": { "type": "string" }, "price": { "type": "number" } } } } } }
                    }
                }
            }
        }
    }
}
```

---

## Configuring OpenAI Assistant

### Step 1: Create an OpenAI Assistant

1. Navigate to [OpenAI Platform](https://platform.openai.com/).
2. Go to **Assistants** → **Create New Assistant**.
3. Name it **CloudMart Customer Support**.
4. Select **GPT-4o** model.
5. Paste customer support instructions.
6. Retrieve the **Assistant ID** and **API Key**.

---

## Automating CloudMart Backend Deployment

### Step 1: Update Kubernetes Deployment

Edit `cloudmart-backend.yaml`:

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
        image: public.ecr.aws/l4c0j8h9/cloudmaster-backend:latest
        env:
        - name: PORT
          value: "5000"
        - name: AWS_REGION
          value: "us-east-1"
        - name: BEDROCK_AGENT_ID
          value: "xxxx"
        - name: OPENAI_API_KEY
          value: "xxxx"
        - name: OPENAI_ASSISTANT_ID
          value: "xxxx"
```

### Step 2: Apply Deployment in Kubernetes

```zsh
kubectl apply -f cloudmart-backend.yaml
```

#### **Automation Strategy:** Implement a **CI/CD pipeline** to auto-deploy changes in the backend

### Step 3: Test AI Assistant

1. Interact with OpenAI's API to test assistant responses.
2. Query Amazon Bedrock for product recommendations.

---

## Conclusion

This guide automates the deployment of an AI-powered e-commerce backend using AWS Bedrock, OpenAI, and Kubernetes. Enhancements such as IAM best practices, cost-saving strategies, and CI/CD integration ensure efficiency and security.

