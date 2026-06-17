query documentShareStatusByDocumentForDashboard verb=POST {
  api_group = "myPersonaFF"
  auth = "p3DashboardUser"

  input {
    int myDocument?
  }

  stack {
    db.query myPersonaShare {
      where = $db.myPersonaShare.myDocument == $input.myDocument && $db.myPersonaShare.shareByEmail == false
      sort = {
        myPersonaShare.active    : "desc"
        myPersonaShare.created_at: "desc"
      }
    
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "myDocument"
        "company"
        "stoppedOn"
        "active"
        "approvedByReciepent"
        "name"
        "email"
        "lName"
        "shareLink"
        "shareByEmail"
      ]
    
      addon = [
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.company}
        }
      ]
    } as $myPersonaShare1
  }

  response = $myPersonaShare1
}