require 'sinatra'
require 'sinatra/reloader'

get '/' do
  branch = "master"
  app_dir = "/var/www/dev-lavida"

  if branch === "master" then
    return "not a git repository." if `cd #{app_dir} && ls -la | grep ".git"`.empty?
    Dir.chdir(app_dir){
      return `git pull origin #{branch}`
    }
    return  "git pull " << branch << " to " << app_dir

  elsif !(name = branch[/\d{4,10}_(hkobayashi|kyaegashi|hsuzuki|hmurano|zynas)/, 1]).nil?
    return "Not a git repository." if `cd #{app_dir}_#{name} && ls -la | grep ".git"`.empty?
    Dir.chdir(app_dir << "_" << name){
      `git checkout -b #{branch}` if `git branch | grep "*" | grep #{branch}`.empty?
      return `git pull origin #{branch}`
    }

  else
    return "branch name is not matched. " << branch
  end
end
