query editAuditType verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text type? filters=trim
    int[] documents?
    int audit?
    int body?
  }

  stack {
    db.edit audit_types {
      field_name = "id"
      field_value = $input.audit
      enforce_hidden_fields = false
      data = {
        type             : $input.type
        body             : $input.body
        documentsRequired: $input.documents
      }
    
      addon = [
        {
          name : "documents"
          input: {documents_id: $output.$this}
          as   : "documentsRequired"
        }
      ]
    } as $audit_types1
  }

  response = $audit_types1
}