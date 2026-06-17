// Add share_audits record
query share_audits verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "share_audits"
    }
  }

  stack {
    db.add share_audits {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $share_audits
  }

  response = $share_audits
}