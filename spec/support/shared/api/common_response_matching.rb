# frozen_string_literal: true

shared_examples 'api/common_response_matching' do
  it 'responds with an expected http code' do
    expect(response.code).to eq(expected_http_code)
  end

  it 'responds with an expected response body' do
    expect(response_body).to eq(expected_response_body)
  end
end
