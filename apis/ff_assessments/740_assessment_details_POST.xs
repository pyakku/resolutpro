query assessmentDetails verb=POST {
  api_group = "ffAssessments"
  auth = "user"

  input {
    int company?
    int assessmentID?
  }

  stack {
    !db.get companies {
      field_name = "id"
      field_value = $input.company
    } as $companies1
  
    db.query assessmentsV2 {
      where = $db.assessmentsV2.id == $input.assessmentID
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
  
    var $temp {
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
  
    foreach ($assessmentsV21.assessmentSections) {
      each as $item {
        var $tempQuestions {
          value = []
        }
      
        foreach ($item.questionList) {
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
      
        var.update $temp {
          value = $temp
            |push:($item
              |set:"questionList":$tempQuestions
            )
        }
      }
    }
  
    var.update $assessmentsV21 {
      value = $assessmentsV21|set:"assessmentSections":$temp
    }
  }

  response = $assessmentsV21
}