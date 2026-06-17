query getRecievedDocuments verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    var $x1 {
      value = []
    }
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.query companies {
      where = $db.companies.created_by_user == $auth.id && $db.companies.individual == true
      return = {type: "list"}
    } as $companies1
  
    db.query share_audits {
      where = $db.share_audits.email == $user1.email
      return = {type: "list"}
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.$this}
          as   : "documents"
        }
        {
          name  : "companies"
          output: ["Company_Name"]
          input : {companies_id: $output.company}
        }
      ]
    } as $share_audits1
  
    conditional {
      if ($share_audits1|is_empty) {
      }
    
      else {
        foreach ($share_audits1) {
          each as $item {
            foreach ($item.documents) {
              each as $documentitem {
                var.update $x1 {
                  value = $x1
                    |push:($documentitem
                      |set:"sharedOn":$item.created_at
                      |set:"company":$item.Company_Name
                    )
                }
              }
            }
          }
        }
      }
    }
  
    var $myDocuments1 {
      value = $x1
    }
  
    conditional {
      if ($myDocuments1|is_empty) {
      }
    
      else {
        var $temp {
          value = []
        }
      
        foreach ($myDocuments1) {
          each as $item {
            db.query myPersonaDocumentsViewLog {
              where = $db.myPersonaDocumentsViewLog.document == $item.id && $db.myPersonaDocumentsViewLog.user == $auth.id
              return = {type: "count"}
            } as $myPersonaDocumentsViewLog1
          
            db.query myPersonaDocumentsDownloadLog {
              where = $db.myPersonaDocumentsDownloadLog.document == $item.id && $db.myPersonaDocumentsDownloadLog.user == $auth.id
              return = {type: "count"}
            } as $myPersonaDocumentsDownloadLog1
          
            conditional {
              if ($item.company == $companies1.id) {
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"forSelf":true
                      |set:"viewCount":$myPersonaDocumentsViewLog1
                      |set:"downloadCount":$myPersonaDocumentsDownloadLog1
                    )
                }
              }
            
              else {
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"forSelf":false
                      |set:"viewCount":$myPersonaDocumentsViewLog1
                      |set:"downloadCount":$myPersonaDocumentsDownloadLog1
                    )
                }
              }
            }
          }
        }
      
        var.update $myDocuments1 {
          value = $temp
        }
      }
    }
  }

  response = $myDocuments1|unique:"id"
}