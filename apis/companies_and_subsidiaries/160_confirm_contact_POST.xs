query confirm_contact verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text code? filters=trim
  }

  stack {
    db.edit contacts {
      field_name = "code"
      field_value = $input.code
      enforce_hidden_fields = false
      data = {approved: true}
    } as $contacts_1
  }

  response = {status: "confirmed"}
}