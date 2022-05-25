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

    context 'success' do
      let(:bearer_token) do
        jwt = Users::Sessions::New.call(
          email: user.email,
          password: password
        ).jwt

        "Bearer #{jwt}"
      end

      before do
        request.headers.merge!('Authorization' => bearer_token)
        get :index
      end

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
      it 'looks like success' do
        expect(response.status).to eq(200)
      end

      it 'responds with current user data' do
        expect(response_body).to eq(expected_response_body)
      end
    end

    context 'failure' do
      shared_examples :unauthorized do
        it 'looks like unauthorised' do
          expect(response.status).to eq(401)
        end

        it 'responds with expected response body' do
          expect(response.body).to eq(response_body)
        end
      end

      context 'invalid authorisation' do
        let(:response_body) do
          '{"errors":[{"detail":"Invalid authorisation"}]}'
        end

        context 'missing authorisation header' do
          before do
            get :index
          end

          include_examples :unauthorized
        end

        context 'null authorisation header value' do
          before do
            request.headers.merge!('Authorization' => nil)
            get :index
          end

          include_examples :unauthorized
        end

        context 'invalid authorisation header value' do
          before do
            request.headers.merge!('Authorization' => 'Bearer eyJhbGciOiJFUzM4NCJ9')
            get :index
          end

          include_examples :unauthorized
        end
      end
    end
  end
end
