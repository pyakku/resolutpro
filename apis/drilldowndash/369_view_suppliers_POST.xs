query view_suppliers verb=POST {
  api_group = "drilldowndash"

  input {
    text industry_id? filters=trim
    text company? filters=trim
  }

  stack {
    conditional {
      if (($input.industry_id|is_empty) || $input.industry_id == "") {
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company || $db.relationships.data_owner == $input.company
          return = {type: "list"}
          addon = [
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
        } as $relationships_1
      
        var $functions_1 {
          value = {}|set:"function":"All Industries"
        }
      }
    
      else {
        db.query relationships {
          where = ($db.relationships.assigned_by == $input.company || $db.relationships.data_owner == $input.company) && $db.relationships.functions == $input.industry_id
          return = {type: "list"}
          addon = [
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
        } as $relationships_1
      
        db.get functions {
          field_name = "id"
          field_value = $input.industry_id
          output = ["function"]
        } as $functions_1
      }
    }
  
    var $list {
      value = []
    }
  
    var.update $list {
      value = $relationships_1.assigned_to.id
    }
  
    db.query companies {
      where = $db.companies.id in $list
      return = {type: "list"}
      addon = [
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions"
        }
      ]
    } as $companies_1
  
    db.query required_certificates {
      return = {type: "list"}
    } as $required_certificates_1
  }

  response = {
    companies            : $companies_1
    relationships        : $relationships_1
    required_certificates: $required_certificates_1
    function             : $functions_1
  }
}