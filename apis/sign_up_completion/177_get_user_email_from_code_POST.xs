query get_user_email_from_code verb=POST {
  api_group = "sign_up_completion"

  input {
    text code? filters=trim
  }

  stack {
    db.get user {
      field_name = "name"
      field_value = $input.code
    } as $model
  }

  response = {status: $model|get:"email":null, id: $model.id}
}