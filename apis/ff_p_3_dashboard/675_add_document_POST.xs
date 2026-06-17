query addDocument verb=POST {
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
  }

  stack {
    db.add documents {
      enforce_hidden_fields = false
      data = {
        created_at            : "now"
        documentName          : $input.documentName
        documentClassification: $input.documentClassification
        documentType          : $input.documentType
        desc                  : $input.desc
        details               : $input.details
        approved              : true
        addedBy               : $auth.id
        show                  : $input.show
      }
    } as $documents1
  }

  response = $documents1
}