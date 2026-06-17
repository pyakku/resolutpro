addon governing_body {
  input {
    int governing_body_id? {
      table = "certificationBody"
    }
  }

  stack {
    db.query certificationBody {
      where = $db.certificationBody.id == $input.governing_body_id
      return = {type: "single"}
    }
  }
}