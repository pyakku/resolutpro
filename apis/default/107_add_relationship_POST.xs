query add_relationship verb=POST {
  api_group = "Default"

  input {
    text PTN_no? filters=trim
    bool approved?=false
    int assigned_to?
    int assigned_by?
    int data_owner?
    int Country?
    text desc? filters=trim
    int functions?
    file? sla?
  }

  stack {
    storage.create_attachment {
      value = $input.sla
      access = "public"
    } as $sla
  
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
        sla        : $sla
      }
    } as $relationships_1
  
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
                    PTN             : $input.PTN_no
                    my_policies_id  : $item.id
                    assigned_to     : $input.assigned_to
                    originator      : $input.data_owner
                    acknowledged    : false
                    relationships_id: $relationships_1.id
                    pass            : false
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
                    PTN             : $input.PTN_no
                    my_policies_id  : $item.id
                    assigned_to     : $input.assigned_to
                    originator      : $input.data_owner
                    acknowledged    : true
                    relationships_id: $relationships_1.id
                    pass            : false
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

  response = $relationships_1
}