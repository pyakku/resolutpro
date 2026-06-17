query upload_functions verb=POST {
  api_group = "Companies and Subsidiaries"

  input {
    text[] functions? filters=trim
  }

  stack {
    foreach ($input.functions) {
      each as $item {
        db.add functions {
          enforce_hidden_fields = false
          data = {function: $item}
        } as $functions_1
      }
    }
  }

  response = $functions_1
}