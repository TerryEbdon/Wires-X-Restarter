/**
 * @file
 * @author      Terry Ebdon
 * @date        October 2022
 * @brief       Configuration file for the WIres-X auto-retstart utility
 *
 * This file must be in the same folder as the script
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
 
minTimeBetweenRestartsMins := 0.25
exeName = Wires-X.exe

logFile := A_ScriptDir "\logs\AutoRestartWiresX.log"
;logFile := "*" ; Uncomment to use console logging, instead of log files

; Localisation
logNamePrefixTimeStampFmt = yyyy-MM-dd
timeStampFmt              = %logNamePrefixTimeStampFmt% HH:mm:ss

; Wires-X Localisation
wiresxMsgboxTitle = Warning
wiresxMsgboxTriggerText = Please Reboot the WIRES-X software
