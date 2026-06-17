query terminate_ptn verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text ptn? filters=trim
  }

  stack {
    db.query relationships {
      where = $db.relationships.PTN_no == $input.ptn
      return = {type: "list"}
    } as $relationships_1
  
    foreach ($relationships_1) {
      each as $item {
        db.edit relationships {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {terminated: true}
        } as $relationships_2
      }
    }
  }

  response = {status: "done"}
}