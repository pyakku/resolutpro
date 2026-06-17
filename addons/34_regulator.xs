addon regulator {
  input {
    int regulator_id? {
      table = "regulator"
    }
  }

  stack {
    db.query regulator {
      where = $db.regulator.id == $input.regulator_id
      return = {type: "single"}
    }
  }
}