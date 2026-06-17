query getAllCompanies verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.query companies {
      where = $db.companies.test == false && $db.companies.individual == false
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      output = ["id", "Company_Name"]
    } as $companies1
  }

  response = $companies1
}