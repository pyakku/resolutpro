query get_governing_body_email_from_code verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text code? filters=trim
  }

  stack {
    db.get certificationBody {
      field_name = "code"
      field_value = $input.code
    } as $governing_body_1
  }

  response = {status: $governing_body_1.email}
}