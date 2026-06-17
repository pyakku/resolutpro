addon kpi {
  input {
    int kpi_id? {
      table = "kpi"
    }
  }

  stack {
    db.query kpi {
      where = $db.kpi.id == $input.kpi_id
      return = {type: "single"}
    }
  }
}