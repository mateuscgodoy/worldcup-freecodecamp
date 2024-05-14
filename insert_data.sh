#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams;")

# Loop over the contents from the CSV file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Checking if we are NOT on the first line
  if [[ $YEAR != year ]]
  then
    # Look for the team_id for the Winner
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    # If not found
    if [[ -z $WINNER_ID ]]
    then
      # Insert the new team into the table
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER');")

      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "New team added: $WINNER"
      fi
    fi

    # Look for the team_id for the Opponent
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")

    # If not found
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT');")

      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo "New team added: $OPPONENT"
      fi
    fi

    # Get the team_id for Winner and Opponent
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';") 
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    
    # Insert information into the Games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")

    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "New game added: $ROUND - $WINNER ($WINNER_GOALS) x $OPPONENT ($OPPONENT_GOALS)"
    fi
  fi
done