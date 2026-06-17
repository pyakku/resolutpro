query add_invited_company_to_existing_user verb=POST {
  api_group = "sign_up_completion"

  input {
    text email? filters=trim
    text f_name? filters=trim
    text l_name? filters=trim
    text password? filters=trim
    text userid? filters=trim
  }

  stack {
    var $status {
      value = "Error"
    }
  
    db.get user {
      field_name = "id"
      field_value = $input.userid
    } as $user_2
  
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $existing_user
  
    db.query companies {
      where = $db.companies.company_reg == "unregistered" && $db.companies.created_by_user == $user_2.id
      return = {type: "list"}
    } as $companies_3
  
    foreach ($companies_3) {
      each as $item {
        db.edit companies {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {created_by_user: $existing_user.id, plan: 11}
        } as $companies_4
      }
    }
  
    db.query invitations {
      where = $db.invitations.invited_user == $user_2.id
      return = {type: "list"}
    } as $invitations_1
  
    foreach ($invitations_1) {
      each as $item {
        db.edit invitations {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {accepted: true}
        } as $invitations_2
      }
    }
  
    db.query subscriptions {
      where = $db.subscriptions.user_id == $user_2.id
      return = {type: "list"}
    } as $subscriptions_2
  
    foreach ($subscriptions_2) {
      each as $item {
        db.edit subscriptions {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {user_id: $existing_user.id}
        } as $subscriptions_3
      }
    }
  
    db.query user {
      where = $db.user.email == $input.email && $db.user.email != $user_2.email
      return = {type: "exists"}
    } as $user_3
  
    db.del user {
      field_name = "id"
      field_value = $input.userid
    }
  
    var $status {
      value = "Done"
    }
  }

  response = {status: $status}
}