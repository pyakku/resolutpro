query checkPassword verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    text password? filters=trim
  }

  stack {
    db.get auditor {
      field_name = "id"
      field_value = $auth.id
      output = [
        "id"
        "created_at"
        "first_name"
        "middle_name"
        "last_name"
        "email"
        "password"
        "city"
        "country"
        "industry_body"
        "ib_membership"
        "organisation_name"
        "organisation_reg"
        "phone"
        "org_phone"
        "org_email"
        "org_country"
        "primary_professional_body"
        "ppb_membership"
        "title"
        "no_of_auditors"
        "code"
        "governing_body"
        "qualification"
        "image"
      ]
    } as $auditor1
  
    security.check_password {
      text_password = $input.password
      hash_password = $auditor1.password
    } as $x1
  }

  response = {correct: $x1}
}