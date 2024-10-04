# Deployment Configuration of Workshop 000006

In this section, we need to deploy

- Infrastructure
- Application (Server)

# Requirements

- Terraform CLI
- Docker
- Linux (in VM, WSL or Configure a EC2 Instance)

> Note: you should configure another key-pair in `aws_instance` block. And configure ASG later, so we you destroy the infrastructure, please make you clean up ASG first.

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

Now we have to validate our configuration and plan it

```bash
terraform plan
```

Then tell Terraform apply the plan to deploy our infrastructure

```bash
terraform apply
```

Result Logs:

```bash
...
aws_db_instance.rds: Still creating... [11m39s elapsed]
aws_db_instance.rds: Creation complete after 11m48s [id=db-RHGNL3HTBGBPBHBJJO637MOYK4]

Apply complete! Resources: 32 added, 0 changed, 0 destroyed.

Outputs:

database_arn = "arn:aws:rds:ap-southeast-1:<your-account-id>:db:fcj-management-db-instance"
database_id = "db-RHGNL3HTBGBPBHBJJO637MOYK4"
database_password = <sensitive>
...
```

## 2 - Deploy application

Before we go to these steps, you should do something:

- Copy your SSH private key (of EC2) to `key` directory.
- Copy all of Terraform outputs in the previous test.

Change directory to `000006-auto-scaling`, copy the content of `deploy-application` to the EC2 which is created

```bash
chmod 400 key/key-name.pem
scp -i key/key-name.pem -r deploy-application ec2-user@"ec2-public-ipv4":/home/ec2-user
```

Result

**INSERT IMAGE HERE**

Connect SSH to the EC2 Instance

**INSERT IMAGE HERE**
**INSERT IMAGE HERE**

Run the `deploy.sh` script

```bash
bash deploy.sh
```

> Note: some packages require you allowing, so you should pay attention for them.

You'll be asked for DB Password, just type it and the deployment will be continute. PLEASE, TYPE CAREFULLY!!!

**INSERT IMAGE HERE**

In the case you type the password incorrectly, you can use the script bellow.

```bash
mysql -h $DB_HOST -u $DB_USER $DB_NAME -p < init.sql
```

> Note: replace values for these Environment Variables.

After the deployment is done, check the result

**INSERT IMAGE HERE**
**INSERT IMAGE HERE**

## 3 - Deploy Auto Scaling Group

First, you should copy values `public_sg_id`, `target_group_arn`, `server_id` and subnet ids in Infrastructure Output. Then go to `deploy-asg/main.tf` and replace corresponding values.

Change directory to `deploy-asg`, and use terraform to deploy ASG like the 2 step.

```bash
terraform init
```

Now we have to validate our configuration and plan it

```bash
terraform plan
```

Then tell Terraform apply the plan to deploy our infrastructure

```bash
terraform apply
```

### 3.1 - Create launch template

### 3.2 - Create ASG

## 4 - View result

Go back to Load Balancer console, enter the LB which is created before. Go to tab **Resource map - new** and check

![image](https://github.com/user-attachments/assets/8cec29a9-c641-47b6-9ed5-15a71a2ee7b2)

You can see the target is health. Now copy public dns of Load Balancer, paste to address bar of browser, hit enter and see the result

![image](https://github.com/user-attachments/assets/a7e00db5-b9fa-4e00-abcd-c37dd3903ff7)

## 5 - Clean up resources

Change directory to `deploy-asg`

```bash
terraform destroy
```

Result Logs

```bash
aws_autoscaling_group.asg: Destruction complete after 6m34s
aws_launch_template.my_launch_template: Destroying... [id=lt-06f65e37f1e2d88a3]
aws_launch_template.my_launch_template: Destruction complete after 0s
aws_ami_from_instance.instance_ami: Destroying... [id=ami-0b8965a8bb3b921da]
aws_ami_from_instance.instance_ami: Destruction complete after 5s

Destroy complete! Resources: 3 destroyed.
```

Change directory to `deploy-infrastructure`

```bash
terraform destroy
```

Result Logs

```bash
aws_subnet.private_subnet_2: Destruction complete after 0s
aws_subnet.private_subnet_3: Destruction complete after 0s
aws_security_group.db_sg: Destruction complete after 0s
aws_vpc.aslab: Destroying... [id=vpc-0e9713682d8f3d6ae]
aws_vpc.aslab: Destruction complete after 1s

Destroy complete! Resources: 32 destroyed.
```
