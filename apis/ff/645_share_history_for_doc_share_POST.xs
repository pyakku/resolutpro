query shareHistoryForDocShare verb=POST {
  api_group = "ff"

  input {
    text sid? filters=trim
  }

  stack {
    db.get share_audits {
      field_name = "controller"
      field_value = $input.sid
    } as $share_audits1
  
    db.query share_audits {
      where = ($db.share_audits.email|to_lower) == ($share_audits1.email|to_lower) && $db.share_audits.controller != $input.sid
      sort = {share_audits.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name", "created_by_user"]
          input : {companies_id: $output.company}
          addon : [
            {
              name  : "user"
              output: ["name", "l_name", "email"]
              input : {user_id: $output.created_by_user}
              as    : "user"
            }
          ]
          as    : "_companies"
        }
      ]
    } as $share_audits2
  
    db.query share_audits {
      where = $db.share_audits.controller == $input.sid
      sort = {share_audits.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name", "created_by_user"]
          input : {companies_id: $output.company}
          addon : [
            {
              name  : "user"
              output: ["name", "l_name", "email"]
              input : {user_id: $output.created_by_user}
              as    : "user"
            }
          ]
          as    : "_companies"
        }
      ]
    } as $share_audits3
  }

  response = $share_audits3|merge:$share_audits2
}