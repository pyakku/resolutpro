query getAllAuditors verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query auditor {
      sort = {
        auditor.first_name : "asc"
        auditor.middle_name: "asc"
        auditor.last_name  : "asc"
      }
    
      return = {type: "list"}
    } as $auditor1
  
    var $temp {
      value = []
    }
  
    foreach ($auditor1) {
      each as $item {
        db.query auditorDetails {
          where = $db.auditorDetails.auditor == $item.id
          return = {type: "list"}
          addon = [
            {
              name : "certificationBody"
              input: {certificationBody_id: $output.certificationBody}
              as   : "certificationBody"
            }
          ]
        } as $auditorDetails1
      
        conditional {
          if ($auditorDetails1|is_empty) {
            var.update $temp {
              value = $temp
                |push:($item|set:"certificationBody":[])
            }
          }
        
          else {
            var.update $temp {
              value = $temp
                |push:($item
                  |set:"certificationBody":$auditorDetails1.certificationBody
                )
            }
          }
        }
      }
    }
  
    var.update $auditor1 {
      value = $temp
    }
  }

  response = $auditor1
}