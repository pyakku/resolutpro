query deleteDocumentClassification verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int classification?
  }

  stack {
    db.del documentClassification {
      field_name = "id"
      field_value = $input.classification
    }
  }

  response = $documentClassification1
}