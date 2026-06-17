query plans verb=GET {
  api_group = "ptn&doc pricing"

  input {
  }

  stack {
    db.query plan {
      return = {type: "list"}
    } as $plan_1
  }

  response = $plan_1
}