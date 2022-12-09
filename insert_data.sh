#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams,games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
  #Get Team ID
    WINNING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #If not found
    if [[ -z $WINNING_TEAM_ID ]]
    then
      #Adding it to the database if not
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        WINNING_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        echo -e "\n'$WINNER' inserted from winner col"
      fi
    fi
    #Listing opponent teams in current database
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id from teams WHERE name='$OPPONENT'")
    #Verifying if team is already added to the database
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      #Adding it to the database if not
      INSERT_TEAM_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_OPPONENT == "INSERT 0 1" ]]
      then
        OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        echo -e "\n'$OPPONENT' inserted from OPPONENT col"
      fi
    fi
    INSERT_GAME=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,opponent_goals,winner_goals) VALUES($YEAR,'$ROUND',$WINNING_TEAM_ID,$OPPONENT_TEAM_ID,$OPPONENT_GOALS,$WINNER_GOALS)")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "Games Inserted"
    fi
  fi
done 