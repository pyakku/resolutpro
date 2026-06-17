query edit_cert_holder verb=POST {
  api_group = "Certificates"

  input {
    int id?
    int holder?
  }

  stack {
    db.edit required_certificates {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {holder: $input.holder}
    } as $required_certificates_1
  }

  response = $required_certificates_1
}