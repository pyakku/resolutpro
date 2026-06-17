// Edit assessmentsV2Sections record
query "assessmentsv2sections/{assessmentsv2sections_id}" verb=PATCH {
  api_group = "ff"

  input {
    int assessmentsv2sections_id? filters=min:1
    dblink {
      table = "assessmentsV2Sections"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch assessmentsV2Sections {
      field_name = "id"
      field_value = $input.assessmentsv2sections_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $assessmentsv2sections
  }

  response = $assessmentsv2sections
}