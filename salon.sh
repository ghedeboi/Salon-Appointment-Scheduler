#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~ Salon Appointment Scheduler ~~~~\n"

# Function to display the services list
display_services() {
  echo -e "Please select a sercvice:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
}

# Initial prompt
display_services 

# Get the service ID from the user
read SERVICE_ID_SELECTED

# Validate the service ID
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
while [[ -z $SERVICE_NAME ]]
do 
  echo -e "\nInvalid selection. Please choose a valid service ID."
  display_services
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

# Get the customer phone number 
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check if the customer exists 
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If customer does not exist, ask for their name and add them to the database
if [[ -z $CUSTOMER_NAME ]]
then 
  echo -e "\nIt looks like you're a new customer. What's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# Get the customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Get the appointment time
echo -e "\nWhat time would you like to book your $SERVICE_NAME appointment?"
read SERVICE_TIME

# Insert the appointment into the appointments table 
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm the appointment 
if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
then 
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi