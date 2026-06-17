query get_my_relationships verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text id? filters=trim
  }

  stack {
    function.run get_my_relationships {
      input = {id: $input.id}
    } as $func_1
  }

  response = $func_1
}