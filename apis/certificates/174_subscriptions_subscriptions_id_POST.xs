// Edit subscriptions record
query "subscriptions/{subscriptions_id}" verb=POST {
  api_group = "Certificates"

  input {
    int subscriptions_id? filters=min:1
    dblink {
      table = "subscriptions"
    }
  }

  stack {
    db.edit subscriptions {
      field_name = "id"
      field_value = $input.subscriptions_id
      enforce_hidden_fields = false
      data = {}
    } as $subscriptions
  }

  response = $subscriptions
}