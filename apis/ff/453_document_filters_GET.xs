query documentFilters verb=GET {
  api_group = "ff"

  input {
  }

  stack {
    db.query documentClassification {
      sort = {documentClassification.classification: "asc"}
      return = {type: "list"}
      output = ["id", "classification"]
    } as $documentClassification1
  
    var.update $documentClassification1 {
      value = $documentClassification1
        |unshift:({}
          |set:"id":0
          |set:"classification":"All Documents"
        )
    }
  }

  response = $documentClassification1
}