query addRelationship verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int assignedBy?
    int assignedTo?
    int dataOwner?
    int function?
    int country?
    text desc? filters=trim
    file? sla?
    text ptn? filters=trim
  }

  stack {
    db.add relationships {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        PTN_no     : $input.ptn
        assigned_to: $input.assignedTo
        assigned_by: $input.assignedBy
        data_owner : $input.dataOwner
        functions  : $input.function
        Country    : $input.country
        desc       : $input.desc
      }
    } as $relationships1
  
    conditional {
      if ($input.sla|is_empty) {
      }
    
      else {
        storage.create_attachment {
          value = $input.sla
          access = "public"
          filename = ""
        } as $x1
      
        db.edit relationships {
          field_name = "id"
          field_value = $relationships1.id
          enforce_hidden_fields = false
          data = {sla: $x1}
        } as $relationships2
      }
    }
  }

  response = $relationships1
}