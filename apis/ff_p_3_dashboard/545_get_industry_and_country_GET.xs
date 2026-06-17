query getIndustryAndCountry verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query industries {
      sort = {industries.industry: "asc"}
      return = {type: "list"}
    } as $industries1
  
    db.query countries {
      sort = {countries.Name: "asc"}
      return = {type: "list"}
    } as $countries1
  }

  response = {industries: $industries1, countries: $countries1}
}