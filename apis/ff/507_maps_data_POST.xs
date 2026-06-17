query mapsData verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int company?
    int filter?
  }

  stack {
    var $processes {
      value = []
    }
  
    conditional {
      if ($input.filter == 0) {
        db.query relationships {
          where = $db.relationships.assigned_to == $input.company || $db.relationships.assigned_by == $input.company || $db.relationships.data_owner == $input.company
          return = {
            type : "aggregate"
            group: {relationships_Country: $db.relationships.Country}
            eval : {
              assignedTo: $db.relationships.assigned_to|count
              assignedBy: $db.relationships.assigned_by|count
              dataOwner : $db.relationships.data_owner|count
            }
          }
        
          addon = [
            {
              name  : "countries"
              output: ["Name"]
              input : {countries_id: $output.relationships_Country}
            }
          ]
        } as $relationships1
      }
    }
  
    conditional {
      if ($input.filter == 1) {
        db.query relationships {
          where = $db.relationships.data_owner == $input.company
          return = {
            type : "aggregate"
            group: {relationships_Country: $db.relationships.Country}
            eval : {
              assignedTo: $db.relationships.assigned_to|count
              assignedBy: $db.relationships.assigned_by|count
              dataOwner : $db.relationships.data_owner|count
            }
          }
        
          addon = [
            {
              name  : "countries"
              output: ["Name"]
              input : {countries_id: $output.relationships_Country}
            }
          ]
        } as $relationships1
      }
    }
  
    conditional {
      if ($input.filter == 2) {
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company
          return = {
            type : "aggregate"
            group: {relationships_Country: $db.relationships.Country}
            eval : {
              assignedTo: $db.relationships.assigned_to|count
              assignedBy: $db.relationships.assigned_by|count
              dataOwner : $db.relationships.data_owner|count
            }
          }
        
          addon = [
            {
              name  : "countries"
              output: ["Name"]
              input : {countries_id: $output.relationships_Country}
            }
          ]
        } as $relationships1
      }
    }
  
    conditional {
      if ($input.filter == 3) {
        db.query relationships {
          where = $db.relationships.assigned_to == $input.company
          return = {
            type : "aggregate"
            group: {relationships_Country: $db.relationships.Country}
            eval : {
              assignedTo: $db.relationships.assigned_to|count
              assignedBy: $db.relationships.assigned_by|count
              dataOwner : $db.relationships.data_owner|count
            }
          }
        
          addon = [
            {
              name  : "countries"
              output: ["Name"]
              input : {countries_id: $output.relationships_Country}
            }
          ]
        } as $relationships1
      }
    }
  
    !var $data {
      value = []
        |push:({}
          |set:"countryname":"India"
          |set:"valueRep":55000
        )
        |push:({}
          |set:"countryname":"China"
          |set:"valueRep":1000
        )
    }
  
    var.update $processes {
      value = $relationships1
    }
  
    conditional {
      if (($processes|is_empty) == false) {
        var $newItem {
          value = []
        }
      
        foreach ($processes) {
          each as $item {
            var $temp {
              value = ""
            }
          
            var.update $temp {
              value = {}
                |set:"countryname":$item.Name
                |set:"valueRep":$item.assignedTo
            }
          
            var.update $newItem {
              value = $newItem|push:$temp
            }
          }
        }
      
        var.update $processes {
          value = $newItem
        }
      }
    }
  }

  response = $processes
}