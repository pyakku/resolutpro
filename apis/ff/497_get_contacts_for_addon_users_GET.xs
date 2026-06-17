query getContactsForAddonUsers verb=GET {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company && $db.contact_relationship.approved == true
      return = {type: "list"}
      addon = [
        {
          name  : "contacts"
          output: ["name", "l_name", "email"]
          input : {contacts_id: $output.contact}
        }
      ]
    } as $contact_relationship1
  
    var.update $contact_relationship1 {
      value = $contact_relationship1|unique:"contact"
    }
  
    db.get subscriptions {
      field_name = "company"
      field_value = $input.company
      addon = [
        {
          name : "user"
          input: {user_id: $output.$this}
          as   : "addon_user"
        }
        {
          name : "user"
          input: {user_id: $output.user_id}
          as   : "user"
        }
      ]
    } as $subscriptions1
  
    var $owner {
      value = $subscriptions1.user
    }
  
    var.update $owner {
      value = $owner.email
    }
  
    var.update $owner {
      value = $owner|to_lower
    }
  
    var $addons {
      value = $subscriptions1.addon_user
    }
  
    conditional {
      if ($addons|is_empty) {
      }
    
      else {
        var.update $addons {
          value = $addons.email|to_lower
        }
      
        var $addonTemp {
          value = []
        }
      
        foreach ($addons) {
          each as $addon {
            var.update $addonTemp {
              value = $addonTemp|push:($addon|to_lower)
            }
          }
        }
      
        var.update $addons {
          value = $addonTemp
        }
      }
    }
  
    var $temp {
      value = []
    }
  
    foreach ($contact_relationship1) {
      each as $item {
        conditional {
          if (($item.email|to_lower|in:$addons) == false && $item.email != $owner) {
            var.update $temp {
              value = $temp
                |push:($item
                  |set:"label":($item.name
                    |concat:(" "
                      |concat:($item.l_name
                        |concat:(" - "|concat:$item.role:""):""
                      ):""
                    ):""
                  )
                )
            }
          }
        }
      }
    }
  
    var.update $contact_relationship1 {
      value = $temp
    }
  }

  response = $contact_relationship1
}