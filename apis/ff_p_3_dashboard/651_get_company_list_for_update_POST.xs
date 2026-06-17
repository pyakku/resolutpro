query get_company_list_for_update verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    timestamp? created_at?
  }

  stack {
    db.query companies {
      where = $db.companies.created_at > $input.created_at && $db.companies.individual == false && $db.companies.test == false
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
    } as $companies_1
  }

  response = $companies_1
}