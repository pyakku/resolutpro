query shareDocPriorCheck verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int document?
    text email? filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.get myDocuments {
      field_name = "id"
      field_value = $input.document
    } as $myDocuments1
  
    security.create_secret_key {
      bits = 256
      format = "base64"
    } as $crypto1
  
    db.query share_audits {
      where = $input.document in $db.share_audits.documents && $db.share_audits.email == ($input.email|to_lower) && $db.share_audits.myPersona == true && $db.share_audits.company == $db.share_audits.company
      return = {type: "exists"}
    } as $exists
  
    !api.request {
      url = "https://itrackersignup.p3audit.com/emailAPIs/myPersonaShareDocEmailToSender.php"
      method = "POST"
      params = {}
        |set:"documentName":$myDocuments1.nameUA
        |set:"reciever":($input.fname|concat:$input.lname:" ")
        |set:"recieverEmail":$input.email
        |set:"email":$user1.email
        |set:"firstName":$user1.name
      headers = []
        |push:"Content-Type: application/json"
    } as $api2
  }

  response = {canShare: $exists|not}
}