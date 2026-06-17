query addCertificationBody verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text name? filters=trim
    text email? filters=trim
    text address? filters=trim
    text contactName? filters=trim
    text designation? filters=trim
    int[] regulators?
    text phone? filters=trim
  }

  stack {
    db.transaction {
      stack {
        db.add certificationBody {
          enforce_hidden_fields = false
          data = {
            created_at : "now"
            name       : $input.name
            address    : $input.address
            email      : $input.email
            member_name: $input.contactName
            designation: $input.designation
            phone      : $input.phone
          }
        } as $certificationBody2
      
        conditional {
          if ($input.regulators|is_empty) {
          }
        
          else {
            foreach ($input.regulators) {
              each as $item {
                db.add certificationBodyDetails {
                  enforce_hidden_fields = false
                  data = {
                    created_at       : "now"
                    certificationBody: $certificationBody2.id
                    regulator        : $item
                  }
                } as $certificationBodyDetails2
              }
            }
          }
        }
      }
    }
  }

  response = $certificationBody2
}