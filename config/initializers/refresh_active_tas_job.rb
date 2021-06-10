
class MyNewRailtie < Rails::Railtie
  config.after_initialize do
    RefreshActiveTasJob.set(wait: 10.seconds).perform_later
  end
end
