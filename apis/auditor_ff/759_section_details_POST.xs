query sectionDetails verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int company?
    int sectionID?
    int auditID?
  }

  stack {
    conditional {
      if (($input.sectionID|is_empty) || ($input.company|is_empty)) {
        return {
          value = []
        }
      }
    }
  
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
  
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
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
                  |set:"checkedByAuditor":false
                  |set:"comment":null
                  |set:"checkedByAuditorOn":null
                  |set:"acceptedByAuditor":false
                )
            }
          }
        
          else {
            array.find ($audit1.assessmentCheck) if ($this.question == $assessmentsV2MyAssessments1.question) as $assessmentCheckDetails
            conditional {
              if ($assessmentCheckDetails|is_empty) {
                var.update $tempQuestions {
                  value = $tempQuestions
                    |push:($questionList
                      |set:"checked":$assessmentsV2MyAssessments1.checked
                      |set:"lastCheckedOn":$assessmentsV2MyAssessments1.lastCheckedOn
                      |set:"checkedByAuditor":false
                      |set:"comment":null
                      |set:"checkedByAuditorOn":null
                      |set:"acceptedByAuditor":false
                    )
                }
              }
            
              else {
                var.update $tempQuestions {
                  value = $tempQuestions
                    |push:($questionList
                      |set:"checked":$assessmentsV2MyAssessments1.checked
                      |set:"lastCheckedOn":$assessmentsV2MyAssessments1.lastCheckedOn
                      |set:"checkedByAuditor":true
                      |set:"comment":$assessmentCheckDetails.comment
                      |set:"checkedByAuditorOn":$assessmentCheckDetails.checkedOn
                      |set:"acceptedByAuditor":$assessmentCheckDetails.accept
                    )
                }
              }
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