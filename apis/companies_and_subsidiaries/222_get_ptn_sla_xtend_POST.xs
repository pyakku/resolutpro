query get_ptn_sla_xtend verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text ptn? filters=trim
    text company? filters=trim
  }

  stack {
    db.query relationships {
      where = $db.relationships.PTN_no == $input.ptn && ($db.relationships.assigned_by == $input.company || $db.relationships.assigned_to == $input.company)
      sort = {relationships.PTN_no: "asc", relationships.created_at: "asc"}
      return = {type: "list"}
      addon = [
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
        {
          name : "companies_01"
          input: {companies_id: $output.assigned_to}
          addon: [
            {
              name : "countries"
              input: {countries_id: $output.country_code}
              as   : "country_code"
            }
          ]
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
      ]
    } as $relationships_1
  }

  response = $relationships_1
}