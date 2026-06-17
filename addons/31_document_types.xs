addon document_types {
  input {
    int document_types_id? {
      table = "document_types"
    }
  }

  stack {
    db.query document_types {
      where = $db.document_types.id == $input.document_types_id
      return = {type: "single"}
    }
  }
}