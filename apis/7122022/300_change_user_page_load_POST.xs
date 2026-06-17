query change_user_page_load verb=POST {
  api_group = "7122022"

  input {
    text company? filters=trim
  }

  stack {
    db.query subscriptions {
      where = $db.subscriptions.company == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.company}
          as   : "company"
        }
        {
          name : "user"
          input: {user_id: $output.$this}
          as   : "addon_user"
        }
        {
          name : "user"
          input: {user_id: $output.user_id}
          as   : "user_id"
        }
      ]
    } as $subscriptions_1
  }

  response = $subscriptions_1
}