# frozen_string_literal: true

shared_examples 'api/missing_root_keys' do
  context 'missing root key' do
    before do
      params.delete(:data)
      request
    end

    let(:expected_response_body) do
      { errors: [{ detail: { data: ['is missing'] } }] }
    end

    it_behaves_like 'api/common_response_matching'
  end

  context 'missing data/attributes key' do
    before do
      params[:data].delete(:attributes)
      request
    end

    let(:expected_response_body) do
      { errors: [{ detail: { data: { attributes: ['is missing'] } } }] }
    end

    it_behaves_like 'api/common_response_matching'
  end
end
