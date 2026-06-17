query acknowledgeDocument verb=POST {
  api_group = "ff"
  auth = "user"

  input {
    int ackID?
  }

  stack {
  }

  response = null
}