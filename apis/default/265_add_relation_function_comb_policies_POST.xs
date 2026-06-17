query add_relation_function_comb_policies verb=POST {
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
    function.run "" {
      input = {relationships__: $input.relationships__}
    } as $func_1
  }

  response = $func_1
}