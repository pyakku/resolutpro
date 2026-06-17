query get_kpis_notfication_homepage verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text company_id? filters=trim
  }

  stack {
    db.query kpi {
      where = $db.kpi.assigned_to == $input.company_id && $db.kpi.ack_required_cert != 0 && $db.kpi.acknowledged == false
      return = {type: "list"}
    } as $kpi_1
  
    db.query policy_requirements {
      where = $db.policy_requirements.assigned_to == $input.company_id && $db.policy_requirements.acknowledged == false
      return = {type: "list"}
      addon = [
        {
          name  : "my_policies"
          output: ["policies_id"]
          input : {my_policies_id: $output.my_policies_id}
          addon : [
            {
              name  : "policies"
              output: ["name"]
              input : {policies_id: $output.policies_id}
            }
          ]
        }
        {
          name  : "companies_01"
          output: ["Company_Name"]
          input : {companies_id: $output.originator}
        }
      ]
    } as $policy_requirements_1
  }

  response = {kpis: $kpi_1, policies: $policy_requirements_1}
}