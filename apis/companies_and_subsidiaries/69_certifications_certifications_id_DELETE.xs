// Delete certifications record.
query "certifications/{certifications_id}" verb=DELETE {
  api_group = "Companies and Subsidiaries"

  input {
    int certifications_id? filters=min:1
  }

  stack {
    db.del "" {
      field_name = "id"
      field_value = $input.certifications_id
    }
  }

  response = null
}