query company_and_owner_details verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    function.run company_and_owner_details as $func_1
  }

  response = $func_1
}