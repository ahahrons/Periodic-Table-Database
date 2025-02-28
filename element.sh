#!/bin/bash

# Define PSQL variable for database connection
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Determine search method (atomic_number, symbol, or name)
if [[ $1 =~ ^[0-9]+$ ]]
then
  # Search by atomic_number
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, t.type, p.melting_point_celsius, p.boiling_point_celsius 
                         FROM elements e 
                         JOIN properties p ON e.atomic_number = p.atomic_number 
                         JOIN types t ON p.type_id = t.type_id 
                         WHERE e.atomic_number = $1")
else
  # Search by symbol or name
  ELEMENT_INFO=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, t.type, p.melting_point_celsius, p.boiling_point_celsius 
                         FROM elements e 
                         JOIN properties p ON e.atomic_number = p.atomic_number 
                         JOIN types t ON p.type_id = t.type_id 
                         WHERE e.symbol = '$1' OR e.name = '$1'")
fi

# Check if element was found
if [[ -z $ELEMENT_INFO ]]
then
  echo "I could not find that element in the database."
  exit
fi

# Extract information from query result
echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL ATOMIC_MASS TYPE MELTING_POINT BOILING_POINT
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
done