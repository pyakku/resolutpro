query listAssessmentsOfCompany verb=POST {
  api_group = "ffAssessments"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company
    } as $companies1
  
    !db.query assessmentsV2 {
      where = $db.assessmentsV2.regulator in $companies1.regulator
      return = {type: "list"}
      addon = [
        {
          name : "assessmentsV2Sections"
          input: {assessmentsV2Sections_id: $output.$this}
          addon: [
            {
              name : "assessmentsV2questions"
              input: {assessmentsV2questions_id: $output.$this}
              as   : "questionList"
            }
          ]
          as   : "assessmentSections"
        }
      ]
    } as $assessmentsV21
  
    db.query assessmentsV2 {
      where = $db.assessmentsV2.regulator in $companies1.regulator
      return = {type: "list"}
      addon = [
        {
          name : "regulator"
          input: {regulator_id: $output.regulator}
          as   : "regulator"
        }
      ]
    } as $assessmentsV21
  }

  response = $assessmentsV21
}