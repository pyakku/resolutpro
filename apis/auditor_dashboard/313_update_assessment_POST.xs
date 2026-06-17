query update_assessment verb=POST {
  api_group = "auditor_dashboard"

  input {
    text id? filters=trim
    text auditor? filters=trim
    json data?
  }

  stack {
    db.edit my_assessments {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {auditor_id: $input.auditor|to_int, auditor: $input.data}
    } as $my_assessments_1
  }

  response = $my_assessments_1
}