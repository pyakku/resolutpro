query sign_upv3 verb=POST {
  api_group = "sign_upv3"

  input {
    text user_name? filters=trim
    text user_lname? filters=trim
    text user_password? filters=trim
    email user_email?
    int user_plan?
    text company_name? filters=trim
    text company_reg? filters=trim
    bool is_sub?=false
    int parent_id?
    text industry? filters=trim
    int country_id?
    text employees? filters=trim
    text revenue? filters=trim
    int function_id?
    text city? filters=trim
    text state? filters=trim
    text postal_code? filters=trim
    text phone? filters=trim
    text verifier_email? filters=trim
    text verifier_name? filters=trim
  }

  stack {
    var $response {
      value = ""
    }
  
    db.has user {
      field_name = "email"
      field_value = $input.user_email
    } as $user_exists
  
    conditional {
      if ($user_exists == false) {
        db.transaction {
          stack {
            db.add user {
              enforce_hidden_fields = false
              data = {
                name       : $input.user_name
                l_name     : $input.user_lname
                email      : $input.user_email|to_lower
                password   : $input.user_password
                language   : "ENGLISH"
                date_format: "UK"
                is_admin   : false
                plan       : $input.user_plan
              }
            } as $new_user
          
            db.add companies {
              enforce_hidden_fields = false
              data = {
                company_reg    : $input.company_reg
                Company_Name   : $input.company_name
                functions      : []|push:$input.function_id
                is_sub         : $input.is_sub
                test           : false
                created_by_user: $new_user.id
                industry       : $input.industry
                phone_number   : $input.phone
                city           : $input.city
                state          : $input.state
                postal_code    : $input.postal_code
                no_of_employees: $input.employees
                revenue        : $input.revenue
                country_code   : $input.country_id
                plan           : $input.user_plan
                verifier_email : $input.verifier_email
                verifier_name  : $input.verifier_name
                verified       : false
              }
            } as $new_company
          
            conditional {
              if ($input.is_sub) {
                db.add subsidiary_table {
                  enforce_hidden_fields = false
                  data = {
                    parent_company: $input.parent_id
                    subsidiary    : $new_company.id
                    approved      : false
                    rejected      : false
                  }
                } as $subsidiary_table_1
              }
            }
          
            db.add contacts {
              enforce_hidden_fields = false
              data = {
                name        : $input.user_name
                l_name      : $input.user_lname
                email       : $input.user_email
                phone_number: $input.phone
                created_by  : $new_company.id
                approved    : true
              }
            } as $new_contact
          
            db.add contact_relationship {
              enforce_hidden_fields = false
              data = {
                contact : $new_contact.id
                company : $new_company.id
                role    : "System User"
                approved: true
              }
            } as $contact_relationship_1
          
            db.query certificates_needed {
              where = $db.certificates_needed.functions_id == $input.function_id && $db.certificates_needed.countries_id == $input.country_id
              return = {type: "list"}
            } as $certificates_needed_for_company
          
            foreach ($certificates_needed_for_company) {
              each as $item {
                db.add required_certificates {
                  enforce_hidden_fields = false
                  data = {
                    companies_id           : $new_company.id
                    certificates_id        : $item.certificates_id
                    active                 : true
                    required_for_compliance: true
                  }
                } as $required_certificates_1
              }
            }
          
            !function.run default_certificates_add_on_signup {
              input = {company_id: $new_company.id}
            } as $func_1
          
            var.update $response {
              value = "Sign Up Successful"
            }
          }
        }
      }
    
      else {
        db.transaction {
          stack {
            db.get user {
              field_name = "email"
              field_value = $input.user_email
            } as $old_user
          
            db.add companies {
              enforce_hidden_fields = false
              data = {
                company_reg    : $input.company_reg
                Company_Name   : $input.company_name
                functions      : []|push:$input.function_id
                is_sub         : $input.is_sub
                created_by_user: $old_user.id
                industry       : $input.industry
                phone_number   : $input.phone
                city           : $input.city
                state          : $input.state
                postal_code    : $input.postal_code
                no_of_employees: $input.employees
                revenue        : $input.revenue
                country_code   : $input.country_id
                plan           : $input.user_plan
                onetrust       : ""
              }
            } as $new_company
          
            conditional {
              if ($input.is_sub) {
                db.add subsidiary_table {
                  enforce_hidden_fields = false
                  data = {
                    parent_company: $input.parent_id
                    subsidiary    : $new_company.id
                    approved      : false
                    rejected      : false
                  }
                } as $subsidiary_table_1
              }
            }
          
            db.get contacts {
              field_name = "email"
              field_value = $input.user_email
            } as $old_contact
          
            db.add contact_relationship {
              enforce_hidden_fields = false
              data = {
                contact : $old_contact.id
                company : $new_company.id
                role    : "System User"
                approved: true
              }
            } as $contact_relationship_1
          
            db.query certificates_needed {
              where = $db.certificates_needed.functions_id == $input.function_id && $db.certificates_needed.countries_id == $input.country_id
              return = {type: "list"}
            } as $certificates_needed_for_company
          
            foreach ($certificates_needed_for_company) {
              each as $item {
                db.add required_certificates {
                  enforce_hidden_fields = false
                  data = {
                    companies_id           : $new_company.id
                    certificates_id        : $item.certificates_id
                    required_for_compliance: true
                  }
                } as $required_certificates_1
              }
            }
          
            !function.run default_certificates_add_on_signup {
              input = {company_id: $new_company.id}
            } as $func_1
          
            var.update $response {
              value = "Company Added to your account."
            }
          }
        }
      }
    }
  
    function.run create_subscription_free_plan {
      input = {
        email       : $input.user_email
        company_name: $new_company.Company_Name
        first_name  : $input.user_name
        last_name   : $input.user_lname
        phone       : $new_company.phone_number
        company_id  : $new_company.id
        user_id     : $new_company.created_by_user
        plan        : $input.user_plan
      }
    } as $func_2
  
    function.run sign_up_notification_p3 {
      input = {
        name   : $input.company_name
        plan   : $input.user_plan
        email  : $input.user_email
        phone  : $input.phone
        address: $input.city
        user   : $input.user_email
      }
    } as $func_3
  
    !api.request {
      url = "https://p3audit.com/itracker/onboarding_mail.php"
      method = "GET"
      params = {}
        |set:"email":$input.user_email
        |set:"username":$input.user_name
        |set:"company":$input.company_name
      headers = []
        |push:"Content-Type: application/json"
    } as $api_1
  
    function.run send_verification_email {
      input = {
        verifier_name : $input.verifier_name
        verifier_email: $input.verifier_email
        user_name     : $input.user_name|concat:(" "|concat:$input.user_lname:""):""
        cid           : $new_company.id
        company       : $input.company_name
      }
    } as $func_4
  }

  response = {api: $func_2, new_company: $new_company}
}