function policy_requirement_email {
  input {
    text to? filters=trim
    text by? filters=trim
    text certificate? filters=trim
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.to|to_int
      addon = [
        {
          name  : "user"
          output: ["email"]
          input : {user_id: $output.created_by_user}
        }
      ]
    } as $to
  
    db.get companies {
      field_name = "id"
      field_value = $input.by|to_int
    } as $by
  
    db.get my_policies {
      field_name = "id"
      field_value = $input.certificate|to_int
      addon = [
        {
          name  : "policies"
          output: ["name"]
          input : {policies_id: $output.policies_id}
        }
      ]
    } as $policy
  
    var $to_name {
      value = $to.Company_Name
    }
  
    var $to_email {
      value = $to|get:"email":null
    }
  
    var $by_name {
      value = $by.Company_Name
    }
  
    var $certificate_name {
      value = $policy.name
    }
  
    api.request {
      url = "https://p3audit.com/itracker/mail_certificate_acknowledgement_notification.php"
      method = "POST"
      params = {}
        |set:"to":$to_name
        |set:"by":$by_name
        |set:"email":$to_email
        |set:"certificate":$certificate_name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  }

  response = null
}