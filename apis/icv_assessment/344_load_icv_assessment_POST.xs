query load_icv_assessment verb=POST {
  api_group = "ICV ASSESSMENT"

  input {
    text company? filters=trim
  }

  stack {
    var $assessment {
      value = ""
    }
  
    db.query my_assessments {
      where = $db.my_assessments.assessments_id == 9 && $db.my_assessments.companies_id == $input.company
      return = {type: "list"}
    } as $my_assessments_1
  
    conditional {
      if (($my_assessments_1|count) == 0) {
        db.get assessments {
          field_name = "id"
          field_value = 9
        } as $assessments_1
      
        var.update $assessment {
          value = $assessments_1.sample
        }
      }
    
      else {
        db.query my_assessments {
          where = $db.my_assessments.companies_id == $input.company && $db.my_assessments.assessments_id == 9
          return = {type: "list"}
        } as $my_assessments_2
      
        var.update $assessment {
          value = $my_assessments_2|first|get:"company":null
        }
      }
    }
  }

  response = $assessment
}