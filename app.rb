require 'sinatra'
require 'sinatra/reloader'

get '/' do
  branch = "20160521_hkobayashi_test"
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
