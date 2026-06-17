query getMyDocumentsMyPersona verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.get contacts {
      field_name = "email"
      field_value = $user1.email
    } as $contacts1
  
    db.query companies {
      where = $db.companies.created_by_user == $auth.id && $db.companies.individual == true
      return = {type: "single"}
    } as $companies1
  
    db.query myDocuments {
      where = $db.myDocuments.holderContact == $contacts1.id
      sort = {
        myDocuments.expiryDate: "desc"
        myDocuments.created_at: "desc"
      }
    
      return = {type: "list"}
      addon = [
        {
          name : "documents"
          input: {documents_id: $output.document}
          as   : "document"
        }
        {
          name  : "companies"
          output: ["Company_Name"]
          input : {companies_id: $output.company}
        }
      ]
    } as $myDocuments1
  
    conditional {
      if ($myDocuments1|is_empty) {
        var.update $myDocuments1 {
          value = []
            |push:({}
              |set:"id":-1
              |set:"created_at":0
              |set:"company":$companies1.id
              |set:"globalAck":false
              |set:"noExpiry":false
              |set:"nameUA":"Insurance"
              |set:"issueDate":0
              |set:"expiryDate":0
              |set:"validationDate":null
              |set:"holderContact":$contacts1.id
              |set:"issuedBy":""
              |set:"lastTestDate":null
              |set:"testAuditor":""
              |set:"validationComments":""
              |set:"validatedBy":0
              |set:"validated":false
              |set:"rejected":false
              |set:"active":true
              |set:"holder_company":$companies1.id
              |set:"markelInsurance":true
              |set:"archived":false
              |set:"myPersona":true
              |set:"mypersonaClassification":"Regulatory"
              |set:"markedForDeletion":false
              |!set:"file":({}
                |set:"access":"public"
                |set:"path":"/vault/a_hha0n2/Iybhv3E8JYs0OP1zUdiuOucdAUI/1PBBAg../1746686123574504.pdf"
                |set:"name":"1746686123574504.pdf"
                |set:"type":"pdf"
                |set:"size":542252
                |set:"mime":"application/pdf"
                |set:"meta":({}|set:"validated":false)
                |set:"url":"https://xjno-rqiq-2v6x.n7.xano.io/vault/a_hha0n2/Iybhv3E8JYs0OP1zUdiuOucdAUI/1PBBAg../1746686123574504.pdf"
              )
              |set:"document":null
              |set:"Company_Name":$companies1.Company_Name
              |set:"forSelf":true
              |set:"viewCount":0
              |set:"downloadCount":0
            )
        }
      }
    
      else {
        var $temp {
          value = []
        }
      
        foreach ($myDocuments1) {
          each as $item {
            db.query myPersonaDocumentsViewLog {
              where = $db.myPersonaDocumentsViewLog.document == $item.id && $db.myPersonaDocumentsViewLog.user != $auth.id
              return = {type: "count"}
            } as $myPersonaDocumentsViewLog1
          
            db.query myPersonaDocumentsDownloadLog {
              where = $db.myPersonaDocumentsDownloadLog.document == $item.id
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
      
        db.query myDocuments {
          where = $db.myDocuments.holderContact == $contacts1.id && $db.myDocuments.markelInsurance == true
          sort = {
            myDocuments.expiryDate: "desc"
            myDocuments.created_at: "desc"
          }
        
          return = {type: "list"}
          addon = [
            {
              name : "documents"
              input: {documents_id: $output.document}
              as   : "document"
            }
            {
              name  : "companies"
              output: ["Company_Name"]
              input : {companies_id: $output.company}
            }
          ]
        } as $insuranceDocs
      
        conditional {
          if ($insuranceDocs|is_empty) {
            var.update $myDocuments1 {
              value = $myDocuments1
                |push:({}
                  |set:"id":-1
                  |set:"created_at":0
                  |set:"markelInsurance":true
                  |set:"company":$companies1.id
                  |set:"globalAck":false
                  |set:"noExpiry":false
                  |set:"nameUA":"Insurance"
                  |set:"issueDate":0
                  |set:"expiryDate":0
                  |set:"validationDate":null
                  |set:"holderContact":$contacts1.id
                  |set:"issuedBy":""
                  |set:"lastTestDate":null
                  |set:"testAuditor":""
                  |set:"validationComments":""
                  |set:"validatedBy":0
                  |set:"validated":false
                  |set:"rejected":false
                  |set:"active":true
                  |set:"holder_company":$companies1.id
                  |set:"archived":false
                  |set:"myPersona":true
                  |set:"mypersonaClassification":"Regulatory"
                  |set:"markedForDeletion":false
                  |!set:"file":({}
                    |set:"access":"public"
                    |set:"path":"/vault/a_hha0n2/Iybhv3E8JYs0OP1zUdiuOucdAUI/1PBBAg../1746686123574504.pdf"
                    |set:"name":"1746686123574504.pdf"
                    |set:"type":"pdf"
                    |set:"size":542252
                    |set:"mime":"application/pdf"
                    |set:"meta":({}|set:"validated":false)
                    |set:"url":"https://xjno-rqiq-2v6x.n7.xano.io/vault/a_hha0n2/Iybhv3E8JYs0OP1zUdiuOucdAUI/1PBBAg../1746686123574504.pdf"
                  )
                  |set:"document":null
                  |set:"Company_Name":$companies1.Company_Name
                  |set:"forSelf":true
                  |set:"viewCount":0
                  |set:"downloadCount":0
                )
            }
          }
        }
      }
    }
  }

  response = $myDocuments1
}