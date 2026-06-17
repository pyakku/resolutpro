query get_employees verb=POST {
  api_group = "employees"

  input {
    text company? filters=trim
  }

  stack {
    db.query employees {
      where = $input.company == $input.company
      sort = {employees.f_name: "asc", employees.m_name: "asc"}
      return = {type: "list"}
    } as $employees_1
  }

  response = $employees_1
}