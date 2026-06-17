query addAuditType verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text type? filters=trim
    int[] documents?
    int body?
  }

  stack {
    db.add audit_types {
      enforce_hidden_fields = false
      data = {
        created_at       : "now"
        type             : $input.type
        regulator        : $input.body
        documentsRequired: $input.documents
      }
    } as $audit_types2
  }

  response = null
}