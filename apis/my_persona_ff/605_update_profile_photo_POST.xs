query updateProfilePhoto verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    text profileImage? filters=trim
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      enforce_hidden_fields = false
      data = {profile_img: $input.profileImage}
    } as $user1
  }

  response = {done: "done"}
}