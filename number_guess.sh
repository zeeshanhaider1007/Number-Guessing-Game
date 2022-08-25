#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
secret_number=$(( RANDOM % 1000 + 1 ))
echo "Enter your username:"
read USERNAME

# play game
function PLAY_GAME(){
echo "${1}"
user_input=0
while [[ $secret_number -ne $user_input ]]
do

read user_input
while [[ ! $user_input =~ ^[0-9]+$ ]]
do
echo "$2"
read user_input
done

if [[ $secret_number -lt $user_input ]]
then
echo "$3"
elif [[ $secret_number -gt $user_input ]]
then
echo "$4"
fi
((number_of_guesses=number_of_guesses+1))
done

#return $number_of_guesses;

}
# fetch user data
user_data=$($PSQL "select user_id, username, games_played, best_game from users where username = '$USERNAME'")
guess="Guess the secret number between 1 and 1000:"
not_integer="That is not an integer, guess again:"
lower="It's lower than that, guess again:"
higher="It's higher than that, guess again:"
if [[ -z $user_data ]]
then
## new user
echo -e "Welcome, $USERNAME! It looks like this is your first time here."
number_of_guesses=0
PLAY_GAME "$guess" "$not_integer" "$lower" "$higher"
echo -e "\nYou guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"
insert_user=$($PSQL "insert into users(username, games_played, best_game) values('$USERNAME', 1, $number_of_guesses)")

else

IFS='|' read -ra ADDR <<< "$user_data"
username=${ADDR[1]}
games_played=${ADDR[2]}
best_game=${ADDR[3]}
number_of_guesses=0
echo -e "\nWelcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
PLAY_GAME "$guess" "$not_integer" "$lower" "$higher"
if [[ $best_game -gt $number_of_guesses ]]
then
best_game=$number_of_guesses
fi
((games_played=games_played+1))
insert_user=$($PSQL "update users set games_played = $games_played, best_game = $best_game where username = '$username'")
echo -e "\nYou guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!"
fi