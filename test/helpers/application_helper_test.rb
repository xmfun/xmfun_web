require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         'XmfunWeb'
    assert_equal full_title("Help"), 'XmfunWeb | Help'
  end
end
