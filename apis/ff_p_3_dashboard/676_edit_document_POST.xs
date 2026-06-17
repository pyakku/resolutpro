query editDocument verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    dblink {
      table = "documents"
      override = {
        desc                  : {hidden: false}
        logo                  : {hidden: true}
        show                  : {hidden: false}
        addedBy               : {hidden: true}
        details               : {hidden: false}
        approved              : {hidden: true}
        created_at            : {hidden: true}
        documentName          : {hidden: false}
        documentType          : {hidden: false}
        documentClassification: {hidden: false}
      }
    }
  
    int id?
  }

  stack {
    db.edit documents {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        documentName          : $input.documentName
        documentClassification: $input.documentClassification
        documentType          : $input.documentType
        desc                  : $input.desc
        details               : $input.details
        addedBy               : $auth.id
        show                  : $input.show
      }
    } as $documents1
  }

  response = $documents1
}