# Rest Service Client

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
    headers 'Authorization' => 'OAuth 1111|111'

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

p service.first_photo['id']
# 1

p service.second_photo['id']
# 2

p service.photo(id: 10)['id']
# 10

```

### GET

```ruby
class SimpleService
  include RestServiceClient
  host 'https://jsonplaceholder.typicode.com'
  get :photo, '/photos/:id', { id: 1 }
end

service = SimpleService.new
p service.photo['id']         # 1
p service.photo(id: 2)['id']  # 2
```

```ruby
class SimpleService
  include RestServiceClient
  host 'https://jsonplaceholder.typicode.com'
  
  get :first_photo, '/photos/1', {}, { Authentication: 'my-token' }
end

service = SimpleService.new
# Sends the request to 'https://jsonplaceholder.typicode.com/photos/1'
# includes Headers: { 'Authentication': 'my-token' }
p service.first_photo['albumId'] # 1

# Sends the request to 'https://jsonplaceholder.typicode.com/photos/1'
# includes Headers: { 
#   'Authentication': 'my-token',
#   'AnotherHeaderKey': 'AnotherHeaderValue' 
# }
another_headers = { AnotherHeaderKey: 'AnotherHeaderValue' }
photo = service.first_photo(headers: another_headers)
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
service.delete_photo id: 1
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
p service.add_photo payload: photo
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
p updated_photo['title']
# "new title"

```

## Debug mode

You can debug mode on for see what is happening

```ruby
class SimpleService
  include RestServiceClient
  debug true
  host 'https://jsonplaceholder.typicode.com'
  headers key1: 'value1', 'key2': 'value2'
  get :photo, '/photos/1'
end

service = SimpleService.new
service.photo
=begin
 ______
|
|  SimpleService is processing GET request to https://jsonplaceholder.typicode.com/photos/1
|    Headers: {:key1=>"value1", :key2=>"value2"}
|    Payload: {}
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


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/besya/rest-service-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ServiceClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/service_client/blob/master/CODE_OF_CONDUCT.md).
