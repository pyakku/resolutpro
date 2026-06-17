// Get the record belonging to the authentication token
query "auth/me" verb=GET {
  api_group = "Auditor FF"
  auth = "auditor"

  input {
  }

  stack {
    db.get auditor {
      field_name = "id"
      field_value = $auth.id
      output = [
        "id"
        "created_at"
        "first_name"
        "middle_name"
        "last_name"
        "email"
        "city"
        "country"
        "industry_body"
        "ib_membership"
        "organisation_name"
        "organisation_reg"
        "phone"
        "org_phone"
        "org_email"
        "org_country"
        "primary_professional_body"
        "ppb_membership"
        "title"
        "no_of_auditors"
        "code"
        "qualification"
        "image.access"
        "image.path"
        "image.name"
        "image.type"
        "image.size"
        "image.mime"
        "image.meta"
        "image.url"
      ]
    } as $auditor
  }

  response = $auditor
}