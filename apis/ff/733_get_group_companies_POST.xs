query getGroupCompanies verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int companies_id? {
      table = "companies"
    }
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.companies_id
    } as $companies1
  
    conditional {
      if ($companies1.is_sub) {
        db.get subsidiary_table {
          field_name = "subsidiary"
          field_value = $input.companies_id
        } as $subsidiary_table1
      
        db.query subsidiary_table {
          where = $db.subsidiary_table.parent_company == $subsidiary_table1.parent_company && $db.subsidiary_table.subsidiary != $input.companies_id
          return = {type: "list", distinct: "no"}
          output = ["parent_company", "subsidiary", "approved", "rejected"]
          addon = [
            {
              name : "companies_01"
              input: {companies_id: $output.subsidiary}
              as   : "_companies"
            }
          ]
        } as $subsidiary_table_1
      }
    
      else {
        var $subsidiary_table_1 {
          value = []
        }
      }
    }
  }

  response = $subsidiary_table_1
}