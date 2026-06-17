query get_bbee_rating verb=POST {
  api_group = "BBEEE"

  input {
    text company? filters=trim
  }

  stack {
    db.has bbeee_validation {
      field_name = "company"
      field_value = $input.company
    } as $bbeee_validation_2
  
    conditional {
      if ($bbeee_validation_2) {
        db.get bbeee_validation {
          field_name = "company"
          field_value = $input.company
        } as $bbeee_validation_1
      
        var $return {
          value = $bbeee_validation_1|get:"level":null
        }
      }
    
      else {
        var $return {
          value = "NA"
        }
      }
    }
  }

  response = $return
}