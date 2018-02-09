# Software_Architecture_Styles_EE
Investigating SAS Energy Implications

# ToDo

Comparing different SAS energy consumption

# Deploy
Most of the function in the current ds3 php scripts are using functions from php 5.3 version that 
are not supported in php 7.  
 
# Run with Php 7 and Mysqli
A work-around it to use the changingToMySQLi_functions.sh that is going to change the functions of 
the traditional mysql to mysqli. 
 
Note: You have to uncomment the life extension=mysqli.so from my /etc/php.ini. 
