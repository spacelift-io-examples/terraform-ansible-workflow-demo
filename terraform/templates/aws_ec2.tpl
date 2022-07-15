---
plugin: aws_ec2
regions:
  - eu-central-1
filters:
  tag-key: "Ansible"
  instance-state-name: "running"
  tag:SpaceliftStackID: ${spacelift_stack_id}
