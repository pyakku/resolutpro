// Get subscriptions record
query "subscriptions/{subscriptions_id}" verb=GET {
  api_group = "Certificates"

  input {
    int subscriptions_id? filters=min:1
  }

  stack {
    db.get subscriptions {
      field_name = "id"
      field_value = $input.subscriptions_id
    } as $subscriptions
  
    precondition ($subscriptions != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $subscriptions
}