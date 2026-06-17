query ADD_relationship_No_SLA verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "relationships"
      override = {
        sla        : {hidden: true}
        desc       : {hidden: false}
        PTN_no     : {hidden: false}
        Country    : {hidden: false}
        approved   : {hidden: false}
        replaces   : {hidden: false}
        functions  : {hidden: false}
        created_at : {hidden: true}
        data_owner : {hidden: false}
        terminated : {hidden: false}
        assigned_by: {hidden: false}
        assigned_to: {hidden: false}
      }
    }
  }

  stack {
    db.add relationships {
      enforce_hidden_fields = false
      data = {
        PTN_no     : $input.PTN_no
        approved   : $input.approved
        assigned_to: $input.assigned_to
        assigned_by: $input.assigned_by
        data_owner : $input.data_owner
        functions  : $input.functions
        Country    : $input.Country
        desc       : $input.desc
      }
    } as $model
  
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.data_owner
      return = {type: "count"}
    } as $data_owner_policies
  
    conditional {
      if ($data_owner_policies != 0) {
        db.query my_policies {
          where = $db.my_policies.companies_id == $input.data_owner
          return = {type: "list"}
        } as $my_policies_1
      
        foreach ($my_policies_1) {
          each as $item {
            var $policy_id_current {
              value = $item.policies_id
            }
          
            db.query policy_requirements {
              where = $db.policy_requirements.assigned_to == $input.assigned_to && $db.policy_requirements.my_policies_id == $policy_id_current && $db.policy_requirements.acknowledged == true
              return = {type: "count"}
            } as $policy_requirements_2
          
            conditional {
              if ($policy_requirements_2 == 0) {
                db.add policy_requirements {
                  enforce_hidden_fields = false
                  data = {
                    created_at      : "now"
                    PTN             : $input.PTN_no
                    my_policies_id  : $item.id
                    assigned_to     : $input.assigned_to
                    originator      : $input.data_owner
                    acknowledged    : false
                    relationships_id: $model.id
                  }
                } as $policy_requirements_1
              
                function.run policy_requirement_email {
                  input = {
                    to         : $input.assigned_to
                    by         : $input.data_owner
                    certificate: $policy_id_current
                  }
                } as $func_1
              }
            
              else {
                db.add policy_requirements {
                  enforce_hidden_fields = false
                  data = {
                    created_at      : "now"
                    PTN             : $input.PTN_no
                    my_policies_id  : $item.id
                    assigned_to     : $input.assigned_to
                    originator      : $input.data_owner
                    acknowledged    : true
                    relationships_id: $model.id
                  }
                } as $policy_requirements_1
              
                function.run policy_requirement_email {
                  input = {
                    to         : $input.assigned_to
                    by         : $input.data_owner
                    certificate: $policy_id_current
                  }
                } as $func_1
              }
            }
          }
        }
      }
    }
  }

  response = $model
}