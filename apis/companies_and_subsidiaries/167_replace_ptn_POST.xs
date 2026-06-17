query replace_ptn verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    dblink {
      table = "relationships"
      override = {
        sla        : {hidden: false}
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
    conditional {
      if ($input.sla == null) {
        db.add relationships {
          enforce_hidden_fields = false
          data = {
            created_at : "now"
            PTN_no     : $input.PTN_no
            approved   : $input.approved
            assigned_to: $input.assigned_to
            assigned_by: $input.assigned_by
            data_owner : $input.data_owner
            functions  : $input.functions
            Country    : $input.Country
            desc       : $input.desc
            terminated : $input.terminated
            replaces   : $input.replaces
          }
        } as $relationships_1
      }
    
      else {
        storage.create_attachment {
          value = $input.sla
          access = "public"
        } as $sla_document
      
        db.add relationships {
          enforce_hidden_fields = false
          data = {
            created_at : "now"
            PTN_no     : $input.PTN_no
            approved   : $input.approved
            assigned_to: $input.assigned_to
            assigned_by: $input.assigned_by
            data_owner : $input.data_owner
            functions  : $input.functions
            Country    : $input.Country
            desc       : $input.desc
            terminated : $input.terminated
            replaces   : $input.replaces
            sla        : $sla_document
          }
        } as $relationships_1
      }
    }
  
    db.query relationships {
      where = $db.relationships.PTN_no == $input.replaces
      return = {type: "list"}
    } as $relationships_2
  
    foreach ($relationships_2) {
      each as $item {
        db.edit relationships {
          field_name = "id"
          field_value = $item.id
          enforce_hidden_fields = false
          data = {terminated: true}
        } as $relationships_3
      }
    }
  }

  response = $relationships_1
}