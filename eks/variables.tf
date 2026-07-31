##########################################################
# AWS
##########################################################

variable "region" {

  default = "ap-south-1"
}

##########################################################
# PROJECT
##########################################################

variable "project_name" {

  default = "eks-demo"
}

variable "environment" {

  default = "dev"
}

##########################################################
# NETWORK
##########################################################

variable "vpc_cidr" {

  default = "10.0.0.0/16"
}

variable "public_subnets" {

  type = list(string)

  default = [

    "10.0.1.0/24",

    "10.0.2.0/24"
  ]
}

variable "private_subnets" {

  type = list(string)

  default = [

    "10.0.11.0/24",

    "10.0.12.0/24"
  ]
}

variable "availability_zones" {

  type = list(string)

  default = [

    "ap-south-1a",

    "ap-south-1b"
  ]
}

##########################################################
# EKS
##########################################################

variable "cluster_name" {

  default = "eks-demo"
}

variable "cluster_version" {

  default = "1.33"
}
