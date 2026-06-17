query documentShareStatusByCompany verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
    int loggedInUserCompany?
  }

  stack {
    db.query myDocuments {
      where = $db.myDocuments.company == $input.loggedInUserCompany && $db.myDocuments.myPersona == true
      return = {type: "list"}
    } as $myDocuments1
  
    conditional {
      if ($myDocuments1|is_empty) {
        var $myPersonaShare1 {
          value = []
        }
      }
    
      else {
        db.query myPersonaShare {
          where = $db.myPersonaShare.myDocument in $myDocuments1.id && $db.myPersonaShare.company == $input.company
          sort = {
            myPersonaShare.active    : "desc"
            myPersonaShare.created_at: "desc"
          }
        
          return = {type: "list"}
          output = [
            "id"
            "created_at"
            "myDocument"
            "company"
            "stoppedOn"
            "active"
            "approvedByReciepent"
            "name"
            "email"
            "lName"
            "shareLink"
            "shareByEmail"
          ]
        
          addon = [
            {
              name  : "companies_01"
              output: ["Company_Name"]
              input : {companies_id: $output.company}
            }
            {
              name  : "myDocuments"
              output: ["nameUA"]
              input : {myDocuments_id: $output.myDocument}
            }
          ]
        } as $myPersonaShare1
      }
    }
  }

  response = $myPersonaShare1
}