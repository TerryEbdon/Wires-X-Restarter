/**
 * @file
 * @author      Terry Ebdon
 * @date        October 2022
 * @brief       Script to auto-dismiss Wires-X "Please Reboot" messages
 *
 * Wires-X will restart itself once the message is dismissed. This script
 * restarts the app with minimal delay. All restarts are logged. By default
 * messages are logged to the console. This can be changed via the configuration
 * file. Multiple consecutive restarts are handled, with a short delay between
 * restarts to avoid locking the user out. The Wires-X reboot requests are
 * typically hours, even days, apart. Under these circumstances the script's
 * response will be almost instantaneous.
 */

 /**
 * @copyright   Terry Ebdon, 2022
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%
#Include, Config.ahk

logScriptVersion()
logSystemDetails()
logMessage( "Trigger title:    " . wiresxMsgboxTitle )
logMessage( "Trigger exe:      " . exeName )
logMessage( "Trigger text:     " . wiresxMsgboxTriggerText )

DetectHiddenWindows, On ; Interact with pop-up when it's behind another window
Loop {
  logMessage( "Waiting for a WIRES-X restart request." )
  WinWait, %wiresxMsgboxTitle% ahk_exe %exeName%,%wiresxMsgboxTriggerText%

  logWiresxRestartRequest()
  WinActivate, %wiresxMsgboxTitle% ahk_exe %exeName%,%wiresxMsgboxTriggerText%
  SendInput {Space}
  infiniteLoopBreaker()
}

/* Prevent user lock-outs by sleeping between events.
 * If Wires-X continually dismally restart requests it's
 * possible that the AHK / Wires-X interaction could Lock
 * the user out. To avoid this the script sleeps after dismissing the
 * Wires-X restart request. The sleep time is the sum of the
 * minTimeBetweenRestartsMins configuration value (in minutes) and a
 * hard-coded 15 seconds. The hard-coded value is a safety delay,
 * in case of configuration errors.
*/
infiniteLoopBreaker() {
  global minTimeBetweenRestartsMins
  static sleepTime := minTimeBetweenRestartsMins * 60 * 1000

  logMessage( "Sleeping for " 
    . minTimeBetweenRestartsMins . " minutes" )

  Sleep, %sleepTime%
  logMessage( "Almost awake" )
  Sleep, 15000 ; Back stop, in case of misconfiguration.
}

logSystemDetails() {
  if ( A_Is64bitOS ) {
    osWordSize = 64
  } else {
    osWordSize = 32
  }

  logMessage( "v--  OS Details   --v")
  logMessage( "OS Version:            " . A_OSVersion )
  logMessage( "OS word size:          " . osWordSize )
  logMessage( "Pointer size:          " . A_PtrSize )
  logMessage( "Language:              " . A_Language )
  logMessage( "Computer name:         " . A_ComputerName )
  logMessage( "Logged in as:          " . A_UserName )
  logMessage( "Is admin:              " . A_IsAdmin )
  logMessage( "^--  OS Details   --^")
}

logScriptVersion() {
  FileGetVersion, ahkVersion, %A_ProgramFiles%\AutoHotkey\AutoHotkey.exe
  FileGetSize,    scriptSize, %A_ScriptName%, b
  FileGetTime,    scriptTime, %A_ScriptName%
  FormatTime,     scriptTimeFormatted, %scriptTime%, yyyy-MM-dd HH:mm:ss

  logMessage( "AHK Version:      " . ahkVersion )
  logMessage( "Script: path:     " . A_ScriptFullPath )
  logMessage( "Script timestamp: " . scriptTimeFormatted )
  logMessage( "Script size:      " . scriptSize . " bytes" )
  logHashes()
}

logHashes() {
  logMessage( "v-- Script Hashes --v")
  logHash( A_ScriptName )
  logHash( "Config.ahk" )
  logMessage( "^-- Script Hashes --^")
}

logHash( file ) {
  cmd := "cmd.exe /q /c CertUtil -hashfile " . file
  certUtilOutput := ComObjCreate("WScript.Shell").Exec( cmd ).StdOut.ReadAll()
  outputArr := ( StrSplit( certUtilOutput, "`r`n" ) )
  sha1Hash  := outputArr[2]
  logMessage( sha1Hash . " " . file )
}

/* Log text from the Wires-X message box
 * All non-blank lines will be logged, with one line per log entry.
*/
logWiresxRestartRequest() {
  WinGetText, text
  Loop, parse, text, `n, `r
  {
    if ( A_LoopField != "" ) {
      logMessage( A_LoopField )
    }
  }
}

/* Log a message prefixed with a timestamp.
 * The timestamp format and log file name are derived from
 * the configutation file.
 * @param message the string to be logged.
*/
logMessage( message ) {
  global logFile
  global timeStampFmt
  FormatTime, now,, %timeStampFmt%
  outMessage := now . " " . message . "`n"
  FileAppend, % outMessage, %logFile%
}
