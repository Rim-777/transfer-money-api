# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Accounts::TransactionsController, type: :request do
  let(:response_body) { JSON.parse(response.body, symbolize_names: true) }

  describe 'POST /api/accounts/transactions' do
    let(:bearer_token) do
      jwt = Users::Sessions::New.call(
        email: sender_user.email,
        password: user_password
      ).jwt

      "Bearer #{jwt}"
    end

    let(:headers) do
      {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Authorization' => bearer_token
      }
    end

    def request
      post '/api/accounts/transactions',
           headers: headers,
           params: params.to_json,
           xhr: true
    end

    let(:user_password) { 'valid-password' }
    let!(:sender_user) do
      create(
        :user,
        first_name: 'Sacha Baron',
        last_name: 'Cohen',
        password: user_password
      )
    end

    let!(:receiver_user) { create(:user, first_name: 'David', last_name: 'Gilmour') }
    let(:amount) { 10_000.00 }
    let!(:sender) { create(:account, balance: amount, user: sender_user) }
    let!(:receiver) { create(:account, balance: 0, user: receiver_user) }

    let(:params) do
      {
        data: {
          attributes: {
            sender_id: sender.id,
            receiver_id: receiver.id,
            amount: amount,
            description: 'For having fun'
          }
        }
      }
    end

    context 'success' do
      before { request }

      let(:json_schema) { TransactionSchema.call }

      it 'returns an expected http code' do
        expect(response.code).to eq('201')
      end

      it 'matches schema' do
        expect { JSON::Validator.validate!(json_schema, response_body) }.not_to raise_error
      end

      it 'returns an expected relationships' do
        relationships = response_body[:data][:relationships]
        expect(relationships[:sender][:data][:id]).to eq(sender.id.to_s)
        expect(relationships[:receiver][:data][:id]).to eq(receiver.id.to_s)
      end

      it 'returns an expected attributes' do
        expect(response_body[:data][:attributes])
          .to eq(
            {
              amount: '10000.0',
              description: 'For having fun'
            }
          )
      end

      it 'returns an expected included' do
        receiver_user_id = receiver_user.id.to_s
        sender_user_id = sender_user.id.to_s
        receiver_id = receiver.id.to_s
        sender_id = sender.id.to_s
        expect(response_body[:included])
          .to contain_exactly(
            {
              attributes: {
                first_name: 'David',
                last_name: 'Gilmour'
              },
              id: receiver_user_id,
              type: 'user'
            },
            {
              id: receiver_id,
              relationships: {
                user: {
                  data: {
                    id: receiver_user_id,
                    type: 'user'
                  }
                }
              },
              type: 'account'
            },
            {
              attributes: {
                first_name: 'Sacha Baron',
                last_name: 'Cohen'
              },
              id: sender_user_id,
              type: 'user'
            },
            {
              id: sender_id,
              relationships: {
                user: {
                  data: {
                    id: sender_user_id,
                    type: 'user'
                  }
                }
              },
              type: 'account'
            }
          )
      end
    end

    context 'failure' do
      context '401 unauthorized user' do
        before do
          headers['Authorization'] = 'some invalid token'
          request
        end

        let(:expected_http_code) { '401' }
        let(:expected_response_body) do
          { errors: [{ detail: 'Invalid authorisation' }] }
        end

        it_behaves_like 'api/common_response_matching'
      end

      context '400 invalid params' do
        let(:expected_http_code) { '400' }

        it_behaves_like 'api/missing_root_keys'

        context 'invalid sender id' do
          let(:key) { :sender_id }
          context 'missing key' do
            before do
              params[:data][:attributes].delete(key)
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'is missing')
            end

            it_behaves_like 'api/common_response_matching'
          end

          context 'invalid value' do
            before do
              params[:data][:attributes][key] = 'some string'
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'must be an integer')
            end

            it_behaves_like 'api/common_response_matching'
          end
        end

        context 'invalid receiver id' do
          let(:key) { :receiver_id }

          context 'missing key' do
            before do
              params[:data][:attributes].delete(key)
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'is missing')
            end

            it_behaves_like 'api/common_response_matching'
          end

          context 'invalid value' do
            before do
              params[:data][:attributes][key] = 'some string'
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'must be an integer')
            end

            it_behaves_like 'api/common_response_matching'
          end
        end

        context 'invalid amount' do
          let(:key) { :amount }

          context 'missing key' do
            before do
              params[:data][:attributes].delete(key)
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'is missing')
            end

            it_behaves_like 'api/common_response_matching'
          end

          context 'invalid value' do
            before do
              params[:data][:attributes][key] = 'some string'
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'must be a float')
            end

            it_behaves_like 'api/common_response_matching'
          end

          context 'negative value' do
            before do
              params[:data][:attributes][key] = -1.054
              request
            end

            let(:expected_response_body) do
              ApiMacros.code_400_message_base(key, 'cannot be negative')
            end

            it_behaves_like 'api/common_response_matching'
          end
        end
      end

      context '404 resource not found' do
        let(:expected_http_code) { '404' }

        shared_examples :not_found do
          let(:wrong_id) { 79_762_349_762_346 }

          before do
            params[:data][:attributes][resource_id] = wrong_id
            request
          end

          let(:expected_response_body) do
            { errors: [{ detail: "Couldn't find Account with 'id'=#{wrong_id}" }] }
          end

          it_behaves_like 'api/common_response_matching'
        end

        context 'receiver' do
          let(:resource_id) { :receiver_id }
          include_examples :not_found
        end

        context 'sender' do
          let(:resource_id) { :sender_id }
          include_examples :not_found
        end
      end
    end
  end
end
