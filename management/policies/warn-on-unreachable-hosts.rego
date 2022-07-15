package spacelift

warn["Some hosts were unreachable"] {
  input.ansible.dark != {}
}

sample { true }
