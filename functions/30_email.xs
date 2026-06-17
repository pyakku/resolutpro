function email {
  input {
  }

  stack {
    api.lambda {
      code = ""
      timeout = 10
    } as $x1
  }

  response = $x1
}