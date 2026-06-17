query get_gov_bodies verb=GET {
  api_group = "gov_body_dash"

  input {
  }

  stack {
    db.query certificationBody {
      return = {type: "list"}
    } as $governing_body_1
  }

  response = $governing_body_1
}