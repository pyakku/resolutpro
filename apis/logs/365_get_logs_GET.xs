query get_logs verb=GET {
  api_group = "logs"

  input {
  }

  stack {
    db.query logs {
      sort = {logs.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.companies_id}
        }
        {
          name  : "user"
          output: ["name", "l_name", "email"]
          input : {user_id: $output.user_id}
        }
      ]
    } as $logs_1
  }

  response = $logs_1
}