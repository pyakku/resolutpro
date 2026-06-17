function auditPrepared {
  input {
    int company?
    int auditID?
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
      if (($input.company|is_empty) || ($input.auditID|is_empty)) {
        return {
          value = []
        }
      }
    }
  
    db.get audit_types {
      field_name = "id"
      field_value = $input.auditID
      addon = [
        {
          name : "documents"
          input: {documents_id: $output.$this}
          as   : "documentsRequired"
        }
      ]
    } as $audit_types1
  
    var $documentsRequired {
      value = $audit_types1.documentsRequired
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
  
    array.filter_count ($documentsRequired) if ($this.has) as $documentsAvailable
  }

  response = {
    documentsRequired : $documentsRequired|count
    documentsAvailable: $documentsAvailable
  }
}