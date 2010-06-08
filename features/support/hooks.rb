Before('@javascript') do
  FakeWeb.allow_net_connect = true
end

After do
  FakeWeb.clean_registry
  FakeWeb.allow_net_connect = false
  AppEngine::URLFetch.clean_registry
end
