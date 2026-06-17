query edit_cert_issue_date verb=POST {
  api_group = "Certificates"

  input {
    text id? filters=trim
    text date? filters=trim
  }

  stack {
    db.edit required_certificates {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {issued_date: $input.date}
    } as $required_certificates_1
  }

  response = $required_certificates_1
}