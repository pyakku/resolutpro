query news verb=GET {
  api_group = "External"

  input {
  }

  stack {
    api.request {
      url = "http://api.mediastack.com/v1/news?access_key=c7e5a5eb8fd4f04ccce9e347e544b8e8&languages=en&categories=business&countries=us,gb&limit=6"
      method = "GET"
    } as $api_1
  }

  response = $api_1
}