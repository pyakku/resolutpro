query checkSection verb=POST {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
    int auditID?
    int myAssessmentID?
    text comment? filters=trim
    bool accept?
  }

  stack {
    db.get audit {
      field_name = "id"
      field_value = $input.auditID
    } as $audit1
  
    array.find ($audit1.assessmentCheck) if ($this.question == $input.myAssessmentID) as $checkExists
    conditional {
      if ($checkExists|is_empty) {
        db.edit audit {
          field_name = "id"
          field_value = $input.auditID
          enforce_hidden_fields = false
          data = {
            assessmentCheck: $audit1.assessmentCheck|push:({}|set:"question":$input.myAssessmentID|set:"comment":$input.comment|set:"checkedOn":now|set:"accept":$input.accept)
          }
        } as $audit2
      }
    
      else {
        db.edit audit {
          field_name = "id"
          field_value = $input.auditID
          enforce_hidden_fields = false
          data = {
            assessmentCheck: $audit1.assessmentCheck|remove:$input.myAssessmentID:"question":false|push:({}|set:"question":$input.myAssessmentID|set:"comment":$input.comment|set:"checkedOn":now|set:"accept":$input.accept)
          }
        } as $audit2
      }
    }
  }

  response = $audit1
}