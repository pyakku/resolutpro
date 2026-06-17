query risk_rating verb=POST {
  api_group = "risks"

  input {
    text company_id? filters=trim
  }

  stack {
    var $risk_rating {
      value = 0
    }
  
    var $data_security {
      value = 0
    }
  
    var $business_continuity {
      value = 0
    }
  
    var $cyber_risk {
      value = 0
    }
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.active == true && $db.required_certificates.required_for_compliance == true
      return = {type: "list"}
    } as $required_certificates_1
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.active == true && $db.required_certificates.required_for_compliance == true && ($db.required_certificates.certificates_id == 8 || $db.required_certificates.certificates_id == 52 || $db.required_certificates.certificates_id == 5 || $db.required_certificates.certificates_id == 59)
      return = {type: "list"}
    } as $cyber_risk_list
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.active == true && $db.required_certificates.required_for_compliance == true && ($db.required_certificates.certificates_id == 7 || $db.required_certificates.certificates_id == 53 || $db.required_certificates.certificates_id == 54 || $db.required_certificates.certificates_id == 55)
      return = {type: "list"}
    } as $business_continuity_list
  
    db.query required_certificates {
      where = $db.required_certificates.companies_id == $input.company_id && $db.required_certificates.active == true && $db.required_certificates.required_for_compliance == true && ($db.required_certificates.certificates_id == 8 || $db.required_certificates.certificates_id == 52 || $db.required_certificates.certificates_id == 5)
      return = {type: "list"}
    } as $data_security_list
  
    !var $risk_rating_potential {
      value = $required_certificates_1|count|multiply:5
    }
  
    var $risk_rating_potential {
      value = $required_certificates_1|count|multiply:3
    }
  
    foreach ($required_certificates_1) {
      each as $item {
        !conditional {
          if ($item.p3_audited) {
            var.update $risk_rating {
              value = $risk_rating|add:5
            }
          
            continue
          }
        
          else {
            conditional {
              if ($item.remote_validation) {
                var.update $risk_rating {
                  value = $risk_rating|add:3
                }
              
                continue
              }
            
              else {
                conditional {
                  if ($item.document != null) {
                    var.update $risk_rating {
                      value = $risk_rating|add:1
                    }
                  
                    continue
                  }
                }
              }
            }
          }
        }
      
        conditional {
          if ($item.document != null) {
            var.update $risk_rating {
              value = $risk_rating|add:3
            }
          }
        }
      }
    }
  
    foreach ($cyber_risk_list) {
      each as $item {
        conditional {
          if ($item.document != null) {
            var.update $cyber_risk {
              value = $cyber_risk|add:5
            }
          }
        }
      
        !conditional {
          if ($item.p3_audited) {
            var.update $cyber_risk {
              value = $cyber_risk|add:5
            }
          
            continue
          }
        
          else {
            conditional {
              if ($item.remote_validation) {
                var.update $cyber_risk {
                  value = $cyber_risk|add:3
                }
              
                continue
              }
            
              else {
                conditional {
                  if ($item.document != null) {
                    var.update $cyber_risk {
                      value = $cyber_risk|add:1
                    }
                  
                    continue
                  }
                }
              }
            }
          }
        }
      }
    }
  
    foreach ($data_security_list) {
      each as $item {
        !conditional {
          if ($item.p3_audited) {
            var.update $data_security {
              value = $data_security|add:5
            }
          
            continue
          }
        
          else {
            conditional {
              if ($item.remote_validation) {
                var.update $data_security {
                  value = $data_security|add:3
                }
              
                continue
              }
            
              else {
                conditional {
                  if ($item.document != null) {
                    var.update $data_security {
                      value = $data_security|add:1
                    }
                  
                    continue
                  }
                }
              }
            }
          }
        }
      
        conditional {
          if ($item.document != null) {
            var.update $data_security {
              value = $data_security|add:5
            }
          }
        }
      }
    }
  
    foreach ($business_continuity_list) {
      each as $item {
        !conditional {
          if ($item.p3_audited) {
            var.update $business_continuity {
              value = $business_continuity|add:5
            }
          
            continue
          }
        
          else {
            conditional {
              if ($item.remote_validation) {
                var.update $risk_rating {
                  value = $risk_rating|add:3
                }
              
                continue
              }
            
              else {
                conditional {
                  if ($item.document != null) {
                    var.update $business_continuity {
                      value = $business_continuity|add:1
                    }
                  
                    continue
                  }
                }
              }
            }
          }
        }
      
        conditional {
          if ($item.document != null) {
            var.update $business_continuity {
              value = $business_continuity|add:5
            }
          }
        }
      }
    }
  }

  response = {
    risk_rating          : $risk_rating
    risk_rating_potential: $risk_rating_potential
    data_security        : $data_security
    business_continuity  : $business_continuity
    cyber_risk           : $cyber_risk
  }
}