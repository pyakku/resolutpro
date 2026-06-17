query isIndividual verb=POST {
  api_group = "individual"
  auth = "user"

  input {
    int companyID?
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.companyID
    } as $companies1
  }

  response = {individual: $companies1.individual}
}