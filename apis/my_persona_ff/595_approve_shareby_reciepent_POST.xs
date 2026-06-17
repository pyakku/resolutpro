query approveSharebyReciepent verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    int shareID?
  }

  stack {
    db.edit myPersonaShare {
      field_name = "id"
      field_value = $input.shareID
      enforce_hidden_fields = false
      data = {approvedByReciepent: true}
    } as $myPersonaShare1
  }

  response = $myPersonaShare1
}