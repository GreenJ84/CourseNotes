# MultiCloud Day 1

## Step 1: Generate Terraform Code for AWS Resources

Terraform is an Infrastructure as Code (IaC) tool used to provision and manage cloud resources. Here, we'll use an AI assistant (such as Claude) to generate Terraform configuration for an S3 bucket.

1. Request Terraform code for an S3 bucket with a unique name. Example prompt:

   _"Generate Terraform code to create an S3 bucket in AWS with a unique name."_

2. The expected output should be similar to:

   ```hcl
   provider "aws" {
     region = "us-west-2"  # Change to your preferred region
   }

   resource "random_id" "bucket_suffix" {
     byte_length = 8
   }

   resource "aws_s3_bucket" "my_bucket" {
     bucket = "my-unique-bucket-name-${random_id.bucket_suffix.hex}"

     tags = {
       Name        = "My bucket"
       Environment = "Dev"
     }
   }

   resource "aws_s3_bucket_acl" "my_bucket_acl" {
     bucket = aws_s3_bucket.my_bucket.id
     acl    = "private"
   }
   ```

3. Save this Terraform code for later deployment.

## Step 2: Create an IAM Role for EC2

IAM (Identity and Access Management) controls permissions and access policies in AWS. We'll create a role that allows an EC2 instance to interact with AWS resources.

1. Navigate to the IAM dashboard in AWS.
2. Click on "Roles" and select "Create role."
3. Choose "AWS service" as the trusted entity and "EC2" as the use case.
4. Attach the "AdministratorAccess" policy (note: for production, use a more restrictive policy).
5. Name the role "EC2Admin" and add a description.
6. Review and create the role.

## Step 3: Launch an EC2 Instance

EC2 (Elastic Compute Cloud) is a virtual machine in AWS. We'll deploy one as our workstation for running Terraform commands.

1. Go to the EC2 dashboard and select "Launch Instance."
2. Choose "Amazon Linux 2" as the AMI (Amazon Machine Image).
3. Select the `t2.micro` instance type.
4. Configure instance details:
   - Network: Default VPC
   - Subnet: Any available
   - Auto-assign Public IP: Enable
   - IAM role: Select "EC2Admin"
5. Keep default storage settings.
6. Add a tag: Key="Name", Value="workstation".
7. Configure a security group allowing SSH access from EC2 Connect IP.
8. Review and launch, selecting or creating a key pair for SSH access.

## Step 4: Connect to the EC2 Instance and Install Terraform

1. In the EC2 dashboard, select the "workstation" instance.
2. Click "Connect" and use "EC2 Instance Connect."
3. In the terminal, update system packages:

   ```sh
   sudo yum update -y
   ```

4. Install `yum-utils`:

   ```sh
   sudo yum install -y yum-utils
   ```

5. Add the HashiCorp repository:

   ```sh
   sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
   ```

6. Install Terraform:

   ```sh
   sudo yum -y install terraform
   ```

7. Verify the installation:

   ```sh
   terraform version
   ```

## Step 5: Apply Terraform Configuration

1. Create a new directory and navigate to it:

   ```sh
   mkdir terraform-project && cd terraform-project
   ```

2. Create a new Terraform configuration file:

   ```sh
   nano main.tf
   ```

3. Paste the Terraform code from Step 1.
4. Save and exit the file (Ctrl+X, then Y, then Enter in nano).
5. Initialize Terraform:

   ```sh
   terraform init
   ```

6. Review the execution plan:

   ```sh
   terraform plan
   ```

7. Apply the configuration:

   ```sh
   terraform apply
   ```

8. Type "yes" when prompted to confirm resource creation.

## Step 6: Create DynamoDB Tables

DynamoDB is AWS's managed NoSQL database. We will modify our Terraform configuration to create tables for a hypothetical CloudMart application.

1. Remove any S3-related resources from `main.tf`.
2. Add the following DynamoDB table definitions:

   ```hcl
   provider "aws" {
     region = "us-east-1"  # Change as needed
   }

   resource "aws_dynamodb_table" "cloudmart_products" {
     name           = "cloudmart-products"
     billing_mode   = "PAY_PER_REQUEST"
     hash_key       = "id"

     attribute {
       name = "id"
       type = "S"
     }
   }

   resource "aws_dynamodb_table" "cloudmart_orders" {
     name           = "cloudmart-orders"
     billing_mode   = "PAY_PER_REQUEST"
     hash_key       = "id"

     attribute {
       name = "id"
       type = "S"
     }
   }

   resource "aws_dynamodb_table" "cloudmart_tickets" {
     name           = "cloudmart-tickets"
     billing_mode   = "PAY_PER_REQUEST"
     hash_key       = "id"

     attribute {
       name = "id"
       type = "S"
     }
   }
   ```

3. Re-run Terraform to apply the changes:

   ```sh
   terraform apply
   ```

By following these refined steps, you've removed unnecessary promotional content, ensured clarity, and understood the underlying AWS concepts in a practical way.

