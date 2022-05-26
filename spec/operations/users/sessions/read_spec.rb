# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::Sessions::Read do
  let(:operation) { described_class.new(params) }
  let(:password) { 'valid-password' }
  let(:expiration) { 600 }

  let!(:user) { create(:user, password: password) }

  describe '#call' do
    def operation_call
      operation.call
    end

    let(:jwt) do
      Users::Sessions::New.call(
        email: user.email,
        password: password,
        expiration: expiration
      ).jwt
    end

    let(:bearer_token) { "Bearer #{jwt}" }
    let(:params) { { token: bearer_token } }

    context 'success' do
      it 'looks like success' do
        expect(operation_call).to be_success
      end

      it 'does not contain errors' do
        expect(operation_call.errors).to be_empty
      end

      it 'returns a user' do
        operation_call
        expect(operation.user).to eq(user)
      end
    end

    context 'failure' do
      shared_examples :failure do
        it 'looks like failure' do
          expect(operation_call).to be_failure
        end

        it 'contains expected errors' do
          expect(operation_call.errors).to eq([expected_error_massage])
        end

        it 'does not set an operation user' do
          expect(operation_call.user).to be_nil
        end
      end

      context 'token is invalid ' do
        let(:expected_error_massage) { 'Invalid authorisation' }

        context 'invalid format' do
          let(:bearer_token) { jwt }
          include_examples :failure
        end

        context 'token hs not been given' do
          let(:bearer_token) { nil }
          include_examples :failure
        end

        context 'token hs not been given' do
          let(:expiration) { -200 }
          let(:expected_error_massage) { 'Expired authorisation' }

          include_examples :failure
        end
      end
    end
  end
end
