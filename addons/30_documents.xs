addon documents {
  input {
    int documents_id? {
      table = "documents"
    }
  }

  stack {
    db.query documents {
      where = $db.documents.id == $input.documents_id
      return = {type: "single"}
    }
  }
}