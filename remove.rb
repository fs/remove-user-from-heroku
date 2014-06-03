#!/usr/bin/env ruby

require 'bundler/setup'
require 'heroku-api'
require 'active_support/core_ext/hash/keys'

require 'byebug'

class ApiClient
  def initialize(heroku)
    @heroku = heroku
  end

  def applications
    @heroku.get_apps.body.map do |application|
      Application.new(application)
    end
  end

  def collaborators(application)
    @heroku.get_collaborators(application.name).body.map do |collaborator|
      Colloborator.new(collaborator)
    end
  end

  def remove_collaborator(application, collaborator)
    # @heroku.delete_collaborator(application, collaborator)
  end
end

class Application
  def initialize(data)
    @data = data.symbolize_keys
  end

  def name
    @data[:name]
  end
end

class Colloborator
  def initialize(data)
    @data = data.symbolize_keys
  end

  def email
    @data[:email]
  end
end

class RemoveColloborator
  def initialize(api_client, collaborator)
    @api_client = api_client
    @collaborator = collaborator
  end

  def process!
    applications.each do |application|
      remove(application) if exists?(application)
    end
  end

  private

  def applications
    @api_client.applications
  end

  def remove(application)
    puts "  Remove: #{@collaborator.email} from #{application.name}"
    puts
    # @api_client.remove_collaborator(application, @collaborator)
  end

  def exists?(application)
    puts "Checking #{application.name} for #{@collaborator.email}..."

    @api_client.collaborators(application)
      .map(&:email)
      .include?(@collaborator.email)
  end
end

api_key = ENV['KEY']
collaborator = Colloborator.new(email: ENV['EMAIL'])

heroku = Heroku::API.new(api_key: api_key)
api_client = ApiClient.new(heroku)
remove = RemoveColloborator.new(api_client, collaborator)

remove.process!
