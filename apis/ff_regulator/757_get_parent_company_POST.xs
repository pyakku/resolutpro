query getParentCompany verb=POST {
  api_group = "FFRegulator"
  auth = "regulator"

  input {
    int company?
  }

  stack {
    db.get subsidiary_table {
      field_name = "subsidiary"
      field_value = $input.company
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.parent_company}
          as   : "parent_company"
        }
      ]
    } as $subsidiary_table1
  }

  response = $subsidiary_table1
}