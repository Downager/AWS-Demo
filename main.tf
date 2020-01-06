provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "VPC"
    Project = "${var.tag_project}"
    Owner   = "${var.tag_owner}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name    = "${var.project_name}-VPC-GW"
    Project = "${var.tag_project}"
    Owner   = "${var.tag_owner}"
  }
}

resource "aws_route" "main" {
  route_table_id         = "${aws_vpc.main.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_subnet" "main" {
  # 取得 Availability Zone 的數量，每個 AZ 各建立一個 subnet
  count             = length(var.aws_availability_zone)
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = "${element(var.aws_availability_zone, count.index)}"

  tags = {
    Name    = "${var.project_name}-SUBNET"
    Project = "${var.tag_project}"
    Owner   = "${var.tag_owner}"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group_rule" "allow_all_http_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_vpc.main.default_security_group_id}"
}


resource "aws_key_pair" "main" {
  key_name   = "${var.keypair_name}"
  public_key = "${var.keypair_public}"
}

resource "aws_instance" "main" {
  count                  = "${var.instance_count}"
  ami                    = "${var.ami_ubuntu18_04}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_vpc.main.default_security_group_id}", "${aws_security_group.allow_ssh.id}"]
  subnet_id              = "${aws_subnet.main[(count.index % length(var.aws_availability_zone))].id}" # 取 count / AZ數量的餘數來選擇第幾個 subnet (目前為 3)
  key_name = "${var.keypair_name}"

  tags = {
    Name        = "${var.project_name}-${count.index + 1}"
    Project     = "${var.tag_project}"
    Environment = "${var.tag_env}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_eip" "main" {
  count    = "${var.instance_count}"
  instance = "${aws_instance.main[count.index].id}"
  tags = {
    Name        = "${var.project_name}-EIP-${count.index + 1}"
    Project     = "${var.tag_project}"
    Environment = "${var.tag_env}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_lb" "main" {
  name               = "${var.project_name}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_vpc.main.default_security_group_id}"]
  subnets            = "${aws_subnet.main.*.id}"

  tags = {
    Name        = "${var.project_name}-ALB"
    Project     = "${var.tag_project}"
    Environment = "${var.tag_env}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-LB-TG"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  
  tags = {
    Name        = "${var.project_name}-TG"
    Project     = "${var.tag_project}"
    Environment = "${var.tag_env}"
    Owner       = "${var.tag_owner}"
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count            = "${var.instance_count}"
  target_group_arn = "${aws_lb_target_group.main.arn}"
  target_id        = "${aws_instance.main[count.index].id}"
  port             = 80
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.main.arn}"
  }
}

output "instance_public_dns" {
  value = ["${aws_eip.main.*.public_dns}"]
}
output "alb_public_dns" {
  value = "${aws_lb.main.dns_name}"
}
