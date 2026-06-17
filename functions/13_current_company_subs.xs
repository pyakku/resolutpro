function current_company_subs {
  input {
    text company_id? filters=trim
  }

  stack {
    var $parent_company {
      value = 0
    }
  
    db.get subsidiary_table {
      field_name = "subsidiary"
      field_value = $input.company_id
    } as $subsidiary_table_2
  
    conditional {
      if ($subsidiary_table_2 != null) {
        var.update $parent_company {
          value = $subsidiary_table_2.parent_company
        }
      }
    }
  
    !db.query subsidiary_table {
      where = $db.subsidiary_table.parent_company == $input.company_id
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "parent_company"
        "subsidiary"
        "approved"
        "rejected"
      ]
    
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.subsidiary}
          as   : "subsidiary_details"
        }
      ]
    } as $subsidiary_table_1
  
    conditional {
      if ($parent_company == 0) {
        db.query subsidiary_table {
          where = $db.subsidiary_table.parent_company == $input.company_id || $db.subsidiary_table.subsidiary == $input.company_id
          return = {type: "list"}
          addon = [
            {
              name : "companies"
              input: {companies_id: $output.subsidiary}
              addon: [
                {
                  name : "countries"
                  input: {countries_id: $output.country_code}
                  as   : "_countries"
                }
              ]
              as   : "subsidiary_details"
            }
          ]
        } as $subsidiary_table_1
      }
    
      else {
        db.query subsidiary_table {
          where = $db.subsidiary_table.parent_company == $input.company_id || $db.subsidiary_table.subsidiary == $input.company_id || $db.subsidiary_table.parent_company == $parent_company
          return = {type: "list"}
          addon = [
            {
              name : "companies"
              input: {companies_id: $output.subsidiary}
              addon: [
                {
                  name : "countries"
                  input: {countries_id: $output.country_code}
                  as   : "_countries"
                }
              ]
              as   : "subsidiary_details"
            }
          ]
        } as $subsidiary_table_1
      }
    }
  }

  response = $subsidiary_table_1
}