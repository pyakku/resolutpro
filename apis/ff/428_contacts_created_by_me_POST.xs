query contacts_created_by_me verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company_id?
  }

  stack {
    db.query contacts {
      where = $db.contacts.created_by == $input.company_id
      sort = {contacts.name: "asc"}
      return = {type: "list"}
    } as $contacts1
  
    db.query contact_relationship {
      where = $db.contact_relationship.company == $input.company_id && $db.contact_relationship.mypersona == true
      return = {type: "list"}
      addon = [
        {
          name : "contacts"
          input: {contacts_id: $output.contact}
          as   : "contact"
        }
      ]
    } as $contact_relationship2
  
    var $mypersona {
      value = []
    }
  
    conditional {
      if ($contact_relationship2|is_empty) {
      }
    
      else {
        foreach ($contact_relationship2) {
          each as $item {
            var.update $mypersona {
              value = $mypersona
                |push:($item.contact
                  |set:"role":$item.role
                  |set:"mypersona":true
                  |set:"approved":$item.approved
                  |set:"relID":$item.id
                )
            }
          }
        }
      }
    }
  
    var $temp {
      value = []
    }
  
    conditional {
      if ($contacts1 != null) {
        foreach ($contacts1) {
          each as $item {
            db.query contact_relationship {
              where = $db.contact_relationship.contact == $item.id && $db.contact_relationship.company == $input.company_id
              return = {type: "list"}
            } as $contact_relationship1
          
            conditional {
              if ($contact_relationship1 != null) {
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"role":($contact_relationship1|first|get:"role":null)
                      |set:"approved":($contact_relationship1|first|get:"approved":null)
                      |set:"mypersona":($contact_relationship1|first|get:"mypersona":null)
                      |set:"relID":($contact_relationship1|first|get:"id":null)
                    )
                }
              }
            
              else {
                var.update $temp {
                  value = $temp
                    |push:($item
                      |set:"role":"Not Assigned"
                      |set:"approved":false
                      |set:"mypersona":false
                      |set:"relID":0
                    )
                }
              }
            }
          }
        }
      }
    }
  
    var.update $contacts1 {
      value = $temp
        |merge:$mypersona
        |sort:"id":"itext":true
    }
  
    var $temp2 {
      value = []
    }
  
    conditional {
      if ($contacts1|is_empty) {
      }
    
      else {
        foreach ($contacts1) {
          each as $item {
            array.find ($mypersona) if ($this == $item) as $x1
            array.find ($temp2) if ($this == $item) as $x2
            conditional {
              if ($x1 == null && $x2 == null) {
                var.update $temp2 {
                  value = $temp2|push:$item
                }
              }
            }
          }
        }
      }
    }
  
    var.update $contacts1 {
      value = $temp2|merge:$mypersona
    }
  }

  response = $contacts1
}