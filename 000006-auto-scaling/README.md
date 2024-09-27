# Deployment Configuration of Workshop 000006

In this section, we need to deploy

- Infrastructure
- Application

# Requirements

- Terraform CLI
- Docker
- Jenkins

> Note: in future, we'll use jenkins (inside a docker container) to deploy our application. But for now, we have to deploy it manualy.

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

Apply complete! Resources: 29 added, 0 changed, 0 destroyed.

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

Now, copy the endpoint of RDS in Terminal (Terraform Output) or in Management Console. Then we connect to this database server

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
yum instal git
```

Use `Ctrl + D` to exist Root User and clone this repository

```bash
git clone https://github.com/First-Cloud-Journey/000004-EC2.git
```

Change directory to `000004-EC2`

```bash
cd 000004-EC2
```

Install NodeJS dependencies

```bash
npm install
```

Set up env

```bash
export DB_HOST="your-rds-endpoint"
export DB_NAME="awsfcjuser"
export DB_USER="fcjdntu"
export DB_PASS="letmein12345"
```

Run server

```bash
npm start
```

```bash
> simple-crudapp@1.0.0 start
> nodemon app.js

[nodemon] 2.0.16
[nodemon] to restart at any time, enter `rs`
[nodemon] watching path(s): *.*
[nodemon] watching extensions: js,mjs,json
[nodemon] starting `node app.js`
Listening on port 5000
connected as ID **
```

## 3 - View result

Copy public dns of EC2 instance of server in Terraform Outputs or in Management Console and append `:5000` behind it. We'll receive an result

![3](https://github.com/user-attachments/assets/568ddfe9-2c10-4e51-bb20-d99121b08a98)
