query delete_role verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text id? filters=trim
    text company_id? filters=trim
  }

  stack {
    db.get contact_relationship {
      field_name = "id"
      field_value = $input.id
      addon = [
        {
          name : "contacts"
          input: {contacts_id: $output.contact}
          as   : "contacts"
        }
      ]
    } as $contact_relationship_3
  
    db.get user {
      field_name = "email"
      field_value = $contact_relationship_3.contacts.email
    } as $user_1
  
    db.query contact_relationship {
      where = $db.contact_relationship.company == $contact_relationship_3.company && $db.contact_relationship.contact == $contact_relationship_3.contact
      return = {type: "count"}
    } as $contact_relationship_4
  
    conditional {
      if ($contact_relationship_4 == 1 && $user_1 != null) {
        !db.get subscriptions {
          field_name = "company"
          field_value = $contact_relationship_3.company
        } as $subscriptions_1
      
        !db.edit subscriptions {
          field_name = "id"
          field_value = "subscriptions_1.id"
          enforce_hidden_fields = false
          data = {
            addon_user: "subscriptions_1.addon_user"|remove:$user_1.id:"":false
          }
        } as $subscriptions_2
      
        db.query subscriptions {
          where = $db.subscriptions.company == $contact_relationship_3.company && $user_1.id in $db.subscriptions.addon_user
          return = {type: "count"}
        } as $subscriptions_1
      
        conditional {
          if ($subscriptions_1 == 0) {
            db.del contact_relationship {
              field_name = "id"
              field_value = $input.id
            }
          
            db.query contact_relationship {
              where = $db.contact_relationship.company == $input.company_id
              return = {type: "list"}
              addon = [
                {
                  name : "contacts"
                  input: {contacts_id: $output.contact}
                  as   : "contact"
                }
              ]
            } as $contact_relationship_2
          }
        
          else {
            var $contact_relationship_2 {
              value = "error"
            }
          }
        }
      }
    
      else {
        db.del contact_relationship {
          field_name = "id"
          field_value = $input.id
        }
      
        db.query contact_relationship {
          where = $db.contact_relationship.company == $input.company_id
          return = {type: "list"}
          addon = [
            {
              name : "contacts"
              input: {contacts_id: $output.contact}
              as   : "contact"
            }
          ]
        } as $contact_relationship_2
      }
    }
  }

  response = $contact_relationship_2
}