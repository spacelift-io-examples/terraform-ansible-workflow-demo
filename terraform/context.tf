# Ansible Context  dynamic inventory definition
resource "spacelift_context" "ansible-context" {
  description = "Context for Terraform-Ansible workflow demo"
  name        = "Ansible context - ${var.spacelift_stack_id}"

  labels = toset(var.spacelift_labels)
}


resource "spacelift_environment_variable" "ansible_confg_var" {
  context_id = spacelift_context.ansible-context.id
  name       = "ANSIBLE_INVENTORY"
  value      = "/mnt/workspace/aws_ec2.yml"
  write_only = false
}

data "template_file" "aws_dynamic_inventory" {
  template = "${file("${path.module}/templates/aws_ec2.tpl")}"
  vars = {
    aws_region = var.aws_region
    spacelift_stack_id = var.spacelift_stack_id
  }
}

resource "spacelift_mounted_file" "aws_inventory" {
  context_id    = spacelift_context.ansible-context.id
  relative_path = "aws_ec2.yml"
  content       = base64encode(data.template_file.aws_dynamic_inventory.rendered)
  write_only    = false
}

resource "spacelift_context_attachment" "attachment" {
  context_id = spacelift_context.ansible-context.id
  stack_id   = var.spacelift_ansible_stack_id
  priority   = 0
}