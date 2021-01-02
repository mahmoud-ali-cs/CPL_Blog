# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
             headers: :any,
             expose: %w[access-token client uid],
             methods: %i[get post patch put]
  end
end
