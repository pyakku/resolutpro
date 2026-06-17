query addIndustry verb=POST {
  api_group = "ffP3Dashboard"
  auth = "p3DashboardUser"

  input {
    text industry? filters=trim
  }

  stack {
    db.has industries {
      field_name = "industry"
      field_value = $input.industry
    } as $industries2
  
    conditional {
      if ($industries2) {
      }
    
      else {
        db.add industries {
          enforce_hidden_fields = false
          data = {created_at: "now", industry: $input.industry}
        } as $industries1
      }
    }
  }

  response = $industries2
}