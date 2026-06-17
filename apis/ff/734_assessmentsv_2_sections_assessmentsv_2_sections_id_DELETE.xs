// Delete assessmentsV2Sections record.
query "assessmentsv2sections/{assessmentsv2sections_id}" verb=DELETE {
  api_group = "ff"

  input {
    int assessmentsv2sections_id? filters=min:1
  }

  stack {
    db.del assessmentsV2Sections {
      field_name = "id"
      field_value = $input.assessmentsv2sections_id
    }
  }

  response = null
}