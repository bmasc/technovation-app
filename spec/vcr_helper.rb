require 'vcr'
require 'webmock/rspec'
require 'elasticsearch_helper'

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock # or :fakeweb
  config.configure_rspec_metadata!
  config.ignore_localhost = true
  config.ignore_hosts *ElasticsearchHelper.hosts
end
