function invite_email {
  input {
    bool vendor?=false
    text inviting_company? filters=trim
    text code? filters=trim
    dblink {
      table = "invitations"
      override = {
        email               : {hidden: false}
        company             : {hidden: false}
        contact             : {hidden: false}
        accepted            : {hidden: false}
        created_at          : {hidden: false}
        invited_user        : {hidden: false}
        relationship        : {hidden: false}
        inviting_user       : {hidden: false}
        last_email_res      : {hidden: false}
        invited_company     : {hidden: false}
        last_email_sent     : {hidden: false}
        invited_company_name: {hidden: false}
      }
    }
  }

  stack {
    conditional {
      if ($input.vendor) {
        api.request {
          url = "https://p3audit.com/itracker/invite_vendor.php?email="
            |concat:($input.email
              |concat:("&client="
                |concat:($input.inviting_company
                  |concat:("&code="
                    |concat:($input.code
                      |concat:("&vendor="
                        |concat:$input.invited_company_name:""
                      ):""
                    ):""
                  ):""
                ):""
              ):""
            ):""
            |replace:" ":"%20"
          method = "GET"
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      }
    
      else {
        api.request {
          url = "https://p3audit.com/itracker/invite.php?email="
            |concat:($input.email
              |concat:("&client="
                |concat:($input.inviting_company
                  |concat:("&f_name="|concat:$input.contact:""):""
                ):""
              ):""
            ):""
            |replace:" ":"%20"
          method = "GET"
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      }
    }
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = $api_1
}