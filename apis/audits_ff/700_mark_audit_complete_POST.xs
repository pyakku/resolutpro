query markAuditComplete verb=POST {
  api_group = "auditsFF"
  auth = "user"

  input {
    int auditID?
  }

  stack {
    db.edit audit {
      field_name = "id"
      field_value = $input.auditID
      enforce_hidden_fields = false
      data = {completed_on: now}
    } as $audit1
  }

  response = $audit1
}