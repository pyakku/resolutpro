query create_role verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "contact_relationship"
      override = {
        role         : {hidden: false}
        company      : {hidden: false}
        contact      : {hidden: false}
        approved     : {hidden: false}
        created_at   : {hidden: true}
        approval_code: {hidden: true}
      }
    }
  }

  stack {
    security.random_number {
      min = 0
      max = 9007199254740991
    } as $code
  
    db.add contact_relationship {
      enforce_hidden_fields = false
      data = {
        contact      : $input.contact
        company      : $input.company
        role         : $input.role
        approved     : $input.approved
        approval_code: $code
      }
    
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.company}
          as   : "company"
        }
        {
          name : "contacts"
          input: {contacts_id: $output.contact}
          as   : "contact"
        }
      ]
    } as $contact_relationship_1
  
    var $role {
      value = $contact_relationship_1.role
    }
  
    var $company {
      value = $contact_relationship_1.company.Company_Name
    }
  
    var $email {
      value = $contact_relationship_1.contact.email
    }
  
    var $name {
      value = $contact_relationship_1.contact.name
    }
  
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company
      return = {type: "list"}
      addon = [
        {
          name : "contacts"
          input: {contacts_id: $output.contact}
          as   : "contact"
        }
      ]
    } as $contact_relationship_2
  
    api.request {
      url = "https://p3audit.com/itracker/role.php"
      method = "POST"
      params = {}
        |set:"code":$code
        |set:"role":$role
        |set:"company":$company
        |set:"email":$email
        |set:"name":$name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {created_at: "now", response: $api_1}
    } as $email_log_1
  }

  response = $contact_relationship_2
}