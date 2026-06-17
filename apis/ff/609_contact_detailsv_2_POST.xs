query contactDetailsv2 verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
    int contact?
    int role?
  }

  stack {
    conditional {
      if ($input.role == 0) {
        db.get contacts {
          field_name = "id"
          field_value = $input.contact
        } as $contact_relationship1
      
        var.update $contact_relationship1 {
          value = $contact_relationship1
            |set:"contact":$contact_relationship1.id
            |set:"relID":0
            |set:"mypersona":false
            |set:"role":"Not Set"
            |set:"employer":false
        }
      }
    
      else {
        db.query contact_relationship {
          where = $db.contact_relationship.id == $input.role
          return = {type: "single"}
          addon = [
            {
              name  : "contacts"
              output: ["name", "l_name", "email", "phone_number", "created_by"]
              input : {contacts_id: $output.contact}
            }
          ]
        } as $contact_relationship1
      
        var.update $contact_relationship1 {
          value = $contact_relationship1
            |set:"relID":$contact_relationship1.id
            |set:"mypersona":$contact_relationship1.mypersona
            |set:"employer":$contact_relationship1.employer
        }
      }
    }
  
    var.update $contact_relationship1 {
      value = $contact_relationship1
        |set:"owner":($contact_relationship1.created_by|equals:$input.company)
    }
  }

  response = $contact_relationship1
}