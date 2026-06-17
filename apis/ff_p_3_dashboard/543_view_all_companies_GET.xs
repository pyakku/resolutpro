query viewAllCompanies verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query companies {
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country_details"
        }
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions"
        }
      ]
    } as $companies1
  
    var $temp {
      value = []
    }
  
    foreach ($companies1) {
      each as $item {
        db.get subscriptions {
          field_name = "company"
          field_value = $item.id
          addon = [
            {
              name  : "user"
              output: ["email"]
              input : {user_id: $output.user_id}
            }
          ]
        } as $subscriptions1
      
        conditional {
          if ($subscriptions1|is_empty) {
            var $email {
              value = ""
            }
          }
        
          else {
            var $email {
              value = $subscriptions1.email
            }
          }
        }
      
        var.update $temp {
          value = $temp
            |push:($item|set:"systemUser":$email)
        }
      }
    }
  }

  response = $temp
}