query assessmentSectionDocPrepared verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int company?
    int sectionID?
  }

  stack {
    !db.query audit {
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
  
    conditional {
      if (($input.company|is_empty) || ($input.sectionID|is_empty)) {
        return {
          value = []
        }
      }
    }
  
    db.get assessmentsV2Sections {
      field_name = "id"
      field_value = $input.sectionID
      addon = [
        {
          name : "documents"
          input: {documents_id: $output.$this}
          as   : "documents"
        }
      ]
    } as $assessmentsV2Sections1
  
    var $documentsRequired {
      value = $assessmentsV2Sections1.documents
    }
  
    var $temp {
      value = []
    }
  
    conditional {
      if ($documentsRequired|is_empty) {
      }
    
      else {
        foreach ($documentsRequired) {
          each as $item {
            db.query myDocuments {
              where = $db.myDocuments.document == $item.id && $db.myDocuments.validated == true && $db.myDocuments.archived == false && $db.myDocuments.company == $input.company
              return = {type: "exists"}
            } as $exists
          
            conditional {
              if ($exists) {
                db.query myDocuments {
                  where = $db.myDocuments.document == $item.id && $db.myDocuments.validated == true && $db.myDocuments.archived == false && $db.myDocuments.company == $input.company
                  return = {type: "single"}
                  addon = [
                    {
                      name : "documents"
                      input: {documents_id: $output.document}
                      as   : "document"
                    }
                  ]
                } as $myDocument
              
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"has":$exists
                      |set:"myDocument":$myDocument
                    )
                }
              }
            
              else {
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"has":$exists
                      |set:"myDocument":0
                    )
                }
              }
            }
          }
        }
      }
    }
  
    var.update $documentsRequired {
      value = $temp
    }
  }

  response = $documentsRequired
}