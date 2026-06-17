// Query all countries records
query countries verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query countries {
      sort = {countries.Name: "asc"}
      return = {type: "list"}
    } as $countries
  }

  response = $countries
}