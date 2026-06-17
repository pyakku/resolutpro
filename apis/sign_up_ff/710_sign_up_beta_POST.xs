query signUpBeta verb=POST {
  api_group = "Sign Up FF"

  input {
    text email? filters=trim
    text password? filters=trim
    text firstName? filters=trim
    text lastName? filters=trim
    text? profileImage? filters=trim
    int? parentId?
    text companyName? filters=trim
    text companyRegistration? filters=trim
    int[] functions?
    int plan?
    bool isSub?
    text phone? filters=trim
    text city? filters=trim
    int[] regulators?
    text state? filters=trim
    text postalCode? filters=trim
    int country?
    int[] industry?
  }

  stack {
    db.add user {
      enforce_hidden_fields = false
      data = {
        created_at : "now"
        name       : $input.firstName
        l_name     : $input.lastName
        email      : $input.email|to_lower
        password   : $input.password
        profile_img: $input.profileImage
        plan       : $input.plan
      }
    } as $newUser
  
    db.add companies {
      enforce_hidden_fields = false
      data = {
        created_at       : "now"
        Company_Name     : $input.companyName
        company_reg      : $input.companyRegistration
        functions        : $input.functions
        is_sub           : $input.isSub
        email            : $input.email
        created_by_user  : $newUser.id
        industryTableLink: $input.industry
        phone_number     : $input.phone
        city             : $input.city
        state            : $input.state
        postal_code      : $input.postalCode
        country_code     : $input.country
        plan             : $input.plan
        regulator        : $input.regulators
      }
    } as $newCompany
  
    conditional {
      if ($input.isSub) {
        db.add subsidiary_table {
          enforce_hidden_fields = false
          data = {
            created_at    : "now"
            parent_company: $input.parentId
            subsidiary    : $newCompany.id
            approved      : true
            rejected      : false
          }
        } as $subsidiary_table1
      }
    }
  
    !function.run create_subscription_free_plan {
      input = {
        email       : $input.email
        company_name: $input.companyName
        first_name  : $input.firstName
        last_name   : $input.lastName
        phone       : $input.phone
        company_id  : $newCompany.id
        user_id     : $newUser.id
        plan        : $input.plan
      }
    } as $func1
  
    function.run create_subscriptionBETA2025 {
      input = {company_id: $newCompany.id, user_id: $newUser.id}
    } as $func1
  }

  response = $func1
}