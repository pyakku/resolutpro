addon assessmentsV2questions {
  input {
    int assessmentsV2questions_id? {
      table = "assessmentsV2questions"
    }
  }

  stack {
    db.query assessmentsV2questions {
      where = $db.assessmentsV2questions.id == $input.assessmentsV2questions_id
      return = {type: "single"}
    }
  }
}