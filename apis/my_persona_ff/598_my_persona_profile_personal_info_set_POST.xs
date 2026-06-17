query myPersonaProfilePersonalInfoSet verb=POST {
  api_group = "myPersonaFF"
  auth = "user"

  input {
    text fname? filters=trim
    text lname? filters=trim
    text phone? filters=trim
    text role? filters=trim
    text regulatorMembershipNumber? filters=trim
    bool active?
    text city? filters=trim
    text regulator? filters=trim
  }

  stack {
    db.transaction {
      stack {
        db.get user {
          field_name = "id"
          field_value = $auth.id
        } as $user1
      
        db.get contacts {
          field_name = "email"
          field_value = $user1.email
        } as $contacts1
      
        db.query companies {
          where = $db.companies.created_by_user == $auth.id && $db.companies.individual == true
          return = {type: "single"}
        } as $companies1
      
        db.edit user {
          field_name = "id"
          field_value = $auth.id
          enforce_hidden_fields = false
          data = {name: $input.fname, l_name: $input.lname}
        } as $user2
      
        db.edit contacts {
          field_name = "id"
          field_value = $contacts1.id
          enforce_hidden_fields = false
          data = {name: $input.fname, l_name: $input.lname}
        } as $contacts2
      
        db.edit companies {
          field_name = "id"
          field_value = $companies1.id
          enforce_hidden_fields = false
          data = {Company_Name: $input.fname|concat:$input.lname:" "}
        } as $companies2
      
        db.get regulator {
          field_name = "name"
          field_value = $input.regulator
        } as $regulator1
      
        db.add_or_edit locum {
          field_name = "user_id"
          field_value = $auth.id
          enforce_hidden_fields = false
          data = {
            regulator_id    : $regulator1.id
            city            : $input.city
            active          : $input.active
            role            : $input.role
            membershipNumber: $input.regulatorMembershipNumber
          }
        } as $locum2
      }
    }
  }

  response = $user1
}