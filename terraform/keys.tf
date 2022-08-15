# RSA key of size 4096 bits
resource "tls_private_key" "rsa-ansible" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible-key" {
  key_name   = "tf-ansible-workflow-key-${var.spacelift_stack_id}"
  public_key = tls_private_key.rsa-ansible.public_key_openssh

  tags = {
    Name = "tf-ansible-workflow"
    SpaceliftStackID = var.spacelift_stack_id
    Ansible = "true"
  }
}

resource "spacelift_mounted_file" "ansible-key" {
  context_id    = spacelift_context.ansible-context.id
  relative_path = "tf-ansible-key.pem"
  content       = base64encode(nonsensitive(tls_private_key.rsa-ansible.private_key_pem))
  write_only    = true
  file_mode     = "600"
}

resource "spacelift_environment_variable" "ansible_private_key_file" {
  context_id = spacelift_context.ansible-context.id
  name       = "ANSIBLE_PRIVATE_KEY_FILE"
  value      = "/mnt/workspace/tf-ansible-key.pem"
  write_only = false
}
