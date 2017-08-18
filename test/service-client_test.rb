require 'test_helper'

class ServiceClientTest < Minitest::Test
  class TestingService
    include ServiceClient

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
    refute_nil ::ServiceClient::VERSION
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
end
