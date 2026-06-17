query company_of_current_user_v2 verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text user_id? filters=trim
  }

  stack {
    !db.query companies {
      where = $db.companies.created_by_user == $input.user_id
      sort = {companies.Company_Name: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country_code"
        }
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          as   : "created_by_user"
        }
      ]
    } as $companies_1
  
    db.query companies {
      where = $db.companies.created_by_user == $input.user_id && $db.companies.company_reg == "unregistered"
      return = {type: "list"}
    } as $companies_1
  
    foreach ($companies_1) {
      each as $item {
        db.query subscriptions {
          where = $db.subscriptions.company == $item.id
          return = {type: "exists"}
        } as $subscriptions_3
      
        conditional {
          if ($subscriptions_3 == false) {
            db.add subscriptions {
              enforce_hidden_fields = false
              data = {
                created_at    : "now"
                company       : $item.id
                user_id       : $input.user_id|to_int
                plan          : 11
                active        : false
                hosted_page_id: "dummy"
              }
            } as $subscriptions_4
          }
        }
      }
    }
  
    db.query subscriptions {
      where = $db.subscriptions.user_id == $input.user_id
      sort = {subscriptions.company: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          addon: [
            {
              name : "countries"
              input: {countries_id: $output.country_code}
              as   : "country_code"
            }
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "created_by_user"
            }
          ]
          as   : "company"
        }
      ]
    } as $subscriptions_1
  
    foreach ($subscriptions_1) {
      each as $item {
        conditional {
          if ($item.subscription_id == null || $item.active == false) {
            function.run get_subscription_from_hosting_page {
              input = {hosted_page_id: $item.hosted_page_id}
            } as $func_1
          
            var $subscription_id {
              value = $func_1|get:"id":null
            }
          
            function.run subscription_details {
              input = {subscription_id: $subscription_id}
            } as $func_2
          
            conditional {
              if (($func_2|get:"subscription.status":null) == "active") {
                db.edit subscriptions {
                  field_name = "id"
                  field_value = $item.id
                  enforce_hidden_fields = false
                  data = {active: true, subscription_id: $func_1|get:"id":null}
                } as $subscriptions_2
              
                !api.request {
                  url = "https://p3audit.com/itracker/onboarding_mail.php?company="
                    |concat:($item.company.Company_Name
                      |concat:("&email="
                        |concat:($item.company.created_by_user.email
                          |concat:("&username="
                            |concat:$item.company.created_by_user.email:""
                          ):""
                        ):""
                      ):""
                    ):""
                  method = "GET"
                } as $api_1
              }
            
              else {
                db.edit subscriptions {
                  field_name = "id"
                  field_value = $item.id
                  enforce_hidden_fields = false
                  data = {active: false, subscription_id: $func_1|get:"id":null}
                } as $subscriptions_2
              }
            }
          }
        }
      }
    }
  
    db.query subscriptions {
      where = $db.subscriptions.user_id == $input.user_id || $input.user_id in $db.subscriptions.addon_user
      sort = {subscriptions.company: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.company}
          addon: [
            {
              name : "countries"
              input: {countries_id: $output.country_code}
              as   : "country_code"
            }
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "created_by_user"
            }
            {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
          ]
          as   : "company"
        }
      ]
    } as $subscriptions_1
  }

  response = $subscriptions_1
}