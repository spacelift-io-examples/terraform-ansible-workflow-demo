resource "random_string" "stack_name_suffix" {
  length  = 5
  special = false
}

data "spacelift_current_stack" "this" {}

data "spacelift_stack" "current_stack" {
  stack_id = data.spacelift_current_stack.this.id
}

# Terraform stack
resource "spacelift_stack" "terraform-ansible-workflow-terraform" {
  branch         = data.spacelift_stack.current_stack.branch
  name           = "Terraform Ansible Workflow - Terraform - ${random_string.stack_name_suffix.result}"
  project_root   = "terraform"
  repository     = data.spacelift_stack.current_stack.repository
  labels         = toset(var.spacelift_labels)
  administrative = true
  autodeploy     = true

  dynamic "github_enterprise" {
    for_each = var.github_org_name != "" ? [1] : []
    content {
      namespace   = var.github_org_name
    }
  }

  terraform_version            = "1.2.4"
  terraform_smart_sanitization = true
}

# Terraform context variable
resource "spacelift_environment_variable" "ansible_context_id" {
  stack_id   = spacelift_stack.terraform-ansible-workflow-terraform.id
  name       = "TF_VAR_spacelift_ansible_stack_id"
  value      = spacelift_stack.terraform-ansible-workflow-ansible.id
  write_only = false
}

resource "spacelift_environment_variable" "aws_region" {
  stack_id   = spacelift_stack.terraform-ansible-workflow-terraform.id
  name       = "TF_VAR_aws_region"
  value      = var.aws_region
  write_only = false
}

# Terraform stack attachments
resource "spacelift_aws_role" "terraform-stack" {
  stack_id = spacelift_stack.terraform-ansible-workflow-terraform.id
  role_arn = var.aws_role
}

resource "spacelift_stack_destructor" "terraform-stack" {
  depends_on = [
    spacelift_environment_variable.ansible_context_id,
    spacelift_environment_variable.aws_region,
    spacelift_aws_role.terraform-stack,
  ]

  stack_id = spacelift_stack.terraform-ansible-workflow-terraform.id
}

# Ansible stack
resource "spacelift_stack" "terraform-ansible-workflow-ansible" {
  ansible {
    playbook = "playbook.yml"
  }

  branch       = data.spacelift_stack.current_stack.branch
  name         = "Terraform Ansible Workflow - Ansible - ${random_string.stack_name_suffix.result}"
  project_root = "ansible"
  repository   = data.spacelift_stack.current_stack.repository
  labels       = toset(concat(var.spacelift_labels, ["depends-on:${spacelift_stack.terraform-ansible-workflow-terraform.id}"]))
  autodeploy   = true
  before_init = ["chmod 600 /mnt/workspace/tf-ansible-key.pem"]
  before_apply = ["chmod 600 /mnt/workspace/tf-ansible-key.pem"]

  dynamic "github_enterprise" {
    for_each = var.github_org_name != "" ? [1] : []
    content {
      namespace   = var.github_org_name
    }
  }

  runner_image = "public.ecr.aws/spacelift/runner-ansible-aws:latest"
}

resource "spacelift_environment_variable" "ansible_config_env_var" {
  stack_id   = spacelift_stack.terraform-ansible-workflow-ansible.id
  name       = "ANSIBLE_CONFIG"
  value      = "/mnt/workspace/source/ansible/ansible.cfg"
  write_only = false
}

# Ansible stack attachments
resource "spacelift_aws_role" "ansible-stack" {
  stack_id = spacelift_stack.terraform-ansible-workflow-ansible.id
  role_arn = var.aws_role
}

resource "spacelift_policy_attachment" "warn-on-unreachable-hosts-ansible" {
  policy_id = spacelift_policy.warn-on-unreachable-hosts.id
  stack_id  = spacelift_stack.terraform-ansible-workflow-ansible.id
}

# The Ansible stack depends on the Terraform one
resource "spacelift_stack_dependency" "terraform-ansible" {
  stack_id            = spacelift_stack.terraform-ansible-workflow-ansible.id
  depends_on_stack_id = spacelift_stack.terraform-ansible-workflow-terraform.id
}

# Trigger a run in terraform stack

resource "spacelift_run" "this" {
  stack_id = spacelift_stack.terraform-ansible-workflow-terraform.id

  depends_on = [
    spacelift_environment_variable.ansible_context_id,
    spacelift_aws_role.ansible-stack,
  ]
}
