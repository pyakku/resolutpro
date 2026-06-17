query try verb=GET {
  api_group = "drilldowndash"

  input {
  }

  stack {
    db.query relationships {
      return = {type: "list"}
    } as $relationships_1
  
    var.update $relationships_1 {
      value = $relationships_1|unique:"PTN_no"
    }
  }

  response = $relationships_1
}