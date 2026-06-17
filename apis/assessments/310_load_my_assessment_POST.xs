query load_my_assessment verb=POST {
  api_group = "assessments"

  input {
    text company? filters=trim
    text assessment? filters=trim
  }

  stack {
    db.query my_assessments {
      where = $db.my_assessments.companies_id == $input.company && $db.my_assessments.assessments_id == $input.assessment
      return = {type: "list"}
    } as $my_assessments_1
  }

  response = $my_assessments_1
}