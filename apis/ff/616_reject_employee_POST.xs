query rejectEmployee verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int relID?
  }

  stack {
    db.get contact_relationship {
      field_name = "id"
      field_value = $input.relID
    } as $contact_relationship1
  
    db.query contact_relationship {
      where = $db.contact_relationship.company == $contact_relationship1.company && $db.contact_relationship.contact == $contact_relationship1.contact
      return = {type: "list"}
    } as $contact_relationship2
  
    conditional {
      if (($contact_relationship2|count) > 1) {
      }
    
      else {
        db.query myDocuments {
          where = $db.myDocuments.holderContact == $contact_relationship1.contact && $db.myDocuments.myPersona == true
          return = {type: "list"}
        } as $myDocuments1
      
        conditional {
          if ($myDocuments1|is_empty) {
          }
        
          else {
            var.update $myDocuments1 {
              value = $myDocuments1.id
            }
          
            !db.query myPersonaShare {
              where = $db.myPersonaShare.myDocument in $myDocuments1 && $db.myPersonaShare.company == $contact_relationship1.company
              return = {type: "list"}
            } as $myPersonaShare1
          
            db.bulk.delete myPersonaShare {
              where = $db.myPersonaShare.myDocument in $myDocuments1 && $db.myPersonaShare.company == $contact_relationship1.company
            } as $myPersonaShare2
          }
        }
      }
    }
  
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
  
    api.request {
      url = $env.emailBase
        |concat:"myPersonaEmployerAddedRejectedByEmployer.php":""
      method = "POST"
      params = {}
        |set:"firstName":$contacts1.name
        |set:"email":$contacts1.email
        |set:"role":$contact_relationship2.role
        |set:"companyName":$companies1.Company_Name
      headers = []
        |push:"Content-Type: application/json"
    } as $api1
  
    db.del contact_relationship {
      field_name = "id"
      field_value = $input.relID
    }
  }

  response = "Done"
}