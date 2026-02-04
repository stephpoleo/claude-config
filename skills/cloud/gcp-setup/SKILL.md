---
name: gcp-setup
description: Setup and configure GCP services (Compute Engine, Cloud Storage, BigQuery, etc.)
user-invocable: true
categories: [cloud, gcp, infrastructure]
version: 1.0.0
---

# GCP Setup and Configuration

Configure Google Cloud Platform services following best practices.

## Usage

```
/gcp-setup <service> <description>
```

### Examples

```
/gcp-setup "Cloud Storage bucket for data lake"
/gcp-setup "Compute Engine instance for application"
/gcp-setup "BigQuery dataset for analytics"
```

## gcloud CLI Setup

```bash
# Install gcloud
# Download from: https://cloud.google.com/sdk/docs/install

# Initialize
gcloud init

# Authenticate
gcloud auth login

# Set project
gcloud config set project PROJECT_ID
```

## Common Services

### Cloud Storage

```python
from google.cloud import storage

# Create client
client = storage.Client()

# Create bucket
bucket = client.create_bucket('my-data-bucket')

# Upload file
blob = bucket.blob('data/file.csv')
blob.upload_from_filename('local_file.csv')

# Download file
blob.download_to_filename('downloaded_file.csv')

# List blobs
blobs = client.list_blobs('my-data-bucket')
for blob in blobs:
    print(blob.name)
```

### Compute Engine

```python
from google.cloud import compute_v1

# Create instance
instance_client = compute_v1.InstancesClient()

instance = compute_v1.Instance()
instance.name = 'my-instance'
instance.machine_type = f"zones/us-central1-a/machineTypes/e2-micro"

# Disk
disk = compute_v1.AttachedDisk()
disk.boot = True
disk.auto_delete = True
initialize_params = compute_v1.AttachedDiskInitializeParams()
initialize_params.source_image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
disk.initialize_params = initialize_params
instance.disks = [disk]

# Network
network_interface = compute_v1.NetworkInterface()
network_interface.name = "global/networks/default"
instance.network_interfaces = [network_interface]

# Create
operation = instance_client.insert(
    project='PROJECT_ID',
    zone='us-central1-a',
    instance_resource=instance
)
```

### BigQuery

```python
from google.cloud import bigquery

# Create client
client = bigquery.Client()

# Create dataset
dataset = bigquery.Dataset(f"{client.project}.my_dataset")
dataset.location = "US"
dataset = client.create_dataset(dataset)

# Create table
schema = [
    bigquery.SchemaField("name", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("age", "INTEGER", mode="REQUIRED"),
    bigquery.SchemaField("email", "STRING"),
]

table = bigquery.Table(f"{client.project}.my_dataset.users", schema=schema)
table = client.create_table(table)

# Query
query = """
    SELECT name, COUNT(*) as count
    FROM `project.dataset.table`
    GROUP BY name
"""
query_job = client.query(query)
results = query_job.result()

for row in results:
    print(f"{row.name}: {row.count}")

# Load data from file
job_config = bigquery.LoadJobConfig(
    source_format=bigquery.SourceFormat.CSV,
    skip_leading_rows=1,
    autodetect=True,
)

with open("data.csv", "rb") as source_file:
    job = client.load_table_from_file(
        source_file,
        f"{client.project}.my_dataset.my_table",
        job_config=job_config,
    )

job.result()  # Wait for job to complete
```

### Cloud Functions

```python
# main.py
def hello_world(request):
    """HTTP Cloud Function."""
    request_json = request.get_json()
    name = request_json.get('name', 'World')

    return f'Hello {name}!'

def process_file(event, context):
    """Triggered by Cloud Storage."""
    file = event['name']
    bucket = event['bucket']

    print(f'Processing file: {file} from bucket: {bucket}')
    # Process file
```

Deploy:
```bash
# HTTP function
gcloud functions deploy hello_world \
  --runtime python311 \
  --trigger-http \
  --allow-unauthenticated

# Storage trigger
gcloud functions deploy process_file \
  --runtime python311 \
  --trigger-resource my-bucket \
  --trigger-event google.storage.object.finalize
```

### Cloud Run

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 app:app
```

Deploy:
```bash
# Build and deploy
gcloud run deploy my-service \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

## Infrastructure as Code (Terraform)

```hcl
provider "google" {
  project = "my-project"
  region  = "us-central1"
}

# Storage Bucket
resource "google_storage_bucket" "data_bucket" {
  name     = "my-data-bucket"
  location = "US"

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Compute Instance
resource "google_compute_instance" "app_server" {
  name         = "app-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}

# BigQuery Dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id = "my_dataset"
  location   = "US"
}
```

## Security Best Practices

1. **Service Accounts**: Use for authentication
2. **IAM Roles**: Principle of least privilege
3. **VPC**: Use private IPs
4. **Firewall Rules**: Restrict access
5. **Encryption**: Enable by default
6. **Cloud Armor**: Protect against DDoS
7. **Audit Logs**: Enable Cloud Logging
8. **Secret Manager**: Store sensitive data

## Cost Optimization

1. Use **Committed Use Discounts**
2. Use **Preemptible VMs** for batch jobs
3. Set up **Budgets and Alerts**
4. Use **Cloud Storage lifecycle policies**
5. Monitor with **Cost Management**
6. Right-size instances

## Monitoring

```python
from google.cloud import monitoring_v3

# Create client
client = monitoring_v3.MetricServiceClient()
project_name = f"projects/{project_id}"

# Write custom metric
series = monitoring_v3.TimeSeries()
series.metric.type = "custom.googleapis.com/my_metric"
series.resource.type = "global"

point = monitoring_v3.Point()
point.value.double_value = 42.0
point.interval.end_time.seconds = int(time.time())

series.points = [point]

client.create_time_series(name=project_name, time_series=[series])
```

## Authentication

```python
# Set credentials
import os
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'path/to/key.json'

# Or use Application Default Credentials
from google.auth import default
credentials, project = default()
```

## Notes

- Always use service accounts for applications
- Enable versioning on Cloud Storage
- Use Secret Manager for credentials
- Tag resources for cost tracking
- Use Terraform or Deployment Manager for IaC
- Consider multi-region for high availability
