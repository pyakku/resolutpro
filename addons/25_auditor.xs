addon auditor {
  input {
    int auditor_id? {
      table = "auditor"
    }
  }

  stack {
    db.query auditor {
      where = $db.auditor.id == $input.auditor_id
      return = {type: "single"}
    }
  }
}