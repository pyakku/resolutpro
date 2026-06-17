query business_dev_sent_invites_fn verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text user? filters=trim
  }

  stack {
    function.run business_dev_sent_invites_fn {
      input = {user: $input.user}
    } as $func_1
  }

  response = $func_1
}