query assessmentDetailsHomePage verb=POST {
  api_group = "ffAssessments"
  auth = "user"

  input {
    int companyID?
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.companyID
    } as $companies1
  
    db.query assessmentsV2 {
      where = $db.assessmentsV2.regulator in $companies1.regulator
      return = {type: "list"}
    } as $assessmentsV21
  
    conditional {
      if ($assessmentsV21|is_empty) {
      }
    
      else {
        foreach ($assessmentsV21) {
          each as $item {
            conditional {
              if ($item.assessmentSections|is_empty) {
                var.update $item.doneCount {
                  value = 0
                }
              
                var.update $item.totalCount {
                  value = 0
                }
              }
            
              else {
                var $doneCount {
                  value = 0
                }
              
                var $totalCount {
                  value = 0
                }
              
                foreach ($item.assessmentSections) {
                  each as $section {
                    db.query assessmentsV2Sections {
                      where = $db.assessmentsV2Sections.id == $section
                      return = {type: "list"}
                    } as $assessmentsV2Sections1
                  
                    conditional {
                      if ($assessmentsV2Sections1.questionList|is_empty) {
                      }
                    
                      else {
                        var.update $totalCount {
                          value = $totalCount
                            |add:($assessmentsV2Sections1.questionList|count)
                        }
                      
                        foreach ($assessmentsV2Sections1.questionList) {
                          each as $question {
                            db.query assessmentsV2MyAssessments {
                              where = $db.assessmentsV2MyAssessments.question == $question && $db.assessmentsV2MyAssessments.checked == true && $db.assessmentsV2MyAssessments.company == $input.companyID
                              return = {type: "exists"}
                            } as $exists
                          
                            conditional {
                              if ($exists) {
                                var.update $doneCount {
                                  value = $doneCount|add:1
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  
                    var.update $item.doneCount {
                      value = $doneCount
                    }
                  
                    var.update $item.totalCount {
                      value = $totalCount
                    }
                  
                    var.update $item.percentage {
                      value = (($var.doneCount/$var.totalCount)*100)|ceil
                    }
                  
                    var.update $item.progress {
                      value = ($var.doneCount/$var.totalCount)|round:1
                    }
                  }
                }
              }
            }
          }
        }
      
        array.filter ($assessmentsV21) if ($this.totalCount != 0) as $assessmentsV21
      }
    }
  }

  response = $assessmentsV21
}