query getAuditTypes verb=GET {
  api_group = "ff"

  input {
  }

  stack {
    db.query audit_types {
      sort = {audit_types.type: "asc"}
      return = {type: "list"}
    } as $audit_types1
  }

  response = $audit_types1
}