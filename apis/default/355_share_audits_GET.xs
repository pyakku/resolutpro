// Query all share_audits records
query share_audits verb=GET {
  api_group = "Default"

  input {
  }

  stack {
    db.query share_audits {
      return = {type: "list"}
    } as $share_audits
  }

  response = $share_audits
}