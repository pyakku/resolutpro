query getAllIndustries verb=GET {
  api_group = "Sign Up FF"

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