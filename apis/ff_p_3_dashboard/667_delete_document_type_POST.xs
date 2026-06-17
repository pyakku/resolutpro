query deleteDocumentType verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    int type?
  }

  stack {
    db.del document_types {
      field_name = "id"
      field_value = $input.type
    }
  }

  response = $document_types1
}