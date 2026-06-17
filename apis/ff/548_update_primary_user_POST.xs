query updatePrimaryUser verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int newSystemUser?
    int company?
  }

  stack {
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company
    } as $subscriptions2
  
    db.edit subscriptions {
      field_name = "company"
      field_value = $input.company
      enforce_hidden_fields = false
      data = {
        user_id   : $input.newSystemUser
        addon_user: $subscriptions2.addon_user|remove:$input.newSystemUser:"":false|push:$auth.id
      }
    } as $subscriptions1
  }

  response = $subscriptions1
}