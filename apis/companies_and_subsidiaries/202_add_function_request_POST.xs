query add_function_request verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "function_request"
      override = {
        accepted    : {hidden: true}
        function    : {hidden: false}
        rejected    : {hidden: true}
        created_at  : {hidden: true}
        requested_by: {hidden: false}
        requested_to: {hidden: false}
      }
    }
  }

  stack {
    db.query function_request {
      where = $db.function_request.requested_by == $input.requested_by && $db.function_request.requested_to == $input.requested_to && $db.function_request.function == $input.function
      return = {type: "exists"}
    } as $function_request_2
  
    var $output {
      value = "You Have Already Requested the function."
    }
  
    conditional {
      if ($function_request_2) {
      }
    
      else {
        db.add function_request {
          enforce_hidden_fields = false
          data = {
            requested_by: $input.requested_by
            requested_to: $input.requested_to
            function    : $input.function
            rejected    : false
            accepted    : false
          }
        
          addon = [
            {
              name : "companies"
              input: {companies_id: $output.requested_by}
              as   : "requested_by"
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
              as   : "requested_to"
            }
            {
              name : "functions"
              input: {functions_id: $output.function}
              as   : "function"
            }
          ]
        } as $function_request
      
        db.get function_request {
          field_name = "id"
          field_value = $function_request.id
          addon = [
            {
              name : "companies"
              input: {companies_id: $output.requested_by}
              as   : "requested_by"
            }
            {
              name : "companies"
              input: {companies_id: $input.requested_to}
              addon: [
                {
                  name : "user"
                  input: {user_id: $output.created_by_user}
                  as   : "created_by_user"
                }
              ]
              as   : "requested_to"
            }
            {
              name : "functions"
              input: {functions_id: $output.function}
              as   : "function"
            }
          ]
        } as $function_request_1
      
        !api.request {
          url = "https://p3audit.com/itracker/email_function_requested.php?email="
            |concat:($function_request_1.requested_to.created_by_user.email
              |concat:("&function="
                |concat:($function_request_1.function.function
                  |concat:("&by_company="
                    |concat:($function_request_1.requested_by.Company_Name
                      |concat:("&to_company="
                        |concat:$function_request_1.requested_to.Company_Name:""
                      ):""
                    ):""
                  ):""
                ):""
              ):""
            ):""
            |url_encode
          method = "GET"
        } as $api_1
      
        api.request {
          url = "https://p3audit.com/itracker/email_function_requested.php"
          method = "POST"
          params = {}
            |set:"email":$function_request_1.requested_to.created_by_user.email
            |set:"to_company":$function_request_1.requested_to.Company_Name
            |set:"by_company":$function_request_1.requested_by.Company_Name
            |set:"function":$function_request_1.function.function
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      
        var.update $output {
          value = "Function Requested."
        }
      }
    }
  }

  response = $var.output
}