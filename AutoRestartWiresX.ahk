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

logMessage( "Triger title: " . wiresxMsgboxTitle )
logMessage( "Trigger exe:  " . exeName )
logMessage( "Trigger text: " . wiresxMsgboxTriggerText )

DetectHiddenWindows, On ; Interact with pop-up when it's behind another window
Loop {
  logMessage( "Waiting for a Wires-X restart request." )
  WinWait, %wiresxMsgboxTitle% ahk_exe %exeName%,%wiresxMsgboxTriggerText%

  logWiresxRestartRequest()
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
