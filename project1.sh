#!/bin/bash
# This script will create a new user account and return whether the account creation is successful or not
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

# Read the username. -p tag indicates a prompt to the user.
read -p 'Enter your username ' USERNAME

# Read the full name
read -p 'Enter your full name ' FULLNAME

# Read the password. -s indicates it is a secret.
read -p 'Enter your password ' PASSWORD

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
