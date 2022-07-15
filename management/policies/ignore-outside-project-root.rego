package spacelift

track {
    affected
    input.push.branch == input.stack.branch
}

propose { affected }
ignore  { not affected }
ignore  { input.push.tag != "" }

affected {
    filepath := input.push.affected_files[_]

    startswith(filepath, input.stack.project_root)
}

sample { true }
