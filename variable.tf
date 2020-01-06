variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
    default = "ap-northeast-1"
}
variable "aws_availability_zone" {
    default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}
variable "instance_count" {
    default = "3"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "ami_ubuntu18_04" {
    default = "ami-0cd744adeca97abb1"
}
variable "keypair_name" {
    default = "Relk-Laptop"
}
variable "keypair_public" {
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq0klieYwNfC56z/j21RDvxG9hetD0CvQnW/AErMunEbjhODlzoN38+7ZnwNVKR8Fuy2SpGj7MzFphZ3hTbwDxzmTa8AY0dQUZ/Swuhv40kcV6xapJf9O1P57awrrMG4TEcRdsVYD3j3GQ4L8DyLvmDvoc3nSOzASPKgsCydDHJ1OSzjdcmFkNd08An0FsRbxzPHQmXTCMA1xzugBwI+vSXn130XiuijN5sxIxLNm3ZY9KtG5wcdaSkFXYqBC5tO6OBiz+cjU0cHXI14RSW4uL6f7DYXnZtI/+GjF+TXnFwtiewr8IFL8oaThuQt7cAeOVn/us2n1IbCud/Km7sq8l relk@relk-Inspiron-7375"
}
variable "project_name" {
    default = "AWS-DEMO"
}
variable "tag_project" {
    default = "AWS-DEMO"
}
variable "tag_env" {
    default = "Staging"
}
variable "tag_owner" {
    default = "Relk"
}
