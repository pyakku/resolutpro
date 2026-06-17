query getAuditorList verb=GET {
  api_group = "ff"
  auth = "user"

  input {
  }

  stack {
    db.query auditor {
      sort = {auditor.first_name: "asc", auditor.last_name: "asc"}
      eval = {
        first_name: $db.auditor.first_name|concat:"  "|concat:$db.auditor.last_name
      }
    
      return = {type: "list"}
    } as $auditor1
  }

  response = $auditor1
}