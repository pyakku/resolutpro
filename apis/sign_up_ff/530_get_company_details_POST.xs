query getCompanyDetails verb=POST {
  api_group = "Sign Up FF"
  auth = "user"

  input {
    int id?
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.id
    } as $companies1
  }

  response = {name: $companies1.Company_Name}
}