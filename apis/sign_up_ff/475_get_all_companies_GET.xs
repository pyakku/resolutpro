query getAllCompanies verb=GET {
  api_group = "Sign Up FF"

  input {
  }

  stack {
    db.query companies {
      where = $db.companies.test == false
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      output = ["id", "Company_Name"]
    } as $companies1
  }

  response = $companies1
}