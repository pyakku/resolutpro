// Delete subscriptions record.
query "subscriptions/{subscriptions_id}" verb=DELETE {
  api_group = "Certificates"

  input {
    int subscriptions_id? filters=min:1
  }

  stack {
    db.del subscriptions {
      field_name = "id"
      field_value = $input.subscriptions_id
    }
  }

  response = null
}