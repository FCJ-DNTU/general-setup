# Deployment Configuration of Workshop 000006

In this section, we need to deploy

- Infrastructure
- Application

# Requirements

- Terraform CLI
- Docker
- Jenkins

> Note: in future, we'll use jenkins (inside a docker container) to deploy our application. But for now, we have to deploy it manualy.

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

Apply complete! Resources: 31 added, 0 changed, 0 destroyed.

Outputs:

database_arn = "arn:aws:rds:ap-southeast-1:<your-account-id>:db:fcj-management-db-instance"
database_id = "db-RHGNL3HTBGBPBHBJJO637MOYK4"
database_password = <sensitive>
...
```

## 2 - Setup Web Server

> Note: I will automatize this step in future

### 2.1 - Install NodeJS

Download NVM install script and install

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

Save env to profile

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

Install Node 20

```bash
nvm install 20
```

Result Logs

```bash
Downloading and installing node v20.17.0...
Downloading https://nodejs.org/dist/v20.17.0/node-v20.17.0-linux-x64.tar.xz...
####################################################################################################################################################################################################### 100.0%
Computing checksum with sha256sum
Checksums matched!
Now using node v20.17.0 (npm v10.8.2)
Creating default alias: default -> 20 (-> v20.17.0)
```

### 2.2 - Install MySQL client

Install MySQL client

1. Use this if you use `Amazon Linux 2`

```bash
sudo yum install mariadb
```

2. Use this if you use `Amazon Linux 2023`

```bash
sudo dnf install mariadb105
```

Check result with

```bash
mysql --version
```

```bash
mysql  Ver 15.1 Distrib 10.5.25-MariaDB, for Linux (x86_64) using  EditLine wrapper
```

Now, copy the endpoint of RDS (`database_endpoint`) in Terminal (Terraform Output) or in Management Console. Then we connect to this database server

```bash
mysql -h "your-rds-endpoint" -P 3306 -u fcjdntu -p
```

Then show all databases to check our deployment.

```bash
MySQL [(none)] > SHOW DATABASES;
```

```bash
+--------------------+
| Database           |
+--------------------+
| awsfcjuser         |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.001 sec)
```

### 2.3 - Insert data

We have to insert data for testing, first, we must **use** `awsfcjuser` database.

```bash
USE awsfcjuser;
```

Go to `deploy-application/init.sql`, copy all scripts and run.

Run this query and you will receive a result

```bash
SELECT * FROM user;
```

```bash
+----+------------+--------------+-----------------------+---------------+----------+--------+
| id | first_name | last_name    | email                 | phone         | comments | status |
+----+------------+--------------+-----------------------+---------------+----------+--------+
|  1 | Amanda     | Nunes        | anunes@ufc.com        | 012345 678910 |          | active |
|  2 | Alexander  | Volkanovski  | avolkanovski@ufc.com  | 012345 678910 |          | active |
|  3 | Khabib     | Nurmagomedov | knurmagomedov@ufc.com | 012345 678910 |          | active |
|  4 | Kamaru     | Usman        | kusman@ufc.com        | 012345 678910 |          | active |
|  5 | Israel     | Adesanya     | iadesanya@ufc.com     | 012345 678910 |          | active |
|  6 | Henry      | Cejudo       | hcejudo@ufc.com       | 012345 678910 |          | active |
|  7 | Valentina  | Shevchenko   | vshevchenko@ufc.com   | 012345 678910 |          | active |
|  8 | Tyron      | Woodley      | twoodley@ufc.com      | 012345 678910 |          | active |
|  9 | Rose       | Namajunas    | rnamajunas@ufc.com    | 012345 678910 |          | active |
| 10 | Tony       | Ferguson     | tferguson@ufc.com     | 012345 678910 |          | active |
| 11 | Jorge      | Masvidal     | jmasvidal@ufc.com     | 012345 678910 |          | active |
| 12 | Nate       | Diaz         | ndiaz@ufc.com         | 012345 678910 |          | active |
| 13 | Conor      | McGregor     | cmcGregor@ufc.com     | 012345 678910 |          | active |
| 14 | Cris       | Cyborg       | ccyborg@ufc.com       | 012345 678910 |          | active |
| 15 | Tecia      | Torres       | ttorres@ufc.com       | 012345 678910 |          | active |
| 16 | Ronda      | Rousey       | rrousey@ufc.com       | 012345 678910 |          | active |
| 17 | Holly      | Holm         | hholm@ufc.com         | 012345 678910 |          | active |
| 18 | Joanna     | Jedrzejczyk  | jjedrzejczyk@ufc.com  | 012345 678910 |          | active |
+----+------------+--------------+-----------------------+---------------+----------+--------+
```

#### 2.4 - Deploy Web Server

We have to install git

```bash
sudo yum instal git
```

Use `Ctrl + D` to exist Root User and clone this repository

```bash
git clone https://github.com/First-Cloud-Journey/000004-EC2.git
```

Change directory to `000004-EC2`

```bash
cd 000004-EC2
```

Install dependencies of NodeJS

```bash
npm install
```

Install PM2

```bash
npm install -g pm2
```

> Note: We'll need to create Launch template with this instance, so we should install pm2 and run our server as daemon and run when instasnce is startup.

Set up env

```bash
vim .env
```

```bash
DB_HOST="your-rds-endpoint"
DB_NAME="awsfcjuser"
DB_USER="fcjdntu"
DB_PASS="letmein12345"
```

Run server with pm2

```bash
pm2 start app.js
```

Result Logs:

```bash
...
[PM2] Spawning PM2 daemon with pm2_home=/home/ec2-user/.pm2
[PM2] PM2 Successfully daemonized
[PM2] Starting /home/ec2-user/000004-EC2/app.js in fork_mode (1 instance)
[PM2] Done.
┌────┬────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id │ name   │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├────┼────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0  │ app    │ default     │ 1.0.0   │ fork    │ 27842    │ 0s     │ 0    │ online    │ 0%       │ 38.3mb   │ ec2-user │ disabled │
└────┴────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
```

Create a start up script in **systemd**

```bash
pm2 startup
```

Receive a logs like this

```bash
...
[PM2] Init System found: systemd
[PM2] To setup the Startup Script, copy/paste the following command:
sudo env PATH=$PATH:/home/ec2-user/.nvm/versions/node/v20.17.0/bin /home/ec2-user/.nvm/versions/node/v20.17.0/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user --hp /home/ec2-user
```

Copy the following command and run, then we'll receive a result

```bash
...
[PM2] Writing init configuration in /etc/systemd/system/pm2-ec2-user.service
[PM2] Making script booting at startup...
[PM2] [-] Executing: systemctl enable pm2-ec2-user...
Created symlink /etc/systemd/system/multi-user.target.wants/pm2-ec2-user.service → /etc/systemd/system/pm2-ec2-user.service.
[PM2] [v] Command successfully executed.
+---------------------------------------+
[PM2] Freeze a process list on reboot via:
$ pm2 save

[PM2] Remove init script via:
$ pm2 unstartup systemd
```

Finally, we should save this process list

```bash
pm2 save
```

Result Logs:

```bash
[PM2] Saving current process list...
[PM2] Successfully saved in /home/ec2-user/.pm2/dump.pm2
```

## 3 - View result

Go back to Load Balancer console, enter the LB which is created before. Go to tab **Resource map - new** and check

![image](https://github.com/user-attachments/assets/8cec29a9-c641-47b6-9ed5-15a71a2ee7b2)

You can see the target is health. Now copy public dns of Load Balancer, paste to address bar of browser, hit enter and see the result

![image](https://github.com/user-attachments/assets/a7e00db5-b9fa-4e00-abcd-c37dd3903ff7)
