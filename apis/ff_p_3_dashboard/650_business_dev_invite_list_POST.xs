query businessDevInviteList verb=POST {
  api_group = "ffP3Dashboard"

  input {
    int user?
  }

  stack {
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
                    var $total {
                      value = 0
                        |add:$bills.data.user_price
                        |add:$bills.data.ptn_price
                        |add:$bills.data.audit_price
                        |add:$bills.data.share_price
                        |add:$bills.data.policies_price
                        |add:$bills.data.certificate_price
                    }
                  
                    var.update $trans_details {
                      value = $trans_details|push:($bills|set:"total":$total)
                    }
                  }
                }
              
                var.update $item.transactions {
                  value = $trans_details
                }
              
                var.update $item.transactions_total {
                  value = $trans_details.total|sum|round:3
                }
              
                var.update $trans_details {
                  value = []
                }
              }
            
              else {
                var.update $item.transactions {
                  value = []
                }
              }
            }
          
            !db.query billing {
              where = $db.billing.companies_id == $item.responding_company.id
              sort = {billing.year: "asc", billing.month: "asc"}
              return = {type: "list"}
            } as $billing1
          
            !conditional {
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
  
    db.get user {
      field_name = "id"
      field_value = $input.user
    } as $user1
  }

  response = {
    invites     : $business_dev_invites_2
    transactions: $trans_details|safe_array
    user        : $user1
  }
}