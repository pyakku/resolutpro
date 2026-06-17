query get_data_dashboard_page verb=POST {
  api_group = "drilldowndash"

  input {
    text company? filters=trim
  }

  stack {
    // Details for My Companies Line on the Dashboard
    group {
      stack {
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company || $db.relationships.data_owner == $input.company
          return = {type: "list"}
          output = ["assigned_to"]
        } as $my_companies
      
        db.query relationships {
          where = $db.relationships.assigned_to == $input.company
          return = {type: "list"}
          output = ["assigned_by"]
        } as $clients
      
        conditional {
          if (($clients|count) != 0) {
            var.update $clients {
              value = $clients.assigned_by
            }
          
            var.update $clients {
              value = $clients|unique:""
            }
          }
        
          else {
            var.update $clients {
              value = []
            }
          }
        }
      
        conditional {
          if (($my_companies|count) == 0) {
            var.update $my_companies {
              value = $clients
            }
          }
        
          else {
            var.update $my_companies {
              value = $my_companies.assigned_to
            }
          
            var.update $my_companies {
              value = $my_companies|unique:""
            }
          
            var.update $my_companies {
              value = $my_companies|merge:$clients
            }
          }
        }
      
        var $my_company_yellow {
          value = 0
        }
      
        var $my_company_red {
          value = 0
        }
      
        var $my_company_green {
          value = 0
        }
      
        var $my_company_orange {
          value = 0
        }
      
        var $percentile {
          value = 0
        }
      
        foreach ($my_companies) {
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
                var.update $my_company_green {
                  value = $my_company_green|add:1
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
                    var.update $my_company_red {
                      value = $my_company_red|add:1
                    }
                  }
                }
              
                conditional {
                  if ($percentile >= 25 && $percentile < 50) {
                    var.update $my_company_orange {
                      value = $my_company_orange|add:1
                    }
                  }
                }
              
                conditional {
                  if ($percentile < 75 && $percentile >= 50) {
                    var.update $my_company_yellow {
                      value = $my_company_yellow|add:1
                    }
                  }
                }
              
                conditional {
                  if ($percentile >= 75) {
                    var.update $my_company_green {
                      value = $my_company_green|add:1
                    }
                  }
                }
              }
            }
          }
        }
      
        var.update $my_companies {
          value = {}
            |set:"red":$my_company_red
            |set:"yellow":$my_company_yellow
            |set:"orange":$my_company_orange
            |set:"green":$my_company_green
            |set:"total":($my_companies|count)
        }
      }
    }
  
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
  
    // Details for My Processes Line on the Dashboard
    group {
      stack {
        db.query relationships {
          where = $db.relationships.data_owner == $input.company
          return = {type: "list"}
          output = ["id", "PTN_no"]
        } as $my_processes
      
        var.update $my_processes {
          value = $my_processes|unique:"PTN_no"
        }
      
        var.update $my_processes {
          value = {}
            |set:"total":($my_processes|count)
        }
      }
    }
  
    // Details for My Client Processes Line on the Dashboard
    group {
      stack {
        db.query relationships {
          where = $db.relationships.assigned_to == $input.company
          return = {type: "list"}
          output = ["id", "PTN_no"]
        } as $my_client_processes
      
        var.update $my_client_processes {
          value = $my_client_processes|unique:"PTN_no"
        }
      
        var.update $my_client_processes {
          value = {}
            |set:"total":($my_client_processes|count)
        }
      }
    }
  
    // Sla Section
    group {
      stack {
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company
          return = {type: "count"}
        } as $total_rel
      
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company && $db.relationships.sla == null
          return = {type: "count"}
        } as $no_sla
      
        var $sla {
          value = {}
            |set:"total":$total_rel
            |set:"no_sla":$no_sla
        }
      }
    }
  
    // Policies Section
    group {
      stack {
        db.query my_policies {
          where = $db.my_policies.companies_id == $input.company
          return = {type: "list"}
          output = ["id", "policies_id"]
          addon = [
            {
              name  : "policies"
              output: ["created_at", "name", "desc"]
              input : {policies_id: $output.policies_id}
            }
          ]
        } as $my_policies
      
        var $policies_section {
          value = []
        }
      
        foreach ($my_policies) {
          each as $policy {
            var $my_policy_id {
              value = $policy.id
            }
          
            db.query policy_requirements {
              where = $db.policy_requirements.my_policies_id == $my_policy_id
              return = {type: "count"}
            } as $total_ack_required
          
            db.query policy_requirements {
              where = $db.policy_requirements.my_policies_id == $my_policy_id && $db.policy_requirements.acknowledged == true
              return = {type: "count"}
            } as $total_acknowledged
          
            conditional {
              if ($total_ack_required == 0) {
                var $details {
                  value = {}
                    |set:"total":$total_ack_required
                    |set:"ack":$total_acknowledged
                    |set:"policy":$policy.name
                    |set:"unack":($total_ack_required|subtract:$total_acknowledged)
                    |set:"ack_p":100
                }
              }
            
              else {
                var $details {
                  value = {}
                    |set:"total":$total_ack_required
                    |set:"ack":$total_acknowledged
                    |set:"policy":$policy.name
                    |set:"unack":($total_ack_required|subtract:$total_acknowledged)
                    |set:"ack_p":($total_acknowledged
                      |divide:$total_ack_required
                      |multiply:100
                      |ceil
                    )
                }
              }
            }
          
            !var $details {
              value = {}
                |set:"total":$total_ack_required
                |set:"ack":$total_acknowledged
                |set:"policy":$policy.name
                |set:"unack":($total_ack_required|subtract:$total_acknowledged)
                |set:"ack_p":($total_acknowledged
                  |divide:$total_ack_required
                  |multiply:100
                  |ceil
                )
            }
          
            var.update $policies_section {
              value = $policies_section|push:$details
            }
          }
        }
      }
    }
  
    // Industry_section
    group {
      stack {
        var $function_report {
          value = []
        }
      
        var $industry_report {
          value = []
        }
      
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company || $db.relationships.data_owner == $input.company
          return = {type: "list"}
          output = ["PTN_no", "assigned_to", "functions"]
          addon = [
            {
              name : "functions"
              input: {functions_id: $output.functions}
              as   : "functions"
            }
          ]
        } as $functions_list
      
        !var.update $functions_list {
          value = $functions_list|unique:"functions.id"
        }
      
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company || $db.relationships.data_owner == $input.company
          return = {type: "list"}
          output = ["id", "PTN_no", "assigned_to", "functions"]
          addon = [
            {
              name : "functions"
              input: {functions_id: $output.functions}
              as   : "functions"
            }
          ]
        } as $company_assigned_list
      
        foreach ($functions_list) {
          each as $function_list_item {
            var $counter {
              value = 0
            }
          
            foreach ($functions_list) {
              each as $function_list_item_2 {
                conditional {
                  if ($function_list_item.functions.id == $function_list_item_2.functions.id) {
                    var.update $counter {
                      value = $counter|add:1
                    }
                  }
                }
              }
            }
          
            var.update $function_report {
              value = $function_report
                |push:({}
                  |set:"function":$function_list_item.functions.id
                  |set:"count":$counter
                  |set:"function_name":$function_list_item.functions.function
                )
            }
          }
        }
      
        foreach ($function_report) {
          each as $function_item {
            var $c_list {
              value = []
            }
          
            foreach ($functions_list) {
              each as $assignment_list {
                conditional {
                  if ($function_item.function == $assignment_list.functions.id) {
                    var.update $c_list {
                      value = $c_list
                        |push:$assignment_list.assigned_to
                    }
                  }
                }
              }
            }
          
            var.update $industry_report {
              value = $industry_report
                |push:({}
                  |set:"company_list":$c_list
                  |set:"functions":$function_item
                )
            }
          }
        }
      }
    }
  
    // Suppliers per process & Average
    group {
      stack {
        var $supplier_numbers {
          value = []
        }
      
        db.query relationships {
          where = $db.relationships.assigned_by == $input.company
          return = {type: "list"}
        } as $list_for_average
      
        foreach ($list_for_average) {
          each as $item {
            var $company_list_for_numbers {
              value = []
            }
          
            foreach ($list_for_average) {
              each as $item2 {
                conditional {
                  if ($item.PTN_no == $item2.PTN_no) {
                    var.update $company_list_for_numbers {
                      value = $company_list_for_numbers|push:$item2.assigned_to
                    }
                  }
                }
              }
            }
          
            var.update $supplier_numbers {
              value = $supplier_numbers
                |push:({}
                  |set:"PTN":$item.PTN_no
                  |set:"companies":$company_list_for_numbers
                )
            }
          }
        }
      }
    }
  
    // certificates
    group {
      stack {
        db.query required_certificates {
          where = $db.required_certificates.active == true && $db.required_certificates.companies_id == $input.company && $db.required_certificates.document != null && $db.required_certificates.validated_on != null && $db.required_certificates.required_for_compliance == true
          return = {type: "count"}
        } as $cert_compliant
      
        db.query required_certificates {
          where = $db.required_certificates.companies_id == $input.company && ($db.required_certificates.document == null || $db.required_certificates.validated_on == null) && $db.required_certificates.required_for_compliance == true
          return = {type: "count"}
        } as $cert_noncompliant
      
        var $certificates {
          value = {}
            |set:"compliant":$cert_compliant
            |set:"non_compliant":$cert_noncompliant
        }
      }
    }
  }

  response = {
    my_companies       : $my_companies
    my_processes       : $my_processes
    my_client_processes: $my_client_processes
    my_suppliers       : $my_suppliers
    sla                : $sla
    policies_section   : $policies_section
    industry_report    : $industry_report
    supplier_numbers   : $supplier_numbers
    certificates       : $certificates
  }
}