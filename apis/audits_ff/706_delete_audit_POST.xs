query deleteAudit verb=POST {
  api_group = "auditsFF"
  auth = "user"

  input {
    int auditID?
  }

  stack {
    db.del audit {
      field_name = "id"
      field_value = $input.auditID
    }
  }

  response = $audit1
}