query documentShareDetails verb=POST {
  api_group = "ff"

  input {
    text sessionID? filters=trim
  }

  stack {
    conditional {
      if (($input.sessionID|is_empty) == false) {
        db.get share_audits {
          field_name = "controller"
          field_value = $input.sessionID
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
            "myPersona"
            "download"
          ]
        
          addon = [
            {
              name  : "companies_01"
              output: [
                "id"
                "created_at"
                "Company_Name"
                "company_reg"
                "created_by"
                "functions"
                "is_sub"
                "test"
                "created_by_user"
                "industry"
                "phone_number"
                "city"
                "state"
                "postal_code"
                "country"
                "no_of_employees"
                "revenue"
                "country_code"
                "functions_inactive"
                "profile_link"
                "plan"
                "onetrust"
                "verifier_email"
                "verifier_name"
                "verified"
                "verified_on"
                "p3_managed"
                "preloaded"
                "regulator"
              ]
              input : {companies_id: $output.company}
              as    : "companyDetails"
            }
          ]
        } as $share_audits1
      }
    
      else {
        var $share_audits1 {
          value = {}
        }
      }
    }
  
    conditional {
      if (($share_audits1|is_empty) == false) {
        group {
          stack {
            var.update $share_audits1.documentCount {
              value = $share_audits1.documents|count
            }
          
            conditional {
              if ($share_audits1.valid|is_empty) {
                var.update $share_audits1.isValid {
                  value = true
                }
              }
            
              else {
                var $lastHour {
                  value = $share_audits1.valid
                    |transform_timestamp:"next day midnight -1 minute":"UTC"
                }
              
                conditional {
                  if ($lastHour >= now) {
                    var.update $share_audits1.isValid {
                      value = true
                    }
                  }
                
                  else {
                    var.update $share_audits1.isValid {
                      value = false
                    }
                  }
                }
              }
            }
          
            db.query myDocuments {
              where = $db.myDocuments.company == $share_audits1.company
              return = {type: "count"}
            } as $myDocuments1
          
            var.update $share_audits1.documentCount {
              value = $myDocuments1
            }
          
            db.query audit {
              where = $db.audit.companies_id == $share_audits1.company
              return = {type: "count"}
            } as $audit1
          
            db.query relationships {
              where = $db.relationships.assigned_by == $share_audits1.company
              return = {type: "count"}
            } as $relationships1
          
            db.query products {
              where = $db.products.company == $share_audits1.company
              return = {type: "count"}
            } as $products1
          
            var.update $share_audits1.auditCount {
              value = $audit1
            }
          
            var.update $share_audits1.processCount {
              value = $relationships1
            }
          
            var.update $share_audits1.productCount {
              value = $products1
            }
          }
        }
      }
    
      else {
        var.update $share_audits1.isValid {
          value = false
        }
      }
    }
  }

  response = $share_audits1
  tags = ["documentshare"]
}