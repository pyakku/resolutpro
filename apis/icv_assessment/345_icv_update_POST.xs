query icv_update verb=POST {
  api_group = "ICV ASSESSMENT"

  input {
    text company? filters=trim
    json data?
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
        db.add my_assessments {
          enforce_hidden_fields = false
          data = {
            created_at    : "now"
            assessments_id: 9
            companies_id  : $input.company|to_int
            company       : $input.data
          }
        } as $my_assessments_3
      }
    
      else {
        db.edit my_assessments {
          field_name = "id"
          field_value = $my_assessments_1|first|get:"id":null
          enforce_hidden_fields = false
          data = {company: $input.data}
        } as $my_assessments_3
      }
    }
  }

  response = $my_assessments_3.company
}