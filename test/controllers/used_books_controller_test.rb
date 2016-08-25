require 'test_helper'

class UsedBooksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get used_books_index_url
    assert_response :success
  end

end
