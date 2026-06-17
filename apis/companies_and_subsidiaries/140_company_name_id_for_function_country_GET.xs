query company_name_id_for_function_country verb=GET {
  api_group = "Companies and Subsidiaries"

  input {
    int function_id?
    text country_id? filters=trim
  }

  stack {
    db.query companies {
      where = ($input.function_id in $db.companies.functions && $db.companies.country_code == $input.country_id && $input.function_id not in $db.companies.functions_inactive)
      return = {type: "list"}
      output = ["id", "Company_Name", "profile_link", "test"]
    } as $companies_1
  }

  response = $companies_1
}