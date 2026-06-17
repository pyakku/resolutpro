addon assessments {
  input {
    int assessments_id? {
      table = "assessments"
    }
  }

  stack {
    db.query assessments {
      where = $db.assessments.id == $input.assessments_id
      return = {type: "single"}
    }
  }
}