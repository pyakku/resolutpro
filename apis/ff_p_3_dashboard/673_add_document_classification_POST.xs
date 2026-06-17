query addDocumentClassification verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text classification? filters=trim
  }

  stack {
    db.add documentClassification {
      enforce_hidden_fields = false
      data = {
        created_at    : "now"
        classification: $input.classification
      }
    } as $documentClassification1
  }

  response = $documentClassification1
}