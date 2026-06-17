addon certificate_types {
  input {
    int certificate_types_id? {
      table = "certificate_types"
    }
  }

  stack {
    db.query certificate_types {
      where = $db.certificate_types.id == $input.certificate_types_id
      return = {type: "single"}
    }
  }
}