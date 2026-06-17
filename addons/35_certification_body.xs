addon certificationBody {
  input {
    int certificationBody_id? {
      table = "certificationBody"
    }
  }

  stack {
    db.query certificationBody {
      where = $db.certificationBody.id == $input.certificationBody_id
      return = {type: "single"}
    }
  }
}