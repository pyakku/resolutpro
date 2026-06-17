addon kpis_types {
  input {
    int kpis_types_id? {
      table = "kpis_types"
    }
  }

  stack {
    db.query kpis_types {
      where = $db.kpis_types.id == $input.kpis_types_id
      return = {type: "single"}
    }
  }
}