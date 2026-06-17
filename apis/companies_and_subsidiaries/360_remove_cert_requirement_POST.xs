query remove_cert_requirement verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text id? filters=trim
  }

  stack {
    db.get certificates_needed {
      field_name = "id"
      field_value = $input.id
    } as $requirements
  
    db.query companies {
      where = $db.companies.country_code == $requirements.countries_id && $requirements.functions_id in $db.companies.functions
      return = {type: "exists"}
    } as $companies_1
  
    conditional {
      if ($companies_1 == false) {
      }
    
      else {
        db.query companies {
          where = $db.companies.country_code == $requirements.countries_id && $requirements.functions_id in $db.companies.functions
          return = {type: "list"}
        } as $companies_1
      
        var $company_list {
          value = $companies_1.id
        }
      
        db.query required_certificates {
          where = $db.required_certificates.required_for_compliance == true && $db.required_certificates.companies_id in $company_list
          return = {type: "list"}
          addon = [
            {
              name  : "companies"
              output: ["functions", "country_code"]
              input : {companies_id: $output.companies_id}
            }
          ]
        } as $required_certificates_3
      
        foreach ($required_certificates_3) {
          each as $item {
            conditional {
              if ($item.certificates_id == $requirements.certificates_id) {
                db.get required_certificates {
                  field_name = "id"
                  field_value = $item.id
                } as $required_certificates_1
              
                conditional {
                  if ($required_certificates_1.document == null) {
                    db.del required_certificates {
                      field_name = "id"
                      field_value = $item.id
                    }
                  }
                
                  else {
                    db.edit required_certificates {
                      field_name = "id"
                      field_value = $item.id
                      enforce_hidden_fields = false
                      data = {required_for_compliance: false}
                    } as $required_certificates_4
                  }
                }
              }
            }
          }
        }
      }
    }
  
    db.del certificates_needed {
      field_name = "id"
      field_value = $input.id
    }
  
    db.query certificates_needed {
      sort = {
        certificates_needed.countries_id: "asc"
        certificates_needed.functions_id: "desc"
      }
    
      return = {type: "list"}
      addon = [
        {
          name : "functions"
          input: {functions_id: $output.functions_id}
          as   : "functions_id"
        }
        {
          name : "countries"
          input: {countries_id: $output.countries_id}
          as   : "countries_id"
        }
        {
          name  : "certificates"
          output: [
            "id"
            "created_at"
            "Certificate_Name"
            "Certificate_Desc"
            "details"
            "approved"
          ]
          input : {certificates_id: $output.certificates_id}
          as    : "certificates_id"
        }
      ]
    } as $certificates_needed_3
  }

  response = {certificates: $certificates_needed_3}
}