query getMyAudits verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query audit {
      where = $db.audit.companies_id == $input.company
      sort = {audit.created_at: "desc", audit.due_by: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "audit_types"
          output: ["type"]
          input : {audit_types_id: $output.audit_types_id}
        }
        {
          name  : "auditor"
          output: ["first_name", "middle_name", "last_name"]
          input : {auditor_id: $output.auditor_id}
        }
        {
          name : "audit_types"
          input: {audit_types_id: $output.audit_types_id}
          addon: [
            {
              name : "documents"
              input: {documents_id: $output.$this}
              as   : "documentsRequired"
            }
          ]
          as   : "auditType"
        }
      ]
    } as $audit1
  
    var $temp {
      value = []
    }
  
    conditional {
      if ($audit1|is_empty) {
      }
    
      else {
        foreach ($audit1) {
          each as $audit {
            db.get audit_types {
              field_name = "id"
              field_value = $audit.audit_types_id
            } as $audit_types1
          
            conditional {
              if ($audit_types1.documentsRequired|is_empty) {
                var.update $temp {
                  value = $temp
                    |push:($audit
                      |set:"required":0
                      |set:"has":0
                      |set:"percentile":100
                    )
                }
              }
            
              else {
                db.query myDocuments {
                  where = $db.myDocuments.document in $audit_types1.documentsRequired && $db.myDocuments.validated == true && $db.myDocuments.company == $input.company && $db.myDocuments.archived == false
                  return = {type: "list"}
                } as $myDocuments1
              
                var.update $myDocuments1 {
                  value = $myDocuments1|unique:"document"
                }
              
                var.update $temp {
                  value = $temp
                    |push:($audit
                      |set:"required":($audit_types1.documentsRequired|count)
                      |set:"has":($myDocuments1|count)
                      |set:"percentile":($myDocuments1
                        |count
                        |divide:($audit_types1.documentsRequired|count)
                        |multiply:100
                      )
                    )
                }
              }
            }
          }
        }
      }
    }
  
    var.update $audit1 {
      value = $temp
    }
  }

  response = $audit1
}