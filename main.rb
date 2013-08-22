require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do 
	def calculate_total(cards)
  		arr = cards.map{|e| e[1]}
  
  		total = 0 
  		arr.each do |value|
    		if value == "A"
      			total += 11
    		elsif value.to_i == 0
      			total += 10 
    		else 
      			total += value.to_i
    		end 
  		end 
  
  	# Modified the Ace value 
  	arr.select{|e| e = "A"}.count.times do 
    	total -= 10 if total > 21 
  	end 
  
  	total 
	end 
end 

before do 
	@show_hit_or_stay_buttons = true 
end 

get '/' do 
	if session[:player_name]
		redirect '/game'
	else 
		redirect '/new_player'
	end 
end 

get '/new_player' do 
	erb :new_player
end 

post '/new_player' do 
	session[:player_name] = params[:player_name]
	redirect '/game'
end 

get '/game' do 
	# create a deck and put it in session 
	suits = ['H','D','C','S']
	values = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
	session[:deck] = suits.product(values).shuffle!

	# deal cards 
	session[:dealer_cards] = []
	session[:player_cards] = []
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop

	erb :game
end

post '/game/player/hit' do 
	session[:player_cards] << session[:deck].pop 
	if calculate_total(session[:player_cards]) > 21 
		@error = "You are busted!."
		@show_hit_or_stay_buttons = false 
	end 

	erb :game
end 

post '/game/player/stay' do 
	@success = "You opted to stay." 
	@show_hit_or_stay_button = false 
	erb :game 
end 
