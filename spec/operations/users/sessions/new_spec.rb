# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::Sessions::New do
  let(:operation) { described_class.new(params) }
  let!(:user) { create(:user, email: 'valid@email.test', password: 'valid-password') }

  describe '#call' do
    def operation_call
      operation.call
    end

    let(:params) do
      {
        email: user.email,
        password: 'valid-password'
      }
    end

    context 'success' do
      let(:jwt_format) do
        %r{^[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_.+/=]*$}
      end

      it 'looks like success' do
        expect(operation_call).to be_success
      end

      it 'returns a user' do
        operation_call
        expect(operation.user).to eq(user)
      end

      it 'returns a valid jwt format' do
        expect(operation_call.jwt).to match(jwt_format)
      end

      context 'jwt stubbing' do
        let(:expected_payload) do
          {
            iss: 'Transfer Money Api',
            sub: user.id,
            email: user.email,
            iat: 1_000_000,
            exp: 1_000_600
          }
        end

        let(:stubbed_jwt) { 'some jwt token' }

        let(:stubbed_signature) { 'OpenSSL::PKey::EC' }

        before do
          allow(OpenSSL::PKey::EC).to receive(:new).and_return(stubbed_signature)
          allow(Time).to receive_message_chain(:now, :utc, :to_i).and_return(1_000_000)
        end

        it 'generates a jwt token' do
          expect(JWT).to receive(:encode).with(expected_payload, stubbed_signature, 'ES384')
          operation_call
        end

        it 'assigns jwt to an operation jwt' do
          allow(JWT).to receive(:encode).and_return(stubbed_jwt)
          expect(operation_call.jwt).to eq(stubbed_jwt)
        end
      end
    end

    context 'failure' do
      shared_examples :failure do
        it 'looks like failure' do
          expect(operation_call).to be_failure
        end

        it 'contains expected errors' do
          expect(operation_call.errors).to eq(['Invalid email or password'])
        end

        it 'does not generate jwt' do
          expect(operation).not_to receive(:create_jwt!)
          operation_call
        end

        it 'does not set an operation jwt' do
          expect(operation_call.jwt).to be_nil
        end
      end

      context 'user does not exist' do
        before do
          params[:email] = 'does.not.exist@email.com'
        end

        it 'does not set an operation user' do
          expect(operation_call.user).to be_nil
        end

        include_examples :failure
      end

      context 'invalid password' do
        before do
          params[:password] = 'invalid password'
        end

        include_examples :failure
      end
    end
  end
end
