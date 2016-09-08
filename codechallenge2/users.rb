require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "yaml"

before do
  @users_details = YAML.load_file('users.yaml')
  @users = @users_details.keys
end

helpers do
  def count_interest
    @total_interest = 0
    @users.each do |user|
      @total_interest += @users_details[user][:interests].size
    end
    [@users.size, @total_interest]
  end
end

get '/' do
  redirect '/users'
end

get '/users' do
  erb :home
end

get '/users/:user_name' do
  @name = params[:user_name]
  @user_info = @users_details[@name.to_sym]
  @email = @user_info[:email]
  @interests = @user_info[:interests].join(', ')

  erb :users
end
