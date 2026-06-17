query requested_of_user verb=POST {
  api_group = "request_functions"

  input {
    text requested_to? filters=trim
  }

  stack {
    db.query function_request {
      where = $db.function_request.requested_to == $input.requested_to && $db.function_request.rejected == false && $db.function_request.accepted == false
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.requested_by}
          as   : "requested_by"
        }
        {
          name : "functions"
          input: {functions_id: $output.function}
          as   : "function"
        }
      ]
    } as $function_request_1
  }

  response = $function_request_1
}