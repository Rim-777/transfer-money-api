class AccountSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :user
end
