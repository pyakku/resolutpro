query retry_failed_subscription verb=POST {
  api_group = "Sign Up FF"

  input {
    int plan?
    int company?
  }

  stack {
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company
    } as $subscriptions2
  
    db.edit subscriptions {
      field_name = "id"
      field_value = $subscriptions2.id
      enforce_hidden_fields = false
      data = {plan: $input.plan}
    } as $subscriptions1
  
    db.get subscriptions {
      field_name = "id"
      field_value = $subscriptions2.id
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
  
    !function.run create_subscription_free_plan {
      input = {
        email       : $subscriptions_1.user_id.email
        company_name: $subscriptions_1.company.Company_Name
        first_name  : $subscriptions_1.user_id.name
        last_name   : $subscriptions_1.user_id.l_name
        phone       : $subscriptions_1.company.phone_number
        company_id  : $subscriptions_1.company.id
        user_id     : $subscriptions_1.user_id.id
        plan        : $input.plan
      }
    } as $func_1
  
    function.run create_subscription_free_plan_FORRETRY {
      input = {
        email       : $subscriptions_1.user_id.email
        company_name: $subscriptions_1.company.Company_Name
        first_name  : $subscriptions_1.user_id.name
        last_name   : $subscriptions_1.user_id.l_name
        phone       : $subscriptions_1.company.phone_number
        company_id  : $subscriptions_1.company.id
        user_id     : $subscriptions_1.user_id.id
        plan        : $input.plan
      }
    } as $func_1
  }

  response = $func_1
}