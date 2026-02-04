---
name: aws-setup
description: Setup and configure AWS services (EC2, S3, RDS, Lambda, etc.)
user-invocable: true
categories: [cloud, aws, infrastructure]
version: 1.0.0
---

# AWS Setup and Configuration

Configure AWS services following best practices for scalability, security, and cost optimization.

## Usage

```
/aws-setup <service> <description>
```

### Examples

```
/aws-setup "S3 bucket for data storage with lifecycle policies"
/aws-setup "EC2 instance for Django application"
/aws-setup "Lambda function for data processing"
```

## AWS CLI Setup

```bash
# Install AWS CLI
pip install awscli

# Configure credentials
aws configure
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: us-east-1
# Default output format: json
```

## Common Services

### S3 - Object Storage

```python
import boto3

# Create S3 client
s3 = boto3.client('s3')

# Create bucket
s3.create_bucket(Bucket='my-data-bucket')

# Upload file
s3.upload_file('data.csv', 'my-data-bucket', 'data/data.csv')

# Download file
s3.download_file('my-data-bucket', 'data/data.csv', 'local_data.csv')

# List objects
response = s3.list_objects_v2(Bucket='my-data-bucket')
for obj in response.get('Contents', []):
    print(obj['Key'])
```

### EC2 - Compute

```python
import boto3

ec2 = boto3.resource('ec2')

# Launch instance
instance = ec2.create_instances(
    ImageId='ami-0c55b159cbfafe1f0',  # Ubuntu 20.04
    InstanceType='t3.micro',
    MinCount=1,
    MaxCount=1,
    KeyName='my-key-pair',
    SecurityGroupIds=['sg-12345678'],
    SubnetId='subnet-12345678',
    TagSpecifications=[{
        'ResourceType': 'instance',
        'Tags': [{'Key': 'Name', 'Value': 'MyApp'}]
    }]
)[0]

print(f"Instance ID: {instance.id}")
```

### RDS - Managed Database

```python
import boto3

rds = boto3.client('rds')

# Create PostgreSQL instance
response = rds.create_db_instance(
    DBInstanceIdentifier='mydb',
    DBInstanceClass='db.t3.micro',
    Engine='postgres',
    MasterUsername='admin',
    MasterUserPassword='SecurePassword123!',
    AllocatedStorage=20,
    BackupRetentionPeriod=7,
    PubliclyAccessible=False,
    VpcSecurityGroupIds=['sg-12345678']
)
```

### Lambda - Serverless

```python
import json

def lambda_handler(event, context):
    """Process data from S3."""
    # Get bucket and key from event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    # Process data
    # ...

    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }
```

Deploy:
```bash
# Zip function
zip function.zip lambda_function.py

# Create function
aws lambda create-function \
  --function-name ProcessData \
  --runtime python3.11 \
  --role arn:aws:iam::ACCOUNT:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip
```

## Infrastructure as Code (Terraform)

```hcl
# main.tf
provider "aws" {
  region = "us-east-1"
}

# S3 Bucket
resource "aws_s3_bucket" "data_bucket" {
  bucket = "my-data-bucket"

  tags = {
    Environment = "Production"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name = "AppServer"
  }
}

# RDS Instance
resource "aws_db_instance" "postgres" {
  identifier           = "mydb"
  engine              = "postgres"
  engine_version      = "15.3"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = var.db_password
  skip_final_snapshot = true
}
```

## Security Best Practices

1. **IAM Roles**: Use roles, not access keys
2. **Least Privilege**: Grant minimum permissions
3. **MFA**: Enable multi-factor authentication
4. **Encryption**: Encrypt data at rest and in transit
5. **VPC**: Use private subnets
6. **Security Groups**: Restrict access
7. **CloudTrail**: Enable logging
8. **Secrets Manager**: Store credentials securely

## Cost Optimization

1. Use **Reserved Instances** for predictable workloads
2. Use **Spot Instances** for flexible workloads
3. Set up **Auto Scaling**
4. Use **S3 lifecycle policies**
5. Monitor with **Cost Explorer**
6. Set **billing alerts**

## Monitoring

```python
import boto3

cloudwatch = boto3.client('cloudwatch')

# Put custom metric
cloudwatch.put_metric_data(
    Namespace='MyApp',
    MetricData=[{
        'MetricName': 'ProcessedRecords',
        'Value': 100,
        'Unit': 'Count'
    }]
)
```

## Notes

- Always use IAM roles for EC2 instances
- Enable versioning on S3 buckets
- Use Parameter Store or Secrets Manager for secrets
- Tag all resources for cost tracking
- Use CloudFormation or Terraform for IaC
