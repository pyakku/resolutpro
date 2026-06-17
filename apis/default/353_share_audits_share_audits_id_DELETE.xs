// Delete share_audits record.
query "share_audits/{share_audits_id}" verb=DELETE {
  api_group = "Default"

  input {
    int share_audits_id? filters=min:1
  }

  stack {
    db.del share_audits {
      field_name = "id"
      field_value = $input.share_audits_id
    }
  }

  response = null
}