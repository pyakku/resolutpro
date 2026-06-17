function "Emails/decode_token_for_report_email" {
  input {
    text token? filters=trim
  }

  stack {
    try_catch {
      try {
        security.jws_decode {
          token = $input.token
          key = $env.hash_key_for_report_url
          check_claims = {}
          signature_algorithm = "HS256"
          timeDrift = 0
        } as $crypto1
      }
    
      catch {
        var $crypto1 {
          value = 0
        }
      }
    }
  }

  response = $crypto1
}