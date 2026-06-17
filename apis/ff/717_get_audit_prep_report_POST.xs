query getAuditPrepReport verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company
    } as $companies1
  
    db.query audit_types {
      where = $db.audit_types.regulator in $companies1.regulator
      return = {type: "list"}
      addon = [
        {
          name : "regulator"
          input: {regulator_id: $output.regulator}
          as   : "regulatorDetails"
        }
      ]
    } as $audit_types2
  
    var $temp {
      value = []
    }
  
    conditional {
      if ($audit_types2|is_empty) {
      }
    
      else {
        foreach ($audit_types2) {
          each as $audit {
            conditional {
              if ($audit.documentsRequired|is_empty) {
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
                  where = $db.myDocuments.document in $audit.documentsRequired && $db.myDocuments.validated == true && $db.myDocuments.company == $input.company && $db.myDocuments.archived == false
                  return = {type: "list"}
                } as $myDocuments1
              
                var.update $myDocuments1 {
                  value = $myDocuments1|unique:"document"
                }
              
                var.update $temp {
                  value = $temp
                    |push:($audit
                      |set:"required":($audit.documentsRequired|count)
                      |set:"has":($myDocuments1|count)
                      |set:"percentile":($myDocuments1
                        |count
                        |divide:($audit.documentsRequired|count)
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
  
    var.update $audit_types2 {
      value = $temp
    }
  }

  response = $audit_types2
}