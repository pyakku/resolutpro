addon audit_types {
  input {
    int audit_types_id? {
      table = "audit_types"
    }
  }

  stack {
    db.query audit_types {
      where = $db.audit_types.id == $input.audit_types_id
      return = {type: "single"}
    }
  }
}