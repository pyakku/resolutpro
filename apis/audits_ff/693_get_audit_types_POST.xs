query getAuditTypes verb=POST {
  api_group = "auditsFF"
  auth = "user"

  input {
    int company?
  }

  stack {
    db.get companies {
      field_name = "id"
      field_value = $input.company
    } as $companies1
  
    conditional {
      if ($companies1|is_empty) {
        db.query audit_types {
          where = $db.audit_types.id in? [4,18]
          sort = {audit_types.type: "asc"}
          return = {type: "list"}
        } as $audit_types1
      }
    
      else {
        db.query audit_types {
          where = $db.audit_types.regulator in? $companies1.regulator || $db.audit_types.id in? [4,18]
          sort = {audit_types.type: "asc"}
          return = {type: "list"}
        } as $audit_types1
      }
    }
  }

  response = $audit_types1
}