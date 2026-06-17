function "Emails/generate management report" {
  input {
    int company_id?
  }

  stack {
    function.run "Get Assessment Details" {
      input = {company_id: $input.company_id}
    } as $func1
  
    db.get companies {
      field_name = "id"
      field_value = $input.company_id
    } as $companies1
  
    // Compliance Inspection Readiness
    group {
      stack {
        db.get companies {
          field_name = "id"
          field_value = $input.company_id
        } as $companies1
      
        foreach ($companies1.regulator) {
          each as $regulator {
            db.query audit_types {
              where = $db.audit_types.regulator == $regulator
              return = {type: "list"}
              addon = [
                {
                  name : "regulator"
                  input: {regulator_id: $output.regulator}
                  as   : "regulatorDetails"
                }
              ]
            } as $audit_types2
          
            db.get regulator {
              field_name = "id"
              field_value = $regulator
            } as $regulator1
          
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
                          where = $db.myDocuments.document in $audit.documentsRequired && $db.myDocuments.validated == true && $db.myDocuments.company == $input.company_id && $db.myDocuments.archived == false
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
                                |round:0
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
          
            var.update $regulator.audit_types {
              value = $audit_types2
            }
          
            var $has {
              value = 0
            }
          
            var $required {
              value = 0
            }
          
            array.filter ($func1) if ($this.regulator == $regulator1.id) as $x2
            var.update $regulator.assessments {
              value = $x2
            }
          
            foreach ($regulator.audit_types) {
              each as $item {
                var.update $has {
                  value = $has|add:$item.has
                }
              
                var.update $required {
                  value = $required|add:$item.required
                }
              
                !var $name {
                  value = $item.regulatorDetails.name
                }
              }
            }
          
            foreach ($regulator.assessments) {
              each as $item {
                var.update $has {
                  value = $has|add:$item.doneCount
                }
              
                var.update $required {
                  value = $required|add:$item.totalCount
                }
              
                !var $name {
                  value = $item.regulatorDetails.name
                }
              }
            }
          
            !var.update $regulator.documents_required {
              value = $audit_types2.has
            }
          
            var.update $regulator.has {
              value = $has
            }
          
            var.update $regulator.required {
              value = $required
            }
          
            conditional {
              if ($required == 0) {
                var.update $regulator.percentile {
                  value = 100
                }
              }
            
              else {
                var.update $regulator.percentile {
                  value = ((($var.has/$var.required)*100)??100)|round:0
                }
              }
            }
          
            var.update $regulator.name {
              value = $regulator1.name
            }
          }
        }
      }
    }
  
    // get_processes
    group {
      stack {
        db.query relationships {
          where = $db.relationships.data_owner == $input.company_id || $db.relationships.assigned_by == $input.company_id || $db.relationships.assigned_to == $input.company_id
          return = {type: "list"}
        } as $total_relationships
      
        db.query relationships {
          where = $db.relationships.data_owner == $input.company_id || $db.relationships.assigned_by == $input.company_id
          return = {type: "list"}
        } as $sub_processors
      }
    }
  
    // get_products
    group {
      stack {
        db.query products {
          where = $db.products.company == $input.company_id
          return = {type: "list"}
        } as $products1
      }
    }
  
    // get_users
    group {
      stack {
        db.get subscriptions {
          field_name = "company"
          field_value = $input.company_id
        } as $subscriptions1
      
        db.query user {
          where = $db.user.id in $subscriptions1.addon_user || $db.user.id == $subscriptions1.user_id
          return = {type: "list"}
          output = ["id", "created_at", "name", "l_name", "email"]
        } as $user1
      
        var $start_date {
          value = now
            |transform_timestamp:"-30 days midnight":"UTC"
        }
      
        foreach ($user1) {
          each as $item {
            conditional {
              if ($subscriptions1.user_id == $item.id) {
                var.update $item.status {
                  value = "Primary"
                }
              }
            
              else {
                var.update $item.status {
                  value = "Add-on User"
                }
              }
            }
          
            db.query logs {
              where = $db.logs.user_id == $item.id && $db.logs.companies_id == $input.company_id
              sort = {logs.created_at: "desc"}
              return = {type: "single"}
            } as $logs1
          
            var.update $item.last_logged_in {
              value = $var.logs1.created_at??null
            }
          
            db.query logs {
              where = $db.logs.created_at > $start_date && $db.logs.companies_id == $input.company_id && $db.logs.user_id == $item.id
              return = {type: "list"}
            } as $logs2
          
            array.map ($logs2) {
              by = {date: $this.created_at|format_timestamp:"d M Y":"UTC"}
            } as $x1
          
            var.update $item.logins_in_30_days {
              value = $x1|unique:"date"|count
            }
          }
        }
      }
    }
  
    // get_Audits
    group {
      stack {
        db.query audit {
          where = $db.audit.companies_id == $input.company_id
          return = {type: "list"}
          output = [
            "id"
            "passed"
            "failed"
            "due_by"
            "completed_on"
            "audit_types_id"
          ]
        
          addon = [
            {
              name  : "audit_types"
              output: ["type", "regulator"]
              input : {audit_types_id: $output.audit_types_id}
              addon : [
                {
                  name  : "regulator"
                  output: ["name"]
                  input : {regulator_id: $output.regulator}
                  as    : "_regulator"
                }
              ]
              as    : "_audit_type"
            }
          ]
        } as $audit1
      }
    }
  
    // Documents
    group {
      stack {
        db.query myDocuments {
          where = $db.myDocuments.company == $input.company_id && $db.myDocuments.markedForDeletion == false
          return = {type: "count"}
        } as $documents
      
        db.query myDocuments {
          where = $db.myDocuments.company == $input.company_id && $db.myDocuments.rejected == true && $db.myDocuments.markedForDeletion == false
          return = {type: "count"}
        } as $invalid
      
        db.get companies {
          field_name = "id"
          field_value = $input.company_id
        } as $companies2
      
        var $regulators {
          value = $companies2.regulator
        }
      
        db.query assessmentsV2 {
          where = $db.assessmentsV2.regulator in $regulators
          return = {type: "list"}
          addon = [
            {
              name : "assessmentsV2Sections"
              input: {assessmentsV2Sections_id: $output.$this}
              as   : "assessmentSections"
            }
          ]
        } as $assessmentsV21
      
        var $documentList {
          value = []
        }
      
        try_catch {
          try {
            var $documentList {
              value = $assessmentsV21.assessmentSections.documents
            }
          }
        }
      
        db.query audit_types {
          where = $db.audit_types.regulator in $regulators
          return = {type: "list"}
        } as $audit_types1
      
        try_catch {
          try {
            var $documentList {
              value = $documentList
                |merge:$audit_types1.documentsRequired
            }
          
            var.update $documentList {
              value = $documentList|unique:""
            }
          
            db.query myDocuments {
              where = $db.myDocuments.company == $input.company_id && $db.myDocuments.validated == true && $db.myDocuments.document in $documentList
              return = {type: "count"}
            } as $compliant
          
            var $nonCompliant {
              value = ($var.documentList|count)-$var.compliant
            }
          
            db.query myDocuments {
              where = $db.myDocuments.company == $input.company_id && $db.myDocuments.noExpiry == false && $db.myDocuments.expiryDate <= (now|timestamp_add_months:3)
              return = {type: "count"}
            } as $expiringIn3Months
          }
        }
      }
    }
  }

  response = {
    documents                      : {}|set:"total":$var.documents??0|set:"invalid":$var.invalid??0|set:"nonCompliant":$var.nonCompliant??0|set:"expiringIn3Months":$var.expiringIn3Months??0
    compliance_inspection_readiness: $companies1
    processes                      : {}|set:"total":($total_relationships|count)|set:"sub_processors":($sub_processors|count)|set:"non_compliant":0
    products                       : {}|set:"total":($products1|count)|set:"sub_processors":($var.products1.third_party_processors?($var.products1.third_party_processors|count):0)|set:"non_compliant":0
    user_details                   : $user1
    audits                         : $audit1
    company                        : $companies1
    assessments                    : $func1
  }
}