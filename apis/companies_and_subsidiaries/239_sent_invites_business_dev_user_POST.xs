query sent_invites_business_dev_user verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text user? filters=trim
  }

  stack {
    db.query business_dev_invites {
      where = $db.business_dev_invites.user == $input.user
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.responding_company}
          as   : "responding_company"
        }
        {
          name : "subscriptions_of_companies"
          input: {company: $output.responding_company}
          addon: [
            {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
          ]
          as   : "subscription"
        }
      ]
    } as $business_dev_invites_1
  }

  response = $business_dev_invites_1
}