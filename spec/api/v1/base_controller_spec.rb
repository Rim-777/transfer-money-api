# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :controller do
  let(:response_body) { JSON.parse(response.body, symbolize_names: true) }

  context 'authentication' do
    controller(described_class) do
      include JwtAuthentication

      def index
        serializer = UserSerializer.new(current_user)
        render json: serializer.serialized_json
      end
    end

    let(:password) { 'valid-password' }
    let!(:user) { create(:user, password: password) }
    let(:expiration) { 600 }

    let(:bearer_token) do
      jwt = Users::Sessions::New.call(
        email: user.email,
        password: password,
        expiration: expiration
      ).jwt

      "Bearer #{jwt}"
    end

    context 'success' do
      before do
        request.headers.merge!('Authorization' => bearer_token)
        get :index
      end

      let(:expected_http_code) { '200' }

      let(:expected_response_body) do
        {
          data: {
            attributes: {
              first_name: 'Kianu',
              last_name: 'Rives'
            },
            id: user.id.to_s,
            type: 'user'
          }
        }
      end

      it_behaves_like 'api/common_response_matching'
    end

    context 'failure' do
      context 'unauthorized' do
        let(:expected_http_code) { '401' }

        context 'invalid authorisation' do
          let(:expected_response_body) do
            { errors: [{ detail: 'Invalid authorisation' }] }
          end

          context 'missing authorisation header' do
            before do
              get :index
            end

            it_behaves_like 'api/common_response_matching'
          end

          context 'null authorisation header value' do
            before do
              request.headers.merge!('Authorization' => nil)
              get :index
            end

            it_behaves_like 'api/common_response_matching'
          end

          context 'invalid authorisation header value' do
            before do
              request.headers.merge!('Authorization' => 'Bearer eyJhbGciOiJFUzM4NCJ9')
              get :index
            end

            it_behaves_like 'api/common_response_matching'
          end
        end

        context 'expired authorisation' do
          let(:expiration) { -200 }

          let(:expected_response_body) do
            { errors: [{ detail: 'Expired authorisation' }] }
          end

          before do
            request.headers.merge!('Authorization' => bearer_token)
            get :index
          end

          it_behaves_like 'api/common_response_matching'
        end
      end
    end
  end
end
