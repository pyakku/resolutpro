query billing_action verb=POST {
  api_group = "Billing"

  input {
  }

  stack {
    db.query companies {
      where = $db.companies.p3_managed == false && $db.companies.test == false && $db.companies.verified == true && $db.companies.plan != 9
      return = {type: "list"}
    } as $companies_1
  
    var.update $companies_1 {
      value = $companies_1.id
    }
  
    db.query subscriptions {
      where = $db.subscriptions.company in $companies_1
      return = {type: "list"}
    } as $subscriptions_1
  
    var $billing_year {
      value = now
        |transform_timestamp:"Last Day of last month":"UTC"
        |format_timestamp:"Y":"UTC"
    }
  
    var $billing_month {
      value = now
        |transform_timestamp:"Last Day of last month":"UTC"
        |format_timestamp:"m":"UTC"
    }
  
    foreach ($subscriptions_1) {
      each as $subscription {
        group {
          stack {
            db.query billing {
              where = $db.billing.month == $billing_month && $db.billing.year == $billing_year && $db.billing.companies_id == $subscription.company
              return = {type: "exists"}
            } as $billing_1
          
            conditional {
              if ($billing_1) {
              }
            
              else {
                function.run Billingbymonthyear {
                  input = {
                    company     : $subscription.company
                    month       : $billing_month
                    year        : $billing_year
                    subscription: $subscription.subscription_id
                  }
                } as $func_1
              
                db.add billing {
                  enforce_hidden_fields = false
                  data = {
                    created_at  : "now"
                    companies_id: $subscription.company|to_int
                    data        : $func_1
                    month       : $billing_month
                    year        : $billing_year
                    invoice_id  : $func_1.invoice
                  }
                } as $billing_2
              }
            }
          }
        }
      }
    }
  
    !db.query billing {
      return = {type: "list"}
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.companies_id}
          as   : "company"
        }
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
      ]
    } as $billing_3
  }

  response = null
}