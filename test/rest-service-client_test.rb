require 'test_helper'

class ServiceClientTest < Minitest::Test
  class TestingService
    include RestServiceClient

    host 'https://jsonplaceholder.typicode.com'

    get :photos, '/photos'
    get :find_photo, '/photos/:id'
    post :add_photo, '/photos'
    put :update_photo, '/photos/:id'
    patch :update_photo_data, '/photos/:id'
    delete :delete_photo, '/photos/:id'
  end

  @@service = TestingService.new
  @@testing_photo_object = {
    'albumId' => 1,
    'id' => 1,
    'title' => 'accusamus beatae ad facilis cum similique qui sunt',
    'url' => 'http://placehold.it/600/92c952',
    'thumbnailUrl' => 'http://placehold.it/150/92c952'
  }.freeze

  def test_that_it_has_a_version_number
    refute_nil ::RestServiceClient::VERSION
  end

  def test_dsl_generates_get_method
    assert @@service.respond_to?(:photos)
    assert @@service.respond_to?(:find_photo)
  end

  def test_dsl_generates_post_method
    assert @@service.respond_to?(:add_photo)
  end

  def test_dsl_generates_put_method
    assert @@service.respond_to?(:update_photo)
  end

  def test_dsl_generates_patch_method
    assert @@service.respond_to?(:update_photo_data)
  end

  def test_dsl_generates_delete_method
    assert @@service.respond_to?(:delete_photo)
  end

  def test_get_methods_can_return_a_list
    assert_equal 5000, @@service.photos.count
  end

  def test_get_methods_can_return_an_object
    object = @@testing_photo_object
    assert_equal object, @@service.find_photo(id: 1)
  end

  def test_post_method
    new_object = { 'albumId' => 1, 'title' => 'testing photo' }
    expected_result = new_object.clone.merge('id' => 5001)
    assert_equal expected_result, @@service.add_photo(payload: new_object)
  end

  def test_put_method
    updated_object = @@testing_photo_object.clone.merge('albumId' => 2)
    assert_equal updated_object,
                 @@service.update_photo(id: 1, payload: updated_object)
  end

  def test_patch_method
    fields_to_update = { 'albumId' => 2 }
    expected_result = @@testing_photo_object.clone.merge('albumId' => 2)
    assert_equal expected_result,
                 @@service.update_photo_data(id: 1, payload: fields_to_update)
  end

  def test_delete_method
    empty_hash = {}
    assert_equal empty_hash, @@service.delete_photo(id: 1)
  end

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


  class PhotoService
    include RestServiceClient
    host 'https://jsonplaceholder.typicode.com'
    serializer PhotoSerializer
    get :photos, '/photos'
    get :find_photo, '/photos/:id'
    get :find_post, '/posts/:id', serializer: PostSerializer
  end

  def test_custom_deserialization
    service = PhotoService.new
    photo = service.find_photo id: 1
    last_photo = service.photos.last
    post = service.find_post(id: 1)


    assert_equal 1, photo.album_id
    assert_equal 5000, last_photo.id
    assert_equal 1, post.user_id

  end
end
