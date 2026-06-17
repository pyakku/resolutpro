query isPolicy verb=POST {
  api_group = "Policy Acknowledgement FF"
  auth = "user"

  input {
    int documentID?
  }

  stack {
    db.get documents {
      field_name = "id"
      field_value = $input.documentID
    } as $documents1
  
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

  response = {isPolicy: $policy}
}