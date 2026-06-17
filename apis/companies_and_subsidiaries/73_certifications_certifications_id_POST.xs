// Edit certifications record
query "certifications/{certifications_id}" verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int certifications_id? filters=min:1
    dblink {
      table = ""
    }
  }

  stack {
    db.edit "" {
      field_name = "id"
      field_value = $input.certifications_id
      enforce_hidden_fields = false
      data = {}
    } as $certifications
  }

  response = $certifications
}