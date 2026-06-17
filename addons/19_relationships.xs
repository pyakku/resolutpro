addon relationships {
  input {
    int relationships_id? {
      table = "relationships"
    }
  }

  stack {
    db.query relationships {
      where = $db.relationships.id == $input.relationships_id
      return = {type: "single"}
    }
  }
}