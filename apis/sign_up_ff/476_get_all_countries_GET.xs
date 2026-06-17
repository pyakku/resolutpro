query getAllCountries verb=GET {
  api_group = "Sign Up FF"

  input {
  }

  stack {
    db.query countries {
      sort = {countries.Name: "asc"}
      return = {type: "list"}
      output = ["id", "Name"]
    } as $countries1
  }

  response = $countries1
}