addon documentClassification {
  input {
    int documentClassification_id? {
      table = "documentClassification"
    }
  }

  stack {
    db.query documentClassification {
      where = $db.documentClassification.id == $input.documentClassification_id
      return = {type: "single"}
    }
  }
}