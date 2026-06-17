query companyName verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.has companies {
      field_name = "id"
      field_value = $input.company
    } as $companies2
  
    conditional {
      if ($companies2) {
        db.get companies {
          field_name = "id"
          field_value = $input.company
        } as $companies1
      
        var $companyName {
          value = $companies1.Company_Name
        }
      }
    
      else {
        var $companyName {
          value = ""
        }
      }
    }
  }

  response = {companyName: $companyName}
}