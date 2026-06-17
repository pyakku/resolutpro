query dashboard_supplier_sbom verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    text company? filters=trim
  }

  stack {
    // Details for My Suppliers Line on the Dashboard
    group {
      stack {
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company || $db.relationships.data_owner == $input.company
          return = {type: "list", distinct: "yes"}
          output = ["assigned_to"]
        } as $my_suppliers
      
        conditional {
          if (($my_suppliers|count) == 0) {
            var.update $my_suppliers {
              value = []
            }
          }
        
          else {
            var.update $my_suppliers {
              value = $my_suppliers.assigned_to
            }
          
            var.update $my_suppliers {
              value = $my_suppliers|unique:""
            }
          }
        }
      
        var $my_suppliers_red {
          value = 0
        }
      
        var $my_suppliers_yellow {
          value = 0
        }
      
        var $my_suppliers_green {
          value = 0
        }
      
        var $my_suppliers_orange {
          value = 0
        }
      
        var $percentile {
          value = 0
        }
      
        foreach ($my_suppliers) {
          each as $my_company {
            db.query required_certificates {
              where = $db.required_certificates.companies_id == $my_company
              return = {type: "count"}
            } as $total_certificates_required
          
            db.query required_certificates {
              where = $db.required_certificates.companies_id == $my_company && $db.required_certificates.document != null
              return = {type: "count"}
            } as $total_certificates_uploaded
          
            conditional {
              if ($total_certificates_required == 0) {
                var.update $my_suppliers_green {
                  value = $my_suppliers_green|add:1
                }
              }
            
              else {
                var.update $percentile {
                  value = $total_certificates_uploaded
                    |divide:$total_certificates_required
                    |multiply:100
                }
              
                conditional {
                  if ($percentile < 25) {
                    var.update $my_suppliers_red {
                      value = $my_suppliers_red|add:1
                    }
                  }
                }
              
                conditional {
                  if ($percentile >= 25 && $percentile < 50) {
                    var.update $my_suppliers_orange {
                      value = $my_suppliers_orange|add:1
                    }
                  }
                }
              
                conditional {
                  if ($percentile < 75 && $percentile >= 50) {
                    var.update $my_suppliers_yellow {
                      value = $my_suppliers_yellow|add:1
                    }
                  }
                }
              
                conditional {
                  if ($percentile >= 75) {
                    var.update $my_suppliers_green {
                      value = $my_suppliers_green|add:1
                    }
                  }
                }
              }
            }
          }
        }
      
        var.update $my_suppliers {
          value = {}
            |set:"red":$my_suppliers_red
            |set:"yellow":$my_suppliers_yellow
            |set:"orange":$my_suppliers_orange
            |set:"green":$my_suppliers_green
            |set:"total":($my_suppliers|count)
        }
      }
    }
  
    // Details for SBOM Section on Dashboard
    group {
      stack {
        db.query products {
          where = $db.products.company == $input.company && ($db.products.third_party_processors|length) != 0
          return = {type: "count"}
        } as $sbom_total
      
        db.query products {
          where = $db.products.company == $input.company && ($db.products.third_party_processors|length) != 0 && $db.products.validated_on == null
          return = {type: "count"}
        } as $sbom_red
      
        db.query products {
          where = $db.products.company == $input.company && ($db.products.third_party_processors|length) != 0 && $db.products.validated_on != null
          return = {type: "count"}
        } as $sbom_green
      
        var $sbom {
          value = {}
            |set:"total":$sbom_total
            |set:"red":$sbom_red
            |set:"yellow":0
            |set:"orange":0
            |set:"green":$sbom_green
        }
      }
    }
  }

  response = {my_suppliers: $my_suppliers, sbom: $sbom}
}