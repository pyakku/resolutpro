query getDocumentShareHistoryByDocumentDashboard verb=GET {
  api_group = "myPersonaFF"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query companies {
      where = $db.companies.created_by_user == $auth.id && $db.companies.individual == true
      return = {type: "single"}
    } as $companies1
  
    db.query myDocuments {
      where = $db.myDocuments.company == $companies1.id && $db.myDocuments.myPersona == true
      return = {type: "list"}
    } as $myDocuments1
  
    var $return {
      value = []
    }
  
    conditional {
      if ($myDocuments1|is_empty) {
      }
    
      else {
        foreach ($myDocuments1) {
          each as $item {
            db.query myPersonaShare {
              where = $db.myPersonaShare.myDocument == $item.id
              return = {type: "list"}
              addon = [
                {
                  name  : "companies_01"
                  output: ["Company_Name"]
                  input : {companies_id: $output.company}
                }
              ]
            } as $myPersonaShare1
          
            conditional {
              if (($myPersonaShare1|count) == 0) {
              }
            
              else {
                var.update $return {
                  value = $return
                    |push:($item
                      |set:"count":($myPersonaShare1|count)
                      |set:"companies":($myPersonaShare1.Company_Name|safe_array)
                    )
                }
              }
            }
          }
        }
      }
    }
  }

  response = $return
}