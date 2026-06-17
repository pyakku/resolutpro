query sample_data verb=GET {
  api_group = "reg_program_owner_dash"

  input {
  }

  stack {
    db.query sample {
      where = $db.sample.id == 1
      return = {type: "list"}
      output = ["data"]
    } as $sample_1
  }

  response = $sample_1.data
}