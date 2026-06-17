query get_assoc_companies verb=POST {
  api_group = "certificates_new"

  input {
    text company? filters=trim
  }

  stack {
    db.query subsidiary_table {
      where = $db.subsidiary_table.parent_company == $input.company
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
          name : "companies_01"
          input: {companies_id: $output.subsidiary}
          as   : "company"
        }
      ]
    } as $subsidiaries
  
    var $sister {
      value = []
    }
  
    db.query subsidiary_table {
      where = $db.subsidiary_table.subsidiary == $input.company
      return = {type: "single"}
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
          name : "companies_01"
          input: {companies_id: $output.parent_company}
          as   : "company"
        }
      ]
    } as $parent
  
    conditional {
      if (($parent|count) != 0) {
        db.query subsidiary_table {
          where = $db.subsidiary_table.parent_company == $parent.parent_company
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
              name : "companies_01"
              input: {companies_id: $output.subsidiary}
              as   : "company"
            }
          ]
        } as $sister
      }
    }
  
    var $associated_companies {
      value = []
    }
  
    conditional {
      if (($subsidiaries|count) != 0) {
        var.update $associated_companies {
          value = $associated_companies|push:$subsidiaries.company
        }
      }
    }
  
    conditional {
      if (($parent|count) != 0) {
        var.update $associated_companies {
          value = $associated_companies|push:$parent.company
        }
      }
    }
  
    conditional {
      if (($sister|count) != 0) {
        var.update $associated_companies {
          value = $associated_companies|push:$sister.company
        }
      }
    }
  }

  response = $associated_companies
}