query update_sla verb=POST {
  api_group = "Default"

  input {
    file? sla?
    text id? filters=trim
  }

  stack {
    storage.create_attachment {
      value = $input.sla
      access = "public"
    } as $document
  
    db.edit relationships {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {sla: $document}
    } as $relationships_1
  }

  response = $relationships_1
}