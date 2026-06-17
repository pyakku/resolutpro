query getProjectionList verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text month? filters=trim
    text year? filters=trim
  }

  stack {
    db.query companies {
      where = $db.companies.test == false && $db.companies.plan != 9 && $db.companies.verified == true && $db.companies.p3_managed == false
      return = {type: "list"}
    } as $companies2
  
    var.update $companies2 {
      value = $companies2.id
    }
  
    var $temp {
      value = []
    }
  
    foreach ($companies2) {
      each as $item {
        function.run projectBilling {
          input = {company: $item, month: $input.month, year: $input.year}
        } as $func1
      
        db.get companies {
          field_name = "id"
          field_value = $item
          output = ["Company_Name"]
        } as $companies1
      
        var.update $temp {
          value = $temp
            |push:($item
              |set:"bills":$func1
              |set:"companyName":$companies1.Company_Name
              |set:"total":($func1.certificate_price
                |to_decimal
                |add:($func1.ptn_price
                  |to_decimal
                  |add:($func1.user_price
                    |to_decimal
                    |add:($func1.audit_price
                      |to_decimal
                      |add:($func1.share_price
                        |to_decimal
                        |add:($func1.contacts_price|to_decimal)
                      )
                    )
                  )
                )
                |round:2
              )
            )
        }
      }
    }
  
    var.update $companies2 {
      value = $temp
    }
  }

  response = $companies2|sort:"companyName":"itext":true
}