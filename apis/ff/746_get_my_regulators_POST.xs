query getMyRegulators verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company
      addon = [
        {
          name : "regulator"
          input: {regulator_id: $output.$this}
          as   : "regulator"
        }
      ]
    } as $companies1
  }

  response = $companies1.regulator
}