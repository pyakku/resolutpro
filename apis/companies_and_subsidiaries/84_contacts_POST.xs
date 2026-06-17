// Add contacts record
query contacts verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "contacts"
      override = {
        code        : {hidden: true}
        name        : {hidden: false}
        email       : {hidden: false}
        l_name      : {hidden: false}
        approved    : {hidden: true}
        created_at  : {hidden: true}
        created_by  : {hidden: false}
        phone_number: {hidden: false}
      }
    }
  }

  stack {
    db.has contacts {
      field_name = "email"
      field_value = $input.email
    } as $contacts_1
  
    conditional {
      if ($contacts_1 == false) {
        security.random_number {
          min = 0
          max = 9007199254740991
        } as $code
      
        db.add contacts {
          enforce_hidden_fields = false
          data = {
            created_at  : "now"
            name        : $input.name
            l_name      : $input.l_name
            email       : $input.email
            phone_number: $input.phone_number
            created_by  : $input.created_by
            approved    : false
            code        : $code
          }
        
          addon = [
            {
              name : "companies_01"
              input: {companies_id: $output.created_by}
              as   : "created_by"
            }
          ]
        } as $contacts
      
        var $company {
          value = $contacts.created_by.Company_Name
        }
      
        var $email {
          value = $contacts.email
        }
      
        api.request {
          url = "https://p3audit.com/itracker/add_contact_mail.php"
          method = "POST"
          params = {}
            |set:"code":$code
            |set:"company":$company
            |set:"email":$email
            |set:"name":$input.name
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      
        db.add email_log {
          enforce_hidden_fields = false
          data = {created_at: "now", response: $api_1}
        } as $email_log_1
      }
    }
  }

  response = $contacts_1|not
}