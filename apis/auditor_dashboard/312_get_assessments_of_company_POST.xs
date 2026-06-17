query get_assessments_of_company verb=POST {
  api_group = "auditor_dashboard"

  input {
    text audit_type? filters=trim
    text company? filters=trim
  }

  stack {
    db.query assessments {
      where = $db.assessments.audit_types_id == $input.audit_type
      return = {type: "list"}
    } as $assessments_1
  
    var $list_of_assessments {
      value = []
    }
  
    foreach ($assessments_1) {
      each as $item {
        var.update $list_of_assessments {
          value = $list_of_assessments|push:$item.id
        }
      }
    }
  
    db.query my_assessments {
      where = $db.my_assessments.companies_id == $input.company && $db.my_assessments.assessments_id in $list_of_assessments
      return = {type: "list"}
      addon = [
        {
          name : "assessments"
          input: {assessments_id: $output.assessments_id}
          addon: [
            {
              name : "audit_types"
              input: {audit_types_id: $output.audit_types_id}
              as   : "audit_type"
            }
          ]
          as   : "assessments_id"
        }
      ]
    } as $my_assessments_1
  }

  response = {
    my_assessments: $my_assessments_1
    assessments   : $assessments_1
  }
}