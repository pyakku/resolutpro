query remove_addon verb=POST {
  api_group = "multiple user access"
  auth = "user"

  input {
    text company? filters=trim
    text id? filters=trim
  }

  stack {
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company
    } as $subscriptions_2
  
    db.edit subscriptions {
      field_name = "company"
      field_value = $input.company
      enforce_hidden_fields = false
      data = {
        addon_user: $subscriptions_2.addon_user|remove:$input.id:"":false
      }
    } as $subscriptions_1
  
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company
      addon = [
        {
          name : "user"
          input: {user_id: $output.$this}
          as   : "addon_user.addon_user"
        }
      ]
    } as $subscriptions_2
  
    db.get user {
      field_name = "id"
      field_value = $input.id
    } as $user_1
  
    db.get companies {
      field_name = "id"
      field_value = $input.company
      addon = [
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          as   : "created_by_user"
        }
      ]
    } as $companies_1
  
    api.request {
      url = "https://p3audit.com/itracker/remove_system_user_notification.php"
      method = "POST"
      params = {}
        |set:"company_name":$companies_1.Company_Name
        |set:"primary_name":($companies_1.created_by_user.name
          |concat:(" "
            |concat:$companies_1.created_by_user.l_name:""
          ):""
        )
        |set:"primary_email":$companies_1.created_by_user.email
        |set:"removed_name":$user_1.name
        |set:"removed_email":$user_1.email
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = $subscriptions_2
}