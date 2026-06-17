query getSubscriptionsIdFromCompany verb=POST {
  api_group = "Sign Up FF"
  auth = "user"

  input {
    int companyId?
  }

  stack {
    db.get subscriptions {
      field_name = "company"
      field_value = $input.companyId
    } as $subscriptions1
  }

  response = {id: $subscriptions1.id}
}