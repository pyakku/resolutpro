task emailLowerCase {
  stack {
    db.query user {
      return = {type: "list"}
    } as $user1
  
    foreach ($user1) {
      each as $item {
        db.edit user {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {email: $item.email|to_lower}
        } as $user2
      }
    }
  }

  schedule = [{starts_on: 2024-10-22 09:49:47+0000, freq: 300}]
}