query verify_addition verb=POST {
  api_group = "sign_upv3"

  input {
    text key? filters=trim
  }

  stack {
    db.get add_company_from_login_page {
      field_name = "key"
      field_value = $input.key
      addon = [
        {
          name  : "user"
          output: ["email"]
          input : {user_id: $output.user}
        }
      ]
    } as $add_company_from_login_page_1
  }

  response = $add_company_from_login_page_1
}