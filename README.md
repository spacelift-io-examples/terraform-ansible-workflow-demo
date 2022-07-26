# Terraform Ansible workflow demo

This is a test repository that will set up an example Terraform and Ansible stacks. The set up consists of three stacks:
- Management stack - it will create all the remaining stacks and destroy them (together with their resources)
- Terraform stack - provisions EC2, generates private key and sets up Ansible context with templated dynamic inventory and private key configuration
- Ansible stack - provisions simple website on an Apache server on the just created EC2 instance

Please find the Loom video for explanation on how to set this up: https://www.loom.com/share/2f05265e98334fa396847c2a46a2e8c1