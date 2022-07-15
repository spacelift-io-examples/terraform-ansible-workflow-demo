variable "aws_role" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "spacelift_labels" {
  type    = list(string)
  default = ["folder:ansible-example"]
}

variable "github_org_name" {
  type    = string
  default = ""
}

variable "github_repository_name" {
  type    = string
  default = "terraform-ansible-workflow-demo"
}
