addon certificates {
  input {
    int certificates_id? {
      table = "certificates"
    }
  }

  stack {
    db.query certificates {
      where = $db.certificates.id == $input.certificates_id
      return = {type: "single"}
    }
  }
}