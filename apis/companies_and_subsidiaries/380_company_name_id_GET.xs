query company_name_id verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query companies {
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      output = ["id", "Company_Name", "test"]
    } as $companies_1
  }

  response = $companies_1
}