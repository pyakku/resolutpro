query approve_function verb=POST {
  api_group = "request_functions"

  input {
    text id? filters=trim
  }

  stack {
    db.get function_request {
      field_name = "id"
      field_value = $input.id
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.requested_to}
          as   : "requested_to"
        }
        {
          name : "companies"
          input: {companies_id: $output.requested_by}
          addon: [
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "created_by_user"
            }
          ]
          as   : "requested_by"
        }
      ]
    } as $record
  
    db.transaction {
      stack {
        db.get companies {
          field_name = "id"
          field_value = $record.requested_to.id
        } as $company
      
        var $contains {
          value = false
        }
      
        foreach ($company.functions) {
          each as $item {
            conditional {
              if ($item == $record.function) {
                var.update $contains {
                  value = true
                }
              }
            }
          }
        }
      
        conditional {
          if ($contains == false) {
            db.edit companies {
              field_name = "id"
              field_value = $record.requested_to.id
              enforce_hidden_fields = false
              data = {
                functions: $record.requested_to.functions|push:$record.function
              }
            } as $company
          }
        }
      
        var $company_id {
          value = $company.id
        }
      
        var $country {
          value = $company.country_code
        }
      
        var $function {
          value = $record.function
        }
      
        db.query certificates_needed {
          where = $db.certificates_needed.countries_id == $country && $db.certificates_needed.functions_id == $function
          return = {type: "list"}
        } as $certificates_needed_1
      
        foreach ($certificates_needed_1) {
          each as $item {
            var $certificate_id {
              value = $item.certificates_id
            }
          
            db.query required_certificates {
              where = $db.required_certificates.companies_id == $company_id && $db.required_certificates.certificates_id == $certificate_id
              return = {type: "exists"}
            } as $already_exists
          
            conditional {
              if ($already_exists == false) {
                db.add required_certificates {
                  enforce_hidden_fields = false
                  data = {
                    companies_id           : $company_id
                    certificates_id        : $certificate_id
                    active                 : true
                    required_for_compliance: true
                  }
                } as $required_certificates_1
              }
            }
          }
        }
      }
    }
  
    db.edit function_request {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {accepted: true}
    } as $function_request_1
  
    db.get function_request {
      field_name = "id"
      field_value = $input.id
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.requested_by}
          addon: [
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "created_by_user"
            }
          ]
          as   : "requested_by"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.requested_to}
          as   : "requested_to"
        }
        {
          name : "functions"
          input: {functions_id: $output.function}
          as   : "function"
        }
      ]
    } as $function_request_3
  
    api.request {
      url = "https://p3audit.com/itracker/email_function_request_accepted.php"
      method = "POST"
      params = {}
        |set:"function":$function_request_3.function.function
        |set:"to_company":$function_request_3.requested_to.Company_Name
        |set:"email":$function_request_3.requested_by.created_by_user.email
        |set:"by_company":$function_request_3.requested_by.Company_Name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.query function_request {
      where = $db.function_request.requested_to == $company_id && $db.function_request.rejected == false && $db.function_request.accepted == false
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.requested_by}
          as   : "requested_by"
        }
        {
          name : "functions"
          input: {functions_id: $output.function}
          as   : "function"
        }
      ]
    } as $function_request_2
  }

  response = $function_request_2
}