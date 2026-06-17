query assignAuditor verb=POST {
  api_group = "auditsFF"
  auth = "user"

  input {
    int certificationBody?
    bool newAuditor?
    text auditorName? filters=trim
    text auditorLastName? filters=trim
    text auditorMiddleName? filters=trim
    text auditorEmail? filters=trim
    int auditorCertificationBody?
    text clientName? filters=trim
    text clientPhone? filters=trim
    text clientEmail? filters=trim
    int auditorID?
    bool independent?
    int auditType?
    int company?
    date? date?
    int auditID?
  }

  stack {
    conditional {
      if ($input.newAuditor) {
        db.transaction {
          stack {
            db.add auditor {
              enforce_hidden_fields = false
              data = {
                created_at : "now"
                first_name : $input.auditorName
                middle_name: $input.auditorMiddleName
                last_name  : $input.auditorLastName
                email      : $input.auditorEmail
                independent: $input.independent
                employed   : $input.independent|not
              }
            } as $auditor1
          
            conditional {
              if ($input.auditorCertificationBody|is_empty) {
              }
            
              else {
                db.add auditorDetails {
                  enforce_hidden_fields = false
                  data = {
                    created_at       : "now"
                    auditor          : $auditor1.id
                    certificationBody: $input.certificationBody
                  }
                } as $auditorDetails1
              }
            }
          
            var $auditor_id {
              value = $auditor1.id
            }
          }
        }
      }
    
      else {
        var $auditor_id {
          value = $input.auditorID
        }
      }
    }
  
    !security.create_uuid as $x1
    db.edit audit {
      field_name = "id"
      field_value = $input.auditID
      enforce_hidden_fields = false
      data = {
        auditor_id            : $auditor_id
        desc                  : $input.desc
        due_by                : $input.date
        audit_types_id        : $input.auditType
        gov_body              : $input.certificationBody
        place                 : $input.city
        client_contact        : $input.clientName
        client_contact_contact: $input.clientEmail
        client_contact_phone  : $input.clientPhone
        address1              : $input.address1
        address2              : $input.address2
        sharedDocuments       : $input.documents
      }
    } as $audit2
  
    !db.add audit {
      enforce_hidden_fields = false
      data = {
        created_at            : "now"
        companies_id          : $input.company
        auditor_id            : $auditor_id
        desc                  : $input.desc
        passed                : false
        failed                : false
        due_by                : $input.date
        audit_types_id        : $input.auditType
        gov_body              : $input.certificationBody
        place                 : $input.city
        client_contact        : $input.clientName
        client_contact_contact: $input.clientEmail
        client_contact_phone  : $input.clientPhone
        address1              : $input.address1
        address2              : $input.address2
        sharedDocuments       : $input.documents
        auditIDP3             : $x1
      }
    } as $audit1
  }

  response = $audit2
}