query addDocumentType verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text type? filters=trim
  }

  stack {
    db.add document_types {
      enforce_hidden_fields = false
      data = {created_at: "now", type: $input.type}
    } as $document_types1
  }

  response = $document_types1
}