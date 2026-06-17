// Edit share_audits record
query "share_audits/{share_audits_id}" verb=POST {
  api_group = "Default"

  input {
    int share_audits_id? filters=min:1
    dblink {
      table = "share_audits"
    }
  }

  stack {
    db.edit share_audits {
      field_name = "id"
      field_value = $input.share_audits_id
      enforce_hidden_fields = false
      data = {}
    } as $share_audits
  }

  response = $share_audits
}