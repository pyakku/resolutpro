addon policies {
  input {
    int policies_id? {
      table = "policies"
    }
  }

  stack {
    db.query policies {
      where = $db.policies.id == $input.policies_id
      return = {type: "single"}
    }
  }
}