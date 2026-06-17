query get_client_list verb=GET {
  api_group = "Default"

  input {
    int company_id?
  }

  stack {
    db.query relationships {
      where = $db.relationships.assigned_to == $input.company_id
      return = {type: "list"}
      addon = [
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