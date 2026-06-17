query getAllCompanies verb=GET {
  api_group = "FFRegulator"
  auth = "regulator"

  input {
  }

  stack {
    db.query companies {
      where = $auth.id in $db.companies.regulator
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country"
        }
        {
          name : "functions"
          input: {functions_id: $output.$this}
          as   : "functions"
        }
      ]
    } as $companies1
  
    db.query audit_types {
      where = $db.audit_types.regulator == $auth.id
      return = {type: "list"}
    } as $audit_types1
  
    conditional {
      if ($audit_types1|is_empty) {
        var $overallCompliance {
          value = 100
        }
      
        var $compliant {
          value = $companies1|count
        }
      
        var $totalCount {
          value = $companies1|count
        }
      }
    
      else {
        var $compliant {
          value = 0
        }
      
        var $totalCount {
          value = $companies1|count
        }
      
        foreach ($companies1) {
          each as $companyList {
            var $compliantAudits {
              value = 0
            }
          
            foreach ($audit_types1) {
              each as $auditItem {
                function.run auditPrepared {
                  input = {company: $companyList.id, auditID: $auditItem.id}
                } as $func1
              
                conditional {
                  if ($func1.documentsRequired == $func1.documentsAvailable) {
                    var.update $compliantAudits {
                      value = $compliantAudits|add:1
                    }
                  }
                }
              }
            }
          
            conditional {
              if ($compliantAudits == ($audit_types1|count)) {
                var.update $compliant {
                  value = $compliant|add:1
                }
              }
            }
          }
        }
      
        var $overallCompliance {
          value = ($var.compliant/$var.totalCount)*100
        }
      }
    }
  }

  response = {
    companiesList    : $companies1
    compliant        : $compliant
    totalCount       : $totalCount
    overallCompliance: $overallCompliance
    nonCompliant     : $totalCount|subtract:$compliant
  }
}