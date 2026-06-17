query verify_company verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text id? filters=trim
  }

  stack {
    db.edit companies {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {verified: true, verified_on: now}
    } as $companies_1
  }

  response = {status: "done"}
}