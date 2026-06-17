query updateCompany verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int id?
    text companyName? filters=trim
    text registration? filters=trim
    text employees? filters=trim
    text revenue? filters=trim
    int[] functions?
    int[] regulators?
    text phone? filters=trim
    text city? filters=trim
    text state? filters=trim
    int country?
    text postal? filters=trim
    int[] industry?
  }

  stack {
    db.edit companies {
      field_name = "id"
      field_value = $input.id
      enforce_hidden_fields = false
      data = {
        Company_Name     : $input.companyName
        company_reg      : $input.registration
        functions        : $input.functions
        industryTableLink: $input.industry
        phone_number     : $input.phone
        city             : $input.city
        state            : $input.state
        postal_code      : $input.postal
        revenue          : $input.revenue
        country_code     : $input.country
        regulator        : $input.regulators
      }
    } as $companies2
  
    db.get companies {
      field_name = "id"
      field_value = $input.id
      addon = [
        {
          name : "countries"
          input: {countries_id: $output.country_code}
          as   : "country"
        }
      ]
    } as $companies1
  }

  response = $companies1
}