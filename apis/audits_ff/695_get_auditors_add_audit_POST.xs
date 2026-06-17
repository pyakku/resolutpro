query getAuditorsAddAudit verb=POST {
  api_group = "auditsFF"
  auth = "user"

  input {
    int certificationBody?
  }

  stack {
    db.query auditorDetails {
      where = $db.auditorDetails.certificationBody == $input.certificationBody
      return = {type: "list"}
    } as $auditorDetails1
  
    conditional {
      if ($auditorDetails1|is_empty) {
        db.query auditor {
          where = $db.auditor.independent == true
          sort = {auditor.first_name: "asc"}
          return = {type: "list"}
          output = [
            "id"
            "created_at"
            "first_name"
            "middle_name"
            "last_name"
            "email"
            "city"
            "country"
            "phone"
            "code"
            "independent"
            "employed"
          ]
        } as $auditor1
      }
    
      else {
        db.query auditor {
          where = $db.auditor.id in $auditorDetails1.auditor || $db.auditor.independent == true
          sort = {auditor.first_name: "asc"}
          return = {type: "list"}
          output = [
            "id"
            "created_at"
            "first_name"
            "middle_name"
            "last_name"
            "email"
            "city"
            "country"
            "phone"
            "code"
            "independent"
            "employed"
          ]
        } as $auditor1
      }
    }
  
    conditional {
      if ($auditor1|is_empty) {
      }
    
      else {
        var $x1 {
          value = []
        }
      
        foreach ($auditor1) {
          each as $item {
            var.update $x1 {
              value = $x1
                |push:($item
                  |set:"name":($item.first_name
                    |concat:$item.middle_name:" "
                    |concat:$item.last_name:" "
                  )
                )
            }
          }
        }
      
        var.update $auditor1 {
          value = $x1|sort:"name":"itext":true
        }
      }
    }
  }

  response = $auditor1
}