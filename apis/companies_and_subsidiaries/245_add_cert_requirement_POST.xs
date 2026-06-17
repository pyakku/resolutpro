query add_cert_requirement verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text country? filters=trim
    text func? filters=trim
    text certificate? filters=trim
    bool global?=false
  }

  stack {
    var $out {
      value = "Record Created"
    }
  
    conditional {
      if ($input.global) {
        db.query countries {
          return = {type: "list"}
        } as $countries_1
      
        foreach ($countries_1) {
          each as $country_list {
            conditional {
              if ($input.func != 0) {
                db.query certificates_needed {
                  where = $db.certificates_needed.functions_id == $input.func && $db.certificates_needed.countries_id == $country_list.id && $db.certificates_needed.certificates_id == $input.certificate
                  return = {type: "exists"}
                } as $certificates_needed_1
              
                conditional {
                  if ($certificates_needed_1) {
                    var.update $out {
                      value = "This Requirement Already Exists"
                    }
                  }
                
                  else {
                    db.add certificates_needed {
                      enforce_hidden_fields = false
                      data = {
                        functions_id   : $input.func|to_int
                        countries_id   : $country_list.id|to_int
                        certificates_id: $input.certificate|to_int
                      }
                    } as $certificates_needed_2
                  
                    var $current_function {
                      value = $input.func|to_int
                    }
                  
                    db.query companies {
                      where = $db.companies.country_code == $country_list.id && $current_function in $db.companies.functions
                      return = {type: "list"}
                    } as $companies_1
                  
                    foreach ($companies_1) {
                      each as $item {
                        db.query required_certificates {
                          where = $db.required_certificates.companies_id == $item.id && $db.required_certificates.certificates_id == $input.certificate
                          return = {type: "exists"}
                        } as $required_certificates_1
                      
                        conditional {
                          if ($required_certificates_1 == false) {
                            db.add required_certificates {
                              enforce_hidden_fields = false
                              data = {
                                created_at             : "now"
                                companies_id           : $item.id
                                certificates_id        : $input.certificate|to_int
                                active                 : true
                                required_for_compliance: true
                                validated_on           : ""
                              }
                            } as $required_certificates_2
                          }
                        
                          else {
                            db.query required_certificates {
                              where = $db.required_certificates.companies_id == $item.id && $db.required_certificates.certificates_id == $input.certificate
                              return = {type: "single"}
                            } as $edit
                          
                            db.edit required_certificates {
                              field_name = "id"
                              field_value = $edit.id
                              enforce_hidden_fields = false
                              data = {required_for_compliance: true}
                            } as $required_certificates_3
                          }
                        }
                      }
                    }
                  }
                }
              }
            
              else {
                db.query functions {
                  return = {type: "list"}
                } as $functions_1
              
                foreach ($functions_1) {
                  each as $item {
                    db.query certificates_needed {
                      where = $db.certificates_needed.functions_id == $item.id && $db.certificates_needed.countries_id == $input.country && $db.certificates_needed.certificates_id == $input.certificate
                      return = {type: "exists"}
                    } as $certificates_needed_1
                  
                    conditional {
                      if ($certificates_needed_1) {
                      }
                    
                      else {
                        db.add certificates_needed {
                          enforce_hidden_fields = false
                          data = {
                            functions_id   : $item.id
                            countries_id   : $input.country|to_int
                            certificates_id: $input.certificate|to_int
                          }
                        } as $certificates_needed_2
                      
                        var $current_function {
                          value = $item.id
                        }
                      
                        db.query companies {
                          where = $db.companies.country_code == $input.country && $current_function in $db.companies.functions
                          return = {type: "list"}
                        } as $companies_1
                      
                        foreach ($companies_1) {
                          each as $item_company {
                            db.query required_certificates {
                              where = $db.required_certificates.companies_id == $item_company.id && $db.required_certificates.certificates_id == $input.certificate
                              return = {type: "exists"}
                            } as $required_certificates_1
                          
                            conditional {
                              if ($required_certificates_1 == false) {
                                db.add required_certificates {
                                  enforce_hidden_fields = false
                                  data = {
                                    created_at             : "now"
                                    companies_id           : $item_company.id
                                    certificates_id        : $input.certificate|to_int
                                    active                 : true
                                    required_for_compliance: true
                                  }
                                } as $required_certificates_2
                              }
                            
                              else {
                                db.query required_certificates {
                                  where = $db.required_certificates.companies_id == $item_company.id && $db.required_certificates.certificates_id == $input.certificate
                                  return = {type: "single"}
                                } as $edit
                              
                                db.edit required_certificates {
                                  field_name = "id"
                                  field_value = $edit.id
                                  enforce_hidden_fields = false
                                  data = {required_for_compliance: true}
                                } as $required_certificates_4
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    
      else {
        conditional {
          if ($input.func != 0) {
            db.query certificates_needed {
              where = $db.certificates_needed.functions_id == $input.func && $db.certificates_needed.countries_id == $input.country && $db.certificates_needed.certificates_id == $input.certificate
              return = {type: "exists"}
            } as $certificates_needed_1
          
            conditional {
              if ($certificates_needed_1) {
                var.update $out {
                  value = "This Requirement Already Exists"
                }
              }
            
              else {
                db.add certificates_needed {
                  enforce_hidden_fields = false
                  data = {
                    functions_id   : $input.func|to_int
                    countries_id   : $input.country|to_int
                    certificates_id: $input.certificate|to_int
                  }
                } as $certificates_needed_2
              
                var $current_function {
                  value = $input.func|to_int
                }
              
                db.query companies {
                  where = $db.companies.country_code == $input.country && $current_function in $db.companies.functions
                  return = {type: "list"}
                } as $companies_1
              
                foreach ($companies_1) {
                  each as $item {
                    db.query required_certificates {
                      where = $db.required_certificates.companies_id == $item.id && $db.required_certificates.certificates_id == $input.certificate
                      return = {type: "exists"}
                    } as $required_certificates_1
                  
                    conditional {
                      if ($required_certificates_1 == false) {
                        db.add required_certificates {
                          enforce_hidden_fields = false
                          data = {
                            created_at             : "now"
                            companies_id           : $item.id
                            certificates_id        : $input.certificate|to_int
                            active                 : true
                            required_for_compliance: true
                          }
                        } as $required_certificates_2
                      }
                    
                      else {
                        db.query required_certificates {
                          where = $db.required_certificates.companies_id == $item.id && $db.required_certificates.certificates_id == $input.certificate
                          return = {type: "single"}
                        } as $edit
                      
                        db.edit required_certificates {
                          field_name = "id"
                          field_value = $edit.id
                          enforce_hidden_fields = false
                          data = {required_for_compliance: true}
                        } as $required_certificates_5
                      }
                    }
                  }
                }
              }
            }
          }
        
          else {
            db.query functions {
              return = {type: "list"}
            } as $functions_1
          
            foreach ($functions_1) {
              each as $item {
                db.query certificates_needed {
                  where = $db.certificates_needed.functions_id == $item.id && $db.certificates_needed.countries_id == $input.country && $db.certificates_needed.certificates_id == $input.certificate
                  return = {type: "exists"}
                } as $certificates_needed_1
              
                conditional {
                  if ($certificates_needed_1) {
                  }
                
                  else {
                    db.add certificates_needed {
                      enforce_hidden_fields = false
                      data = {
                        functions_id   : $item.id
                        countries_id   : $input.country|to_int
                        certificates_id: $input.certificate|to_int
                      }
                    } as $certificates_needed_2
                  
                    var $current_function {
                      value = $item.id
                    }
                  
                    db.query companies {
                      where = $db.companies.country_code == $input.country && $current_function in $db.companies.functions
                      return = {type: "list"}
                    } as $companies_1
                  
                    foreach ($companies_1) {
                      each as $item_company {
                        db.query required_certificates {
                          where = $db.required_certificates.companies_id == $item_company.id && $db.required_certificates.certificates_id == $input.certificate
                          return = {type: "exists"}
                        } as $required_certificates_1
                      
                        conditional {
                          if ($required_certificates_1 == false) {
                            db.add required_certificates {
                              enforce_hidden_fields = false
                              data = {
                                created_at             : "now"
                                companies_id           : $item_company.id
                                certificates_id        : $input.certificate|to_int
                                active                 : true
                                required_for_compliance: true
                              }
                            } as $required_certificates_2
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  
    db.query certificates_needed {
      sort = {
        certificates_needed.countries_id: "asc"
        certificates_needed.functions_id: "desc"
      }
    
      return = {type: "list"}
      addon = [
        {
          name : "functions"
          input: {functions_id: $output.functions_id}
          as   : "functions_id"
        }
        {
          name : "countries"
          input: {countries_id: $output.countries_id}
          as   : "countries_id"
        }
        {
          name  : "certificates"
          output: [
            "id"
            "created_at"
            "Certificate_Name"
            "Certificate_Desc"
            "details"
            "approved"
          ]
          input : {certificates_id: $output.certificates_id}
          as    : "certificates_id"
        }
      ]
    } as $certificates_needed_3
  }

  response = {certificates: $certificates_needed_3, out: $out}
}