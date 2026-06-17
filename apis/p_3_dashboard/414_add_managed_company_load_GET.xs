query add_managed_company_load verb=GET {
  api_group = "p3dashboard"

  input {
  }

  stack {
    db.query industries {
      sort = {industries.industry: "asc"}
      return = {type: "list"}
    } as $industries_1
  
    db.query countries {
      sort = {countries.Name: "asc"}
      return = {type: "list"}
    } as $countries_1
  }

  response = {industries: $industries_1, countries: $countries_1}
}