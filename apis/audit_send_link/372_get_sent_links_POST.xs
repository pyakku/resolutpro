query get_sent_links verb=POST {
  api_group = "Audit_Send Link"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query share_audits {
      where = $db.share_audits.company == $input.company
      sort = {share_audits.created_at: "desc"}
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "company"
        "f_name"
        "l_name"
        "email"
        "controller"
        "valid"
        "documents"
        "viewed"
        "sendHistory"
        "download"
      ]
    
      addon = [
        {
          name : "myDocuments"
          input: {myDocuments_id: $output.$this}
          addon: [
            {
              name : "documents"
              input: {documents_id: $output.document}
              as   : "documents"
            }
          ]
          as   : "documents"
        }
      ]
    } as $share_audits_1
  
    conditional {
      if (($share_audits_1|is_empty) == false) {
        var $temp {
          value = []
        }
      
        foreach ($share_audits_1) {
          each as $item {
            conditional {
              if ($item.valid|is_empty) {
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"documentCount":($item.documents|count)
                      |set:"documentList":$item.documents.id
                      |set:"viewValid":true
                      |set:"datePresent":false
                    )
                }
              }
            
              else {
                conditional {
                  if ($item.valid <= now) {
                    var.update $temp {
                      value = $temp
                        |push:($item
                          |set:"documentCount":($item.documents|count)
                          |set:"documentList":$item.documents.id
                          |set:"viewValid":false
                          |set:"datePresent":true
                        )
                    }
                  }
                
                  else {
                    var.update $temp {
                      value = $temp
                        |push:($item
                          |set:"documentCount":($item.documents|count)
                          |set:"documentList":$item.documents.id
                          |set:"viewValid":true
                          |set:"datePresent":true
                        )
                    }
                  }
                }
              }
            }
          
            !var.update $temp {
              value = $temp
                |push:($item
                  |set:"documentCount":($item.documents|count)
                  |set:"documentList":$item.documents.id
                )
            }
          }
        }
      
        var.update $share_audits_1 {
          value = $temp
        }
      }
    }
  }

  response = $share_audits_1
}