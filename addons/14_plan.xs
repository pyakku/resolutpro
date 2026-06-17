addon plan {
  input {
    int plan_id? {
      table = "plan"
    }
  }

  stack {
    db.query plan {
      where = $db.plan.id == $input.plan_id
      return = {type: "single"}
    }
  }
}