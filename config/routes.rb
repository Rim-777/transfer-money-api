Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  api vendor_string: 'transfer-money-api', default_version: 1 do
    version 1 do
      cache as: 'v1' do
      end
    end
  end
end
