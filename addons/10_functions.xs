addon functions {
  input {
    int functions_id? {
      table = "functions"
    }
  }

  stack {
    db.query functions {
      where = $db.functions.id == $input.functions_id
      return = {type: "single"}
    }
  }
}