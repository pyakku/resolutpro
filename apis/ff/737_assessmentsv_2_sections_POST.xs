// Add assessmentsV2Sections record
query assessmentsv2sections verb=POST {
  api_group = "ff"

  input {
    dblink {
      table = "assessmentsV2Sections"
    }
  }

  stack {
    db.add assessmentsV2Sections {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $assessmentsv2sections
  }

  response = $assessmentsv2sections
}