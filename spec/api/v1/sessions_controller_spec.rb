# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  let(:response_body) { JSON.parse(response.body, symbolize_names: true) }
  extend ApiMacros
  let(:headers) do
    { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  describe 'POST api/session' do
    let(:password) { 'valid-password' }
    let!(:user) do
      create(
        :user,
        email: 'valid@email.com',
        password: password,
        first_name: 'Timo',
        last_name: 'Moss'
      )
    end

    let(:params) do
      {
        data: {
          attributes: {
            email: user.email,
            password: password
          }
        }
      }
    end

    def request
      post '/api/sessions',
           headers: headers,
           params: params.to_json,
           xhr: true
    end

    context 'success' do
      let(:access_token_header) { 'X-AccessToken' }
      context 'integration' do
        let(:expected_http_code) { '201' }
        let(:expected_response_body) do
          {
            data: {
              attributes: {
                first_name: 'Timo',
                last_name: 'Moss'
              },
              id: user.id.to_s,
              type: 'user'
            }
          }
        end

        before { request }

        it_behaves_like 'api/common_response_matching'

        it 'returns X-AccessToken header' do
          expect(response.headers).to include(access_token_header)
        end

        it 'returns X-AccessToken header with a present value' do
          expect(response.headers[access_token_header]).to be_present
        end
      end

      context 'jwt stubbing' do
        let(:jwt_value) { 'some jwt token' }
        let(:operation_double) { double(success?: true, user: user, jwt: jwt_value) }

        before do
          allow(Users::Sessions::New).to receive(:call).and_return(operation_double)
        end

        it 'returns an expected access token' do
          request
          expect(response.headers[access_token_header]).to eq(jwt_value)
        end
      end
    end

    context 'failure' do
      context '400' do
        let(:expected_http_code) { '400' }

        it_behaves_like 'api/missing_root_keys'

        context 'data/attributes/email key' do
          let(:key) { :email }

          context 'missing' do
            before do
              params[:data][:attributes].delete(key)
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'is missing')
            end

            it_behaves_like 'api/common_response_matching'
          end

          context 'invalid_format' do
            before do
              params[:data][:attributes][:email] = 'invalid@email'
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'invalid format')
            end

            it_behaves_like 'api/common_response_matching'
          end
        end

        context 'data/attributes/password key' do
          let(:key) { :password }
          context 'missing' do
            before do
              params[:data][:attributes].delete(key)
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'is missing')
            end

            it_behaves_like 'api/common_response_matching'
          end

          context 'invalid length' do
            before do
              params[:data][:attributes][key] = '12345'
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'must contain at least 6 symbols')
            end

            it_behaves_like 'api/common_response_matching'
          end
        end
      end

      context '422' do
        let(:expected_http_code) { '422' }
        let(:message) { 'some error message' }
        let(:operation_double) { double(success?: false, errors: [message]) }

        before do
          allow(Users::Sessions::New).to receive(:call).and_return(operation_double)
          request
        end

        let(:expected_response_body) do
          { errors: [{ detail: message }] }
        end

        it_behaves_like 'api/common_response_matching'
      end
    end
  end
end
