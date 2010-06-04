After do
  FakeWeb.clean_registry
  AppEngine::URLFetch.clean_registry
end
