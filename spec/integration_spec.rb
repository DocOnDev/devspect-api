require_relative 'spec_helper'

require './app'
require 'rack'
require 'rack/test'

set :environment, :test

describe 'Integration' do
  include Rack::Test::Methods

  def app
    DevSpectAPI
  end

  describe 'creating a story' do
    it 'responds with success' do
      post '/pivotal-tracker', Fixtures.create_story_xml

      assert last_response.ok?
      assert_equal "OK", last_response.body
    end

    it 'creates database records' do
    end
  end

  describe 'estimating a story' do
    it 'responds with success' do
      post "/pivotal-tracker", Fixtures.update_estimate_xml

      assert last_response.ok?
      assert_equal "OK", last_response.body
    end

    it 'updates the points value for the story' do
    end
  end
end
