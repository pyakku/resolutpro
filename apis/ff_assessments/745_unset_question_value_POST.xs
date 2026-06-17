query unsetQuestionValue verb=POST {
  api_group = "ffAssessments"
  auth = "user"

  input {
    int questionID?
    int companyID?
  }

  stack {
    db.query assessmentsV2MyAssessments {
      where = $db.assessmentsV2MyAssessments.question == $input.questionID && $db.assessmentsV2MyAssessments.company == $input.companyID
      return = {type: "single"}
    } as $assessmentsV2MyAssessments1
  
    db.edit assessmentsV2MyAssessments {
      field_name = "id"
      field_value = $assessmentsV2MyAssessments1.id
      enforce_hidden_fields = false
      data = {checked: false}
    } as $assessmentsV2MyAssessments2
  }

  response = $assessmentsV2MyAssessments1
}