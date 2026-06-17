addon my_policies {
  input {
    int my_policies_id? {
      table = "my_policies"
    }
  }

  stack {
    db.query my_policies {
      where = $db.my_policies.id == $input.my_policies_id
      return = {type: "single"}
    }
  }
}