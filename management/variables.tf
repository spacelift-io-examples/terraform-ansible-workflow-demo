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
