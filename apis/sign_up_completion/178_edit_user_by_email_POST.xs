query edit_user_by_email verb=POST {
  api_group = "sign_up_completion"

  input {
    text email? filters=trim
    text f_name? filters=trim
    text l_name? filters=trim
    text password? filters=trim
    text userid? filters=trim
  }

  stack {
    var $status {
      value = "Error"
    }
  
    db.get user {
      field_name = "id"
      field_value = $input.userid
    } as $user_2
  
    db.query user {
      where = $db.user.email == $input.email && $db.user.email != $user_2.email
      return = {type: "exists"}
    } as $user_3
  
    conditional {
      if ($user_3 == false) {
        db.transaction {
          stack {
            db.edit user {
              field_name = "id"
              field_value = $input.userid
              enforce_hidden_fields = false
              data = {
                name    : $input.f_name
                l_name  : $input.l_name
                email   : $input.email
                password: $input.password
                plan    : 1
              }
            } as $user_1
          
            db.has companies {
              field_name = "created_by"
              field_value = $user_1.id
            } as $companies_3
          
            conditional {
              if ($companies_3) {
                db.get companies {
                  field_name = "created_by"
                  field_value = $user_1.id
                } as $companies_1
              
                db.edit companies {
                  field_name = "id"
                  field_value = $companies_1|get:"id":null
                  enforce_hidden_fields = false
                  data = {created_by_user: $user_1|get:"id":null, plan: 1}
                } as $companies_2
              
                db.add subscriptions {
                  enforce_hidden_fields = false
                  data = {
                    company       : $companies_2|get:"id":null
                    user_id       : $user_1|get:"id":null
                    plan          : 1
                    active        : false
                    hosted_page_id: "dummy"
                  }
                } as $subscriptions_1
              }
            }
          
            var $status {
              value = "Done"
            }
          }
        }
      }
    }
  }

  response = {status: $status}
}