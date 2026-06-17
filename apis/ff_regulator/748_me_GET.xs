query me verb=GET {
  api_group = "FFRegulator"
  auth = "regulator"

  input {
  }

  stack {
    db.get regulator {
      field_name = "id"
      field_value = $auth.id
    } as $regulator1
  }

  response = $regulator1
}