class Accounts::TransactionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :amount, :description

  belongs_to :sender,
             serializer: ::AccountSerializer,
             record_type: :account
  belongs_to :receiver,
             serializer: ::AccountSerializer,
             record_type: :account
end
