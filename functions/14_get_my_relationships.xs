function get_my_relationships {
  input {
    text id? filters=trim
  }

  stack {
    db.query relationships {
      where = $db.relationships.assigned_by == $input.id
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.assigned_to}
          as   : "assigned_to"
        }
        {
          name : "companies"
          input: {companies_id: $output.assigned_by}
          as   : "assigned_by"
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