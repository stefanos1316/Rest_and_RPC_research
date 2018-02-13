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

# How to install DS3 on RPi

1) Clone from https://github.com/dvdstore/ds3.git
2) After installing and configuring nginx, MySQL, and PHP5 make sure that they run properly.
3) Create a MYSQL user with the following commnad: GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost' IDENTIFIED BY 'password'; 
	where the username and password are 'web' (as defined in the ds3 files statically, in case you want a more secure one run the
	script.changePassword).
4) The binary files that create a number of CSV files (that will be loaded in the MYSQL DB) are not compatible for RPi, since they 
	are compiled in a different architecture. Use the script.re-compile and give the ds3 as  a --dir argument to recompile them.
5) Install perl and execute the Install_DVDStore.pl script (this will let you configure the size of the database) and will execute all 
	the aforementioned re-compiled binaries to create the new CSV files (customers, orders, reviews, and so on). 
6) In case you are using MySQL DB, go in the mysqlds3 directory and execute the mysqlds3_create_all.sh file.
	WARNING: the mysql version that I used did not allowed the use of LOCAL DATA and I had to '--local-infile' before the -u web command,
	you can execute this command in order to do the job for you: $ sed -i 's/mysql\ -u/mysql\ --local-infile\ -u/g' mysqlds3_create_add.sh
	While executing the mysqlds_create_all.sh script to load all the data in mysql might take up to 8 hours, so lay back and enjoy a  cup of coffee.
7) After, the files that are used by the client to execute the benchmark have some mysql commands that are not used any longer. Therefore, you might use the 
	script.changingToMySQLi_functions ds3/ds3/mysqlds3/web/php5/*.php. This command will change some of the mysql commands to make them compatible with php 5.4 and above.
8) In order for the client to use the php scritp you have to add add them in the /var/www/html/ds3/ds3/mysqlds3/web/php5/ 
9) Then run the command CreateConfigFile.pl that creates the configuration file (DriverConfig.txt) for the client to start the workload on the server (make sure that the virt_dir=ds3/ds3/mysqlds/web/php5/)
10) Make sure that the ip tables of the server allow port 80 in and out bound traffic,
11) On the client side you can start the workload test by executing the ds3webdriver.exe found under the driver directory. You can execute this on windows 
	by open the cmd as an administrator ($./ds3webdriver --config_file=/pathto/DriverConfig.txt) or you can run this on Linux 
	by using wine32 (wine32 ./ds3webdriver.exe --config_file=/pathto/DriverConfig.txt) 

NOTE: In case of error you can also check the /var/loh/nginx/error.log for more information.
	For additional help you can contact me at sgeorgiouATaueb.gr
