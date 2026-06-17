query getProfileImage verb=GET {
  api_group = "myPersonaFF"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  }

  response = $user1
}