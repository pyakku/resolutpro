query retry_failed_subscription verb=POST {
  api_group = "subscriptions"

  input {
    text subscription_id? filters=trim
  }

  stack {
    db.get subscriptions {
      field_name = "id"
      field_value = $input.subscription_id
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          as   : "company"
        }
        {
          name : "user"
          input: {user_id: $output.user_id}
          as   : "user_id"
        }
      ]
    } as $subscriptions_1
  
    function.run create_subscription_free_plan {
      input = {
        email       : $subscriptions_1.user_id.email
        company_name: $subscriptions_1.company.Company_Name
        first_name  : $subscriptions_1.user_id.name
        last_name   : $subscriptions_1.user_id.l_name
        phone       : $subscriptions_1.company.phone_number
        company_id  : $subscriptions_1.company.id
        user_id     : $subscriptions_1.user_id.id
        plan        : $subscriptions_1.plan
      }
    } as $func_1
  }

  response = $func_1
}