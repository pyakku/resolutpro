query deleteAccount verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.edit companies {
      field_name = "id"
      field_value = $input.company
      enforce_hidden_fields = false
      data = {markedForDeletion: true}
    } as $companies1
  }

  response = $companies1
}