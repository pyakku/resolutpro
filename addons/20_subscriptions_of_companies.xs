addon subscriptions_of_companies {
  input {
    int company? {
      table = "companies"
    }
  }

  stack {
    db.query subscriptions {
      where = $db.subscriptions.company == $input.company
      return = {type: "single"}
    }
  }
}