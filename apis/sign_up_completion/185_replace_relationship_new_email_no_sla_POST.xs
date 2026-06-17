query REPLACE_relationship_new_email_no_sla verb=POST {
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
    text replaced_ptn? filters=trim
  }

  stack {
    var $return {
      value = "Error"
    }
  
    db.transaction {
      stack {
        security.random_number {
          min = 100000
          max = 99999999
        } as $random_code
      
        api.request {
          url = "https://thearkkalimpong.com/iTracker/invite_vendor.php?email="
            |concat:($input.email
              |concat:(" &client="
                |concat:($input.assigned_by_name
                  |concat:("&vendor="
                    |concat:($input.company_name
                      |concat:("&code="|concat:$random_code:""):""
                    ):""
                  ):""
                ):""
              ):""
            ):""
          method = "GET"
        } as $api_1
      
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
            company_reg    : "unregistered"
            created_by     : $input.user_id
            Company_Name   : $input.company_name
            functions      : []|push:$input.function_id
            is_sub         : false
            created_by_user: $new_user.id
            country_code   : $input.country_id|to_int
            plan           : 1
          }
        } as $new_company
      
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
            replaces   : $input.replaced_ptn
          }
        } as $relationships_1
      
        db.edit relationships {
          field_name = "PTN_no"
          field_value = $input.replaced_ptn
          enforce_hidden_fields = false
          data = {terminated: true}
        } as $relationships_2
      
        var $return {
          value = "Done"
        }
      }
    }
  }

  response = $return
}