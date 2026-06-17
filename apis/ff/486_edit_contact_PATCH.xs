query editContact verb=PATCH {
  api_group = "ff"
  auth = "user"

  input {
    int contact?
    text firstName? filters=trim
    text lastName? filters=trim
    text role? filters=trim
    text email? filters=trim
    text phone? filters=trim
    int company?
  }

  stack {
    db.edit contacts {
      field_name = "id"
      field_value = $input.contact
      enforce_hidden_fields = false
      data = {
        name        : $input.firstName
        l_name      : $input.lastName
        email       : $input.email
        phone_number: $input.phone
      }
    } as $contacts1
  
    db.get companies {
      field_name = "id"
      field_value = $input.company
    } as $companies1
  
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company && $db.contact_relationship.contact == $input.contact
      return = {type: "list"}
    } as $contact_relationship2
  
    security.random_number {
      min = 0
      max = 9007199254740991
    } as $code
  
    conditional {
      if ($contact_relationship2|is_empty) {
        db.add contact_relationship {
          enforce_hidden_fields = false
          data = {
            created_at   : "now"
            contact      : $input.contact
            company      : $input.company
            role         : $input.role
            approved     : false
            approval_code: $code
          }
        } as $contact_relationship1
      }
    
      else {
        db.edit contact_relationship {
          field_name = "id"
          field_value = $contact_relationship2|first|get:"id":null
          enforce_hidden_fields = false
          data = {
            role         : $input.role
            approved     : false
            approval_code: $code
          }
        } as $contact_relationship1
      }
    }
  
    api.request {
      url = $env.emailBase|concat:"role.php":""
      method = "POST"
      params = {}
        |set:"code":$code
        |set:"role":$input.role
        |set:"company":$companies1.Company_Name
        |set:"email":$input.email
        |set:"name":$input.firstName
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api1}
    } as $email_log1
  }

  response = $contact_relationship1
}