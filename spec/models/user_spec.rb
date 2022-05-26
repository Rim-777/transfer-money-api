require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:accounts).inverse_of(:user).dependent(:destroy) }
end
