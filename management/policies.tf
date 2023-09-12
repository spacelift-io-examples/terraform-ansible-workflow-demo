resource "spacelift_policy" "warn-on-unreachable-hosts" {
  name = "Require manual confirm on unreachable hosts - ${random_string.stack_name_suffix.result}"
  body = file("${path.module}/policies/warn-on-unreachable-hosts.rego")
  type = "PLAN"

  labels = toset(var.spacelift_labels)
}
