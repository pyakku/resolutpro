query acknowledge_policy_ack_requirements verb=POST {
  api_group = "policies"

  input {
    text rel? filters=trim
    text id? filters=trim
  }

  stack {
    db.get policy_requirements {
      field_name = "id"
      field_value = $input.id
    } as $policy_requirements_3
  
    var $originator {
      value = $policy_requirements_3.originator
    }
  
    var $assigned_to {
      value = $policy_requirements_3.assigned_to
    }
  
    var $policy_id {
      value = $policy_requirements_3.my_policies_id
    }
  
    db.query policy_requirements {
      where = $db.policy_requirements.originator == $originator && $db.policy_requirements.my_policies_id == $policy_id && $db.policy_requirements.assigned_to == $assigned_to
      return = {type: "list"}
    } as $policy_requirements_4
  
    foreach ($policy_requirements_4) {
      each as $item {
        db.edit policy_requirements {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {acknowledged: true, validation_date: now, pass: true}
        } as $policy_requirements_5
      }
    }
  
    !db.edit policy_requirements {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        acknowledged   : true
        acknowledged_on: now
        validation_date: now
        pass           : true
      }
    } as $policy_requirements_2
  
    db.query policy_requirements {
      where = $db.policy_requirements.relationships_id == $input.rel
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.originator}
          as   : "originator"
        }
        {
          name : "my_policies"
          input: {my_policies_id: $output.my_policies_id}
          addon: [
            {
              name : "policies"
              input: {policies_id: $output.policies_id}
              as   : "policies"
            }
          ]
          as   : "my_policies_id"
        }
      ]
    } as $policy_requirements_1
  }

  response = $policy_requirements_1
}