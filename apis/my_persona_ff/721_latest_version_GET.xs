query latestVersion verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.query mypersonaVersions {
      sort = {mypersonaVersions.created_at: "desc"}
      return = {type: "single"}
    } as $mypersonaVersions1
  }

  response = {latestVersion: $mypersonaVersions1.version}
}