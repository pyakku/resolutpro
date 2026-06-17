// Query all companies records
query companies verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query companies {
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
    } as $companies
  }

  response = $companies
}