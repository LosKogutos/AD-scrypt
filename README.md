# AD-scrypt
Adds a list of users and their assigned computers to specified security group in Active Directory

Usage instruciton:
1) Save the file in directory containing 3 empty csv files (User_and_Groups.csv User_and_Groups_ResultFile.csv User_and_Groups_errors.txt)
2) Fulfill User_and_Groups.csv - each row has to contain coma separated enumerator (simple row ID), username, AD group name
3) Running the ps1 scrypt will add each user and their associated hostnames to security group specified row-by-row in User_and_Groups.csv
4) Result information is printed in User_and_Groups_ResultFile.csv
5) Exceptions (if any) are printed in User_and_Groups_errors.txt 
