query reject_request verb=POST {
  api_group = "request_functions"

  input {
    text id? filters=trim
  }

  stack {
    db.edit function_request {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {rejected: true}
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
  
    var $company_id {
      value = $function_request_3.requested_to.id
    }
  
    api.request {
      url = "https://p3audit.com/itracker/email_function_request_rejected.php"
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