query addAuditorProfile verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text first_name? filters=trim
    text middle_name? filters=trim
    text last_name? filters=trim
    text email? filters=trim
    bool independent?
    int[] cb?
  }

  stack {
    db.transaction {
      stack {
        db.add auditor {
          enforce_hidden_fields = false
          data = {
            created_at : "now"
            first_name : $input.first_name
            middle_name: $input.middle_name
            last_name  : $input.last_name
            email      : $input.email
            independent: $input.independent
            employed   : $input.independent|not
          }
        } as $auditor1
      
        conditional {
          if ($input.cb|is_empty) {
          }
        
          else {
            foreach ($input.cb) {
              each as $item {
                db.add auditorDetails {
                  enforce_hidden_fields = false
                  data = {
                    created_at       : "now"
                    auditor          : $auditor1.id
                    certificationBody: $item
                  }
                } as $auditorDetails1
              }
            }
          }
        }
      }
    }
  }

  response = $auditor1
}