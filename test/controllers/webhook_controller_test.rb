require "test_helper"

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test "should get ping" do
    get webhook_ping_url
    assert_response :success
  end
end
