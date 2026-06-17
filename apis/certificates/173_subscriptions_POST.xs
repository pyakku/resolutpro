// Add subscriptions record
query subscriptions verb=POST {
  api_group = "Certificates"

  input {
    dblink {
      table = "subscriptions"
    }
  }

  stack {
    db.add subscriptions {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $subscriptions
  }

  response = $subscriptions
}