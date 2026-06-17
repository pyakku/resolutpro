query addEmployer verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int contact?
    int company?
    text role? filters=trim
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company
      output = ["Company_Name", "created_by_user"]
    } as $companies1
  
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company
      addon = [
        {
          name  : "user"
          output: ["name", "l_name", "email"]
          input : {user_id: $output.user_id}
          as    : "user"
        }
      ]
    } as $subscriptions1
  
    db.get contacts {
      field_name = "id"
      field_value = $input.contact
    } as $contacts1
  
    db.add contact_relationship {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        contact   : $input.contact
        company   : $input.company
        role      : $input.role
        approved  : false
        mypersona : true
        employer  : true
      }
    } as $contact_relationship1
  
    api.request {
      url = $env.emailBase
        |concat:"myPersonaEmployerAddedToEmployer.php":""
      method = "POST"
      params = {}
        |set:"companyUserName":$subscriptions1.user.name
        |set:"firstName":$contacts1.name
        |set:"lastName":$contacts1.l_name
        |set:"email":$subscriptions1.user.email
        |set:"role":$input.role
        |set:"companyName":$companies1.Company_Name
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