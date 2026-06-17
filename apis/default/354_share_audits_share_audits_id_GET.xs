// Get share_audits record
query "share_audits/{share_audits_id}" verb=GET {
  api_group = "Default"

  input {
    int share_audits_id? filters=min:1
  }

  stack {
    db.get share_audits {
      field_name = "id"
      field_value = $input.share_audits_id
    } as $share_audits
  
    precondition ($share_audits != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $share_audits
}