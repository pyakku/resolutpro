addon required_certificates {
  input {
    int required_certificates_id? {
      table = "required_certificates"
    }
  }

  stack {
    db.query required_certificates {
      where = $db.required_certificates.id == $input.required_certificates_id
      return = {type: "single"}
    }
  }
}