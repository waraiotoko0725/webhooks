require 'sinatra'
require 'sinatra/reloader'
require 'logger'
require 'json'

set :environment, :production

logger = Logger.new('/var/tmp/sinatra.log')

get '/' do
  http_headers = request.env.select { |k, v| k.start_with?('HTTP_') }
  logger.info http_headers
  payload = JSON.parse(params[:payload])
  branch = payload["ref"][/refs\/heads\/(.*)/, 1]
  app_dir = "/var/www/dev-lavida"

  if !(name = branch[/\d{4,10}_(hkobayashi|kyaegashi|hsuzuki|hmurano|zynas)/, 1]).nil?
    app_dir = app_dir << "_" << name
  elsif branch != "master" then
    # not deploy branch
    return "branch name is not matched. " << branch
  end

  # repository  check
  return "not a git repository." if `cd #{app_dir} && ls -la | grep ".git"`.empty?

  # checkout brach and pull branch
  Dir.chdir(app_dir){
    `git checkout -b #{branch}` if `git branch | grep "*" | grep #{branch}`.empty?
    return "dir: " << app_dir << "\n" << "branch: " << branch << "\n" << `git pull origin #{branch}`
  }

end
