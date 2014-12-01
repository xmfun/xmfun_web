require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:foo)
    @other_user = users(:bar)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'a', user.name
    end
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@user)

    get users_path
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a', user.name
    end
    assert_select 'a', text: 'delete'
    user = first_page_of_users.first
    assert_difference 'User.count', -1 do
      delete user_path(user)
    end
  end

  test "index as non-admin" do
    log_in_as(@other_user)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
