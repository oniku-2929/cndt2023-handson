terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  region = "ap-northeast-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {}
}

resource "tls_private_key" "cndt2023_handson_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_cndt2023_handson_pem" {
  filename        = ".ssh/cndt2023-handson-key.pem"
  content         = tls_private_key.cndt2023_handson_key.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "cndt2023-handson-key"
  public_key = tls_private_key.cndt2023_handson_key.public_key_openssh
}

locals {
  ingress_settings = [
    {
      port : 22,
      description : "ssh"
    },
    {
      port : 80,
      description : "http"
    },
    {
      port : 443,
      description : "https"
    },
    {
      port : 8080,
      description : ""
    },
    {
      port : 8443,
      description : ""
    },
    {
      port : 18080,
      description : ""
    },
    {
      port : 18443,
      description : ""
    },
    {
      port : 28080,
      description : ""
    },
    {
      port : 28443,
      description : ""
    }
  ]

  instance_type = "t2.xlarge"
}

resource "aws_security_group" "cndt2023_handson_segcroup" {
  name        = "cndt2023-handson-segcroup"
  description = "CNDT2023 handson security group"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = local.ingress_settings
    content {
      description = "description ${ingress.value.description}"
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_ami" "base_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230919"]
  }

}

#https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/examples/complete/main.tf
locals {
  vm_name = "cndt2023-handson-vm"
  vm_tags = {
    Name = local.vm_name
  }
}
data "aws_ec2_spot_price" "current" {
  instance_type     = local.instance_type
  availability_zone = element(module.vpc.azs, 0)

  filter {
    name   = "product-description"
    values = ["Linux/UNIX"]
  }
}

module "ec2_spot_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  ami                         = data.aws_ami.base_ami.id
  name                        = "cndt2023-handson-vm"
  create_spot_instance        = true
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  instance_type               = local.instance_type
  vpc_security_group_ids      = [aws_security_group.cndt2023_handson_segcroup.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.key_name

  # Spot request specific attributes
  spot_price                          = data.aws_ec2_spot_price.current.spot_price
  spot_wait_for_fulfillment           = true
  spot_type                           = "one-time"
  spot_instance_interruption_behavior = "terminate"
  # End spot request specific attributes

  #user_data_base64 = base64encode(local.user_data)

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = false
      volume_type = "gp3"
      throughput  = 0
      volume_size = 50
      tags = {
        Name = "my-root-block"
      }
    },
  ]


  tags          = local.vm_tags
  instance_tags = local.vm_tags
}

resource "terraform_data" "setup_vm" {
  triggers_replace = [
    module.ec2_spot_instance.id
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = module.ec2_spot_instance.public_ip
      private_key = tls_private_key.cndt2023_handson_key.private_key_pem
    }
    script = "../scripts/setup_vm.sh"
  }
}



module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0.0"

  name = "cndt2023-handson-vpc"
  cidr = local.vpc_cidr

  create_igw = true

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  #IPV6で怒られたので、これで動作するか確認する
  #enable_ipv6                     = true
  #assign_ipv6_address_on_creation = true
  #create_egress_only_igw          = true
  #public_subnet_ipv6_prefixes  = [0, 1, 2]
  #private_subnet_ipv6_prefixes = [3, 4, 5]
  #intra_subnet_ipv6_prefixes   = [6, 7, 8]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  public_subnet_tags = {
    #"kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    #"kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
