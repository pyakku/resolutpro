// Query all assessmentsV2Sections records
query assessmentsv2sections verb=GET {
  api_group = "ff"

  input {
  }

  stack {
    db.query assessmentsV2Sections {
      return = {type: "list"}
    } as $assessmentsv2sections
  }

  response = $assessmentsv2sections
}