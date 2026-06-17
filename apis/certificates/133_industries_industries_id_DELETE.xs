// Delete industries record.
query "industries/{industries_id}" verb=DELETE {
  api_group = "Certificates"

  input {
    int industries_id? filters=min:1
  }

  stack {
    db.del industries {
      field_name = "id"
      field_value = $input.industries_id
    }
  }

  response = null
}