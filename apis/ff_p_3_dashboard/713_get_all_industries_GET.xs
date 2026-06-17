query getAllIndustries verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query industries {
      sort = {industries.industry: "asc"}
      return = {type: "list"}
    } as $industries1
  }

  response = $industries1
}