query delete_subsidiary verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text id? filters=trim
  }

  stack {
    db.get subsidiary_table {
      field_name = "id"
      field_value = $input.id
      output = [
        "id"
        "created_at"
        "parent_company"
        "subsidiary"
        "approved"
        "rejected"
      ]
    
      addon = [
        {
          name : "companies"
          input: {companies_id: $output.subsidiary}
          as   : "subsidiary"
        }
      ]
    } as $subsidiary_table_2
  
    var $sub_id {
      value = $subsidiary_table_2.subsidiary.id
    }
  
    db.query subsidiary_table {
      where = $db.subsidiary_table.subsidiary == $sub_id
      return = {type: "count"}
    } as $subsidiary_table_3
  
    conditional {
      if ($subsidiary_table_3 == 1) {
        db.del subsidiary_table {
          field_name = "id"
          field_value = $input.id
        }
      
        db.edit companies {
          field_name = "id"
          field_value = $sub_id
          enforce_hidden_fields = false
          data = {is_sub: false}
        } as $companies_1
      }
    
      else {
        db.del subsidiary_table {
          field_name = "id"
          field_value = $input.id
        }
      }
    }
  }

  response = $subsidiary_table_1
}