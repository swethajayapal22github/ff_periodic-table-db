
#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# No argument provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Check if input is a number, symbol, or name
if [[ $1 =~ ^[0-9]+$ ]]; then
  QUERY="SELECT atomic_number, name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements
         JOIN properties USING(atomic_number)
         JOIN types USING(type_id)
         WHERE atomic_number=$1"
else
  QUERY="SELECT atomic_number, name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements
         JOIN properties USING(atomic_number)
         JOIN types USING(type_id)
         WHERE symbol='$1' OR name='$1'"
fi

# Query the database
result=$(psql -U freecodecamp -d periodic_table -t --no-align -c "
  SELECT elements.atomic_number, elements.name, elements.symbol, types.type, 
         properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius 
  FROM elements
  JOIN properties ON elements.atomic_number = properties.atomic_number
  JOIN types ON properties.type_id = types.type_id
  WHERE elements.atomic_number = '$1' OR elements.symbol = '$1' OR elements.name = '$1';")

#!/bin/bash

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Query the database and fetch the element details
result=$(psql -U freecodecamp -d periodic_table -t --no-align -c "
  SELECT elements.atomic_number, elements.name, elements.symbol, types.type, 
         properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius 
  FROM elements
  JOIN properties ON elements.atomic_number = properties.atomic_number
  JOIN types ON properties.type_id = types.type_id
  WHERE elements.atomic_number::text = '$1' OR elements.symbol = '$1' OR elements.name = '$1';
")

# Check if the query returned any result
if [[ -z $result ]]; then
  echo "I could not find that element in the database."
else
  # Read the query result into variables
  IFS="|" read atomic_number name symbol type atomic_mass melting_point boiling_point <<< "$result"
  
  # Display the element information
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi
