query confirm_role verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text code? filters=trim
  }

  stack {
    db.edit contact_relationship {
      field_name = "approval_code"
      field_value = $input.code
      enforce_hidden_fields = false
      data = {approved: true}
    } as $contact_relationship_1
  }

  response = {status: "confirmed"}
}