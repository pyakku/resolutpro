query get_ptn_details verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    text ptn? filters=trim
  }

  stack {
    db.query relationships {
      where = $db.relationships.PTN_no == $input.ptn
      sort = {relationships.created_at: "asc"}
      return = {type: "list"}
      addon = [
        {
          name : "companies_01"
          input: {companies_id: $output.assigned_to}
          addon: [
            {
              name : "user"
              input: {user_id: $output.created_by_user}
              as   : "created_by_user"
            }
          ]
          as   : "assigned_to"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.assigned_by}
          as   : "assigned_by"
        }
        {
          name : "companies_01"
          input: {companies_id: $output.data_owner}
          as   : "data_owner"
        }
        {
          name : "countries"
          input: {countries_id: $output.Country}
          as   : "Country"
        }
        {
          name : "functions"
          input: {functions_id: $output.functions}
          as   : "functions"
        }
      ]
    } as $relationships_1
  
    var $object {
      value = ""
    }
  
    var $object_return {
      value = []
    }
  
    foreach ($relationships_1) {
      each as $item {
        var $ptn {
          value = $item.PTN_no
        }
      
        var $id {
          value = $item.id
        }
      
        var $assigned_to {
          value = $item.assigned_to.id
        }
      
        db.query kpi {
          where = $db.kpi.relationship == $id && $db.kpi.assigned_to == $db.kpi.assigned_to && $db.kpi.pass == true
          return = {type: "count"}
        } as $validated
      
        db.query kpi {
          where = $db.kpi.relationship == $id && $db.kpi.assigned_to == $db.kpi.assigned_to && $db.kpi.pass == false
          return = {type: "count"}
        } as $unvalidated
      
        db.query policy_requirements {
          where = $db.policy_requirements.assigned_to == $assigned_to && $db.policy_requirements.relationships_id == $id && $db.policy_requirements.pass == true
          return = {type: "count"}
        } as $validated_policies
      
        db.query policy_requirements {
          where = $db.policy_requirements.assigned_to == $assigned_to && $db.policy_requirements.relationships_id == $id && $db.policy_requirements.pass == false
          return = {type: "count"}
        } as $unvalidated_policies
      
        var.update $object {
          value = $object
            |set:"validated":$validated
            |set:"unvalidated":$unvalidated
            |set:"relationship":$item
            |set:"validated_policies":$validated_policies
            |set:"unvalidated_policies":$unvalidated_policies
            |set:"rel_id":$item.id
            |set:"company_id":$item.assigned_to.id
        }
      
        var.update $object_return {
          value = $object_return|push:$object
        }
      }
    }
  }

  response = {
    object_return: $object_return
    relationships: $relationships_1
  }
}