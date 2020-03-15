require 'test_helper'

class DownloaderControllerTest < ActionDispatch::IntegrationTest
  test "should get downloadYoutubeVideo" do
    get downloader_downloadYoutubeVideo_url
    assert_response :success
  end

end
