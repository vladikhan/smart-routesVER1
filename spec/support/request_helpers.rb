module RequestHelpers
  def expect_flash_notice(message)
    expect(flash[:notice]).to eq(message)
  end

  def expect_flash_alert(message)
    expect(flash[:alert]).to eq(message)
  end

  def expect_redirect_with_notice(path, message)
    expect(response).to redirect_to(path)
    expect(flash[:notice]).to eq(message)
  end

  def expect_redirect_with_alert(path, message)
    expect(response).to redirect_to(path)
    expect(flash[:alert]).to eq(message)
  end

  def json_response
    JSON.parse(response.body)
  end

  def expect_json_success(count_key = nil, expected_count = nil)
    json = json_response
    expect(json['success']).to be true
    expect(json[count_key]).to eq(expected_count) if count_key
  end

  def expect_json_error(message)
    json = json_response
    expect(json['success']).to be false
    expect(json['error']).to eq(message)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end

