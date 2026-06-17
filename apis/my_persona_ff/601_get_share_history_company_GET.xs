query getShareHistoryCompany verb=GET {
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
      where = $db.myDocuments.company == $companies1.id
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
          value = $myDocuments1.id
        }
      }
    }
  }

  response = $companies1
}