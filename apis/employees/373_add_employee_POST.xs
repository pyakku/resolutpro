query add_employee verb=POST {
  api_group = "employees"

  input {
    dblink {
      table = "employees"
    }
  }

  stack {
    db.add employees {
      enforce_hidden_fields = false
      data = {
        created_at: "now"
        company   : $input.company
        f_name    : $input.f_name
        m_name    : $input.m_name
        l_name    : $input.l_name
        role      : $input.role
        dob       : $input.dob
        doj       : $input.doj
        email     : $input.email
        phone     : $input.phone
      }
    } as $employees_1
  }

  response = $employees_1
}