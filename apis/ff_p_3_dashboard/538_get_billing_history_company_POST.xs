query getBillingHistoryCompany verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int company?
  }

  stack {
    db.query billing {
      where = $db.billing.companies_id == $input.company
      sort = {billing.created_at: "desc"}
      return = {type: "list"}
    } as $billing1
  }

  response = $billing1
}