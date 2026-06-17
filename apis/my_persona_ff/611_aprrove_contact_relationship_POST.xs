query aprroveContactRelationship verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int relID?
  }

  stack {
    db.edit contact_relationship {
      field_name = "id"
      field_value = $input.relID
      enforce_hidden_fields = false
      data = {approved: true}
    } as $contact_relationship1
  }

  response = $contact_relationship1
}