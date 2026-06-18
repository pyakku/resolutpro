// Companies the authenticated user can access (owned + addon-shared), for the
// company selection screen. Read-only; sorted by company name.
query "user/list_companies" verb=GET {
  api_group = "resolut_apis"
  auth = "user"

  input {
  }

  stack {
    db.query subscriptions {
      where = $db.subscriptions.user_id == $auth.id || $auth.id in $db.subscriptions.addon_user
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
              name  : "user"
              output: [
                "id"
                "created_at"
                "name"
                "l_name"
                "email"
                "user_id"
                "language"
                "date_format"
                "is_admin"
                "plan"
                "business_dev"
                "completed_walkthrough"
              ]
              input : {user_id: $output.created_by_user}
              as    : "created_by_user"
            }
            {name: "plan", input: {plan_id: $output.plan}, as: "plan"}
          ]
          as   : "company"
        }
      ]
    } as $subscriptions_1

    conditional {
      if ($subscriptions_1|is_empty) {
      }

      else {
        var $temp {
          value = []
        }

        foreach ($subscriptions_1) {
          each as $item {
            var.update $temp {
              value = $temp
                |push:($item
                  |set:"companyName":$item.company.Company_Name
                  |set:"individual":$item.company.individual
                )
            }
          }
        }

        var.update $subscriptions_1 {
          value = $temp|sort:"companyName":"itext":true
        }
      }
    }
  }

  response = $subscriptions_1
  guid = "1B7OauOGP2DMiA3zX0q_5_Ck6vw"
}
