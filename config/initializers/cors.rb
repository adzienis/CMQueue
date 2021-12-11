Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "accounts.google.com"
    resource "*", headers: :any, methods: [:get, :post, :patch, :put]
  end
end
