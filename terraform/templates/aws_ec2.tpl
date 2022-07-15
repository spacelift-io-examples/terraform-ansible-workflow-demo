---
plugin: aws_ec2
regions:
  - "${aws_region}"
filters:
  tag-key: "Ansible"
  instance-state-name: "running"
  tag:SpaceliftStackID: "${spacelift_stack_id}"
