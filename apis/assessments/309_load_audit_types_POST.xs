query load_audit_types verb=POST {
  api_group = "assessments"

  input {
    text country? filters=trim
  }

  stack {
    db.query audit_types {
      where = $input.country in $db.audit_types.country
      sort = {audit_types.type: "asc"}
      return = {type: "list"}
    } as $audit_types_1
  }

  response = $audit_types_1
}