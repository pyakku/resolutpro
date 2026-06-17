query update_assessment verb=POST {
  api_group = "assessments"

  input {
    text company? filters=trim
    text assessment? filters=trim
    json data?
    text edit? filters=trim
  }

  stack {
    conditional {
      if ($input.edit == 0) {
        db.add my_assessments {
          enforce_hidden_fields = false
          data = {
            created_at    : "now"
            assessments_id: $input.assessment|to_int
            companies_id  : $input.company|to_int
            company       : $input.data
          }
        } as $my_assessments_1
      }
    
      else {
        db.edit my_assessments {
          field_name = "id"
          field_value = $input.edit
          enforce_hidden_fields = false
          data = {company: $input.data}
        } as $my_assessments_2
      }
    }
  }

  response = "Done"
}