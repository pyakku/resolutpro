query addRelationshipNewEmail verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text email? filters=trim
    text company_name? filters=trim
    text user_id? filters=trim
    text assigned_by? filters=trim
    text desc? filters=trim
    text function_id? filters=trim
    text country_id? filters=trim
    file? sla?
    text assigned_by_name? filters=trim
    text ptn? filters=trim
  }

  stack {
    var $return {
      value = "Error"
    }
  
    db.get companies {
      field_name = "id"
      field_value = $input.assigned_by
    } as $companies_1
  
    db.transaction {
      stack {
        security.random_number {
          min = 100000
          max = 99999999
        } as $random_code
      
        db.has user {
          field_name = "email"
          field_value = $input.email
        } as $user_1
      
        conditional {
          if ($user_1) {
            db.get user {
              field_name = "email"
              field_value = $input.email
            } as $new_user
          
            db.add companies {
              enforce_hidden_fields = false
              data = {
                Company_Name   : $input.company_name
                company_reg    : "unregistered"
                created_by     : $input.user_id
                functions      : []|push:$input.function_id
                is_sub         : false
                test           : false
                email          : $input.email
                created_by_user: $new_user.id
                country_code   : $input.country_id|to_int
                plan           : 1
                onetrust       : ""
                verifier_email : ""
                verifier_name  : ""
                verified       : false
                verified_on    : ""
                p3_managed     : ""
                preloaded      : ""
                regulator      : []
                individual     : ""
              }
            } as $new_company
          }
        
          else {
            db.add user {
              enforce_hidden_fields = false
              data = {
                name       : $random_code
                email      : $input.email
                user_id    : $input.user_id
                language   : "ENGLISH"
                date_format: "UK"
                is_admin   : false
                plan       : 1
              }
            } as $new_user
          
            db.add companies {
              enforce_hidden_fields = false
              data = {
                Company_Name   : $input.company_name
                company_reg    : "unregistered"
                created_by     : $input.user_id
                functions      : []|push:$input.function_id
                is_sub         : false
                test           : false
                email          : $input.email
                created_by_user: $new_user.id
                country_code   : $input.country_id|to_int
                plan           : 1
                onetrust       : ""
                verifier_email : ""
                verifier_name  : ""
                verified       : false
                verified_on    : ""
                p3_managed     : ""
                preloaded      : ""
                regulator      : []
                individual     : ""
              }
            } as $new_company
          
            api.request {
              url = $env.emailBase
                |concat:"invite_vendor.php?email=":""
                |concat:($input.email
                  |concat:("&client="
                    |concat:($input.assigned_by_name
                      |concat:("&vendor="
                        |concat:($input.company_name
                          |concat:("&code="|concat:$random_code:""):""
                        ):""
                      ):""
                    ):""
                  ):""
                ):""
                |replace:" ":"%20"
              method = "GET"
              headers = []
                |push:"Content-Type: application/json"
              verify_host = false
              verify_peer = false
            } as $api_1
          }
        }
      
        db.add relationships {
          enforce_hidden_fields = false
          data = {
            PTN_no     : $input.ptn
            approved   : true
            assigned_to: $new_company.id|to_int
            assigned_by: $input.assigned_by|to_int
            data_owner : $input.assigned_by|to_int
            functions  : $input.function_id|to_int
            Country    : $input.country_id|to_int
            desc       : $input.desc
            terminated : false
          }
        } as $relationships_1
      
        db.add subscriptions {
          enforce_hidden_fields = false
          data = {
            created_at: "now"
            company   : $new_company.id
            user_id   : $new_user.id
          }
        } as $subscriptions1
      
        conditional {
          if ($input.sla|is_empty) {
          }
        
          else {
            storage.create_attachment {
              value = $input.sla
              access = "public"
              filename = ""
            } as $sla_doc
          
            db.edit relationships {
              field_name = "id"
              field_value = $relationships_1.id
              enforce_hidden_fields = false
              data = {sla: $sla_doc}
            } as $relationships1
          }
        }
      
        db.add invitations {
          enforce_hidden_fields = false
          data = {
            created_at          : "now"
            company             : $input.assigned_by|to_int
            invited_user        : $new_user.id
            invited_company     : $new_company.id
            inviting_user       : $companies_1.created_by_user
            relationship        : $relationships_1.id
            invited_company_name: $input.company_name
            email               : $input.email
            last_email_sent     : now
            accepted            : false
          }
        } as $invitations_1
      
        var $return {
          value = "Done"
        }
      }
    }
  }

  response = $return
}