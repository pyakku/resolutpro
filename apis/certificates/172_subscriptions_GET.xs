// Query all subscriptions records
query subscriptions verb=GET {
  api_group = "Certificates"

  input {
  }

  stack {
    db.query subscriptions {
      return = {type: "list"}
    } as $subscriptions
  }

  response = $subscriptions
}