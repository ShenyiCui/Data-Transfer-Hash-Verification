# Data Transfer Hash Verification
A windows AutoIt script (compiled .exe) that will recursively hash every file in a given root directory. Generates a comparable Hash Log.
The purpose of this program is to ensure that data integrity is maintained during data transfer. 
- The idea is to first hash a root directory before data transfer, creating a "Golden Hash Image". 
- After data transfer you should hash this root directory again. You should use the compare feature of this program to compare the 2 hash values for it to identify what files have been changed since the initial hash before data transfer. 
- An excel table has also been provided for huge datasets that'll take the program too long to compare.
- The program will be able to identify the exact file and directory that has been corrupted since the intial hash before data transfer. 
- This program ONLY supports windows. 


This process is extremly reliable as hashes are generated from the calculation of the bits inside each individual file. Every unique file will have its own unique hash, hence if any singular bit inside any file has been changed or altered its hash value will be different. This allows it to be a valuable way to verify data integrity. This program solves the problem of not being able to hash folders as typically hashes can only be applied to a singular file. 

01. Start by opening "04 Hash Folder.exe"

02. You'll subsequently be asked to choose a folder to hash. Navigate your file system and choose your Root Directory, at the end of the program a hash value will be generated for this folder.

![Image of File Selection](https://github.com/ShenyiCui/Data-Transfer-Hash-Verification/blob/main/README%20Images/Choose%20a%20Folder%20to%20Hash.PNG)

03. After your selection of the root directory the program will then go through the root directory and count all the files and folders inside. If your directory is particularly big it may take up to a minute or two. No progress bar will show during this process, just be paitient and let it run.

After this process is complete this screen will greet you:
![Image of Confirmed Selection](https://github.com/ShenyiCui/Data-Transfer-Hash-Verification/blob/main/README%20Images/Counting%20Files%20and%20Folders.PNG)

04. Click yes if this is the intended root directory to hash. After you click on yes the hashing algorithm will search through every file and directory in the root and start to hash them. At this period of time a progress bar will appear, this process could be extremely lengthy depending on the size of the folder and the number of files you are trying to hash. Generally, this algorithm's speed is affected by the number of files it has to hash and the size of each file it has to hash with each factor being postively related to the total time it'll take to hash the entire root directory. 

![Image of Folder Hash Progress](https://github.com/ShenyiCui/Data-Transfer-Hash-Verification/blob/main/README%20Images/Hash%20Progress%20Bar.png)

05. After your hash completes you'll be given 3 options. 
  - To save this hash log means a local copy of the hash you just did will be saved into ~/Application Package/01 Golden Hash Archive
  - To compare this hash log means it'll compare the hash with another hash folder generated from this program. 

06. Should you choose to save this hash for later use you'll first be asked to save it under a name:
![Image of Name Chosing](https://github.com/ShenyiCui/Data-Transfer-Hash-Verification/blob/main/README%20Images/Save%20Hashlog%20Filename.PNG)
- A new directory under this name will then be created under ~/Application Package/01 Golden Hash Archive
- Inside this directory will contain the following files:
  - Directory Log
    - A txt file where every line is a full directory of a file that exists within your root directory.
  - Directory Structure Log
    - A txt file where every line is a full directory of a folder that exists within your root directory.
  - Errors
    - A txt file where alternate line is a file that cannot be hashed with the subsequent line being the program's best guess as to why. They may've violate windows file naming conventions / are already corrupted. 
  - Hash Log
    - A txt file where every line is a hash value for a file, it matches 1 to 1 in order to the files depicted in the directory log. 
  - Time Taken
    - A txt file that shows you how long this hash took.
  
![Image of Saved File](https://github.com/ShenyiCui/Data-Transfer-Hash-Verification/blob/main/README%20Images/Hash%20Log.png)

07. Should you choose to compare it'll automatically use the most recently hashed folder as the "reference hash" and ask you to choose the folder of a hash log. This should be one of the hash's you just created and saved to ~/Application Package/01 Golden Hash Archive at step 6. If you started by clicking on "05 Compare Hash Logs", you'll be asked to pick 2 hash log folders whereby the first will be chosen as the "reference hash".
