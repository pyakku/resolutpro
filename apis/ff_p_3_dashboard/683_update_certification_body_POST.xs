query updateCertificationBody verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int id?
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
        db.edit certificationBody {
          field_name = "id"
          field_value = $input.id
          enforce_hidden_fields = false
          data = {
            name       : $input.name
            address    : $input.address
            email      : $input.email
            member_name: $input.contactName
            designation: $input.designation
            phone      : $input.phone
          }
        } as $certificationBody1
      
        conditional {
          if ($input.regulators|is_empty) {
            db.bulk.delete certificationBodyDetails {
              where = $db.certificationBodyDetails.certificationBody == $input.id
            } as $certificationBodyDetails3
          }
        
          else {
            db.bulk.delete certificationBodyDetails {
              where = $db.certificationBodyDetails.certificationBody == $input.id && $db.certificationBodyDetails.regulator not in $input.regulators
            } as $certificationBodyDetails3
          }
        }
      
        foreach ($input.regulators) {
          each as $item {
            db.query certificationBodyDetails {
              where = $db.certificationBodyDetails.certificationBody == $input.id && $db.certificationBodyDetails.regulator == $item
              return = {type: "exists"}
            } as $certificationBodyDetails1
          
            conditional {
              if ($certificationBodyDetails1) {
              }
            
              else {
                db.add certificationBodyDetails {
                  enforce_hidden_fields = false
                  data = {
                    created_at       : "now"
                    certificationBody: $input.id
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

  response = $certificationBody1
}