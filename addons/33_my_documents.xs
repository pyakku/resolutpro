addon myDocuments {
  input {
    int myDocuments_id? {
      table = "myDocuments"
    }
  }

  stack {
    db.query myDocuments {
      where = $db.myDocuments.id == $input.myDocuments_id
      return = {type: "single"}
    }
  }
}