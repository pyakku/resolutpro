// Get companies record
query "companies/{companies_id}" verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text company_reg? filters=trim
  }

  stack {
    db.get companies {
      field_name = "company_reg"
      field_value = $input.company_reg
      output = [
        "id"
        "created_at"
        "company_reg"
        "created_by"
        "Company_Name"
        "is_sub"
        "industry"
        "phone_number"
        "city"
        "state"
        "postal_code"
        "country"
        "no_of_employees"
        "revenue"
        "plan"
      ]
    } as $companies
  
    precondition ($companies != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  
    db.has companies {
      field_name = "id"
      field_value = ""
    } as $companies_1
  }

  response = $companies
}