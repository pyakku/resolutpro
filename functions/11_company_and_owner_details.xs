function company_and_owner_details {
  input {
  }

  stack {
    db.query companies {
      where = $db.companies.p3_managed == false
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name  : "user"
          output: [
            "id"
            "created_at"
            "name"
            "l_name"
            "email"
            "user_id"
            "language"
            "date_format"
            "is_admin"
            "plan"
          ]
          input : {user_id: $output.created_by_user}
          as    : "created_by_user"
        }
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "_countries"
        }
      ]
    } as $companies_1
  }

  response = $companies_1
}