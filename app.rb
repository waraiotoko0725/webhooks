require 'rubygems'
require 'sinatra/base'
require 'sinatra/reloader'
require 'logger'
require 'json'

logger = Logger.new('sinatra.log')

class App < Sinatra::Base

  set :environment, :production

  post '/community' do
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
    return "branch is null" if branch.nil?

    script_dir = Dir.pwd
    vhost_dir = "/var/www/dev-community-lavida_virtual/"
    app_dir = vhost_dir + branch

    # check branch (exclude develop)
    excludeBranch = ["develop"]
    if excludeBranch.include?(branch)
      return "This branch is not deployed. branch: #{branch}"
    end

    if branch == "master"
      app_dir = "/var/www/dev-community-lavida/"
    end

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
        `git clone -b #{branch} git@github.com:e-life/lavida-community.git ./#{branch}`
        `chmod -R 777 #{app_dir}/application/var/`
        `chmod -R 777 #{app_dir}/public/_var/`
        `sed -i -e "s/dev\.community\.lavida\.jp/#{branch}\.dev\.community\.lavida\.jp/g" #{app_dir}/application/configs/application.ini`
        `cp #{script_dir}/template/.htaccess #{app_dir}/public/`
        `sed -i -e "s/BRANCH_NAME/#{branch}/g" #{app_dir}/public/.htaccess`
        result = "clone and checkout #{branch}"
      end
    end

    return "dir: #{app_dir}\nbranch: #{branch}\result: #{result}"
  end

  post '/base' do
    http_headers = request.env.select { |k, v| k.start_with?('HTTP_') }
    logger.info http_headers
    payload = JSON.parse(params[:payload])
    return "payload is null." if payload.empty?

    branch = payload["ref"][/refs\/heads\/(.*)/, 1]
    if branch === "master" then
      # merge & push
      return `/bin/bash /home/git/_scripts/merge_lavida_library_assets_from_base.sh -y`
    else
      #work_dir = "/home/git/webhooks/work_repo/"
      #app_dir = "/var/www/dev-community-lavida/"
      #library_dir = "application/library/Lavida/"
      #Dir.chdir(work_dir) do
      #  `git checkout -b #{branch}` if `git branch | grep "*" | grep #{branch}`.empty?
      #  `git pull origin #{branch}`
      #end
      return `not sync`
    end
  end

end

App.run!
