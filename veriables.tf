variable "aws_region" {

  description = "AWS Region"

  type = string

}

variable "environment" {

  type = string

}

variable "project_name" {

  type = string

}

variable "vpc_cidr" {

  type = string

}

variable "public_subnets" {

  type = list(string)

}

variable "private_subnets" {

  type = list(string)

}

variable "availability_zones" {

  type = list(string)

}