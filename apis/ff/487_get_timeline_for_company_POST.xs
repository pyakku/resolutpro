query getTimelineForCompany verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.query timeline {
      where = $db.timeline.company == $input.company
      sort = {timeline.created_at: "desc"}
      return = {type: "list"}
      addon = [
        {
          name  : "user"
          output: ["name", "l_name", "profile_img"]
          input : {user_id: $output.user}
          as    : "user"
        }
      ]
    } as $timeline1
  }

  response = $timeline1
}