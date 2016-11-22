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
    return App.deploy(branch)
  end

  get '/test' do
    branch = request["branch"]
    return App.deploy(branch)
  end

  def App.deploy(branch)
    script_dir = File.expand_path(File.dirname(__FILE__))
    vhost_dir = "/var/www/dev.comsuite.jp/"

    # check branch (exclude develop,master)
    excludeBranch = ["develop", "master"]
    if excludeBranch.include?(branch)
      return "This branch is not deployed. branch: #{branch}"
    end

    app_dir = vhost_dir + branch
    result = ""
    # dir check branch
    if Dir.exist?(app_dir)
      # exists
      Dir.chdir(app_dir) do
        result = `git pull origin #{branch}`
      end
    else
      # not exists
      Dir.chdir(vhost_dir) do
        `git clone -b #{branch} git@github.com:e-life/cs2.git ./#{branch}`
        `chmod -R 777 #{app_dir}/application/var/`
        `chmod -R 777 #{app_dir}/public/_var/`
        `sed -i -e "s/dev-cs2\.comsuite\.jp/#{branch}\.dev\.comsuite\.jp/g" #{app_dir}/application/configs/application.ini`
        `cp #{script_dir}/template/.htaccess #{app_dir}/public/`
        `sed -i -e "s/BRANCH_NAME/#{branch}/g" #{app_dir}/public/.htaccess`
        result = "clone and checkout #{branch}"
      end
    end

    return "dir: #{app_dir}\nbranch: #{branch}\result: #{result}"
  end

end

App.run!
