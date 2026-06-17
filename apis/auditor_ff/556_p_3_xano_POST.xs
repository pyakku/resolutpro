query p3Xano verb=POST {
  api_group = "Auditor FF"

  input {
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = 11
    } as $audit1
  }

  response = $audit1
}