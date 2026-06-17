query load_assessments verb=POST {
  api_group = "assessments"

  input {
    text id? filters=trim
  }

  stack {
    db.query assessments {
      where = $db.assessments.audit_types_id == $input.id
      sort = {assessments.assessment_name: "asc"}
      return = {type: "list"}
    } as $assessments_1
  }

  response = {assessment_list: $assessments_1}
}