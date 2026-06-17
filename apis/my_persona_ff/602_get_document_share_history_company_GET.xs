query getDocumentShareHistoryCompany verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

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
  
    conditional {
      if ($myDocuments1|is_empty) {
        var $return {
          value = []
        }
      }
    
      else {
        var $documentList {
          value = $myDocuments1.id|safe_array
        }
      
        db.query myPersonaShare {
          where = $db.myPersonaShare.myDocument in $documentList && $db.myPersonaShare.shareByEmail == false
          return = {type: "list"}
        } as $myPersonaShare1
      
        conditional {
          if ($myPersonaShare1|is_empty) {
            var $return {
              value = []
            }
          }
        
          else {
            var $companies {
              value = $myPersonaShare1.company|safe_array|unique:""
            }
          
            db.query companies {
              where = $db.companies.id in $companies
              return = {type: "list"}
            } as $companies2
          
            var $return {
              value = []
            }
          
            foreach ($companies2) {
              each as $item {
                db.query myPersonaShare {
                  where = $db.myPersonaShare.myDocument in $documentList && $db.myPersonaShare.company == $item.id
                  return = {type: "list"}
                } as $myPersonaShare2
              
                var.update $return {
                  value = $return
                    |push:($item
                      |set:"shares":($myPersonaShare2|count)
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