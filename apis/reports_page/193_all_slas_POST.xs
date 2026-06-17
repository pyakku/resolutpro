query all_slas verb=POST {
  api_group = "Reports_Page"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query relationships {
      where = ($db.relationships.sla != null && ($db.relationships.assigned_by == $input.company_id))
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.assigned_by}
          as   : "assigned_by"
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
        {
          name : "companies_01"
          input: {companies_id: $output.assigned_to}
          as   : "assigned_to"
        }
      ]
    } as $relationships_1
  }

  response = $relationships_1
}