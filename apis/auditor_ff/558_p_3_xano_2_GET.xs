query p3Xano2 verb=GET {
  api_group = "Auditor FF"

  input {
    text input? filters=trim
  }

  stack {
    util.get_all_input as $x1
    api.request {
      url = "https://api.positionstack.com/v1/reverse?access_key=e3b37a2febf0ec060c2285f5e2751391&query="
        |concat:$input.input.data.lat:""
        |concat:",":""
        |concat:$input.input.data.lng:""
      method = "GET"
    } as $api1
  
    util.ip_lookup {
      value = $env.$remote_ip
    } as $x2
  }

  response = $api1
}