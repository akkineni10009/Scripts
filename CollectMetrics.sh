#! /bin/bash
# Script will collect metrics related to CPU and Memory usage of a docker container
# Input from user (upon prompt): CONTAINER_ID, How long the script would be run (In Minutes) and how often the metrics need to be collected (In Seconds)
# Output: Metrics related to CPU and Memory usage would be printed on the terminal where the script is run

# Get the CONTAINER_ID from the user
read -p 'Enter the Container ID ' CONTAINER_ID

# Verify whether the Container ID is valid
# Container Id is the first field in docker ps, get that using awk. Search for the exact Container ID, using grep -w. Check if the #lines=1, meaning there is a unique Container ID

IS_VALID_CONTAINER=$(docker ps | awk -F' ' '{print $1}' | grep -w ${CONTAINER_ID} | wc -l)

if [[ IS_VALID_CONTAINER -ne 1 ]]
  then
    echo 'The Container ID entered is incorrect. Please enter correct Container ID.'
    exit 1
fi

# Get the amount of time to run the script from user
read -p 'Enter (Positive Integer value) how long(In minutes) do you want to run the script ' TIME

# Verify if the input TIME is an integer (valid) value
if [[ "${TIME}" != [1-9]* ]]
  then 
    echo 'Enter an positive integer value for number of minutes to run.'
    exit 1
fi

# Get TIME in SECONDS. ${?} retreives the status of the most recently executed command.
TIME_IN_SECONDS="$((TIME * 60))"
if [[ ${?} -ne 0 ]]
  then 
    echo 'Check if the entered time to run the the script value is an integer or not'
    exit 1
fi

# Get the frequency to collect the metrics from user
read -p 'Enter(In Seconds) how often(frequency) do you want to collect the metrics ' FREQUENCY

# Verify if the Frequency (In Seconds) is an integer (valid) value
if [[ ${FREQUENCY} != [0-9]* ]]
  then
    echo 'Enter a positive integer value for the frequency to collect metrics'
fi

# Print the header to the screen. '-e' option to echo enables the use of '\t'
echo -e 'CPU\t\t\tMemory'

# Run a for loop for TIME_IN_SECONDS/ FREQUENCY  times
RUN_COUNTER=$((TIME_IN_SECONDS / FREQUENCY))

# docker stats ${CONTAINER_ID} would get statistics pertaining to a specific container
# awk would get the 3rd and 7th fields in each row
# tail -n 1 would get 1 record from the end
# sleep 1 would halt the execution for a second

for ((i=1; i<= ${RUN_COUNTER}; i++))
do
     docker stats ${CONTAINER_ID} --no-stream | awk '{print $3 "\t\t\t" $7}' | tail -n 1
     sleep ${FREQUENCY}
done

# Return and complete execution gracefully
echo 'Script executed successfully!!'
exit 0
