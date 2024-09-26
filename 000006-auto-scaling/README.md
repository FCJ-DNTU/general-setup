# Deployment Configuration of Workshop 000006

In this section, we need to deploy

- Infrastructure
- Application with Docker and Jenkins

# Requirements

- Terraform CLI
- Docker

## Steps

## 1 - Deploy the infrastructure

First, you need to make a plan for deployment

```bash
terraform init
```

Result Logs:

```bash
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.68.0...
- Installed hashicorp/aws v5.68.0 (signed by HashiCorp)
...

Terraform has been successfully initialized!

...
```

Then tell Terraform apply the plan to deploy our infrastructure

```bash
terraform apply
```

Result Logs:

```bash

```

## 2 - Deploy the application

## 3 - View result
