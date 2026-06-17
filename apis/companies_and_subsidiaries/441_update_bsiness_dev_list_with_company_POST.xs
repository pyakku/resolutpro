query update_bsiness_dev_list_with_company verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text user? filters=trim
    text id? filters=trim
    text company? filters=trim
  }

  stack {
    db.edit business_dev_invites {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {responding_company: $input.company|to_int}
    } as $business_dev_invites1
  
    db.query business_dev_invites {
      where = $db.business_dev_invites.user == $input.user
      return = {type: "list"}
      addon = [
        {
          name : "subscriptions_of_companies"
          input: {company: $output.responding_company}
          addon: [
            {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
          ]
          as   : "subscription"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.responding_company}
          as   : "responding_company"
        }
        {name: "user", input: {user_id: $output.user}, as: "user"}
      ]
    } as $business_dev_invites_2
  
    var $trans_details {
      value = []
    }
  
    foreach ($business_dev_invites_2) {
      each as $item {
        conditional {
          if ($item.responding_company == 0 || $item.responding_company == null) {
          }
        
          else {
            db.query billing {
              where = $db.billing.companies_id == $item.responding_company.id
              sort = {billing.year: "asc", billing.month: "asc"}
              return = {type: "list"}
            } as $billing1
          
            conditional {
              if (($billing1|count) != 0) {
                foreach ($billing1) {
                  each as $bills {
                    var.update $trans_details {
                      value = $trans_details|push:$bills
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  response = {
    invites     : $business_dev_invites_2
    transactions: $trans_details|safe_array
  }
}