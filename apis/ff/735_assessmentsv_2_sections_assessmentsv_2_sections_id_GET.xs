// Get assessmentsV2Sections record
query "assessmentsv2sections/{assessmentsv2sections_id}" verb=GET {
  api_group = "ff"

  input {
    int assessmentsv2sections_id? filters=min:1
  }

  stack {
    db.get assessmentsV2Sections {
      field_name = "id"
      field_value = $input.assessmentsv2sections_id
    } as $assessmentsv2sections
  
    precondition ($assessmentsv2sections != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $assessmentsv2sections
}