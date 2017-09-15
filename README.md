# Rest Service Client
[![Gem Version](https://badge.fury.io/rb/rest-service-client.svg)](https://badge.fury.io/rb/rest-service-client)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rest-service-client'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rest-service-client

## Usage
Add this line to top of your file
```ruby
require 'rest-service-client'
````

Create a class, include the RestServiceClient and configure your service
```ruby
class MyAwesomeService
    include RestServiceClient
  
    # Sets the host url
    # You can use MyAwesomeService.new('https://jsonplaceholder.typicode.com')
    # to set the host instead. Using host url via constructor has high priority.
    host 'https://jsonplaceholder.typicode.com'

    # Sets the default headers for every requests.
    # Will be replaced using: MyAwesomeService.new.find_photo(id: 1, headers: { 'Authorization' => 'Bearer 123456' })
    headers Authorization: 'OAuth 1111|111'

    # Sets the default params for every requests.
    # Will be replaced using: MyAwesomeService.new.find_photo(id: 20)
    params id: 10

    # Configure endpoints:
    # _httpmethod _method_name, _path
    # "get :photos, '/photos'" provides an ability 
    # to make GET request to 'https://jsonplaceholder.typicode.com/photos'
    # using MyAwesomeService.new.photos
    # Supported: get, post, put, patch, delete
    get :photos, '/photos'
    
    # You can assign placeholders for params to path.
    # Example: MyAwesomeService.new.find_photo(id: 1)
    get :find_photo, '/photos/:id'
    
    post :add_photo, '/photos'
    put :update_photo, '/photos/:id'
    patch :update_photo_data, '/photos/:id'
    delete :delete_photo, '/photos/:id'
end
```

## Samples

### Simple Service
```ruby
class SimpleService
  include RestServiceClient
  
  host 'https://jsonplaceholder.typicode.com'
  
  get :photo, '/photos/:id'
  get :first_photo, '/photos/1'
  get :second_photo, '/photos/2'
end

service = SimpleService.new

p service.first_photo.result['id']
# 1

p service.second_photo.result['id']
# 2

p service.photo(id: 10).result['id']
# 10

```

### GET

```ruby
class SimpleService
  include RestServiceClient
  host 'https://jsonplaceholder.typicode.com'
  get :photo, '/photos/:id', params: { id: 1 }
end

service = SimpleService.new
p service.photo.result['id']         # 1
p service.photo(id: 2).result['id']  # 2
```

```ruby
class SimpleService
  include RestServiceClient
  host 'https://jsonplaceholder.typicode.com'
  get :first_photo, '/photos/1', headers: { Authentication: 'my-token' }
end

service = SimpleService.new
# Sends the request to 'https://jsonplaceholder.typicode.com/photos/1'
# includes Headers: { 'Authentication': 'my-token' }
p service.first_photo.result['albumId'] # 1

# Sends the request to 'https://jsonplaceholder.typicode.com/photos/1'
# includes Headers: { 
#   'Authentication': 'my-token',
#   'AnotherHeaderKey': 'AnotherHeaderValue' 
# }
another_headers = { AnotherHeaderKey: 'AnotherHeaderValue' }
photo = service.first_photo(headers: another_headers).result
p photo['albumId'] # 1

```

### DELETE
```ruby
class SimpleService
  include RestServiceClient
  host 'https://jsonplaceholder.typicode.com'
  delete :delete_photo, '/photos/:id'
end

service = SimpleService.new
service.delete_photo(id: 1).result
```

### POST
```ruby
class SimpleService
  include RestServiceClient
  host 'https://jsonplaceholder.typicode.com'
  post :add_photo, '/photos'
end

service = SimpleService.new
photo = {
    albumId: 1,
    title: 'new photo',
    url: 'http://placehold.it/600/92c952',
    thumbnailUrl: 'http://placehold.it/150/92c952'
}
response = service.add_photo(payload: photo)
p response.status # 201
p response.headers # {:date=>"...}
p response.result
=begin
{
  "albumId"=>1,
  "title"=>"new photo", 
  "url"=>"http://placehold.it/600/92c952",
  "thumbnailUrl"=>"http://placehold.it/150/92c952",
  "id"=>5001
}
=end

```


### PATCH
```ruby
class SimpleService
  include RestServiceClient
  host 'https://jsonplaceholder.typicode.com'
  patch :update_photo_data, '/photos/:id'
end

service = SimpleService.new
updated_photo = service.update_photo_data id: 1, payload: { title: 'new title'}
p updated_photo.result['title']
# "new title"

```

## Debug mode

You can debug mode on for see what is happening

```ruby
class SimpleService
  include RestServiceClient
  debug true
  host 'https://jsonplaceholder.typicode.com'
  headers key1: 'value1', 'key2' => 'value2'
  get :photo, 
      '/photos/:id', 
      params: { id: 1 }, 
      headers: { key3: 'value3' },
      payload: { data: { type: 'get_photo_by_id' }}
end

service = SimpleService.new
service.photo.result
=begin
 ______
|
|  SimpleService is processing GET request to https://jsonplaceholder.typicode.com/photos/1
|    Headers: {:key1=>"value1", "key2"=>"value2", :key3=>"value3"}
|    Payload: {:data=>{:type=>"get_photo_by_id"}}
|
|  SimpleService is processing the response on GET request to https://jsonplaceholder.typicode.com/photos/1
|    Status: 200
|    Body: {
  "albumId": 1,
  "id": 1,
  "title": "accusamus beatae ad facilis cum similique qui sunt",
  "url": "http://placehold.it/600/92c952",
  "thumbnailUrl": "http://placehold.it/150/92c952"
}
|______
=end

```
## Serializer

By the default RestServiceClient uses JSON serializer and returns the arrays and hashes
with key as string

You can use custom serializer.
For do this, create a serializer class with `self.deserialize` method which 
gets the one argument with response body and returns whatever you want.

And you need to add your serializer to your service using: 
`serializer MyAwesomSerializer`

## Errors

```ruby
class SimpleService
  include RestServiceClient
  debug true
  host 'https://jsonplaceholder.typicode.com'
  get :bad_url, '/bad_url'
end

service = SimpleService.new
response = service.bad_url
p response.status # 404
p response.message # "404 Not Found"

```
### Example
```ruby
  class Photo
    attr_accessor :id, :title, :album_id
  end

  class PhotoSerializer
    class Object::String
      def underscore
        gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end
    end

    def self.deserialize(json)
      data = JSON.parse(json)

      return build_photo(data) if data.is_a? Hash
      return data.map { |p| build_photo(p) } if data.is_a? Array
    end

    def self.build_photo(data)
      object = Photo.new
      data.each_with_object(object) do |(k, v), o|
        setter = "#{k.underscore}=".to_sym
        o.send(setter, v) if o.respond_to?(setter)
      end
      object
    end
  end

  class Post
    attr_accessor :id, :title, :user_id
  end

  class PostSerializer
    def self.deserialize(json)
      data = JSON.parse(json)
      object = Post.new
      object.id = data['id']
      object.title = data['title']
      object.user_id = data['userId']
      object
    end
  end


  class MyService
    include RestServiceClient
    host 'https://jsonplaceholder.typicode.com'
    serializer PhotoSerializer
    get :photos, '/photos'
    get :find_photo, '/photos/:id'
    get :find_post, '/posts/:id', serializer: PostSerializer
  end

  service = MyService.new

  p service.find_photo(id: 1).result.album_id # 1
  p service.photos.result.find { |p| p.id == 3 }.id # 1
  p service.find_post(id: 1).result.user_id # 1

``` 


## Response Object

#### Response
If request was completely sent, the class of response be `RestServiceClient::Response`
This object has `:status`, `:headers`, `:body` and `:result` fields.

`:status` contains the number(integer) of http status code.

`:headers` contains the http headers from response.

`:body` will be a http body as plain text.

`:result` will contain deserialized http body.

#### ResponseWithError
If the request failed, the class of response will be RestServiceClient::ResponseWithError
This object has `:status`, `:headers`, `:body`, `:result` and `:message`
All fields except of `:message` are equals to `RestServiceClient::Response` fields.

`:message` will contain the string with error message

You are able to check the response before trying to use result to avoid exceptions:
```ruby
class SimpleService
  include RestServiceClient
  host 'https://jsonplaceholder.typicode.com'
  get :get_photo, '/photos/:id' 
  get :bad_url, '/bad_url' 
end

service = SimpleService.new

response = service.get_photo id: 1
if response.status == 200
  p "Photo with name: #{response.result['name']} has been loaded"
end

response = service.bad_url
if response.status != 200
  p "Something was wrong. Reason: #{response.message}"
  # "Something was wrong. Reason: 404 Not Found" 
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/besya/rest-service-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ServiceClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/service_client/blob/master/CODE_OF_CONDUCT.md).
