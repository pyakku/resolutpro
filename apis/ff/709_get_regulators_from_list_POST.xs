query getRegulatorsFromList verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int[] regulator?
  }

  stack {
    db.query regulator {
      where = $db.regulator.id in $input.regulator
      return = {type: "list"}
    } as $regulator1
  }

  response = $regulator1
}