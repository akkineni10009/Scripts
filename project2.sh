#!/bin/bash
# This script will create a new user account. The script will take home directory argument (is passed).
# Validation for the arguments passed is not and user would be alerted if something is wrong in passing arguments
# A random password would be automatically generated and assigned for the user
# Returns whether the account creation is successful or not
# Initial password would be setup which would then need to be changed

# Welcome the user. Use single quotes when we have a fixed value to print.
echo 'Welcome'

# Assigning the root UID to a variable. Make sure no spaces before and after =
ROOT_UID=0

# Verify whether the execution is happening with root privileges. Make sure a space before [[ and a space before ]]
if [[ ${UID} -eq ${ROOT_UID} ]]
  then
    echo "Executing with root privileges. UID is ${UID} "
  else
    echo "Not executing with root privileges. UID is ${UID}. This script needs root privileges"
    # Exit at this stage since root privileges are definetely required.
    exit 1
fi

# Print the number of arguments passed
echo "Total number of arguments passed are ${#}."

# Verify the for the appropriate number of arguments
if [ ${#} -lt 1 ] || [ ${#} -gt 2 ]
  then
    echo "Incorrect number of arguments: ${#} passed. Correct usage is ./project2.sh "USER" ["HOME_DIR"]"
    exit 1
fi

# Print the dirname and the basename. ${0} would give the directory and file name which is the 0th argument. Here it would be ./project2.sh
# dirname should give . and the basename should give project2.sh
DIR_NAME=$(dirname ${0})
BASE_NAME=$(basename ${0})

echo "Directory name is : ${DIR_NAME}"
echo "Basename is : ${BASE_NAME}"

# Print the entered username
USERNAME=(${1})
echo "Username of the new account would be  ${USERNAME}"

# Print the home directory name (comment) if entered by the user
FULLNAME=(${2})
if [[ "${FULLNAME}" -ne "" ]]
  then 
    echo "Comment given by the user is ${FULLNAME}"
fi

# Generate a randon password.
# Idea is to generate the current date in nano second, pass it to sha256 (which generates a unique checksum value for this date) and limit the size to 10 by piping to head
# Finally a special character which is generated after fold (split a line into multiple lines), shuffle (shuffle the lines randomly) and get the first line

PASSWORD=$(date +%s%N | sha256sum | head -c 10)
SPECIAL_CHARACTER='~!@#$%^&*()_+=-`'
SPECIAL_CHARACTER=$(echo "${SPECIAL_CHARACTER}" | fold -w1 | shuf | head -c1)
PASSWORD=$(echo "${PASSWORD}${SPECIAL_CHARACTER}")
echo "Randomly generated password is ${PASSWORD}"


# Check if the user is already existing. EXIST would be 1 if the user doesn't exist. If user exists, EXIST will have the UID of the user.
EXIST=$(id -u ${USERNAME})
# Another way to check status of the last executed is to use ${?}.

# Delete if the user is an existing user.
if [[ ${EXIST} -ne 1 ]]
  then
    echo "User with username ${USERNAME} already exists. Deleting this user"
    userdel -f ${USERNAME}
fi

# Create the user. -c indicates comment(which is fullname), it is in double quotes since it can have spaces. -m indicates the user that needs to be added. 
useradd -c "${FULLNAME}" -m ${USERNAME}
echo "User with username ${USERNAME} has been created."

# Set the password for the user.
echo "${USERNAME}:${PASSWORD}" | chpasswd
echo "Password for ${USERNAME} has been set successfully"

# Password has to be reset after use.
passwd -e ${USERNAME}

# If you want to change to the new user account, use the following command and enter new password when prompted.
# su ${USERNAME}.
# Return exit code 0 to indicate successful execution of the script

# In order to list all users, use the following command(s)
# cat /etc/passwd
# awk -F':' '{ print $1}' /etc/passwd

echo 'Script executed successfully!!'
exit 0
