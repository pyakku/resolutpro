query getAllSuppliers verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query companies {
      where = $db.companies.test == false && $db.companies.individual == false
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name  : "countries"
          output: ["Name"]
          input : {countries_id: $output.country_code}
          as    : "country"
        }
        {
          name  : "functions"
          output: ["function"]
          input : {functions_id: $output.$this}
          as    : "functions"
        }
      ]
    } as $companies1
  
    db.query relationships {
      where = $db.relationships.assigned_by == $input.company || $db.relationships.data_owner == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.assigned_to}
          addon: [
            {
              name : "countries"
              input: {countries_id: $output.country_code}
              as   : "country"
            }
            {
              name : "functions"
              input: {functions_id: $output.$this}
              as   : "functions"
            }
          ]
          as   : "assigned_to"
        }
      ]
    } as $relationships1
  
    var.update $companies1 {
      value = $relationships1.assigned_to|sort:"Company_Name":"itext":true
    }
  
    var.update $companies1 {
      value = $companies1|unique:"id"
    }
  }

  response = $companies1
}