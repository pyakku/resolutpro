query update_level verb=POST {
  api_group = "BBEEE"

  input {
    text company? filters=trim
    text certificate? filters=trim
    text level? filters=trim
  }

  stack {
    db.query bbeee_validation {
      where = $db.bbeee_validation.company == $input.company && $db.bbeee_validation.certificate == $input.certificate
      return = {type: "exists"}
    } as $bbeee_validation_1
  
    conditional {
      if ($bbeee_validation_1) {
        db.query bbeee_validation {
          where = $db.bbeee_validation.company == $input.company && $db.bbeee_validation.certificate == $input.certificate
          return = {type: "list"}
        } as $bbeee_validation_2
      
        db.edit bbeee_validation {
          field_name = "id"
          field_value = $bbeee_validation_2|first|get:"id":null
          enforce_hidden_fields = false
          data = {level: $input.level}
        } as $bbeee_validation_3
      }
    
      else {
        db.add bbeee_validation {
          enforce_hidden_fields = false
          data = {
            company    : $input.company|to_int
            level      : $input.level
            certificate: $input.certificate|to_int
          }
        } as $bbeee_validation_4
      }
    }
  
    db.edit required_certificates {
      field_name = "id"
      field_value = $input.certificate
      enforce_hidden_fields = false
      data = {p3_audited: true, validated_on: now}
    } as $required_certificates_2
  
    db.query required_certificates {
      join = {
        bbeee_validation: {
          table: "bbeee_validation"
          type : "left"
          where: $db.required_certificates.id == $db.bbeee_validation.certificate
        }
      }
    
      where = $db.required_certificates.certificates_id == 101 && $db.required_certificates.active == true && $db.required_certificates.document != null
      eval = {level: $db.bbeee_validation.level}
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.companies_id}
          as   : "companies_id"
        }
      ]
    } as $required_certificates_1
  }

  response = $required_certificates_1
}