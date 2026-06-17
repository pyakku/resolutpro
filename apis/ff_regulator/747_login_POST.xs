query login verb=POST {
  api_group = "FFRegulator"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    db.get regulator {
      field_name = "email"
      field_value = $input.email
      output = [
        "id"
        "created_at"
        "name"
        "email"
        "password"
        "countries"
        "industries"
        "allCountries"
        "allIndustries"
      ]
    } as $regulator1
  
    precondition (($regulator1|is_empty) == false) {
      error_type = "accessdenied"
      error = "User not found. Please check your email."
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $regulator1.password
    } as $x1
  
    precondition ($x1) {
      error_type = "unauthorized"
      error = "Wrong Password. Please try again."
    }
  
    security.create_auth_token {
      table = "regulator"
      extras = {}
      expiration = 0
      id = $regulator1.id
    } as $authToken
  }

  response = {authToken: $authToken}
}