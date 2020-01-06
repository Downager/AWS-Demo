# AWS-Demo
### Terraform
- Create VPC / Multi-Zone Subnet
- Create Security Group & Rules
- Create Key Pair
- Create multi availability zone ECS intances
- Create EIP for ECS instances
- Create ALB / Listener / Target Group

### Ansible

- Install docker & docker-compose
- Create Users & Groups, and sudo without password
- Setting sshd_config for force to use publickey login
- Deploy docker-compose use git and ansible

### Step
- Initail AWS ECS & ALB
```
terraform init
terraform apply
```
- Get Instances Public DNS and Rewrite to Ansible hosts
```
Search: \s*"(.*)",
Replace: $1
```
- Ubuntu instances initail setting and deploy nginx container
```
./install.sh
```