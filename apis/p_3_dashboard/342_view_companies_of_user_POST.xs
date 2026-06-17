query view_companies_of_user verb=POST {
  api_group = "p3dashboard"

  input {
    text user? filters=trim
  }

  stack {
    db.query subscriptions {
      where = $db.subscriptions.user_id == $input.user
      return = {type: "list"}
      output = ["id", "company"]
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          as   : "company"
        }
      ]
    } as $owner
  
    db.query subscriptions {
      where = $input.user in $db.subscriptions.addon_user
      return = {type: "list"}
      output = ["id", "company"]
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          as   : "company"
        }
      ]
    } as $addon
  }

  response = {owner: $owner, addon: $addon}
}