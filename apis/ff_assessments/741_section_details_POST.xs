query sectionDetails verb=POST {
  api_group = "ffAssessments"
  auth = "user"

  input {
    int company?
    int sectionID?
  }

  stack {
    !db.get companies {
      field_name = "id"
      field_value = $input.company
    } as $companies1
  
    conditional {
      if (($input.sectionID|is_empty) || ($input.company|is_empty)) {
        return {
          value = []
        }
      }
    }
  
    !db.query assessmentsV2 {
      where = $db.assessmentsV2.id == $input.sectionID
      return = {type: "single"}
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
  
    !var $temp {
      value = []
    }
  
    !db.query assessmentsV2 {
      where = $db.assessmentsV2.regulator in $companies1.regulator
      return = {type: "single"}
      addon = [
        {
          name : "regulator"
          input: {regulator_id: $output.regulator}
          as   : "regulator"
        }
      ]
    } as $assessmentsV21
  
    db.get assessmentsV2Sections {
      field_name = "id"
      field_value = $input.sectionID
      addon = [
        {
          name : "assessmentsV2questions"
          input: {assessmentsV2questions_id: $output.$this}
          as   : "questionList"
        }
      ]
    } as $assessmentsV2Sections1
  
    var $tempQuestions {
      value = []
    }
  
    foreach ($assessmentsV2Sections1.questionList) {
      each as $questionList {
        db.query assessmentsV2MyAssessments {
          where = $db.assessmentsV2MyAssessments.question == $questionList.id && $db.assessmentsV2MyAssessments.company == $input.company
          return = {type: "single"}
        } as $assessmentsV2MyAssessments1
      
        conditional {
          if ($assessmentsV2MyAssessments1|is_empty) {
            var.update $tempQuestions {
              value = $tempQuestions
                |push:($questionList
                  |set:"checked":false
                  |set:"lastCheckedOn":null
                )
            }
          }
        
          else {
            var.update $tempQuestions {
              value = $tempQuestions
                |push:($questionList
                  |set:"checked":$assessmentsV2MyAssessments1.checked
                  |set:"lastCheckedOn":$assessmentsV2MyAssessments1.lastCheckedOn
                )
            }
          }
        }
      }
    }
  
    var.update $assessmentsV2Sections1 {
      value = $assessmentsV2Sections1
        |set:"questionList":$tempQuestions
    }
  }

  response = $assessmentsV2Sections1
}