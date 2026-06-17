query get_processes verb=POST {
  api_group = "auditor_dashboard"

  input {
    text company? filters=trim
  }

  stack {
    db.query relationships {
      where = $db.relationships.assigned_by == $input.company || $db.relationships.assigned_to == $input.company || $db.relationships.data_owner == $input.company
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
          name : "countries"
          input: {countries_id: $output.Country}
          as   : "Country"
        }
        {
          name : "functions"
          input: {functions_id: $output.functions}
          as   : "functions"
        }
      ]
    } as $relationships_1
  }

  response = $relationships_1
}