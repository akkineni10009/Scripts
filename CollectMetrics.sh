#! /bin/bash
# Script will collect metrics related to CPU and Memory usage of a docker container
# To run the script these 3 arguments need to nbe passed: CONTAINER_ID, How long the script would be run (In Minutes) and how often the metrics need to be collected (In Seconds) as command line arguments
# Output: Metrics related to CPU and Memory usage would be printed on the terminal where the script is run

# This function prints enough detail to the screen to enable the user to run the script with required arguments
printUsage() {
  echo "Incorrect number of arguments:${1} passed. Correct usage is as follows:"
  echo './CollectMetrics.sh <CONTAINER_ID> <TIME_IN_MINUTES> <TIME_IN_SECONDS>'
  echo 'Three arguments needs to be passed to the script:'
  echo 'First arguments is: CONTAINER_ID. Run docker ps -q to check all the containers ids.'
  echo 'Second argument is: How long the script needs to be run (In minutes). Enter a positive integer value.'
  echo 'Third argument is: How often the metrics need to be collected (In seconds). Enter a positive integer value.'
  echo "Example: ./CollectMetrics.sh abcdefgh 10 10"
  return 0
}

# Verify if the required number of arguments are passed. If not, invoke printUsage() and exit
if [[ "${#}" -ne 3 ]]
  then
    printUsage "${#}"
    exit 1
fi

# Get the arguments into meaningful variables
CONTAINER_ID="${1}"
TIME="${2}"
FREQUENCY="${3}"

# Verify whether the Container ID is valid
# Get the list of all the containers using docker ps -q. Search for the exact Container ID, using grep -w. Check if the #lines=1, meaning there is a unique Container ID

IS_VALID_CONTAINER=$(docker ps -q | grep -w ${CONTAINER_ID} | wc -l)

if [[ ${IS_VALID_CONTAINER} -ne 1 ]]
  then
    echo 'Container ID entered is not valid. Please enter correct Container ID. Run docker ps to get information of all the containers.'
    exit 1
fi

# Verifies whether the first arguments passed to this function is a positive integer. Second argument is used to give meaningful error to the user.
verifyInteger() {
  if [[ ! $1 =~ ^[1-9][0-9]*$ ]]
    then
       echo "Enter an positive integer value for " $2 
       exit 1
  fi
  return 0
}

# Verify if the TIME_IN_MINUTES is a valid value
verifyInteger "${TIME}" "TIME_IN_MINUTES"

# Verify if TIME_IN_SECONDS is a valid value
verifyInteger "${FREQUENCY}" "TIME_IN_SECONDS"

checkLastExecutedStatus () {
  if [[ ${?} -ne 0 ]]
    then
      echo $1 'must be a positive integer'
      exit 1
  fi
  return 0
}

# Convert TIME_IN_MINUTES to seconds
MINUTES_TO_SECONDS="$((TIME * 60))"


# Check if convertion from minutes to seconds is successful
checkLastExecutedStatus "TIME_IN_MINUTES"

# Run a for loop for TIME_IN_SECONDS/ FREQUENCY  times
RUN_COUNTER=$((MINUTES_TO_SECONDS / FREQUENCY))

# Check if the previous division is successful
checkLastExecutedStatus "TIME_IN_SECONDS"

# Print the header
printf "%-30s %s\n" "CPU" "Memory"

# docker stats ${CONTAINER_ID} would get statistics pertaining to a specific container
# awk would get the 3rd and 7th fields in each row
# tail -n 1 would get 1 record from the end
# sleep 1 would halt the execution for a second

for ((i=1; i<= ${RUN_COUNTER}; i++))
do
     docker stats ${CONTAINER_ID} --no-stream | awk '{printf "%-30s %s\n", $3, $7 }' | tail -n 1
     sleep ${FREQUENCY}
done

# Return and complete execution gracefully
echo 'Script executed successfully!!'
exit 0
