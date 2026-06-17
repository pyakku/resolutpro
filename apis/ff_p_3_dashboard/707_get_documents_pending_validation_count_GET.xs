query getDocumentsPendingValidationCount verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    function.run P3DocumentsPendingValidationCount as $func_1
  }

  response = $func_1
}