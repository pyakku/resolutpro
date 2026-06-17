query add_relationship_new_email_no_sla verb=POST {
  api_group = "sign_up_completion"

  input {
    text email? filters=trim
    text company_name? filters=trim
    text user_id? filters=trim
    text ptn? filters=trim
    text assigned_by? filters=trim
    text desc? filters=trim
    text function_id? filters=trim
    text country_id? filters=trim
    text assigned_by_name? filters=trim
  }

  stack {
    var $return {
      value = "Error"
    }
  
    db.get companies {
      field_name = "id"
      field_value = $input.assigned_by
      addon = [
        {
          name : "user"
          input: {user_id: $output.created_by_user}
          as   : "created_by_user"
        }
      ]
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
              field_name = $input.email
              field_value = $input.email
            } as $user_2
          
            db.add companies {
              enforce_hidden_fields = false
              data = {
                Company_Name   : $input.company_name
                company_reg    : "unregistered"
                created_by     : $input.user_id
                functions      : []|push:$input.function_id
                is_sub         : false
                test           : false
                created_by_user: $user_2.id
                country_code   : $input.country_id|to_int
                plan           : 1
                onetrust       : ""
                verifier_email : ""
                verifier_name  : ""
                verified       : false
                verified_on    : ""
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
                created_by_user: $new_user.id
                country_code   : $input.country_id|to_int
                plan           : 1
                onetrust       : ""
                verifier_email : ""
                verifier_name  : ""
                verified       : false
                verified_on    : ""
              }
            } as $new_company
          }
        }
      
        db.add relationships {
          enforce_hidden_fields = false
          data = {
            PTN_no     : $input.ptn
            approved   : true
            assigned_to: $new_company.id
            assigned_by: $input.assigned_by|to_int
            data_owner : $input.assigned_by|to_int
            functions  : $input.function_id|to_int
            Country    : $input.country_id|to_int
            desc       : $input.desc
            terminated : false
          }
        } as $relationships_1
      
        var $return {
          value = "Done"
        }
      
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
      
        db.add invitations {
          enforce_hidden_fields = false
          data = {
            created_at          : "now"
            company             : $input.assigned_by|to_int
            invited_user        : $new_user.id
            invited_company     : $new_company.id
            inviting_user       : $companies_1.created_by_user.id
            relationship        : $relationships_1.id
            invited_company_name: $input.company_name
            email               : $input.email
            contact             : ""
            last_email_sent     : now
          }
        } as $invitations_1
      }
    }
  
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.assigned_by
      return = {type: "count"}
    } as $data_owner_policies
  
    conditional {
      if ($data_owner_policies != 0) {
        db.query my_policies {
          where = $db.my_policies.companies_id == $input.assigned_by
          return = {type: "list"}
        } as $my_policies_1
      
        foreach ($my_policies_1) {
          each as $item {
            var $policy_id_current {
              value = $item.policies_id
            }
          
            db.query policy_requirements {
              where = $db.policy_requirements.assigned_to == $new_company.id && $db.policy_requirements.my_policies_id == $policy_id_current && $db.policy_requirements.acknowledged == true
              return = {type: "count"}
            } as $policy_requirements_2
          
            conditional {
              if ($policy_requirements_2 == 0) {
                db.add policy_requirements {
                  enforce_hidden_fields = false
                  data = {
                    created_at      : "now"
                    PTN             : $input.ptn
                    my_policies_id  : $item.id
                    assigned_to     : $new_company.id
                    originator      : $input.assigned_by|to_int
                    acknowledged    : false
                    relationships_id: $relationships_1.id
                    pass            : false
                  }
                } as $policy_requirements_1
              
                function.run policy_requirement_email {
                  input = {
                    to         : $new_company.id
                    by         : $input.assigned_by
                    certificate: $policy_id_current
                  }
                } as $func_1
              }
            
              else {
                db.add policy_requirements {
                  enforce_hidden_fields = false
                  data = {
                    created_at      : "now"
                    PTN             : $input.ptn
                    my_policies_id  : $item.id
                    assigned_to     : $new_company.id
                    originator      : $input.assigned_by|to_int
                    acknowledged    : true
                    relationships_id: $relationships_1.id
                    pass            : false
                  }
                } as $policy_requirements_1
              
                function.run policy_requirement_email {
                  input = {
                    to         : $new_company.id
                    by         : $input.assigned_by
                    certificate: $policy_id_current
                  }
                } as $func_1
              }
            }
          }
        }
      }
    }
  }

  response = $return
}