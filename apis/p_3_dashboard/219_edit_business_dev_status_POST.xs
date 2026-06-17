query edit_business_dev_status verb=POST {
  api_group = "p3dashboard"

  input {
    text id? filters=trim
    bool status?=false
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {business_dev: $input.status}
    } as $user_1
  
    db.query user {
      return = {type: "list"}
      output = ["id", "name", "l_name", "email", "is_admin", "business_dev"]
    } as $user_2
  }

  response = $user_2
}