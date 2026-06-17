query delete_contact verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    int contact_id?
  }

  stack {
    db.transaction {
      stack {
        db.query contact_relationship {
          where = $db.contact_relationship.contact == $input.contact_id
          return = {type: "list"}
        } as $contact_relationship_1
      
        foreach ($contact_relationship_1) {
          each as $item {
            db.del contact_relationship {
              field_name = "contact"
              field_value = $input.contact_id
            }
          }
        }
      
        db.del contacts {
          field_name = "id"
          field_value = $input.contact_id
        }
      }
    }
  }

  response = {Status: "Done"}
}