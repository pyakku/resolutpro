query processnepaliQA verb=POST {
  api_group = "gemini"

  input {
    file? file?
  }

  stack {
    storage.read_file_resource {
      value = $input.file
    } as $file1
  
    api.request {
      url = "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=%s"|sprintf:$env.gemini_api_key
      method = "POST"
      params = {}
        |set:"contents":([]
          |push:({}
            |set:"role":"user"
            |set:"parts":([]
              |push:({}
                |set:"text":"""
        Process the multiple choice questions in nepali and return in text format.
        Never make up anything or hallucinate answers.
        These are for a school examination so nothing should change.
        """
              )
              |push:({}
                |set:"inlineData":({}
                  |set:"mimeType":"image/jpeg"
                  |set:"data":($file1.data|base64_encode)
                )
              )
            )
          )
        )
      headers = []
        |push:"Content-Type: application/json"
      timeout = 50
    } as $api1
  }

  response = {api1: $api1}
}