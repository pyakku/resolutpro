query setQuestionValue verb=POST {
  api_group = "ffAssessments"
  auth = "user"

  input {
    int questionID?
    int companyID?
  }

  stack {
    db.query assessmentsV2MyAssessments {
      where = $db.assessmentsV2MyAssessments.question == $input.questionID && $db.assessmentsV2MyAssessments.company == $input.companyID
      return = {type: "exists"}
    } as $assessmentsV2MyAssessments1
  
    conditional {
      if ($assessmentsV2MyAssessments1) {
        db.query assessmentsV2MyAssessments {
          where = $db.assessmentsV2MyAssessments.question == $input.questionID && $db.assessmentsV2MyAssessments.company == $input.companyID
          return = {type: "single"}
        } as $assessmentsV2MyAssessments1
      
        db.edit assessmentsV2MyAssessments {
          field_name = "id"
          field_value = $assessmentsV2MyAssessments1.id
          enforce_hidden_fields = false
          data = {checked: true, lastCheckedOn: now}
        } as $assessmentsV2MyAssessments2
      }
    
      else {
        db.add assessmentsV2MyAssessments {
          enforce_hidden_fields = false
          data = {
            created_at   : "now"
            question     : $input.questionID
            checked      : true
            lastCheckedOn: now
            company      : $input.companyID
          }
        } as $assessmentsV2MyAssessments3
      }
    }
  }

  response = $assessmentsV2MyAssessments1
}