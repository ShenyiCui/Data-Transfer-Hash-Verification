#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <ComboConstants.au3>
#include <Crypt.au3>
#include <GUIConstantsEx.au3>
#include <StringConstants.au3>
#include <WinAPIFiles.au3>
#include <Date.au3>
#include <AutoItConstants.au3>
#include "03 Libraries/CustomMsgBox.au3"
;#RequireAdmin

Global $noSleepPID = 0
Global $TotalNumOfFiles = 0
Global $TotalNumOfFolders = 0
Global $counter = 0
Global $folderCounter = 0
Global $errorCounter= 0
Global $Continue = False
Global $LogFilePath = @ScriptDir & "\00 Log"
Global $GoldenArchivePath = @ScriptDir & "\01 Golden Hash Archive"
Global $ComparisonLogPath = @ScriptDir & "\02 Comparison Log"
Global $iDiffTime = 0

; Create a constant variable in Local scope of the message to display in FileSelectFolder.
Local Const $sMessage = "Select Your Root Directory To Generate Your Folder Hash Value"

; Display an open dialog to select a file.
Local $sFileSelectFolder = FileSelectFolder($sMessage, "")
If @error Then
   ; Display the error message.
   MsgBox($MB_SYSTEMMODAL, "", "No folder was selected.")
Else
   ; Display the selected folder.
   ;MsgBox($MB_SYSTEMMODAL, "", "You chose the following folder:" & @CRLF & $sFileSelectFolder)
   ; List all the files and folders in the desktop directory using the default parameters.
   Local $resp = MsgBox(4, "", "The Chosen Folder Is: "&@CRLF& $sFileSelectFolder&@CRLF&@CRLF&"Begin?")
   If($resp == 6) Then
	  $Continue = True
	  Local $hTimer = TimerInit()
	  Local $aSize = DirGetSize($sFileSelectFolder, $DIR_EXTENDED) ; extended mode
	  If Not @error Then
		 Local $iDiff = Round(TimerDiff($hTimer) / 1000) ; time in seconds
		 $TotalNumOfFiles = $aSize[1]
		 $TotalNumOfFolders = $aSize[2]
	  EndIf
   Else
	   $Continue = False
   EndIf
EndIf

If @error = 1 Then
   MsgBox($MB_SYSTEMMODAL, "", "Path was invalid.")
   Exit
EndIf
If @error = 4 Then
   MsgBox($MB_SYSTEMMODAL, "", "No file(s) were found.")
   Exit
EndIf

Func removeInvalidChar($string)
   $string = StringReplace($string, "*", "")
   $string = StringReplace($string, ".", "")
   $string = StringReplace($string, '"', "")
   $string = StringReplace($string, "/", "")
   $string = StringReplace($string, "\", "")
   $string = StringReplace($string, "[", "")
   $string = StringReplace($string, "]", "")
   $string = StringReplace($string, ":", "")
   $string = StringReplace($string, ";", "")
   $string = StringReplace($string, "|", "")
   $string = StringReplace($string, ",", "")
   Return $string
EndFunc

If($sFileSelectFolder <> "" And $Continue) Then
   If($aSize[1] <> 0) Then
	  Local $resp = MsgBox(4, "", "The Chosen Folder Is: "&@CRLF& $sFileSelectFolder&@CRLF&@CRLF& "Total Number Of Files: " & $TotalNumOfFiles &@CRLF&"Total Number Of Folders: "&$TotalNumOfFolders&@CRLF&@CRLF&"Your Computer Will Not Sleep during this process, Begin Hash?")
	  If($resp == 6) Then
		 ProgressOn("Hashing Folder","Folder Hash Progress:","Hashing...")
		 Local $hFileOpen = FileOpen($LogFilePath & "\Hash Log.txt", $FO_OVERWRITE)
		 FileWriteLine($hFileOpen, "Total Files: "&$TotalNumOfFiles& @CRLF)
		 FileClose($hFileOpen)

		 Local $hFileOpen2 = FileOpen($LogFilePath & "\Directory Log.txt", $FO_OVERWRITE)
		 FileWriteLine($hFileOpen2, "Total Files: "&$TotalNumOfFiles& @CRLF)
		 FileClose($hFileOpen2)

		 Local $hFileOpen3 = FileOpen($LogFilePath & "\Directory Structure Log.txt", $FO_OVERWRITE)
		 FileWriteLine($hFileOpen3, "Total Folders: "&$TotalNumOfFolders& @CRLF)
		 FileClose($hFileOpen3)

		 Local $hFileOpen5 = FileOpen($LogFilePath & "\Errors.txt", $FO_OVERWRITE)
		 FileWriteLine($hFileOpen5, "")
		 FileClose($hFileOpen5)

		 Local $aFileList = _FileListToArray($sFileSelectFolder, "*", Default, True)
		 Global $hTimer2 = TimerInit()
		 $noSleepPID = Run("99 noSleepHash.exe","")
		 FileRecursion($aFileList, 1)
	  Else
		 $Continue = False
	  EndIf
   Else
	  MsgBox($MB_SYSTEMMODAL, "", "No file(s) were found.")
   EndIf
EndIf

Func FileRecursion($FileArray, $arrayIndex)
    Local $iAlgorithm = $CALG_SHA1
   _Crypt_Startup() ; To optimize performance start the crypt library.
   Local $dHash = _Crypt_HashFile($FileArray[$arrayIndex], $iAlgorithm) ; Create a hash of the file.
   _Crypt_Shutdown() ; Shutdown the crypt

   If(StringInStr(FileGetAttrib($FileArray[$arrayIndex]), "D") > 0) Then
	  Local $hFileOpen3 = FileOpen($LogFilePath & "\Directory Structure Log.txt", $FO_APPEND)

	  Local $Pos = StringInStr ( $sFileSelectFolder, "\", 0, -1)
	  Local $FolderName = StringMid ( $sFileSelectFolder ,1,$Pos-1)
	  ;MsgBox($MB_SYSTEMMODAL, "", $FolderName)
	  Local $result = StringReplace($FileArray[$arrayIndex], $FolderName, '')
	  ;MsgBox($MB_SYSTEMMODAL, "", $result)

	  FileWriteLine($hFileOpen3, $result & @CRLF)
	  FileClose($hFileOpen3)
	  $folderCounter = $folderCounter + 1


	  Local $aFileList = _FileListToArray($FileArray[$arrayIndex], "*", Default, True)
	  If($aFileList <> "") Then
		  ;_ArrayDisplay($aFileList, "$aFileList")
		  FileRecursion($aFileList, 1)
		  If($arrayIndex + 1 < Ubound($FileArray)) Then
			FileRecursion($FileArray, $arrayIndex + 1)
		  Else
			Return
		  EndIf
	  Else
		 If($arrayIndex + 1 < Ubound($FileArray)) Then
			FileRecursion($FileArray, $arrayIndex + 1)
		 Else
			Return
		 EndIf
	  EndIf
   Else
	  $counter = $counter + 1
	  Local $hFileOpen = FileOpen($LogFilePath & "\Hash Log.txt", $FO_APPEND)
	  $dHash = _Crypt_HashFile($FileArray[$arrayIndex], $iAlgorithm) ; Create a hash of the file.
	  FileWriteLine($hFileOpen, $dHash & @CRLF)
	  FileClose($hFileOpen)

	  Local $hFileOpen2 = FileOpen($LogFilePath &"\Directory Log.txt", $FO_APPEND)
	  Local $Pos = StringInStr ( $sFileSelectFolder, "\", 0, -1)
	  Local $FolderName = StringMid ( $sFileSelectFolder ,1,$Pos-1)
	  ;MsgBox($MB_SYSTEMMODAL, "", $FolderName)
	  Local $result = StringReplace($FileArray[$arrayIndex], $FolderName, '')
	  FileWriteLine($hFileOpen2, $result & @CRLF)
	  FileClose($hFileOpen2)

	  If($dHash == -1) Then
		 $errorCounter = $errorCounter + 1
		 Local $hFileOpen6 = FileOpen($LogFilePath & "\Errors.txt", $FO_APPEND)
		 FileWriteLine($hFileOpen6, $FileArray[$arrayIndex] & @CRLF)
		 Switch GUICtrlRead(_Crypt_HashFile($FileArray[$arrayIndex], $iAlgorithm))
		 Case 1
			FileWriteLine($hFileOpen6,'Failed to Open File'& @CRLF)
		 Case 10 To 99
			FileWriteLine($hFileOpen6,'Failed to hash final piece'& @CRLF)
		 Case 100 To 999
			FileWriteLine($hFileOpen6,'Failed to get hash piece'& @CRLF)
		 Case Else
			FileWriteLine($hFileOpen6,'_Crypt_Startup() failed'& @CRLF)
		 EndSwitch

		 FileClose($hFileOpen6)
	  EndIf

	  ProgressSet(($counter/$TotalNumOfFiles)*100, "Progress: "&Floor(($counter/$TotalNumOfFiles)*100)&"%" & @CRLF&"File: "&$counter&"/"&$TotalNumOfFiles&@CRLF&"Folder: "&$folderCounter&"/"&$TotalNumOfFolders, "Folder Hash Progress:")

	  If($arrayIndex + 1 < Ubound($FileArray)) Then
		 FileRecursion($FileArray, $arrayIndex + 1)
	  Else
		 Return
	  EndIf
   EndIf
   Return
EndFunc
ProgressOff()

Func compareGoldandCopyArrays($GoldArray, $CopyArray, $ReferenceArrayGold, $ReferenceArrayCopy)
   Local $MasterString = ""
   For $i = 2 to UBound($GoldArray) -1
	  Local $fileHashExists = False
	  For $j = 2 to UBound($CopyArray) -1
		 $comparisonCounter = $comparisonCounter + 1
		 Local $currentPercentage = Floor(($comparisonCounter / $TotalComparisonNumber)*100)
		 ;MsgBox($MB_SYSTEMMODAL, "", ($currentPercentage))
		 ProgressSet($currentPercentage, "Progress: "&$currentPercentage&"%"&@CRLF&"Comparing Files: "&$comparisonCounter&"/"&$TotalComparisonNumber, "Folder Comparison Progress:")
		 ;ConsoleWrite($GoldArray[$i] & @CRLF & $CopyArray[$j]&@CRLF&@CRLF)
		 If($GoldArray[$i] & $ReferenceArrayGold[$i] == $CopyArray[$j] & $ReferenceArrayCopy[$j]) Then
			$fileHashExists = True
		 EndIf
	  Next
	  If(Not $fileHashExists) Then
		 If(StringInStr($MasterString, $ReferenceArrayGold[$i]) == 0) Then
			Local $hFileOpen8 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_APPEND)
			FileWriteLine($hFileOpen8, $ReferenceArrayGold[$i] & @CRLF)
			$MasterString = $MasterString & $ReferenceArrayGold[$i]
			;MsgBox($MB_SYSTEMMODAL, "", $ReferenceArrayGold[$i])
			FileClose($hFileOpen8)
		 EndIf
	  EndIf
   Next
   ;MsgBox($MB_SYSTEMMODAL, "", "Hash Comparison Complete.")
EndFunc

If($sFileSelectFolder <> "" And $Continue == True) Then
   ProcessClose($noSleepPID)
   $iDiffTime = Round(TimerDiff($hTimer2) / 1000) ; time in seconds

   Local $hFileOpen4 = FileOpen($LogFilePath & "\Time Taken.txt", $FO_OVERWRITE)
   FileWriteLine($hFileOpen4,"Total Time Taken: " & $iDiffTime &" secs"& @CRLF)
   FileClose($hFileOpen4)

   $Userin = xMsgBox(16+0x200,"HASH COMPLETE","Total Time Taken: "&$iDiffTime &" secs"&@CRLF&"Total Files Hashed: " & $counter&"/"&$TotalNumOfFiles&@CRLF&"Total Folders Accessed: "&$folderCounter&"/"&$TotalNumOfFolders&@CRLF&"Errors: "&$errorCounter &" Files"&@CRLF&@CRLF&"Choose your next step: " & @CRLF &@CRLF & "01. Save: Save your current Hash as a Golden Hash in the Archive to use to compare later"&@CRLF&@CRLF&"02. Compare: Compare your current Hash with a Previous Hash / Golden Hash","Save","Compare","Cancel", Default)
   ;Button Cancel = 2
   ;Button Save = 6
   ;Button Compare = 7
   If($Userin == 6) Then
	  $Pos = StringInStr ( $sFileSelectFolder, "\", 0, -1)
	  $FolderName = StringMid ( $sFileSelectFolder , $Pos+1)
	  $CAA = " CAA "& _DateTimeFormat(_NowCalc(), 2)&" "&_DateTimeFormat(_NowCalc(), 4)
	  $CAA = removeInvalidChar($CAA)
	  Local $sValue = InputBox("Save Log as Golden Hash", "Enter in the name of your Golden Hash: ", $FolderName &$CAA)
	  if(Not @error) Then
		 $sValue = removeInvalidChar($sValue)
		 ;(*."/\[]:;|,)
		 Local Const $DirPath = $GoldenArchivePath &"\"&$sValue
		 ; If the directory exists the don't continue.
		 ;MsgBox($MB_SYSTEMMODAL, "", $DirPath)
		 If FileExists($DirPath) Then
			MsgBox($MB_SYSTEMMODAL, "", "An error occurred. The directory already exists.")
		 Else
			; Open the directory.
			ShellExecute($GoldenArchivePath)
			; Create the directory.
			DirCreate($DirPath)
			; Display a message of the directory creation.
			If FileExists($DirPath) = 0 Then
			   MsgBox(16, '', 'Sorry, The Golden Hash could not be created. Please check to ensure that your Golden Hash Name does not contain any invalid characters (*."/\[]:;|,)')
			ElseIf FileExists($DirPath) = 1 Then
			   Local $CopyComplete = True

			   FileCopy ( $LogFilePath&"\Hash Log.txt", $DirPath)
			   If @error Then
				  $CopyComplete = False
			   EndIf
			   FileCopy ( $LogFilePath&"\Directory Log.txt", $DirPath)
			   If @error Then
				  $CopyComplete = False
			   EndIf
			   FileCopy ( $LogFilePath&"\Directory Structure Log.txt", $DirPath)
			   If @error Then
				  $CopyComplete = False
			   EndIf
			   FileCopy ( $LogFilePath&"\Time Taken.txt", $DirPath)
			   If @error Then
				  $CopyComplete = False
			   EndIf
			   FileCopy ( $LogFilePath&"\Errors.txt", $DirPath)
			   If @error Then
				  $CopyComplete = False
			   EndIf

			   If($CopyComplete) Then
				  MsgBox(64, '', 'The Golden Hash has been Saved')
			   Else
				  MsgBox(16, '', 'One or More Files Could not be Copied Over')
			   EndIf

			EndIf
		 EndIf
	  EndIf
   ElseIf($Userin == 7) Then
	  ; Create a constant variable in Local scope of the message to display in FileSelectFolder.
	  Local Const $sMessage2 = "Select a Hash Log Folder to compare your current Folder's Hash"
	  ; Display an open dialog to select a file.
	  Local $sFileSelectFolder2 = FileSelectFolder($sMessage2, "")
	  If @error Then
		 ; Display the error message.
		 MsgBox($MB_SYSTEMMODAL, "", "No folder was selected.")
	  Else
		 Global $aFileList2 = _FileListToArray($sFileSelectFolder2, "*", Default, True)
		 ; Open the file for reading and store the handle to a variable.
		 Global $DirectoryLogGold
		 Global $DirectoryStructureLogGold
		 Global $ErrorsGold
		 Global $HashLogGold
		 Global $TimeTakenGold

		 _FileReadToArray($aFileList2[1], $DirectoryLogGold)
		 _FileReadToArray($aFileList2[2], $DirectoryStructureLogGold)
		 _FileReadToArray($aFileList2[3], $ErrorsGold)
		 _FileReadToArray($aFileList2[4], $HashLogGold)
		 _FileReadToArray($aFileList2[5], $TimeTakenGold)

		 Global $aFileList3 = _FileListToArray($LogFilePath, "*", Default, True)
		 Global $DirectoryLog
		 Global $DirectoryStructureLog
		 Global $Errors
		 Global $HashLog
		 Global $TimeTaken

		 _FileReadToArray($aFileList3[1], $DirectoryLog)
		 _FileReadToArray($aFileList3[2], $DirectoryStructureLog)
		 _FileReadToArray($aFileList3[3], $Errors)
		 _FileReadToArray($aFileList3[4], $HashLog)
		 _FileReadToArray($aFileList3[5], $TimeTaken)

		 Global $TotalComparisonNumber = (UBound($HashLogGold)-2) * (UBound($HashLog)-2) + (UBound($DirectoryStructureLogGold)-2) * (UBound($DirectoryStructureLog)-2) + (UBound($DirectoryLog)-1)*(UBound($DirectoryLogGold)-2) + (UBound($DirectoryStructureLog)-2)*(UBound($DirectoryStructureLogGold)-2)
		 Global $comparisonCounter = 0
		 ;_ArrayDisplay($DirectoryLogGold, "$DirectoryLogGold")
		 ; Display the selected folder.
		 ; List all the files and folders in the desktop directory using the default parameters.
		 Local $estTimeLongMin = Round($TotalComparisonNumber / 222855)
		 Local $estTimeDirtyMin = Round((UBound($HashLogGold)-2) / 222855)
		 ;MsgBox(64, "", $TotalComparisonNumber & " / " & 222855 & @CRLF & ($TotalComparisonNumber/222855) & @CRLF & Round($TotalComparisonNumber / 222855))
		 ;MsgBox(64, "", (UBound($HashLogGold)-2) & " / " & 222855 & @CRLF & ((UBound($HashLogGold)-2)/222855)&@CRLF & Round((UBound($HashLogGold)-2) / 222855))
		 Local $recommend = ""
		 If((UBound($HashLogGold)-2) == (UBound($HashLog)-2)) And (UBound($DirectoryStructureLogGold)-2) == (UBound($DirectoryStructureLog)-2) Then
			$recommend = @CRLF&@CRLF&"RECOMMENDATION: Your File number and Folder structure number are equal, a quick or dirty hash is recommended."
		 Else
			$recommend = @CRLF&@CRLF&"RECOMMENDATION: Your File number and Folder structure number are not the same, a quick or long hash is recommended."
		 EndIf
		 If($estTimeDirtyMin == 0) Then
			$estTimeDirtyMin = 0.005
		 EndIf
		 If($estTimeLongMin == 0) Then
			$estTimeLongMin = 0.005
		 EndIf
		 Local $whichCompareUserin = xMsgBox(16+0x200,"COMPARE LOGS","Choose Comparison Type:"&@CRLF&@CRLF&"01. Quick: Hash your 2 Log files to see if they're the same. Fast but doesn't tell you what files are corrupted, only whether the copy was done perfectly or imperfectly."&@CRLF&"EST TIME: 0.5 Sec"&@CRLF&@CRLF&"02. Dirty: Should only be used if Folder and File structure is maintained. Will only show possibly corrupted files - false positives can occur if File and Folder Structure was changed since the copy."&@CRLF&"EST TIME: "&$estTimeDirtyMin&" Mins"&@CRLF&@CRLF&"03. Long: Will compare all files individually, extremely long process, however will identify exactly what was changed, renamed, corrupted or deleted."&@CRLF&"EST TIME: "&$estTimeLongMin&" Min"&$recommend,"Quick","Dirty","Long", Default)

		 If($whichCompareUserin == 2) Then
			Local $resp2 = MsgBox(4, "", "You've Chosen Long Compare"&@CRLF&@CRLF&"The Chosen Hash Log Folder Is: "&@CRLF& $sFileSelectFolder2&@CRLF&@CRLF&"Your computer will not sleep during this process, Begin Comparison?")
			If($resp2 == 6) Then
			   ;$Continue = True
			   $noSleepPID = Run("99 noSleepHash.exe","")
			   Local $hTimer = TimerInit()
			   Local $aSize = DirGetSize($sFileSelectFolder2, $DIR_EXTENDED) ; extended mode
			   If Not @error Then
				  Local $iDiff = Round(TimerDiff($hTimer) / 1000) ; time in seconds
				  If($aSize[1] == 5 And $aSize[2] == 0) Then ;5 Log Files, No Folders
					 ProgressOn("Comparing Folder","Folder Comparison Progress:","Comparing...")

					 Local $hFileOpen7 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_OVERWRITE)
					 FileWriteLine($hFileOpen7,"Renamed / Deleted / Changed / Corrupted Files" & @CRLF)
					 FileClose($hFileOpen7)
					 compareGoldandCopyArrays($HashLogGold, $HashLog, $DirectoryLogGold, $DirectoryLog)

					 Local $hFileOpen10 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_APPEND)
					 FileWriteLine($hFileOpen10, @CRLF & "Deleted / Renamed Folders" & @CRLF)
					 FileClose($hFileOpen10)
					 compareGoldandCopyArrays($DirectoryStructureLogGold, $DirectoryStructureLog, $DirectoryStructureLogGold, $DirectoryStructureLog)

					 Local $hFileOpen9 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_APPEND)
					 FileWriteLine($hFileOpen9, @CRLF & "New Files" & @CRLF)
					 FileClose($hFileOpen9)
					 compareGoldandCopyArrays($DirectoryLog, $DirectoryLogGold, $DirectoryLog, $DirectoryLogGold)

					 Local $hFileOpen10 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_APPEND)
					 FileWriteLine($hFileOpen10, @CRLF & "New Folders" & @CRLF)
					 FileClose($hFileOpen10)
					 compareGoldandCopyArrays($DirectoryStructureLog, $DirectoryStructureLogGold, $DirectoryStructureLog, $DirectoryStructureLogGold)

					 ProgressOff()
					 ProcessClose($noSleepPID)
					 $_Run = "notepad.exe " & $ComparisonLogPath & "\Comparison Log.txt"
					 ConsoleWrite ( "$_Run : " & $_Run & @Crlf )
					 Run ( $_Run, @WindowsDir, @SW_MAXIMIZE )

					 MsgBox(64, '', 'The Comparison has finished, find the log at: ' & @CRLF& $ComparisonLogPath & "\Comparison Log.txt")
				  EndIf
			   EndIf
			EndIf
		 ElseIf($whichCompareUserin == 6) Then
			Local $resp3 = MsgBox(4, "", "You've Chosen Quick Compare"&@CRLF&@CRLF&"The Chosen Hash Log Folder Is: "&@CRLF& $sFileSelectFolder2&@CRLF&@CRLF&"Your computer will not sleep during this process, Begin Comparison?")
			If($resp3 == 6) Then
			   $noSleepPID = Run("99 noSleepHash.exe","")
			   Local $iAlgorithm = $CALG_SHA1
			   _Crypt_Startup() ; To optimize performance start the crypt library.
			   Local $dHashGold = _Crypt_HashFile($aFileList2[4], $iAlgorithm) ; Create a hash of the file.
			   Local $dHashCopy = _Crypt_HashFile($aFileList3[4], $iAlgorithm) ; Create a hash of the file.
			   _Crypt_Shutdown() ; Shutdown the crypt
			   ;MsgBox(64, "", $dHashGold & "/" & $dHashCopy)
			   If($dHashGold == $dHashCopy) Then
				  Local $hFileOpen7 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_OVERWRITE)
				  FileWriteLine($hFileOpen7,"All File's Integrity is Maintained. All is good." & @CRLF)
				  FileClose($hFileOpen7)
			   Else
				  Local $hFileOpen7 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_OVERWRITE)
				  FileWriteLine($hFileOpen7,"Some files may've been corrupted or changed during the transfer, run a long or dirty compare to see which files." & @CRLF)
				  FileClose($hFileOpen7)
			   EndIf
			   $_Run = "notepad.exe " & $ComparisonLogPath & "\Comparison Log.txt"
			   ConsoleWrite ( "$_Run : " & $_Run & @Crlf )
			   Run ( $_Run, @WindowsDir, @SW_MAXIMIZE )
			   ProcessClose($noSleepPID)
			EndIf
		 ElseIf($whichCompareUserin == 7) Then
			Local $resp4 = MsgBox(4, "", "You've Chosen Dirty Compare"&@CRLF&@CRLF&"The Chosen Hash Log Folder Is: "&@CRLF& $sFileSelectFolder2&@CRLF&@CRLF&"Your computer will not sleep during this process, Begin Comparison?")
			If($resp4 ==6) Then
			   ProgressOn("Comparing Folder","Folder Comparison Progress:","Comparing...")
			   Local $hFileOpen9 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_OVERWRITE)
			   FileWriteLine($hFileOpen9,"Renamed / Deleted / Changed / Corrupted Files" & @CRLF)
			   FileClose($hFileOpen9)
			   $noSleepPID = Run("99 noSleepHash.exe","")
			   For $i = 2 To (UBound($HashLogGold)-1) Step 1
				  Local $currentPercentage = Round(($i/(UBound($HashLogGold)-1))*100)
				  ProgressSet($currentPercentage, "Progress: "&$currentPercentage&"%"&@CRLF&"Comparing Files: "&$i&"/"&(UBound($HashLogGold)-1), "Folder Comparison Progress:")
				  If($HashLogGold[$i] <> $HashLog[$i]) Then
					 Local $hFileOpen7 = FileOpen($ComparisonLogPath & "\Comparison Log.txt", $FO_APPEND)
					 FileWriteLine($hFileOpen7,$DirectoryLogGold[$i] & @CRLF)
					 FileClose($hFileOpen7)
				  EndIf
			   Next
			   $_Run = "notepad.exe " & $ComparisonLogPath & "\Comparison Log.txt"
			   ConsoleWrite ( "$_Run : " & $_Run & @Crlf )
			   Run ( $_Run, @WindowsDir, @SW_MAXIMIZE )
			   ProcessClose($noSleepPID)
			   ProgressOff()
			EndIf
		 EndIf
	  EndIf
   EndIf
EndIf