query get_certificate_by_id verb=POST {
  api_group = "p3dashboard"

  input {
    text id? filters=trim
  }

  stack {
    db.get required_certificates {
      field_name = "id"
      field_value = $input.id
    } as $required_certificates_1
  }

  response = $required_certificates_1
}