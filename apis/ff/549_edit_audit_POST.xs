query editAudit verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int auditID?
    text contact? filters=trim
    text contactDetails? filters=trim
    text place? filters=trim
    int auditType?
    int auditor?
    timestamp? date?
    text client_contact_phone? filters=trim
    text desc? filters=trim
    text address1? filters=trim
    text address2? filters=trim
    text governingBody? filters=trim
  }

  stack {
    db.edit audit {
      field_name = "id"
      field_value = $input.auditID
      enforce_hidden_fields = false
      data = {
        auditor_id            : $input.auditor
        desc                  : $input.desc
        due_by                : $input.date|format_timestamp:"Y-m-d":"UTC"
        audit_types_id        : $input.auditType
        place                 : $input.place
        client_contact        : $input.contact
        client_contact_contact: $input.contactDetails
        client_contact_phone  : $input.client_contact_phone
        address1              : $input.address1
        address2              : $input.address2
        governingBody         : $input.governingBody
      }
    } as $audit1
  }

  response = $audit1
}