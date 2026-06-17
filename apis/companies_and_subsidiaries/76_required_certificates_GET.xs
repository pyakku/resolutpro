// Query all required_certificates records
query required_certificates verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
  }

  stack {
    function.run required_certificates as $func_1
  }

  response = $func_1
}