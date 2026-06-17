query getAllPlans verb=GET {
  api_group = "Sign Up FF"

  input {
  }

  stack {
    db.query plan {
      where = $db.plan.id != 9 && $db.plan.id != 18
      sort = {plan.pricePerMonth: "asc"}
      return = {type: "list"}
    } as $plan1
  }

  response = $plan1
}