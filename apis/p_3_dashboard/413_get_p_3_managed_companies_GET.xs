query get_p3_managed_companies verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query companies {
      where = $db.companies.p3_managed == true
      return = {type: "list"}
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country_details"
        }
      ]
    } as $companies_1
  }

  response = $companies_1
}