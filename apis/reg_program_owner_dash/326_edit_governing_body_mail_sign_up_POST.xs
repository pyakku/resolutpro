query edit_governing_body_mail_sign_up verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    db.edit certificationBody {
      field_name = "email"
      field_value = $input.email
      enforce_hidden_fields = false
      data = {password: $input.password, code: ""}
    } as $governing_body_1
  
    var $status {
      value = "Done"
    }
  }

  response = {status: $status}
}