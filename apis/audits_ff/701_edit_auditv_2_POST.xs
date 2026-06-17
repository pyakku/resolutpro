query editAuditv2 verb=POST {
  api_group = "auditsFF"
  auth = "user"

  input {
    int certificationBody?
    int[] documents?
    text desc? filters=trim
    bool newAuditor?
    text auditorName? filters=trim
    text auditorLastName? filters=trim
    text auditorMiddleName? filters=trim
    text auditorEmail? filters=trim
    int auditorCertificationBody?
    text address1? filters=trim
    text address2? filters=trim
    text city? filters=trim
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
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
    var $auditorPresent {
      value = $audit1.auditor_id|is_empty|not
    }
  
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
    
      addon = [
        {
          name  : "audit_types"
          output: ["type"]
          input : {audit_types_id: $output.audit_types_id}
        }
      ]
    } as $audit2
  
    db.get auditor {
      field_name = "id"
      field_value = $auditor_id
    } as $auditor2
  
    conditional {
      if ($auditorPresent && $audit1.auditor_id == $auditor_id) {
      }
    
      else {
        db.get companies {
          field_name = "id"
          field_value = $input.company
        } as $companies1
      
        !security.create_uuid as $x1
        !db.edit audit {
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
        
          addon = [
            {
              name  : "audit_types"
              output: ["type"]
              input : {audit_types_id: $output.audit_types_id}
            }
          ]
        } as $audit2
      
        api.request {
          url = $env.emailBase
            |concat:"assign_audit_mail.php":""
          method = "POST"
          params = {}
            |set:"f_name":$auditor2.first_name
            |set:"audit_name":$audit2.type
            |set:"audit_start_time":($input.date|format_timestamp:"F jS, Y":"UTC")
            |set:"company_name":$companies1.Company_Name
            |set:"company_address":($input.address1
              |concat:$input.address2:","
              |concat:$input.city:", "
            )
            |set:"contact_first_name":$input.clientName
            |set:"contact_email":$input.clientEmail
            |set:"contact_phone":$input.clientPhone
            |set:"link":$audit2.auditIDP3
            |set:"email":$auditor2.email
          headers = []
            |push:"Content-Type: application/json"
        } as $api1
      }
    }
  
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