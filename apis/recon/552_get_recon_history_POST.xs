query getReconHistory verb=POST {
  api_group = "Recon"
  auth = "user"

  input {
    int companyID?
  }

  stack {
    db.query DocumentRecon {
      where = $db.DocumentRecon.company == $input.companyID
      sort = {DocumentRecon.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "user"
          output: ["name", "l_name", "email"]
          input : {user_id: $output.user}
        }
      ]
    } as $DocumentRecon1
  }

  response = $DocumentRecon1
}