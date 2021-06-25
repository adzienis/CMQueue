# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '65610551147-20gdbl7orgd9hu1uo8u9st71f85oql8g.apps.googleusercontent.com',
           'DED-SKwMgtWz2419Ek-aMu9r', prompt: :consent
end
