query deleteDocument verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int myDocument?
  }

  stack {
    db.query myPersonaShare {
      where = $db.myPersonaShare.myDocument == $input.myDocument
      return = {type: "list"}
      addon = [
        {
          name  : "myDocuments"
          output: ["nameUA"]
          input : {myDocuments_id: $output.myDocument}
        }
      ]
    } as $myPersonaShare4
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    conditional {
      if ($myPersonaShare4|is_empty) {
      }
    
      else {
        foreach ($myPersonaShare4) {
          each as $item {
            conditional {
              if ($item.active) {
                api.request {
                  url = $env.emailBase
                    |concat:"myPersonaShareStopped.php":""
                  method = "POST"
                  params = {}
                    |set:"documentName":$item.nameUA
                    |set:"contactName":$item.name
                    |set:"contactEmail":$item.email
                    |set:"email":$user1.email
                    |set:"name":($user1.name|concat:$user1.l_name:" ")
                  headers = []
                    |push:"Content-Type: application/json"
                } as $api1
              
                db.add email_log {
                  enforce_hidden_fields = false
                  data = {created_at: "now", response: $api1}
                } as $email_log2
              }
            }
          }
        }
      }
    }
  
    db.transaction {
      stack {
        db.bulk.delete myPersonaShare {
          where = $db.myPersonaShare.myDocument == $input.myDocument
        } as $myPersonaShare1
      
        db.bulk.delete myPersonaDocumentsDownloadLog {
          where = $db.myPersonaDocumentsDownloadLog.document == $input.myDocument
        } as $myPersonaDocumentsDownloadLog1
      
        db.query myPersonaShare {
          where = $db.myPersonaShare.myDocument == $input.myDocument
          return = {type: "list"}
        } as $myPersonaShare3
      
        conditional {
          if ($myPersonaShare3|is_empty) {
          }
        
          else {
            db.bulk.delete share_audits {
              where = $db.share_audits.id in $myPersonaShare3.shareLink
            } as $share_audits1
          }
        }
      
        db.bulk.delete myPersonaShare {
          where = $db.myPersonaShare.myDocument == $input.myDocument
        } as $myPersonaShare2
      
        db.get myDocuments {
          field_name = "id"
          field_value = $input.myDocument
        } as $myDocuments1
      
        db.get user {
          field_name = "id"
          field_value = $auth.id
        } as $user1
      
        storage.delete_file {
          pathname = $myDocuments1.file.path
        }
      
        db.del myDocuments {
          field_name = "id"
          field_value = $input.myDocument
        }
      
        api.request {
          url = $env.emailBase
            |concat:"myPersonaDeleteDocument.php":""
          method = "POST"
          params = {}
            |set:"recipient_fname":$user1.name
            |set:"email":$user1.email
            |set:"document":$myDocuments1.nameUA
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api1}
        } as $email_log1
      }
    }
  }

  response = {status: "done"}
}