addon assessmentsV2Sections {
  input {
    int assessmentsV2Sections_id? {
      table = "assessmentsV2Sections"
    }
  }

  stack {
    db.query assessmentsV2Sections {
      where = $db.assessmentsV2Sections.id == $input.assessmentsV2Sections_id
      return = {type: "single"}
    }
  }
}