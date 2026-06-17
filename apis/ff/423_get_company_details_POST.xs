query get_company_details verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int id?
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.id
      output = [
        "id"
        "created_at"
        "Company_Name"
        "company_reg"
        "created_by"
        "functions"
        "is_sub"
        "test"
        "email"
        "created_by_user"
        "industry"
        "industryTableLink"
        "phone_number"
        "city"
        "state"
        "postal_code"
        "country"
        "no_of_employees"
        "revenue"
        "country_code"
        "functions_inactive"
        "profile_link"
        "plan"
        "onetrust"
        "verifier_email"
        "verifier_name"
        "verified"
        "verified_on"
        "p3_managed"
        "preloaded"
        "regulator"
        "individual"
        "markedForDeletion"
      ]
    
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country"
        }
      ]
    } as $companies1
  }

  response = $companies1
}