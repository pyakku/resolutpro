query add_gov_body verb=POST {
  api_group = "reg_program_owner_dash"

  input {
    text name? filters=trim
    text email? filters=trim
    text address? filters=trim
    text code? filters=trim
    text owner? filters=trim
    text member? filters=trim
    text designation? filters=trim
    text phone? filters=trim
  }

  stack {
    db.has certificationBody {
      field_name = "email"
      field_value = $input.email
    } as $governing_body_2
  
    var $response {
      value = "Governing Body associated with this email already exists. Please use a different email."
    }
  
    conditional {
      if ($governing_body_2 == false) {
        db.add certificationBody {
          enforce_hidden_fields = false
          data = {
            created_at       : "now"
            reg_program_owner: $input.owner|to_int
            name             : $input.name
            address          : $input.address
            email            : $input.email
            code             : $input.code
          }
        } as $governing_body_1
      
        db.get regulator {
          field_name = "id"
          field_value = $input.owner
        } as $regulatory_program_owner_1
      
        api.request {
          url = "https://p3audit.com/itracker/gov_body_invite.php"
          method = "POST"
          params = {}
            |set:"f_name":$input.name
            |set:"code":$input.code
            |set:"email":$input.email
            |set:"company":$regulatory_program_owner_1.name
            |set:"l_name":$input.member
          headers = []
            |push:"Content-Type: application/json"
        } as $api_1
      
        var.update $response {
          value = "Governing Body Created Successfully."
        }
      }
    }
  
    db.query certificationBody {
      where = $db.certificationBody.reg_program_owner == $input.owner
      return = {type: "list"}
    } as $governing_bodies
  }

  response = {
    governing_bodies: $governing_bodies
    response        : $var.response
  }
}