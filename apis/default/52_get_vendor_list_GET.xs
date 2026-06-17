query get_vendor_list verb=GET {
  api_group = "Default"

  input {
    int company_id?
  }

  stack {
    db.query relationships {
      where = $db.relationships.assigned_by == $input.company_id
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.assigned_to}
          as   : "assigned_to"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.assigned_by}
          as   : "assigned_by"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.data_owner}
          as   : "data_owner"
        }
        {
          name : "functions"
          input: {functions_id: $output.functions}
          as   : "functions"
        }
        {
          name : "countries"
          input: {countries_id: $output.Country}
          as   : "Country"
        }
      ]
    } as $client_vendor_1
  }

  response = $client_vendor_1
}