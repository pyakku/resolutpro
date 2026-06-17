query getAllRegulators verb=POST {
  api_group = "Sign Up FF"

  input {
    int country?
    int[] industry?
  }

  stack {
    !db.query regulator {
      where = $db.regulator.allCountries == true && $db.regulator.allIndustries == true
      sort = {regulatory_program_owner.name: "asc"}
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "name"
        "countries"
        "industries"
        "allCountries"
        "allIndustries"
      ]
    } as $allCountriesAllIndustries
  
    !db.query regulator {
      where = $db.regulator.allCountries == true && $input.industry overlaps $db.regulator.industries
      sort = {regulatory_program_owner.name: "asc"}
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "name"
        "countries"
        "industries"
        "allCountries"
        "allIndustries"
      ]
    } as $allCountriesSpecificIndustries
  
    !db.query regulator {
      where = $input.country in $db.regulator.countries && $db.regulator.allIndustries == true
      sort = {regulatory_program_owner.name: "asc"}
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "name"
        "countries"
        "industries"
        "allCountries"
        "allIndustries"
      ]
    } as $specificCountryAllIndustries
  
    !db.query regulator {
      where = $input.country in $db.regulator.countries && $input.industry overlaps $db.regulator.industries
      sort = {regulatory_program_owner.name: "asc"}
      return = {type: "list"}
      output = [
        "id"
        "created_at"
        "name"
        "countries"
        "industries"
        "allCountries"
        "allIndustries"
      ]
    } as $specificCountrySpecificIndustry
  
    db.query regulator {
      where = ($db.regulator.allCountries || $input.country in $db.regulator.countries) && ($db.regulator.allIndustries || $db.regulator.industries overlaps $input.industry)
      sort = {regulator.name: "asc"}
      return = {type: "list"}
    } as $regulator1
  }

  response = $regulator1
}