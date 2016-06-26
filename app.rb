require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'logger'
require 'json'

logger = Logger.new('sinatra.log')

class App < Sinatra::Base

  set :environment, :production

  post '/' do
    http_headers = request.env.select { |k, v| k.start_with?('HTTP_') }
    logger.info http_headers
    payload = JSON.parse(params[:payload])
    branch = payload["ref"][/refs\/heads\/(.*)/, 1]
    app_dir = "/var/www/dev-lavida"

    if !(name = branch[/\d{4,10}_(hkobayashi|kyaegashi|hsuzuki|hmurano|zynas|tyamamoto)/, 1]).nil?
      app_dir = app_dir << "_" << name
    elsif branch != "master" then
      # not deploy branch
      return "branch name is not matched. " << branch
    end

    # repository  check
    return "not a git repository." if `cd #{app_dir} && ls -la | grep ".git"`.empty?

    result = ""
    # checkout brach and pull branch
    Dir.chdir(app_dir) do
      `git checkout -b #{branch}` if `git branch | grep "*" | grep #{branch}`.empty?
      result = `git pull origin #{branch}`
    end

    return "dir: " << app_dir << "\n" << "branch: " << branch << "\n" << result
  end

  get '/hello' do
    'Hello!'
  end

end

App.run!
