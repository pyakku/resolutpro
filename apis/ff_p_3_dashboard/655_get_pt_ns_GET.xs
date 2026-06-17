query getPTNs verb=GET {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
  }

  stack {
    db.query relationships {
      return = {
        type : "aggregate"
        group: {PTN: $db.relationships.PTN_no}
        eval : {
          relationships: $db.relationships.id|to_list
          dataOwner    : $db.relationships.data_owner|to_distinct_list
        }
      }
    } as $relationships1
  
    conditional {
      if (($relationships1|is_empty) == false) {
        var $newVariable {
          value = []
        }
      
        foreach ($relationships1) {
          each as $item {
            var $relationshipNew {
              value = []
            }
          
            foreach ($item.relationships) {
              each as $relID {
                db.get relationships {
                  field_name = "id"
                  field_value = $relID
                  addon = [
                    {
                      name : "companies_01"
                      input: {companies_id: $output.assigned_to}
                      as   : "assignedTo"
                    }
                    {
                      name : "companies_01"
                      input: {companies_id: $output.assigned_by}
                      as   : "assignedBy"
                    }
                    {
                      name : "companies_01"
                      input: {companies_id: $output.data_owner}
                      as   : "dataOwner"
                    }
                    {
                      name  : "functions"
                      output: ["function"]
                      input : {functions_id: $output.functions}
                    }
                    {
                      name : "countries"
                      input: {countries_id: $output.Country}
                      as   : "country"
                    }
                  ]
                } as $relationships2
              
                var.update $relationshipNew {
                  value = $relationshipNew|push:$relationships2
                }
              }
            }
          
            var.update $newVariable {
              value = $newVariable
                |push:("item"
                  |set:"relationships":$relationshipNew
                  |set:"PTN":$item.PTN
                )
            }
          }
        }
      
        var.update $relationships1 {
          value = $newVariable
        }
      }
    }
  
    conditional {
      if (($relationships1|count) != 0) {
        var $temp {
          value = []
        }
      
        foreach ($relationships1) {
          each as $item {
            var.update $temp {
              value = $temp
                |push:($item
                  |set:"count":($item.relationships|count)
                )
            }
          }
        }
      
        var.update $relationships1 {
          value = $temp|reverse
        }
      }
    }
  }

  response = $relationships1
}