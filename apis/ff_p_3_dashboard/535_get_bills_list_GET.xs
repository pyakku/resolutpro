query getBillsList verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query billing {
      return = {
        type : "aggregate"
        group: {company: $db.billing.companies_id}
      }
    } as $billing1
  
    var $temp {
      value = []
    }
  
    foreach ($billing1) {
      each as $item {
        db.query billing {
          where = $db.billing.companies_id == $item.company
          return = {type: "count"}
        } as $billing2
      
        db.get companies {
          field_name = "id"
          field_value = $item.company
          output = ["Company_Name"]
        } as $companies1
      
        var.update $temp {
          value = $temp
            |push:($item
              |set:"bills":$billing2
              |set:"companyName":$companies1.Company_Name
            )
        }
      }
    }
  
    var.update $billing1 {
      value = $temp
    }
  }

  response = $billing1|sort:"companyName":"itext":true
}