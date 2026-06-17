addon countries {
  input {
    int countries_id? {
      table = "countries"
    }
  }

  stack {
    db.query countries {
      where = $db.countries.id == $input.countries_id
      return = {type: "single"}
    }
  }
}