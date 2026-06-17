function find_empty_companies {
  input {
  }

  stack {
    var $list_of_cos {
      value = []
    }
  
    var $id {
      value = "item.id"
    }
  
    db.query companies {
      return = {type: "list"}
    } as $companies_1
  
    foreach ($companies_1) {
      each as $item {
        var.update $id {
          value = $item.id
        }
      
        db.query relationships {
          where = $db.relationships.assigned_to == $id || $db.relationships.assigned_by == $id || $db.relationships.data_owner == $id
          return = {type: "list"}
        } as $relationships_1
      
        conditional {
          if (($relationships_1|count) != 0) {
          }
        
          else {
            var.update $list_of_cos {
              value = $list_of_cos|push:$item.Company_Name
            }
          }
        }
      }
    }
  }

  response = $list_of_cos
}