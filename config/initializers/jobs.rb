# frozen_string_literal: true

class InitializeJobs < Rails::Railtie
  config.after_initialize do
    #RefreshActiveTasJob.set(wait: 10.seconds).perform_later
    #ClearNotificationsJob.set(wait: 10.seconds).perform_later
  end
end
