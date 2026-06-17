query add_policy_company verb=POST {
  api_group = "policies"

  input {
    dblink {
      table = "my_policies"
      override = {
        date              : {hidden: false}
        document          : {hidden: true}
        created_at        : {hidden: true}
        global_ack        : {hidden: false}
        policies_id       : {hidden: false}
        companies_id      : {hidden: false}
        validation_date   : {hidden: true}
        validation_comment: {hidden: true}
      }
    }
  
    file? doc?
  }

  stack {
    storage.create_attachment {
      value = $input.doc
      access = "public"
      filename = ""
    } as $var_1
  
    db.add my_policies {
      enforce_hidden_fields = false
      data = {
        created_at  : "now"
        companies_id: $input.companies_id
        policies_id : $input.policies_id
        global_ack  : $input.global_ack
        date        : $input.date
        renewal_date: $input.renewal_date
        document    : $var_1
      }
    
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $input.companies_id}
          as   : "company"
        }
        {
          name : "policies"
          input: {policies_id: $input.policies_id}
          as   : "policy"
        }
      ]
    } as $my_policies_1
  
    db.query my_policies {
      where = $db.my_policies.companies_id == $input.companies_id
      return = {type: "list"}
      addon = [
        {
          name : "policies"
          input: {policies_id: $input.policies_id}
          as   : "policies_id"
        }
      ]
    } as $my_policies_2
  
    db.query relationships {
      where = $db.relationships.data_owner == $input.companies_id && $db.relationships.assigned_to != $input.companies_id
      return = {type: "list"}
    } as $relationships_1
  
    conditional {
      if ($input.global_ack) {
        foreach ($relationships_1) {
          each as $item {
            conditional {
              if ($item.assigned_to == $input.companies_id) {
              }
            
              else {
                var $PTN {
                  value = $item.PTN_no
                }
              
                db.add policy_requirements {
                  enforce_hidden_fields = false
                  data = {
                    PTN             : $PTN
                    my_policies_id  : $my_policies_1.id
                    assigned_to     : $item.assigned_to
                    originator      : $input.companies_id
                    acknowledged    : false
                    relationships_id: $item.id
                    pass            : false
                  }
                } as $policy_requirements_1
              
                function.run policy_requirement_email {
                  input = {
                    to         : $item.assigned_to
                    by         : $input.companies_id
                    certificate: $my_policies_1.id
                  }
                } as $func_1
              }
            }
          }
        }
      }
    
      else {
        db.query relationships {
          where = $db.relationships.assigned_by == $input.companies_id
          return = {type: "list"}
        } as $relationships_1
      
        foreach ($relationships_1) {
          each as $item {
            var $PTN {
              value = $item.PTN_no
            }
          
            db.add policy_requirements {
              enforce_hidden_fields = false
              data = {
                PTN             : $PTN
                my_policies_id  : $my_policies_1.id
                assigned_to     : $item.assigned_to
                originator      : $input.companies_id
                acknowledged    : false
                relationships_id: $item.id
                pass            : false
              }
            } as $policy_requirements_1
          
            function.run policy_requirement_email {
              input = {
                to         : $item.assigned_to
                by         : $input.companies_id
                certificate: $my_policies_1.id
              }
            } as $func_1
          }
        }
      }
    }
  
    api.request {
      url = "https://p3audit.com/itracker/add_policy_notify_p3.php"
      method = "POST"
      params = {}
        |set:"company":$my_policies_1.company.Company_Name
        |set:"date":$input.date
        |set:"policy":$my_policies_1.policy.name
        |set:"expiry":$input.renewal_date
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    db.add email_log {
      enforce_hidden_fields = false
      data = {response: $api_1}
    } as $email_log_1
  }

  response = {my_policies: $my_policies_2}
}