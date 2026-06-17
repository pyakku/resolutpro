query contact_roles_at_my_company verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company_id
      return = {type: "list"}
      addon = [
        {
          name  : "contacts"
          output: ["name", "l_name", "email", "phone_number"]
          input : {contacts_id: $output.contact}
        }
      ]
    } as $contact_relationship1
  
    var $final {
      value = []
    }
  
    foreach ($contact_relationship1) {
      each as $item {
        var.update $final {
          value = $final
            |append:($item
              |set:"full_name":($item.name
                |concat:(" "|concat:$item.l_name:""):""
              )
            ):""
        }
      }
    }
  
    var.update $contact_relationship1 {
      value = $final|sort:"full_name":"itext":true
    }
  }

  response = $contact_relationship1
}