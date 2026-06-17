query getClassificationList verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query documentClassification {
      sort = {documentClassification.classification: "asc"}
      return = {type: "list"}
    } as $documentClassification1
  }

  response = $documentClassification1
}