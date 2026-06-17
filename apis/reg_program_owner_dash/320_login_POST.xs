query login verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text email? filters=trim
    text password? filters=trim
  }

  stack {
    var $status {
      value = "Invalid Credentials...Please try again"
    }
  
    var $governing_bodies {
      value = ""
    }
  
    var $auditors {
      value = ""
    }
  
    db.has regulator {
      field_name = "email"
      field_value = $input.email
    } as $regulatory_program_owner_2
  
    conditional {
      if ($regulatory_program_owner_2) {
        db.get regulator {
          field_name = "email"
          field_value = $input.email
          output = ["id", "created_at", "name", "email", "password"]
        } as $regulatory_program_owner_1
      
        security.check_password {
          text_password = $input.password
          hash_password = $regulatory_program_owner_1.password
        } as $var_1
      
        conditional {
          if ($var_1) {
            var $status {
              value = "done"
            }
          
            db.query certificationBody {
              where = $db.certificationBody.reg_program_owner == $regulatory_program_owner_1.id
              return = {type: "list"}
            } as $governing_bodies
          
            var $governing_body_list {
              value = $governing_bodies|get:"id":null
            }
          
            db.query auditor {
              where = $db.auditor.governing_body overlaps $governing_body_list
              return = {type: "list"}
            } as $auditors
          }
        }
      }
    }
  }

  response = {
    status          : $status
    governing_bodies: $governing_bodies
    auditors        : $auditors
    owner           : $regulatory_program_owner_1
  }
}