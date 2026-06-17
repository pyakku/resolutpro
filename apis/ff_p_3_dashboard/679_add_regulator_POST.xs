query addRegulator verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text name? filters=trim
    int[] industries?
    int[] countries?
    bool allIndustries?
    bool allCountries?
  }

  stack {
    db.has regulator {
      field_name = "name"
      field_value = $input.name
    } as $regulator2
  
    conditional {
      if ($regulator2) {
      }
    
      else {
        db.add regulator {
          enforce_hidden_fields = false
          data = {
            created_at   : "now"
            name         : $input.name
            countries    : $input.allCountries==true?[]:$input.countries
            industries   : $input.allIndustries==true?[]:$input.industries
            allCountries : $input.allCountries
            allIndustries: $input.allIndustries
          }
        } as $regulator1
      }
    }
  }

  response = $regulator1
}