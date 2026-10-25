variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "availability_zones" {
  type = list(string)
  nullable = true
}

variable "cidr_block" {
  type = string
  nullable = true
}

variable "public_subnet_ip" {
  type = list(string)
  nullable = false
}

variable "private_subnet_ip" {
  type = list(string)
  nullable = false
}

variable "frontend_ecr_repo_url" {
    type = string
    description = "The URL of the frontend ECR repository"
    nullable = false
}

variable "backend_ecr_repo_url" {
    type = string
    description = "The URL of the backend ECR repository"
    nullable = false
}

variable "db_username" {
    type = string
    description = "Admin username for the database"
    nullable = false
    default = "lab"
}
