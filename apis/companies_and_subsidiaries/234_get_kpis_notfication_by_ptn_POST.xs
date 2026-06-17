query get_kpis_notfication_by_ptn verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text ptn? filters=trim
  }

  stack {
    db.query kpi {
      where = $db.kpi.ptn == $input.ptn && $db.kpi.ack_required_cert != 0 && $db.kpi.acknowledged == false
      return = {type: "list"}
      addon = [
        {
          name : "relationships"
          input: {relationships_id: $output.relationship}
          as   : "relationship"
        }
      ]
    } as $kpi_1
  }

  response = $kpi_1
}