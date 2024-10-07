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

Result:
![2024-10-04_140055](https://github.com/user-attachments/assets/ec37dbf2-6b43-4c74-8036-7da19ec41ece)

## 2 - Deploy application

Before we go to these steps, you should do something:

- Copy your SSH private key (of EC2) to `key` directory.
- Copy all of Terraform outputs in the previous test.

Change directory to `000006-auto-scaling`, you need to change the environment variable in `deploy.sh` script first

![2024-10-04_140139](https://github.com/user-attachments/assets/e993c9cd-8280-460b-a2ac-5d53f13553be)

Copy the content of `deploy-application` to the EC2 which is created.

```bash
chmod 400 key/key-name.pem
scp -i key/key-name.pem -r deploy-application ec2-user@"ec2-public-ipv4":/home/ec2-user
```

Result

![2024-10-04_141914](https://github.com/user-attachments/assets/4842b40e-6f34-4132-b183-8081eaba4ff4)

Connect SSH to the EC2 Instance

![2024-10-04_135821](https://github.com/user-attachments/assets/9aea31a1-92d8-48e4-be73-892d179fe06c)
![2024-10-04_135838](https://github.com/user-attachments/assets/42c097ed-ab2b-4da0-8297-316402a4a2f9)
![2024-10-04_141944](https://github.com/user-attachments/assets/b19dfc20-09bc-4621-9041-fb1d4a176603)

Run the `deploy.sh` script

```bash
bash deploy.sh
```

> Note: some packages require you allowing, so you should pay attention for them.

You'll be asked for DB Password, just type it and the deployment will be continute. PLEASE, TYPE CAREFULLY!!!

![2024-10-04_145649](https://github.com/user-attachments/assets/edc3929b-f4bf-476a-8e31-2fabe793c888)

In the case you type the password incorrectly, you can use the script bellow.

```bash
mysql -h $DB_HOST -u $DB_USER $DB_NAME -p < init.sql
```

> Note: replace values for these Environment Variables.

After the deployment is done, check the result

![2024-10-04_143854](https://github.com/user-attachments/assets/79e59330-9e4b-4750-8e71-e94f79f3b16e)

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
