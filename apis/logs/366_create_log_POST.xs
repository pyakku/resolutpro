query create_log verb=POST {
  api_group = "logs"
  auth = "user"

  input {
    text action? filters=trim
    int company?
  }

  stack {
    function.run create_log {
      input = {
        company: $input.company
        user   : $auth.id
        action : $input.action
      }
    } as $func_1
  }

  response = $func_1
}