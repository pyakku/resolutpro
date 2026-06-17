query getAllCountries verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query countries {
      return = {type: "list"}
    } as $countries1
  }

  response = $countries1
}