query delete_request verb=POST {
  api_group = "request_functions"

  input {
    dblink {
      table = "function_request"
      override = {
        accepted    : {hidden: true}
        function    : {hidden: true}
        rejected    : {hidden: true}
        created_at  : {hidden: true}
        requested_by: {hidden: false}
        requested_to: {hidden: false}
      }
    }
  
    text id? filters=trim
  }

  stack {
    db.del function_request {
      field_name = "id"
      field_value = $input.id
    }
  
    db.query function_request {
      where = $db.function_request.requested_by == $input.requested_by && $db.function_request.requested_to == $input.requested_to && $db.function_request.rejected == false && $db.function_request.accepted == false
      return = {type: "list"}
      addon = [
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