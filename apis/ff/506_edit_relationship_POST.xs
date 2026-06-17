query editRelationship verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int id?
    int function?
    int country?
    text desc? filters=trim
  }

  stack {
    db.edit relationships {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        functions: $input.function
        Country  : $input.country
        desc     : $input.desc
      }
    } as $relationships1
  }

  response = $relationships1
}