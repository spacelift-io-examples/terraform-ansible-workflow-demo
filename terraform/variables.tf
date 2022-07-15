variable "spacelift_run_id" {
  type = string
}

variable "spacelift_stack_id" {
  type = string
}

variable "spacelift_ansible_stack_id" {
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
