query companies_name_id verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    db.query companies {
      return = {type: "list"}
      output = ["id", "company_reg", "Company_Name", "test"]
    } as $model
  }

  response = $model
}