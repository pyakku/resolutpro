query isPolicyFromName verb=POST {
  api_group = "Policy Acknowledgement FF"
  auth = "user"

  input {
    text docName? filters=trim
  }

  stack {
    db.get documents {
      field_name = "documentName"
      field_value = $input.docName
    } as $documents1
  
    conditional {
      if ($documents1|is_empty) {
        var $policy {
          value = false
        }
      }
    
      else {
        conditional {
          if ($documents1.documentClassification == 2) {
            var $policy {
              value = true
            }
          }
        
          else {
            var $policy {
              value = false
            }
          }
        }
      }
    }
  }

  response = {isPolicy: $policy}
}