query approveEmployee verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int relID?
    text role? filters=trim
  }

  stack {
    db.get contact_relationship {
      field_name = "id"
      field_value = $input.relID
    } as $contact_relationship2
  
    db.get companies {
      field_name = "id"
      field_value = $contact_relationship2.company
      output = ["id", "Company_Name", "created_by_user"]
    } as $companies1
  
    db.get subscriptions {
      field_name = "company"
      field_value = $companies1.id
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
      field_value = $contact_relationship2.contact
    } as $contacts1
  
    db.edit contact_relationship {
      field_name = "id"
      field_value = $input.relID
      enforce_hidden_fields = false
      data = {role: $input.role, approved: true}
    } as $contact_relationship1
  
    api.request {
      url = $env.emailBase
        |concat:"myPersonaEmployerAddedConfirmedByEmployer.php":""
      method = "POST"
      params = {}
        |set:"firstName":$contacts1.name
        |set:"email":$contacts1.email
        |set:"role":$input.role
        |set:"companyName":$companies1.Company_Name
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  }

  response = $contact_relationship1
}