#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

team_values=""
game_values=""

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ $year == "year" ]]
  then
    continue
  fi

  team_values="${team_values:+$team_values,}('$winner'),('$opponent')"
  game_values="${game_values:+$game_values,}($year,'$round','$winner','$opponent',$winner_goals,$opponent_goals)"
done < games.csv

team_query="INSERT INTO teams(name) VALUES $team_values ON CONFLICT(name) DO NOTHING;"
game_query="INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
SELECT input.year, input.round, winning_team.team_id, opposing_team.team_id, input.winner_goals, input.opponent_goals
FROM (VALUES $game_values) AS input(year, round, winner, opponent, winner_goals, opponent_goals)
JOIN teams AS winning_team ON winning_team.name = input.winner
JOIN teams AS opposing_team ON opposing_team.name = input.opponent;"

$PSQL "$team_query"
$PSQL "$game_query"
