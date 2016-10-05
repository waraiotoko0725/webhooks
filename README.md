# set up ruby,bundler
yum install git gcc gcc-c++ openssl-devel readline-devel  
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv  
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile  
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile  
exec $SHELL -l  
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build  
rbenv install --list  
rbenv install -v 2.2.3  
rbenv rehash  
rbenv versions  
rbenv global 2.2.3  
gem install bundler  

# sinatra, sinatra-contrib unicorn,
gem install sinatra  
gem install sinatra-contrib  
gem install unicorn  

# run app
unicorn -c unicorn.conf -D  

# brows access
http://localhost:4567/hello
