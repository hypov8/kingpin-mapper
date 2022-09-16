#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=D:\_code_\icon\kp_map_compile.ico
#AutoIt3Wrapper_Outfile=KingpinMapper.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Fileversion=1.0.7.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p

#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $GUI_VERSION = "1.0.7"

;#AutoIt3Wrapper_Res_HiDpi=y

;Kingpin map build tools by hypov8
;concept taken from Q3Map2Build by DLB
;allows custom commands/compilers
;
;v1.0.5 2021-06-06
;added error if default config missing
;added warning for missing maps directory
;set base/main to default maps folder
;
;v1.0.6 2021-06-14
;aded profile loader
;added backup .map option
;fixed bug using DOS names. map compilers reqire full .map name. now only folder name is converted to 8.3. so map name must NOT contain spaces
;fixed bug testing compiler checked values that can be invalid
;added append map switch to config
;
;v1.0.7 2021-07-11
;added shortcut keys  ALT+C=Compile. ALT+P=Play. ALT+V=View Bat. ALT+R=Refresh Maps.
;added quake example tips
;updated config file option to search game type. changes gui tips
;changed exe paths gui. easier to understand maps folder used
;
;todo
;=========================
;patch DPI scale
;add .bsp file switch in config
;check for incompatable forward slash?
;find cause of delay when pressing build for the first time
;game selecter via UI



#include <GuiListView.au3>
#include <EditConstants.au3>
#include <GuiComboBox.au3>
#include <File.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <WindowsConstants.au3>
Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)


#Region ### START Koda GUI section ### Form=C:\Programs\codeing\autoit-v3\SciTe\Koda\Dave\kp\KingpinMapBuild.kxf
Global $KingpinMapBuild = GUICreate("Kingpin-Mapper by HypoV8 (v1.0.7)", 455, 343, -1, -1)
GUISetOnEvent($GUI_EVENT_CLOSE, "KingpinMapBuildClose")
Global $Group_maps = GUICtrlCreateGroup("Maps", 0, 0, 377, 233, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
Global $List0_maps = GUICtrlCreateList("", 8, 14, 305, 188)
GUICtrlSetOnEvent(-1, "List0_mapsClick")
Global $Button0_build_map = GUICtrlCreateButton("&Compile", 316, 16, 53, 49, $WS_BORDER)
GUICtrlSetTip(-1, "Compile .map")
GUICtrlSetOnEvent(-1, "Button0_build_mapClick")
Global $Button0_view_bat = GUICtrlCreateButton("&View .Bat", 316, 116, 53, 29)
GUICtrlSetTip(-1, "Preview the bat file used")
GUICtrlSetOnEvent(-1, "Button0_view_batClick")
Global $Button0_refresh_map = GUICtrlCreateButton("&Refresh", 316, 148, 53, 29)
GUICtrlSetTip(-1, "Refresh maps folder")
GUICtrlSetOnEvent(-1, "Button0_refresh_mapClick")
Global $Combo0_maps = GUICtrlCreateCombo("", 316, 180, 53, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "*.map|*.bsp", "*.map")
GUICtrlSetOnEvent(-1, "Combo0_mapsChange")
Global $Input0_maps = GUICtrlCreateInput("", 8, 204, 261, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
Global $Button6_dir_options = GUICtrlCreateButton("Directory Options", 272, 204, 97, 22)
GUICtrlSetTip(-1, "Setup paths to game and compilers")
GUICtrlSetOnEvent(-1, "Button6_dir_optionsClick")
Global $Button0_play_map = GUICtrlCreateButton("&Play", 316, 84, 53, 29)
GUICtrlSetTip(-1, "Play selected map using the play game 'options'")
GUICtrlSetOnEvent(-1, "Button0_play_mapClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_prebuild = GUICtrlCreateGroup("PRE BUILD", 136, 235, 77, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
Global $Radio1_none = GUICtrlCreateRadio("None", 144, 251, 61, 15)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Radio1_noneClick")
Global $Radio1_default = GUICtrlCreateRadio("Default", 144, 267, 61, 15)
GUICtrlSetOnEvent(-1, "Radio1_noneClick")
Global $Radio1_custom = GUICtrlCreateRadio("Custom", 144, 283, 61, 15)
GUICtrlSetOnEvent(-1, "Radio1_noneClick")
Global $Button1_option = GUICtrlCreateButton("Options", 144, 301, 61, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button1_optionClick")
Global $Checkbox1_pause = GUICtrlCreateCheckbox("Pause", 144, 321, 53, 13)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_bsp = GUICtrlCreateGroup("BSP", 216, 235, 77, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
Global $Radio2_none = GUICtrlCreateRadio("None", 224, 251, 61, 15)
GUICtrlSetOnEvent(-1, "Radio2_noneClick")
Global $Radio2_default = GUICtrlCreateRadio("Default", 224, 267, 61, 15)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Radio2_noneClick")
Global $Radio2_custom = GUICtrlCreateRadio("Custom", 224, 283, 61, 15)
GUICtrlSetOnEvent(-1, "Radio2_noneClick")
Global $Button2_option = GUICtrlCreateButton("Options", 224, 301, 61, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button2_optionClick")
Global $Checkbox2_pause = GUICtrlCreateCheckbox("Pause", 224, 321, 53, 13)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_vis = GUICtrlCreateGroup("VIS", 296, 235, 77, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
Global $Radio3_none = GUICtrlCreateRadio("None", 304, 251, 61, 15)
GUICtrlSetOnEvent(-1, "Radio3_noneClick")
Global $Radio3_default = GUICtrlCreateRadio("Default", 304, 267, 61, 15)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Radio3_noneClick")
Global $Radio3_custom = GUICtrlCreateRadio("Custom", 304, 283, 61, 15)
GUICtrlSetOnEvent(-1, "Radio3_noneClick")
Global $Button3_option = GUICtrlCreateButton("Options", 304, 301, 61, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button3_optionClick")
Global $Checkbox3_pause = GUICtrlCreateCheckbox("Pause", 304, 321, 53, 13)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_light = GUICtrlCreateGroup("LIGHT", 376, 235, 77, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
Global $Radio4_none = GUICtrlCreateRadio("None", 384, 251, 61, 15)
GUICtrlSetOnEvent(-1, "Radio4_noneClick")
Global $Radio4_default = GUICtrlCreateRadio("Default", 384, 267, 61, 15)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Radio4_noneClick")
Global $Radio4_custom = GUICtrlCreateRadio("Custom", 384, 283, 61, 15)
GUICtrlSetOnEvent(-1, "Radio4_noneClick")
Global $Button4_option = GUICtrlCreateButton("Options", 384, 301, 61, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button4_optionClick")
Global $Checkbox4_pause = GUICtrlCreateCheckbox("Pause", 384, 321, 53, 13)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_options = GUICtrlCreateGroup("Build Options", 0, 235, 133, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
Global $Checkbox0_play_build = GUICtrlCreateCheckbox("Play after build", 8, 255, 109, 14)
GUICtrlSetTip(-1, "Play map after build."&@crlf&"Its recommended to use pause after building map.")
Global $Checkbox0_save_bat = GUICtrlCreateCheckbox("Save .bat to maps", 8, 271, 109, 14)
GUICtrlSetTip(-1, "Save batch file into maps directory")
Global $Checkbox0_UseWinStart = GUICtrlCreateCheckbox("Low CPU priority", 8, 287, 109, 14)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, "Compile batch using windows 'start /B /I /low /wait'"&@crlf&"This sets process priority to low."&@crlf&"So you can do other tasks. like map!")
Global $Checkbox0_DOS_8_3 = GUICtrlCreateCheckbox("DOS 8.3 names", 8, 303, 109, 14)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, "Use DOS short folder names in batch."&@crlf&"This fixes issues with spaces in folder names."&@crlf&"Map name cant have spaces")
Global $Checkbox0_backupMap = GUICtrlCreateCheckbox("Backup .map", 8, 319, 101, 13)
GUICtrlSetTip(-1, "Save a copy of .map to /maps/snapshots/"&@crlf&"Never overwrite, incremet name")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button0_exit = GUICtrlCreateButton("Exit", 384, 205, 69, 21)
GUICtrlSetOnEvent(-1, "Button0_exitClick")
Global $Group3 = GUICtrlCreateGroup("Profile", 384, 0, 69, 89, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
Global $Button_p_load = GUICtrlCreateButton("Load", 392, 20, 53, 29)
GUICtrlSetTip(-1, "Load a previous saved profile")
GUICtrlSetOnEvent(-1, "Button_p_loadClick")
Global $Button_p_save = GUICtrlCreateButton("Save", 392, 52, 53, 29)
GUICtrlSetTip(-1, "Save current profile to disk")
GUICtrlSetOnEvent(-1, "Button_p_saveClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group4 = GUICtrlCreateGroup("Play Game", 384, 104, 69, 57, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
Global $Button5_game_options = GUICtrlCreateButton("Options", 392, 124, 53, 29, BitOR($BS_CENTER,$BS_VCENTER,$BS_MULTILINE))
GUICtrlSetTip(-1, "Configure game options for playing map")
GUICtrlSetOnEvent(-1, "Button5_game_optionsClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button0_about = GUICtrlCreateButton("About", 384, 180, 69, 21)
GUICtrlSetOnEvent(-1, "Button0_aboutClick")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###



#Region ;==> global defines
;gui region indexes
Global Enum $iGUI_REGION_0_MAIN, _ ;main gui
			$iGUI_REGION_1_PRE_GAME, _
			$iGUI_REGION_2_BSP, _
			$iGUI_REGION_3_VIS, _
			$iGUI_REGION_4_LIGHT, _
			$iGUI_REGION_5_GAME_OPTIONS, _ ;game options
			$iGUI_REGION_6_DIRECTORIES, _ ;directory's
			$iGUI_REGION_7_BAT, _
			$iGUI_REGION_8_ABOUT

;gui id array's
Global $g_ahGUI_ID[9] = [-1, -1, -1, -1, -1, -1, -1, -1, -1]
Global $g_ahGUI_ID_save[7]
Global $g_ahGUI_ID_cancel[7]
Global $g_ahGUI_ID_reset[7]
Global $g_ahGUI_ID_options[7][100] ;allow 100 lines
Global $g_ahGUI_ID_inputBox[7][100] ;allow 100 lines
Global $g_asGUI_toolTip[7][100] ;allow 100 lines
Global $g_ahGUI_ID_MapPaths[3] ;radio buttin selection
Global $g_ahGUI_ID_MapSave[2] ;check box save map snapshots

Global $g_aiConfigFile_default_Count[7] ;count elements in default config
Global $g_aiConfigFile_custom_Count[7] ;count elements in custom config
Global $g_asConfigFile_default[7][100] ;allow 100 lines
Global $g_asConfigFile_custom[7][100] ;allow 100 lines
Global $g_asConfigUsed_custom[7][100] ;custom compile strings to be used

;generated compile strings
Global $g_aCompileSettings[4][100]


;filepath indexes
Global Enum $switch_PATH_EXE_, _ ;insert kingpin.exe folder/file after switch
			$switch_PATH_BASE, _ ;insert /main folder after switch
			$switch_PATH_MOD_, _ ;insert /gunrace folder  after switch//todo just use string?
			$switch_PATH_PRE_, _ ;insert img2wal.exe folder/file after switch
			$switch_PATH_BSP_, _ ;insert kpbsp.exe folder/file after switch
			$switch_PATH_VIS_, _ ;insert kpvis.exe folder/file after switch
			$switch_PATH_RAD_, _ ;insert kprad.exe folder/file after switch
			$switch_PATH_MAP_ ;insert folder/map.map after switch


;store exe/game paths
Global $sFilePaths[8] = ["","","","","","","",1] ;PATH_EXE, PATH_BASE, PATH_MOD, PATH_PRE, PATH_BSP, PATH_VIS, PATH_RAD, MAP_INDEX
Global $g_sMapSelected_name = ""	;map name
Global $g_sMapSelected_path = "" 	;map folder
Global $g_sMapSelected_full = "" 	;map folder/name

Global $g_as_CompileString[5] ; pre, bsp, vis, rad, game

Global Const $g_sFilename_cfg_paths =	"KingpinMapper_path.txt" ;todo: @ScriptName
Global Const $g_sFilename_cfg_default =	"KingpinMapper_default.txt" ;todo: @ScriptName
Global Const $g_sFilename_cfg_custom = 	"KingpinMapper_custom.txt" ;todo: @ScriptName

Global Const $g_sFilename_cfg_path_full = 		@ScriptDir &"\"& $g_sFilename_cfg_paths
Global Const $g_sFilename_cfg_default_full = 	@ScriptDir &"\"& $g_sFilename_cfg_default
Global Const $g_sFilename_cfg_custom_full = 	@ScriptDir &"\"& $g_sFilename_cfg_custom
Global Const $g_sFileName_bat_full = 			@TempDir &"\kingpinMapper.bat"

Global $GUI_StringType = 0 ; default kingpin. 1=quake1, 2=quake2

Global $GUI_Title[3] = ["Kingpin-Mapper by HypoV8", _
						"Quake1-Mapper by HypoV8", _
						"Quake2-Mapper by HypoV8"]
WinSetTitle($KingpinMapBuild,"", string($GUI_Title[0] &"  (v"& $GUI_VERSION&")"))

#EndRegion

#Region ;==> global keys
Global $aHotKeys[4][2] = [ _	;^=CONTROL !=ALT +=SHIFT
							["^c", $Button0_build_map], _ 		;build map
							["^p", $Button0_play_map], _ 		;play map
							["^v", $Button0_view_bat], _ 		;view bat
							["^r", $Button0_refresh_map] _		;refresh maps list
						]
;~ 							["^l", $Button_p_load], _ 			;load profile
;~ 							["^s", $Button_p_save], _ 			;save profile
;~ 							["^o", $Button5_game_options], _	;game options
;~ 							["^a", $Button0_about], _ 			;about
;~ 							["^e", $Button0_exit] _				;exit

GUISetAccelerators($aHotKeys, $KingpinMapBuild)
#EndRegion

#Region ;==> global functions
Func fn_AppendForwardSlash(ByRef $sInStr)
	local $cChar
	if StringLen($sInStr) < 1 Then Return
	$cChar= StringRight($sInStr, 1)
	If StringCompare($cChar, "/") Then $sInStr &="/"
EndFunc

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func fn_toggleCheck($iNum)
	If $iNum = 1 Then Return $GUI_CHECKED
	Return $GUI_UNCHECKED
EndFunc
#EndRegion

#Region ;==> startup
;read _default.txt (required)
fn_ReadConfigFile_Default()
Func fn_ReadConfigFile_Default()
    Local $iLineCount, $iIdx
    Local $aTmpArray = FileReadToArray($g_sFilename_cfg_default_full)

    If @error Then
        MsgBox($MB_SYSTEMMODAL, "Error", "Error: Can't read file..." &@CRLF&@CRLF&$g_sFilename_cfg_default)
		KingpinMapBuildClose() ;exit
	Else
		$iLineCount = @extended
		;ConsoleWrite("script name="&$g_sFilename_cfg_default_full&@CRLF)
		;_ArrayDisplay($aTmpArray)
		For $iIdx = 0 to ($iLineCount -1)
			if StringCompare($aTmpArray[$iIdx], "GAME",1) = 0 Then
				$iIdx = fn_FillConfigFile_Default_Array($iGUI_REGION_5_GAME_OPTIONS, $iIdx+1, $iLineCount, $aTmpArray)
			elseIf StringCompare($aTmpArray[$iIdx], "PRE",1) = 0 Then
				$iIdx = fn_FillConfigFile_Default_Array($iGUI_REGION_1_PRE_GAME, $iIdx+1, $iLineCount, $aTmpArray)
			elseif  StringCompare($aTmpArray[$iIdx], "BSP",1) = 0 Then
				$iIdx = fn_FillConfigFile_Default_Array($iGUI_REGION_2_BSP, $iIdx+1, $iLineCount, $aTmpArray)
			elseIf StringCompare($aTmpArray[$iIdx], "VIS",1) = 0 Then
				$iIdx = fn_FillConfigFile_Default_Array($iGUI_REGION_3_VIS, $iIdx+1, $iLineCount, $aTmpArray)
			elseIf StringCompare($aTmpArray[$iIdx], "LIGHT",1) = 0 Then
				$iIdx = fn_FillConfigFile_Default_Array($iGUI_REGION_4_LIGHT, $iIdx+1, $iLineCount, $aTmpArray)
			ElseIf  StringCompare($aTmpArray[$iIdx], "GUI_QUAKE",1) = 0 Then
				$GUI_StringType = 1
				WinSetTitle($KingpinMapBuild,"", string($GUI_Title[1] &"  (v"& $GUI_VERSION&")"))
			ElseIf  StringCompare($aTmpArray[$iIdx], "GUI_QUAKE2",1) = 0 Then
				$GUI_StringType = 2
				WinSetTitle($KingpinMapBuild,"", string($GUI_Title[2] &"  (v"& $GUI_VERSION&")"))
			EndIf
		Next
	EndIf
	$aTmpArray = 0
EndFunc
Func fn_FillConfigFile_Default_Array($IDX, $iIdx, $iLineCount, ByRef $aTmpArray)
	local $iCount = 0

	;find first '{'
	While ($iIdx < $iLineCount And Not StringInStr($aTmpArray[$iIdx], "{", 1, 1, 1, 2))
		$iIdx +=1
	WEnd
	$iIdx +=1

	;proocess untill "}" is found
	While ($iIdx < $iLineCount And Not StringInStr($aTmpArray[$iIdx], "}", 1, 1, 1, 2))
		if $aTmpArray[$iIdx] <> "" Then
			$g_asConfigFile_default[$IDX][$iCount] = StringStripWS( $aTmpArray[$iIdx], 3)
			$iCount +=1
		EndIf

		$iIdx +=1
	WEnd

	$g_aiConfigFile_default_Count[$IDX] = $iCount

	Return $iIdx
EndFunc


;read _path.txt (generated on 1st run)
fn_Readfile_ExePaths()
Func fn_Readfile_ExePaths()
    Local $iLineCount, $iIdx, $aSplit, $hFile
    local $aTmpArray = FileReadToArray($g_sFilename_cfg_path_full)

    If @error Then
		if FileExists($g_sFilename_cfg_path_full) Then
			MsgBox($MB_SYSTEMMODAL, "Warning", "Warning: Can't read file..." &@CRLF&@CRLF&$g_sFilename_cfg_paths)
		EndIf
	Else
		$iLineCount = @extended
		;ConsoleWrite("script name="&$g_sFilename_cfg_path_full&@CRLF)
		For $iIdx = 0 to ($iLineCount -1)
			$aSplit = StringSplit($aTmpArray[$iIdx], ",")
			if not @error And $aSplit[0] >=2 then
				if StringCompare($aSplit[1], "PATH_EXE",1) = 0 Then
					$sFilePaths[$switch_PATH_EXE_] = StringReplace($aSplit[2],"\", "/") ;make all forward slash
				elseIf StringCompare($aSplit[1], "PATH_BASE",1) = 0 Then
					$sFilePaths[$switch_PATH_BASE] = StringReplace($aSplit[2],"\", "/") ;make all forward slash
					if $sFilePaths[$switch_PATH_BASE] <> "" Then fn_AppendForwardSlash($sFilePaths[$switch_PATH_BASE]);add forward slash to paths
				elseif StringCompare($aSplit[1], "PATH_MOD",1) = 0 Then
					$sFilePaths[$switch_PATH_MOD_] = StringReplace($aSplit[2],"\", "/") ;make all forward slash
					if $sFilePaths[$switch_PATH_MOD_] <> "" Then fn_AppendForwardSlash($sFilePaths[$switch_PATH_MOD_]);add forward slash to paths
				elseIf StringCompare($aSplit[1], "PATH_PRE",1) = 0 Then
					$sFilePaths[$switch_PATH_PRE_] = StringReplace($aSplit[2],"\", "/") ;make all forward slash
				elseIf StringCompare($aSplit[1], "PATH_BSP",1) = 0 Then
					$sFilePaths[$switch_PATH_BSP_] = StringReplace($aSplit[2],"\", "/") ;make all forward slash
				elseIf StringCompare($aSplit[1], "PATH_VIS",1) = 0 Then
					$sFilePaths[$switch_PATH_VIS_] = StringReplace($aSplit[2],"\", "/") ;make all forward slash
				elseIf StringCompare($aSplit[1], "PATH_RAD",1) = 0 Then
					$sFilePaths[$switch_PATH_RAD_] = StringReplace($aSplit[2],"\", "/") ;make all forward slash
				ElseIf StringCompare($aSplit[1], "MAP_INDEX",1) = 0 Then
					$sFilePaths[$switch_PATH_MAP_] = Number($aSplit[2])


				;main gui checkbox
				ElseIf StringCompare($aSplit[1],"GUI_BACKUP_MAP",1) = 0 Then
					GUICtrlSetState($Checkbox0_backupMap,fn_toggleCheck(Number($aSplit[2])))
				ElseIf StringCompare($aSplit[1],"GUI_PLAY_AFTER",1) = 0 Then
					GUICtrlSetState($Checkbox0_play_build,fn_toggleCheck(Number($aSplit[2])))
				ElseIf StringCompare($aSplit[1],"GUI_SAVE_BAT",1) = 0 Then
					GUICtrlSetState($Checkbox0_save_bat,fn_toggleCheck(Number($aSplit[2])))
				ElseIf StringCompare($aSplit[1],"GUI_USEWIN",1) = 0 Then
					GUICtrlSetState($Checkbox0_UseWinStart,fn_toggleCheck(Number($aSplit[2])))
				ElseIf StringCompare($aSplit[1],"GUI_USE_DOS",1) = 0 Then
					GUICtrlSetState($Checkbox0_DOS_8_3,fn_toggleCheck(Number($aSplit[2])))
				ElseIf StringCompare($aSplit[1],"GUI_PAUSE_PRE",1) = 0 Then
					GUICtrlSetState($Checkbox1_pause,fn_toggleCheck( Number($aSplit[2])))
				ElseIf StringCompare($aSplit[1],"GUI_PAUSE_BSP",1) = 0 Then
					GUICtrlSetState($Checkbox2_pause,fn_toggleCheck( Number($aSplit[2])))
				ElseIf StringCompare($aSplit[1],"GUI_PAUSE_VIS",1) = 0 Then
					GUICtrlSetState($Checkbox3_pause,fn_toggleCheck( Number($aSplit[2])))
				ElseIf StringCompare($aSplit[1],"GUI_PAUSE_RAD",1) = 0 Then
					GUICtrlSetState($Checkbox4_pause,fn_toggleCheck( Number($aSplit[2])))

				;compile type. none, default, custom
				ElseIf StringCompare($aSplit[1],"GUI_BUILD_PRE",1) = 0 Then
					fn_SetCompileRadioTypes(0, Number($aSplit[2]))
				ElseIf StringCompare($aSplit[1],"GUI_BUILD_BSP",1) = 0 Then
					fn_SetCompileRadioTypes(1, Number($aSplit[2]))
				ElseIf StringCompare($aSplit[1],"GUI_BUILD_VIS",1) = 0 Then
					fn_SetCompileRadioTypes(2, Number($aSplit[2]))
				ElseIf StringCompare($aSplit[1],"GUI_BUILD_RAD",1) = 0 Then
					fn_SetCompileRadioTypes(3, Number($aSplit[2]))
				EndIf
			EndIf
		Next
	EndIf
	$aTmpArray = 0

	;if missing, prompt user to setup atleast game.exe
	;if $sFilePaths[0] = "" then fn_Buld_Gui_Directories() ;popup select folder
EndFunc
Func fn_SetCompileRadioTypes($IDX, $iType)
	Local $hGUI_ID_build_opt[4] = [$Button1_option, $Button2_option, $Button3_option, $Button4_option]
	Local $hGUI_ID_build[4][3] =[ [ $Radio1_none, $Radio1_default, $Radio1_custom], _
								[$Radio2_none, $Radio2_default, $Radio2_custom], _
								[$Radio3_none, $Radio3_default, $Radio3_custom], _
								[$Radio4_none, $Radio4_default, $Radio4_custom]]

	;uncheck all radio buttons
	GUICtrlSetState($hGUI_ID_build[$IDX][0], $GUI_UNCHECKED)
	GUICtrlSetState($hGUI_ID_build[$IDX][1], $GUI_UNCHECKED)
	GUICtrlSetState($hGUI_ID_build[$IDX][2], $GUI_UNCHECKED)
	;check radio button
	GUICtrlSetState($hGUI_ID_build[$IDX][$iType], $GUI_CHECKED)

	;activate custome compile button
	If $iType = 2 Then GUICtrlSetState($hGUI_ID_build_opt[$IDX], $GUI_ENABLE)

EndFunc


;read _custom.txt (generated on 1st run)
fn_ReadConfigFile_Custom($g_sFilename_cfg_custom_full)
Func fn_ReadConfigFile_Custom($sFilePath)
    Local $iLineCount, $iIdx
	Local $iCount_GAME=0, $iCount_PRE=0, $iCount_BSP=0, $iCount_VIS=0, $iCount_LIGHT=0
    Local $aTmpArray = FileReadToArray($sFilePath)

    If @error Then
		if FileExists($sFilePath) Then ;only report error if file exists
			MsgBox($MB_SYSTEMMODAL, "Warning", "Warning: Can't read file..." &@CRLF&@CRLF&$g_sFilename_cfg_custom)
		EndIf
    Else
		$iLineCount = @extended
		;ConsoleWrite("script name=" & $sFilePath&@CRLF)
		;_ArrayDisplay($aTmpArray)
		For $iIdx = 0 to ($iLineCount -1)
			Local $aSplit = StringSplit($aTmpArray[$iIdx], ",")
			if not @error And $aSplit[0] >=3 then
				if StringCompare($aSplit[1], "GAME",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_5_GAME_OPTIONS][$iCount_GAME] = StringStripWS( $aTmpArray[$iIdx], 3)
					$iCount_GAME+=1
				elseIf StringCompare($aSplit[1], "PRE",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_1_PRE_GAME][$iCount_PRE] = StringStripWS( $aTmpArray[$iIdx], 3)
					$iCount_PRE+=1
				elseif  StringCompare($aSplit[1], "BSP",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_2_BSP][$iCount_BSP] = StringStripWS( $aTmpArray[$iIdx], 3)
					$iCount_BSP+=1
				elseIf StringCompare($aSplit[1], "VIS",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_3_VIS][$iCount_VIS] = StringStripWS( $aTmpArray[$iIdx], 3)
					$iCount_VIS+=1
				elseIf StringCompare($aSplit[1], "LIGHT",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_4_LIGHT][$iCount_LIGHT] = StringStripWS( $aTmpArray[$iIdx], 3)
					$iCount_LIGHT+=1
				EndIf
			EndIf
		Next
	EndIf

	ConsoleWrite("custom count PRE="&$iCount_PRE& " BSP="&$iCount_BSP& " VIS="&$iCount_VIS& " RAD="&$iCount_LIGHT& " GAME=" &$iCount_GAME&@CRLF)

	$g_aiConfigFile_custom_Count[$iGUI_REGION_1_PRE_GAME] = $iCount_PRE
	$g_aiConfigFile_custom_Count[$iGUI_REGION_2_BSP] = $iCount_BSP
	$g_aiConfigFile_custom_Count[$iGUI_REGION_3_VIS] = $iCount_VIS
	$g_aiConfigFile_custom_Count[$iGUI_REGION_4_LIGHT] = $iCount_LIGHT
	$g_aiConfigFile_custom_Count[$iGUI_REGION_5_GAME_OPTIONS] = $iCount_GAME

	if $sFilePaths[0] = "" then fn_Buld_Gui_Directories() ;popup select folder
EndFunc


;read maps folder
fn_FillMapsList()
Func fn_FillMapsList()
	Local $iIdx = _GUICtrlComboBox_GetCurSel($Combo0_maps)
	Local $aTmp, $sDir, $iTmp, $sTmp = ""
	Local $sTmpMapDir

	;skip it already open
	if Not ($g_ahGUI_ID[$iGUI_REGION_6_DIRECTORIES] = -1) Then Return

	$sDir = fn_BuildMapsPath()

	if ($sDir == "") or ($sDir == "maps/") Then
		MsgBox("", "Note:", "Setup folder for maps" )
		fn_Buld_Gui_Directories() ;popup select folder
		Return
	EndIf

	ConsoleWrite("Maps search folder="&$sDir&@CRLF)

	;show loading message.
	GUICtrlSetData($List0_maps,"Loading...")
	;disable GUI
	GUICtrlSetState($List0_maps,$GUI_DISABLE)
	GUICtrlSetState($Button0_build_map, $GUI_DISABLE)
	GUICtrlSetState($Button0_play_map, $GUI_DISABLE)
	GUICtrlSetState($Button0_refresh_map, $GUI_DISABLE)
	GUICtrlSetState($Button0_view_bat, $GUI_DISABLE)
	GUICtrlSetState($Combo0_maps, $GUI_DISABLE)

	$sTmpMapDir = ($iIdx=0)? ("*.map"): ("*.bsp")

	if ($sFilePaths[$switch_PATH_MAP_] = 0) Then
		$aTmp = _FileListToArrayRec($sDir, $sTmpMapDir, $FLTA_FILES, $FLTAR_RECUR ,$FLTAR_SORT,$FLTAR_RELPATH)
	Else
		$aTmp = _FileListToArray($sDir, $sTmpMapDir, $FLTA_FILES)
	EndIf


	if @error Then
		If @extended = 1 Then
			MsgBox($MB_SYSTEMMODAL, "Maps List", "ERROR 1:"&@CRLF&"Map path not found or invalid"&@CRLF&$sDir,0, $KingpinMapBuild)
		ElseIf @extended = 9 Then
			MsgBox($MB_SYSTEMMODAL, "Maps List", "ERROR 9:"&@CRLF&"No files/folders found in"&@CRLF&$sDir,0, $KingpinMapBuild)
		Else
			MsgBox($MB_SYSTEMMODAL, "Maps List", "ERROR "&@extended&":"&@CRLF&"In map search folder"&@CRLF&$sDir,0, $KingpinMapBuild)
		EndIf
		GUICtrlSetData($List0_maps,"|")
	Else
		if IsArray($aTmp) Then
			For $iI = 1 To $aTmp[0]
				$sTmp &= "|"&$aTmp[$iI]
			Next
			GUICtrlSetData($List0_maps,$sTmp)
		EndIf
	EndIf

	;enable map GUI
	GUICtrlSetState($List0_maps,$GUI_ENABLE)
	GUICtrlSetState($Combo0_maps, $GUI_ENABLE)
	GUICtrlSetState($Button0_refresh_map, $GUI_ENABLE)
	GUICtrlSetData($Input0_maps,$sDir)

EndFunc


fn_Build_Custom_Config($iGUI_REGION_1_PRE_GAME)
fn_Build_Custom_Config($iGUI_REGION_2_BSP)
fn_Build_Custom_Config($iGUI_REGION_3_VIS)
fn_Build_Custom_Config($iGUI_REGION_4_LIGHT)
fn_Build_Custom_Config($iGUI_REGION_5_GAME_OPTIONS)
;fn_Build_Custom_Config($iGUI_REGION_6_DIRECTORIES) ;todo merge?
Func fn_Build_Custom_Config($IDX_GUI)
	Local $aTmp
	Local $iRet, $iRetEnabled, $sRetSwitch, $sRetValue, $sRetValueCust, $iRetEnabledCust
	Local $iCount_default = $g_aiConfigFile_default_Count[$IDX_GUI]-1 ;count elements in default config

	For $iI = 0 To $iCount_default
		;copy default array to custom
		$g_asConfigUsed_custom[$IDX_GUI][$iI] = $g_asConfigFile_default[$IDX_GUI][$iI]

		;get switch and value
		$iRet = fn_GetSwitchValue($IDX_GUI, $iI, $iRetEnabled, $sRetSwitch, $sRetValue, 0)

		;find match
		If fn_compare_custom($IDX_GUI, $iI, $sRetSwitch, $sRetValueCust, $iRetEnabledCust) Then
			$aTmp = StringSplit($g_asConfigUsed_custom[$IDX_GUI][$iI], ",")
			;update checked and new value
			If not @error And $aTmp[0] > 3 Then
				$aTmp[4] = $iRetEnabledCust
				if ($aTmp[0] > 4) And ($sRetValueCust <> "") Then $aTmp[5] = $sRetValueCust
				$g_asConfigUsed_custom[$IDX_GUI][$iI] = _ArrayToString($aTmp, ",", 1)
			EndIf
		Else
			ConsoleWrite ("Warning: no match found in custom config. RetType="& $iRet&" Switch="&$sRetSwitch& @CRLF)
		EndIf
	Next
EndFunc
Func fn_compare_custom(ByRef $IDX_GUI, ByRef $iIdx, ByRef $sRetSwitch, ByRef $sRetValueCust, ByRef $iRetEnabledCust)
	Local $aTmp
	Local $iCount_custom = $g_aiConfigFile_custom_Count[$IDX_GUI]-1
	$iRetEnabledCust = 0

	if $sRetSwitch = "" Then Return 0

	For $iI = 0 To $iCount_custom
		$aTmp = StringSplit($g_asConfigFile_custom[$IDX_GUI][$iI], ",")
		if not @error and $aTmp[0] > 3 Then
			if StringCompare($aTmp[2], $sRetSwitch, 1) = 0 Then
				$iRetEnabledCust = Number($aTmp[3]) ;checked?
				$sRetValueCust = $aTmp[4]
				Return 1 ;found match
			EndIf
		EndIf
	Next

	Return 0 ;missing
EndFunc

#EndRegion ;end starup
;==> end startup

#Region ;==> popup GUI for compile options
Func fn_Create_Element_CheckBox($IDX, $iIdx, $iWidth, $iHeight)
	Local $iI
	Local $sItemName = "ERROR", $sItemSwitch = "", $sChecked = 0
	Local $aSwitch = StringSplit($g_asConfigUsed_custom[$IDX][$iIdx],",");$g_asConfigFile_default

	If not @error Then
		if ($aSwitch[0] >= 2)  And ($aSwitch[2] <> "") Then $sItemName   = $aSwitch[2]
		if ($aSwitch[0] >= 3)  And ($aSwitch[3] <> "") Then $sItemSwitch = $aSwitch[3]
		if ($aSwitch[0] >= 4)  And ($aSwitch[4] <> "") Then $sChecked    = Number($aSwitch[4])
		if ($aSwitch[0] >= 5)  And ($aSwitch[5] <> "") Then $g_asGUI_toolTip[$IDX][$iIdx] = string($sItemSwitch&","&$aSwitch[5])
		if ($aSwitch[0] >= 6) Then ;append multiple tool tips
			for $iI = 6 to $aSwitch[0]
				;If $aSwitch[$iI] <> "" then ;append blank space to
				$g_asGUI_toolTip[$IDX][$iIdx] &= ","&$aSwitch[$iI]
			Next
		EndIf

		;build GUI
		$g_ahGUI_ID_options[$IDX][$iIdx] = GUICtrlCreateCheckbox($sItemName, $iWidth, $iHeight, 100, 16)
		if $sChecked = 1 Then GUICtrlSetState($g_ahGUI_ID_options[$IDX][$iIdx], $GUI_CHECKED)
	Else
		ConsoleWrite ("!ERROR split********"&@CRLF)
	EndIf

EndFunc

Func fn_Create_Element_TextBox($IDX, $iIdx, $iWidth, $iHeight)
	Local $iI
	Local $sItemName = "ERROR", $sItemSwitch = "", $sChecked = 0, $sValue= ""
	Local $aSwitch = StringSplit($g_asConfigUsed_custom[$IDX][$iIdx],",",0);$g_asConfigFile_default

	If Not @error Then
		if ($aSwitch[0] >= 2)  And ($aSwitch[2] <> "") Then $sItemName   = $aSwitch[2]
		if ($aSwitch[0] >= 3)  And ($aSwitch[3] <> "") Then $sItemSwitch = $aSwitch[3]
		if ($aSwitch[0] >= 4)  And ($aSwitch[4] <> "") Then $sChecked    = Number($aSwitch[4])
		if ($aSwitch[0] >= 5)  And ($aSwitch[5] <> "") Then $sValue      = $aSwitch[5]
		if ($aSwitch[0] >= 6)  And ($aSwitch[6] <> "") Then $g_asGUI_toolTip[$IDX][$iIdx] = string($sItemSwitch&","&$aSwitch[6])
		if ($aSwitch[0] >= 7) Then ;append multiple tool tips
			for $iI = 7 to $aSwitch[0]
				;if $aSwitch[$iI] <> "" then ;allow gaps
				$g_asGUI_toolTip[$IDX][$iIdx] &= ","&$aSwitch[$iI]
			Next
		EndIf

		;build GUI
		$g_ahGUI_ID_options[$IDX][$iIdx] = GUICtrlCreateCheckbox($sItemName, $iWidth, $iHeight, 100, 16)
		$g_ahGUI_ID_inputBox[$IDX][$iIdx]= GUICtrlCreateInput($sValue, $iWidth+100, $iHeight, 55, 16)
		if $sChecked = 1 Then GUICtrlSetState($g_ahGUI_ID_options[$IDX][$iIdx], $GUI_CHECKED)
	EndIf
EndFunc

Func fn_Create_Element_TextPath($IDX, $iIdx, $iXPos, ByRef $iYPos, $IDX_PATH)
	Local $iStyle=-1, $sFile, $sInputText=""
	Local $sItemName="ERROR", $sItemSwitch="", $sChecked=0, $iPathID=0, $sText="", $sToolTip = ""
	Local $aSwitch = StringSplit($g_asConfigUsed_custom[$IDX][$iIdx],",",0);$g_asConfigFile_default
	Local Const $g_asToolTip_Folder[8] = [ _
				"  ( Using '\Game.exe' path )", _ 		; $switch_PATH_EXE_
				"  ( Using '\base\' path )", _			; $switch_PATH_BASE
				"  ( Using '\mod\' path )", _ 			; $switch_PATH_MOD_
				"  ( Using '\preBuild.exe' path )", _ 	; $switch_PATH_PRE_
				"  ( Using '\bsp.exe' path )", _ 		; $switch_PATH_BSP_
				"  ( Using '\vis.exe' path )", _ 		; $switch_PATH_VIS_
				"  ( Using '\rad.exe' path )", _ 		; $switch_PATH_RAD_
				"  ( Using '\xyz.map' path )" ]			; $switch_PATH_MAP_

	If not @error Then
		if ($aSwitch[0]) >= 2  And ($aSwitch[2] <> "") Then $sItemName   = $aSwitch[2]
		if ($aSwitch[0]) >= 3  And ($aSwitch[3] <> "") Then $sItemSwitch = $aSwitch[3]
		if ($aSwitch[0]) >= 4  And ($aSwitch[4] <> "") Then $sChecked    = Number($aSwitch[4])
		if ($aSwitch[0]) >= 5  And ($aSwitch[5] <> "") Then $sText       = $aSwitch[5]
		if ($aSwitch[0]) >= 6  And ($aSwitch[6] <> "") Then $iPathID     = Number($aSwitch[6])
		if ($aSwitch[0]) >= 7  And ($aSwitch[7] <> "") Then $sToolTip	 = ","&$aSwitch[7]

		;ToolTip. add switch name (bold)
		$g_asGUI_toolTip[$IDX][$iIdx] = $sItemSwitch
		;ToolTip. append text to folder being used
		$g_asGUI_toolTip[$IDX][$iIdx] &= $g_asToolTip_Folder[$IDX_PATH]
		;ToolTip. append the rest
		$g_asGUI_toolTip[$IDX][$iIdx] &= $sToolTip
		if ($aSwitch[0]) >= 8 Then ;append multiple tool tips
			for $iI = 8 to $aSwitch[0]
				$g_asGUI_toolTip[$IDX][$iIdx] &= ","&$aSwitch[$iI]
			Next
		EndIf

		;map full path?
		if $IDX_PATH = $switch_PATH_MAP_ Then
			$sInputText = $g_sMapSelected_full
		Else
			$sInputText = $sFilePaths[$IDX_PATH]
			;text to display in input-box
			If ($iPathID = 0) Then
				Local $sIdx = StringInStr($sInputText, "/",0, -1)
				if $sIdx Then $sInputText = StringLeft($sInputText,$sIdx)
				$iStyle = BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY)
			ElseIf ($iPathID = 1) Then
				$iStyle = BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY)
			ElseIf ($iPathID = 2) Then
				$sInputText = $sText
			EndIf
		EndIf

		;build GUI
		$g_ahGUI_ID_options[$IDX][$iIdx] = GUICtrlCreateCheckbox($sItemName, $iXPos, $iYPos, 100, 16)
		$g_ahGUI_ID_inputBox[$IDX][$iIdx]= GUICtrlCreateInput($sInputText, $iXPos+100, $iYPos, 55, 16,$iStyle)
		if $sChecked = 1 Then GUICtrlSetState($g_ahGUI_ID_options[$IDX][$iIdx], $GUI_CHECKED)
	EndIf

	$iYPos+= 16
EndFunc

;load popup GUI with custom settings
Func fn_Buld_Gui_Options($IDX)
	Local $iXPos= 8, $iYPos = 10, $iOffXtra =0
	Local $ilineNum =0
	Local $sTmp, $iIdx, $hGroup, $aTmp
	Local $aPos = WinGetPos ( $KingpinMapBuild )
	Local $sTitle[7] = ["MAIN", "Pre Game Options", "BSP Options", "VIS Options", "LIGHT Options", "Game Options", "GAME" ]
	;_ArrayDisplay($g_asConfigUsed_custom)
	GUISetState(@SW_DISABLE,$KingpinMapBuild)

	$g_ahGUI_ID[$IDX] = GUICreate($sTitle[$IDX], 455, 343, $aPos[0],$aPos[1], BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), -1, $KingpinMapBuild) ;BitOR($WS_CLIPCHILDREN,$WS_BORDER ,$WS_POPUP
	GUISetOnEvent($GUI_EVENT_CLOSE, "Button_opt_cancel_"&$IDX, $g_ahGUI_ID[$IDX])

	$hGroup = GUICtrlCreateGroup("", 2, 0, 451, 341)
	;button save
	$g_ahGUI_ID_save[$IDX] = GUICtrlCreateButton("Save", 350,316,50,22,-1,-1)
	GUICtrlSetOnEvent($g_ahGUI_ID_save[$IDX], "Button_opt_save_"&$IDX)
	;button cancel
	$g_ahGUI_ID_cancel[$IDX] = GUICtrlCreateButton("Cancel", 400,316,50,22,-1,-1)
	GUICtrlSetOnEvent($g_ahGUI_ID_cancel[$IDX], "Button_opt_cancel_"&$IDX)
	;button reset
	$g_ahGUI_ID_reset[$IDX] = GUICtrlCreateButton("Reset", 5,316,50,22,-1,-1)
	GUICtrlSetOnEvent($g_ahGUI_ID_reset[$IDX], "Button_opt_reset_"&$IDX)


	;ConsoleWrite("count="&$g_aiConfigFile_default_Count[$IDX]&" $IDX="&$IDX&@CRLF)

	for $iCount = 0 to ($g_aiConfigFile_default_Count[$IDX]-1)
		$g_ahGUI_ID_options[$IDX][$iCount] = 0
		$g_asGUI_toolTip[$IDX][$iCount] = ""
		$g_ahGUI_ID_inputBox[$IDX][$iCount]= 0

		If StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "newcolum", 0, 1, 1, 8)  Then ;$g_asConfigFile_default
			if Not ($iYPos = 10) Then
				$iYPos = 10
				$iXPos += 100 + $iOffXtra
				$ilineNum = 0
				$iOffXtra = 0
			EndIf
			;ConsoleWrite ("!new col1"&@CRLF)
		Elseif StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_CHECK_BOX", 0, 1, 1, 16) Then ;$g_asConfigFile_default
			;ConsoleWrite("+found chkbox"&@CRLF)
			fn_Create_Element_CheckBox($IDX,$iCount, $iXPos, $iYPos)
			$iYPos+= 16
			$ilineNum += 1
		ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_TEXT_BOX_", 0, 1, 1, 16) Then
				fn_Create_Element_TextBox($IDX,$iCount, $iXPos, $iYPos)
			$iYPos+= 16
			$iOffXtra = 60
			$ilineNum += 1
		ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH", 0, 1, 1, 11) Then
			If StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH_EXE_", 0, 1, 1, 16) Then
				fn_Create_Element_TextPath($IDX,$iCount, $iXPos, $iYPos, $switch_PATH_EXE_)
			ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH_BASE", 0, 1, 1, 16) Then
				fn_Create_Element_TextPath($IDX,$iCount, $iXPos, $iYPos, $switch_PATH_BASE)
			ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH_MOD_", 0, 1, 1, 16) Then
				fn_Create_Element_TextPath($IDX,$iCount, $iXPos, $iYPos, $switch_PATH_MOD_)
			ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH_PRE_", 0, 1, 1, 16) Then
				fn_Create_Element_TextPath($IDX,$iCount, $iXPos, $iYPos, $switch_PATH_PRE_)
			ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH_BSP_", 0, 1, 1, 16) Then
				fn_Create_Element_TextPath($IDX,$iCount, $iXPos, $iYPos, $switch_PATH_BSP_)
			ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH_VIS_", 0, 1, 1, 16) Then
				fn_Create_Element_TextPath($IDX,$iCount, $iXPos, $iYPos, $switch_PATH_VIS_)
			ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH_RAD_", 0, 1, 1, 16) Then
				fn_Create_Element_TextPath($IDX,$iCount, $iXPos, $iYPos, $switch_PATH_RAD_)
			ElseIf StringInStr($g_asConfigUsed_custom[$IDX][$iCount], "switch_PATH_MAP_", 0, 1, 1, 16) Then
				fn_Create_Element_TextPath($IDX,$iCount, $iXPos, $iYPos, $switch_PATH_MAP_)
			EndIf
			;$iYPos+= 16
			$iOffXtra = 60
			$ilineNum += 1
		EndIf

		;check for max colums. offset to next colum
		if  $ilineNum = 19 Then
			$ilineNum = 0
			$iYPos = 10
 			$iXPos += 100 + $iOffXtra
			$iOffXtra = 0
		EndIf
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1);end group
	GUISetState(@SW_SHOW, $g_ahGUI_ID[$IDX]) ;show gui then load elements

	;resize window if there is to many elements
	if ($iXPos+100 + $iOffXtra) > 451 Then
		for $iCount = 0 to ($g_aiConfigFile_default_Count[$IDX]-1)
			if ($g_ahGUI_ID_options[$IDX][$iCount] > 0) Then GUICtrlSetResizing($g_ahGUI_ID_options[$IDX][$iCount], $GUI_DOCKALL)
			if ($g_ahGUI_ID_inputBox[$IDX][$iCount]> 0) Then GUICtrlSetResizing($g_ahGUI_ID_inputBox[$IDX][$iCount], $GUI_DOCKALL)
		Next
		GUICtrlSetResizing($hGroup, $GUI_DOCKBORDERS)
		WinMove($g_ahGUI_ID[$IDX],"", Default,Default,$iXPos+100 + $iOffXtra+16); , 343)
	EndIf

;_ArrayDisplay($g_asGUI_toolTip)
	;set tool tip last. very slow
	for $iCount = 0 to ($g_aiConfigFile_default_Count[$IDX]-1)
		if $g_asGUI_toolTip[$IDX][$iCount] <> "" Then
			$aTmp = StringSplit($g_asGUI_toolTip[$IDX][$iCount], ",")
			if not @error and $aTmp[0] >=2 then
				$sTmp = $aTmp[2]
				For $iIdx = 3 to $aTmp[0]
					$sTmp &= @CRLF&$aTmp[$iIdx]
				Next
				GUICtrlSetTip($g_ahGUI_ID_options[$IDX][$iCount],$sTmp,$aTmp[1])
			EndIf
		EndIf
	Next


	;GUISetState(@SW_DISABLE,$KingpinMapBuild)
EndFunc

#EndRegion


#Region ;==> popup GUI for Directories
Func fn_Buld_Gui_Directories()
	Local $iXPos= 8, $iYPos = 16, $iOffXtra =0
	Local $iCount, $ilineNum =0, $iIdx
	Local $aPos = WinGetPos ( $KingpinMapBuild )
	static local $EXE_Names[3] = ["<-- Game.exe.", "<-- Base path", "<-- Mod path"]
	static local $aPathDescriptions[7] = [ _
		"Game.exe path. [eg. C:/Kingpin/kingpin.exe]", _
		"Base/main path. [eg. C:/Kingpin/main/]", _
		"Mod path(optional) [eg. C:/Kingpin/gunrace/]", _
		"Pre build path. [eg. C:/Kingpin/kprad/image2wal.exe]", _
		"Bsp.exe path. [eg. C:/Kingpin/kprad/kpbsp.exe]", _
		"Vis.exe path. [eg. C:/Kingpin/kprad/kpvis.exe]", _
		"Rad.exe path. [eg. C:/Kingpin/kprad/kprad.exe]" ]
	static local $aPathTip_quake1[7] = [ _ ;quake1
		"Quake.exe path. [eg. C:/QuakeSP/quakespasm.exe]", _
		"id1/base path. [eg. C:/QuakeSP/id1/]", _
		"Mod path(optional) [eg. C:/QuakeSP/working/]", _
		"Bsputils path. [eg. C:/QuakeSP/ericw-18/bsputil.exe]", _
		"Bsp.exe path. [eg. C:/QuakeSP/ericw-18/qbsp.exe]", _
		"Vis.exe path. [eg. C:/QuakeSP/ericw-18/vis.exe]", _
		"Light.exe path. [eg. C:/QuakeSP/ericw-18/light.exe]" ]
	static local $aPathTip_quake2[7] = [ _ ;quake2
		"Game.exe path. [eg. C:/Quake2/quake2.exe]", _
		"Base path. [eg. C:/Quake2/base/]", _
		"Mod path(optional) [eg. C:/Quake2/ctf/]", _
		"Bsputils path. [eg. C:/Quake2/_tools/bsputil.exe]", _
		"Bsp.exe path. [eg. C:/Quake2/_tools/qbsp.exe]", _
		"Vis.exe path. [eg. C:/Quake2/_tools/qvis.exe]", _
		"Light.exe path. [eg. C:/Quake2/_tools/arghrad3.exe]" ]

	if ($GUI_StringType = 1) Then
		$aPathDescriptions = $aPathTip_quake1
	ElseIf 	($GUI_StringType = 2) Then
		$aPathDescriptions = $aPathTip_quake2
	EndIf

	;create GUI
	GUISetState(@SW_DISABLE,$KingpinMapBuild)
	$g_ahGUI_ID[$iGUI_REGION_6_DIRECTORIES] = GUICreate("Setup Directory's", 455, 343, $aPos[0],$aPos[1],  BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), -1, $KingpinMapBuild) ;BitOR($WS_CLIPCHILDREN,$WS_BORDER, $WS_POPUP
	GUISetOnEvent($GUI_EVENT_CLOSE, "Button_opt_cancel_"&$iGUI_REGION_6_DIRECTORIES, $g_ahGUI_ID[$iGUI_REGION_6_DIRECTORIES])
	GUISetState(@SW_SHOW, $g_ahGUI_ID[$iGUI_REGION_6_DIRECTORIES]) ;show gui then load elements


	;folder paths
	GUICtrlCreateGroup("Game Paths", 2, 0, 349, 137)
	For $iIdx = 0 to 2
		GUICtrlCreateLabel($aPathDescriptions[$iIdx], 30, $iYPos, 300, 15)
		GUICtrlCreateButton("...", 10, $iYPos+16, 20, 18)
		GUICtrlSetOnEvent(-1, "Button_path_"&$iIdx)
		$g_ahGUI_ID_inputBox[$iGUI_REGION_6_DIRECTORIES][$iIdx] = GUICtrlCreateInput($sFilePaths[$iIdx],30, $iYPos+16, 310, 18)
		$iYPos += 40 ;36
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)


	;maps folder buttons
	GUICtrlCreateGroup("Path for Maps", 355, 0, 97, 137)
	$iYPos = 16
	For $iIdx = 0 to 2
		$g_ahGUI_ID_MapPaths[$iIdx] = GUICtrlCreateRadio($EXE_Names[$iIdx], 360, $iYPos+14, 88, 22, BitOR($GUI_SS_DEFAULT_RADIO,$BS_PUSHLIKE,$BS_FLAT))
		$iYPos += 40 ;36
	Next
	GUICtrlSetState($g_ahGUI_ID_MapPaths[$sFilePaths[7]], $GUI_CHECKED)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	;exe paths
	GUICtrlCreateGroup("Tools Path", 2, 138, 451, 203)
	$iYPos = 154
	For $iIdx = 3 to 6
		GUICtrlCreateLabel($aPathDescriptions[$iIdx], 30, $iYPos, 300, 15)
		GUICtrlCreateButton("...", 10, $iYPos+16, 20, 18)
		GUICtrlSetOnEvent(-1, "Button_path_"&$iIdx)
		$g_ahGUI_ID_inputBox[$iGUI_REGION_6_DIRECTORIES][$iIdx] = GUICtrlCreateInput($sFilePaths[$iIdx],30, $iYPos+16, 412, 18)
		$iYPos += 40 ;36
	Next

	; save/cancel
	$g_ahGUI_ID_save[$iGUI_REGION_6_DIRECTORIES] = GUICtrlCreateButton("Save", 350,316,50,22,-1,-1)
	GUICtrlSetOnEvent($g_ahGUI_ID_save[$iGUI_REGION_6_DIRECTORIES], "Button_opt_save_"&$iGUI_REGION_6_DIRECTORIES)
	$g_ahGUI_ID_cancel[$iGUI_REGION_6_DIRECTORIES] = GUICtrlCreateButton("Cancel", 400,316,50,22,-1,-1)
	GUICtrlSetOnEvent($g_ahGUI_ID_cancel[$iGUI_REGION_6_DIRECTORIES], "Button_opt_cancel_"&$iGUI_REGION_6_DIRECTORIES)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc

;directories GUI save
Func fn_StoreDirectoryPaths()
	;save to internal array..
	For $iI = 0 to 6
		$sFilePaths[$iI] = GUICtrlRead($g_ahGUI_ID_inputBox[$iGUI_REGION_6_DIRECTORIES][$iI])
		$sFilePaths[$iI] = StringReplace($sFilePaths[$iI],"\", "/") ;make all forward slash
	Next

	;append "/" on folders
	if $sFilePaths[1] <> "" Then fn_AppendForwardSlash($sFilePaths[1])
	if $sFilePaths[2] <> "" Then fn_AppendForwardSlash($sFilePaths[2])

	If  _IsChecked($g_ahGUI_ID_MapPaths[0]) Then
		$sFilePaths[$switch_PATH_MAP_] = 0
		ConsoleWrite("radio0"&@CRLF)
	ElseIf _IsChecked($g_ahGUI_ID_MapPaths[1]) Then
		$sFilePaths[$switch_PATH_MAP_] = 1
		ConsoleWrite("radio1"&@CRLF)
	Else
		$sFilePaths[$switch_PATH_MAP_] = 2
		ConsoleWrite("radio2"&@CRLF)
	EndIf

;~ 	If  _IsChecked($g_ahGUI_ID_MapSave[0]) Then
;~ 		$sFilePaths[$switch_PATH_SAVE] = 1
;~ 	Else
;~ 		$sFilePaths[$switch_PATH_SAVE] = 0
;~ 	EndIf

EndFunc

;handle file open paths/buttons in GUI 0 (directories)
Func fn_GetFolderPath($IDX)
	Local Static $sLastFolder=@ScriptDir
	Local Const $sFNames[7] = ["kingpin.exe","","","img2wal.exe","kpbsp.exe","kpvis.exe","kprad.exe"]
    Local $sFileOpenDialog, $sIdx
	Local $sImputValue = GUICtrlRead($g_ahGUI_ID_inputBox[$iGUI_REGION_6_DIRECTORIES][$IDX])

	ConsoleWrite("!begin1="&$sLastFolder&@CRLF)
	ConsoleWrite("!begin2="&$sImputValue&@CRLF)

	If FileExists($sImputValue) Then
		$sLastFolder = $sImputValue
		FileChangeDir($sLastFolder)
		ConsoleWrite("!begin3="&$sImputValue&@CRLF)
	EndIf

	$sLastFolder = StringReplace($sLastFolder,"/", "\")


	$sIdx = StringInStr($sLastFolder,".exe",0, -1)
	if $sIdx Then
		$sIdx = StringInStr($sLastFolder,"\",0, -1)
		if $sIdx Then $sLastFolder = StringLeft($sLastFolder, $sIdx)
		ConsoleWrite("!begin4="&$sLastFolder&@CRLF)
	EndIf

	;trim last "\"
	if (StringRight($sLastFolder,1) == "\") Then $sLastFolder = StringTrimRight($sLastFolder,1)
	FileChangeDir($sLastFolder)
	ConsoleWrite("!begin5="&$sLastFolder&@CRLF)


	if ($IDX = $switch_PATH_BASE) Or ($IDX = $switch_PATH_MOD_)  Then ;insert /gunrace folder  after switch
		$sFileOpenDialog = FileSelectFolder("select folder",$sLastFolder,0,"", $g_ahGUI_ID[$iGUI_REGION_6_DIRECTORIES])
	Else
		$sFileOpenDialog = FileOpenDialog("select file/path", $sLastFolder & "\", "exe (*.exe)|All (*.*)", $FD_FILEMUSTEXIST, $sFNames[$IDX], $g_ahGUI_ID[$iGUI_REGION_6_DIRECTORIES])
	EndIf


    If @error Then
        ;MsgBox($MB_SYSTEMMODAL, "", "No file/folder selected.",0, $KingpinMapBuild)
    Else
		$sFileOpenDialog = StringReplace($sFileOpenDialog,"\", "/")
		if ($IDX = $switch_PATH_BASE) Or ($IDX = $switch_PATH_MOD_)  Then
			if Not (StringRight($sFileOpenDialog,1) == "/") Then $sFileOpenDialog &= "/"
		EndIf
		GUICtrlSetData($g_ahGUI_ID_inputBox[$iGUI_REGION_6_DIRECTORIES][$IDX], $sFileOpenDialog)
		$sLastFolder = $sFileOpenDialog
		ConsoleWrite("!begin6="&$sLastFolder&@CRLF)
    EndIf
EndFunc

Func Button_path_0()
	fn_GetFolderPath(0)
EndFunc
Func Button_path_1()
	fn_GetFolderPath(1)
EndFunc
Func Button_path_2()
	fn_GetFolderPath(2)
EndFunc
Func Button_path_3()
	fn_GetFolderPath(3)
EndFunc
Func Button_path_4()
	fn_GetFolderPath(4)
EndFunc
Func Button_path_5()
	fn_GetFolderPath(5)
EndFunc
Func Button_path_6()
	fn_GetFolderPath(6)
EndFunc
Func Button_path_7()
	fn_GetFolderPath(7)
EndFunc
#EndRegion


#Region ;==> popup GUI. save/cancel buttons
;close popup. show main window
Func fn_RestoreMainWindow($IDX)

	if Not ($g_ahGUI_ID[$IDX] = -1) And WinExists($g_ahGUI_ID[$IDX]) Then
		ConsoleWrite("Close IDX=" &$IDX& " ID=" &$g_ahGUI_ID[$IDX]&@CRLF)
		GUIDelete($g_ahGUI_ID[$IDX])
		sleep(100)
		$g_ahGUI_ID[$IDX] = -1
	Else
		;trying to close a destroyed window. windows delayed event?
		ConsoleWrite("ERROR: IDX="&$IDX& " ID=" &$g_ahGUI_ID[$IDX]&@CRLF)
	EndIf

	GUISetState(@SW_ENABLE, $KingpinMapBuild)
	GUISetState(@SW_RESTORE, $KingpinMapBuild)
EndFunc


Func Button_opt_save_1()
	fn_SaveCustomConfig($iGUI_REGION_1_PRE_GAME)
	fn_RestoreMainWindow($iGUI_REGION_1_PRE_GAME)
EndFunc
Func Button_opt_save_2()
	fn_SaveCustomConfig($iGUI_REGION_2_BSP)
	fn_RestoreMainWindow($iGUI_REGION_2_BSP)
EndFunc
Func Button_opt_save_3()
	fn_SaveCustomConfig($iGUI_REGION_3_VIS)
	fn_RestoreMainWindow($iGUI_REGION_3_VIS)
EndFunc
Func Button_opt_save_4()
	fn_SaveCustomConfig($iGUI_REGION_4_LIGHT)
	fn_RestoreMainWindow($iGUI_REGION_4_LIGHT)
EndFunc
Func Button_opt_save_5()
	fn_SaveCustomConfig($iGUI_REGION_5_GAME_OPTIONS)
	fn_RestoreMainWindow($iGUI_REGION_5_GAME_OPTIONS)
EndFunc
Func Button_opt_save_6()
	fn_StoreDirectoryPaths()
	fn_RestoreMainWindow($iGUI_REGION_6_DIRECTORIES)
	fn_FillMapsList()
EndFunc

Func Button_opt_cancel_1()
	fn_RestoreMainWindow($iGUI_REGION_1_PRE_GAME)
EndFunc
Func Button_opt_cancel_2()
	fn_RestoreMainWindow($iGUI_REGION_2_BSP)
EndFunc
Func Button_opt_cancel_3()
	fn_RestoreMainWindow($iGUI_REGION_3_VIS)
EndFunc
Func Button_opt_cancel_4()
	fn_RestoreMainWindow($iGUI_REGION_4_LIGHT)
EndFunc
Func Button_opt_cancel_5()
	fn_RestoreMainWindow($iGUI_REGION_5_GAME_OPTIONS)
EndFunc
Func Button_opt_cancel_6()
	fn_RestoreMainWindow($iGUI_REGION_6_DIRECTORIES)
EndFunc


Func fn_Reset_GIU_toDefault($IDX_GUI)
	Local $iCount = $g_aiConfigFile_default_Count[$IDX_GUI]-1
	ConsoleWrite("$iCount="&$iCount&@CRLF)
	For $iI = 0 To $iCount
		$g_asConfigUsed_custom[$IDX_GUI][$iI] = $g_asConfigFile_default[$IDX_GUI][$iI]
	Next
EndFunc
Func Button_opt_reset_1()
	fn_RestoreMainWindow($iGUI_REGION_1_PRE_GAME)
	fn_Reset_GIU_toDefault($iGUI_REGION_1_PRE_GAME)
	fn_Buld_Gui_Options($iGUI_REGION_1_PRE_GAME)
EndFunc
Func Button_opt_reset_2()
	fn_RestoreMainWindow($iGUI_REGION_2_BSP)
	fn_Reset_GIU_toDefault($iGUI_REGION_2_BSP)
	fn_Buld_Gui_Options($iGUI_REGION_2_BSP)
EndFunc
Func Button_opt_reset_3()
	fn_RestoreMainWindow($iGUI_REGION_3_VIS)
	fn_Reset_GIU_toDefault($iGUI_REGION_3_VIS)
	fn_Buld_Gui_Options($iGUI_REGION_3_VIS)
EndFunc
Func Button_opt_reset_4()
	fn_RestoreMainWindow($iGUI_REGION_4_LIGHT)
	fn_Reset_GIU_toDefault($iGUI_REGION_4_LIGHT)
	fn_Buld_Gui_Options($iGUI_REGION_4_LIGHT)
EndFunc
Func Button_opt_reset_5()
	fn_RestoreMainWindow($iGUI_REGION_5_GAME_OPTIONS)
	fn_Reset_GIU_toDefault($iGUI_REGION_5_GAME_OPTIONS)
	fn_Buld_Gui_Options($iGUI_REGION_5_GAME_OPTIONS)
EndFunc
Func Button_opt_reset_6()
	fn_RestoreMainWindow($iGUI_REGION_6_DIRECTORIES)
	fn_Reset_GIU_toDefault($iGUI_REGION_6_DIRECTORIES)
	fn_Buld_Gui_Options($iGUI_REGION_6_DIRECTORIES)
EndFunc

#EndRegion


#Region ;==> Main GUI. GameOption, about, exit buttons
;
Func fn_Buld_GUI_About()
	Local $iXPos= 8, $iYPos = 10, $iOffXtra =0
	Local $ilineNum =0
	Local $sTmp, $iIdx, $aTmp
	Local $aPos = WinGetPos ( $KingpinMapBuild )
	Local Const $sOut =	"Kingpin Mapper by David Smyth (hypov8)" &@CRLF& _
						"=======" &@CRLF& _
						"Designed for quake style compilers. Fully customizable. See 'KingpinMapper_default.txt'" &@CRLF& _
						"Concept based on Q3Map2Build by DLB." &@CRLF& _
						"Shortcuts. ALT+C=Compile. ALT+P=Play. ALT+V=View Bat. ALT+R=Refresh Maps." &@CRLF& _
						"Use freely. If you use the source, make sure i get credit." &@CRLF& _
						"" &@CRLF& _
						"Saving/Loading Profiles" &@CRLF& _
						"=======" &@CRLF& _
						"Before saving, set 'Custom' and then set 'Options' for each compile tool." &@CRLF& _
						"After loading a profile, you need to set the 'Custom' radio button for it to be used. Otherwise it will use the 'Default' value from 'KingpinMapper_default.txt'" &@CRLF& _
						"Closing the app will save all custom settings to 'KingpinMapper_custom.txt'" &@CRLF& _
						"" &@CRLF& _
						"Thanks/Links" &@CRLF& _
						"=======" &@CRLF& _
						"MrDamage: Testing, PR" &@CRLF& _
						"Trickle: Testing, icon" &@CRLF& _
						"www.kingpin.info" &@CRLF& _
						"hypov8.kingpin.info" &@CRLF& _
						"hypov8@hotmail.com" &@CRLF

	GUISetState(@SW_DISABLE,$KingpinMapBuild)

	$g_ahGUI_ID[$iGUI_REGION_8_ABOUT] = GUICreate("About", 455, 343, $aPos[0],$aPos[1], BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), -1, $KingpinMapBuild)
	GUISetOnEvent($GUI_EVENT_CLOSE, "Button_opt_closeAbout", $g_ahGUI_ID[$iGUI_REGION_8_ABOUT])

	GUICtrlCreateGroup("", 2, 0, 451, 341)
	GUICtrlCreateEdit($sOut, 10, 16, 435, 316, BitOR($ES_READONLY,$ES_MULTILINE ))

	GUICtrlCreateGroup("", -99, -99, 1, 1);end group
	GUISetState(@SW_SHOW, $g_ahGUI_ID[$iGUI_REGION_8_ABOUT]) ;show gui then load elements
EndFunc

Func Button_opt_closeAbout()
	fn_RestoreMainWindow($iGUI_REGION_8_ABOUT)
EndFunc
Func Button0_aboutClick()
	fn_Buld_GUI_About()
EndFunc


;exicuitable directories
Func Button5_game_optionsClick()
	fn_Buld_Gui_Options($iGUI_REGION_5_GAME_OPTIONS)
EndFunc
Func Button6_dir_optionsClick()
	fn_Buld_Gui_Directories()
EndFunc
Func Button0_exitClick()
	KingpinMapBuildClose()
EndFunc
#EndRegion

#Region ;==> Main GUI. build batch
Func fn_convertStringTo_DOS_83($sInString)
	Local $sRet = $sInString
	Local $sTmp = FileGetShortName($sInString)

	if @error Then
		if $sInString <> "" Then
			MsgBox("", "ERROR: in path" &@CRLF, "Cant convert path to DOS 8.3" &@CRLF& _
												"Check 'Directory Options'" &@CRLF& _
												"Path: "&$sInString&@CRLF,0,$KingpinMapBuild)
		EndIf
		ConsoleWrite("error in 8.3. string="&$sInString&@CRLF)
	Else
		$sRet = $sTmp
	EndIf

	Return $sRet
EndFunc

;checkbox
Func fn_switchType_CheckBox(ByRef $aSplit, ByRef $iRetEnabled, ByRef $sRetSwitch, ByRef $sRetValue)
	Local $iRet = 0

	if $aSplit[3] <> "" Then
		$sRetSwitch = $aSplit[3] ;<compile switch>
		$sRetValue = "" ;<default text>
		$iRet = 1
		if (Number($aSplit[4]) = 1) Then $iRetEnabled = 1 ;checked
	EndIf

	Return $iRet
EndFunc
;checkbos with text
Func fn_switchType_TextBox(ByRef $aSplit, ByRef $iRetEnabled, ByRef $sRetSwitch, ByRef $sRetValue)
	Local $iRet = 0

	if $aSplit[3] <> "" Then
		$sRetSwitch = $aSplit[3] ;<compile switch>
		$iRet = 1
		if $aSplit[0] >= 5 And $aSplit[5] <> "" Then
			$sRetValue = $aSplit[5] ;<default text>
			$iRet = 2
		EndIf
		if (Number($aSplit[4]) = 1) Then $iRetEnabled =  1 ;checked
	EndIf

	Return $iRet
EndFunc
;use compile paths in switch
Func fn_switchType_TextPath(ByRef $aSplit, ByRef $iRetEnabled, ByRef $sRetSwitch, ByRef $sRetValue, $IDX)
	Local $sItemName="ERROR", $iPathID="", $sText="", $iRet = 0

	if $aSplit[3] <> "" Then
		$sRetSwitch =  $aSplit[3]	;<compile switch>
		$sRetValue = "" 			;<default text>
		$iRet = 1

		if (Number($aSplit[4]) = 1) Then $iRetEnabled = 1 ;checked

		if ($aSplit[0] >= 5)  And ($aSplit[5] <> "") Then $sText    = $aSplit[5]
		if ($aSplit[0] >= 6)  And ($aSplit[6] <> "") Then $iPathID  = Number($aSplit[6])

		;use map name
		if ($IDX = $switch_PATH_MAP_) Then
			if _IsChecked($Checkbox0_DOS_8_3) Then ; And ($sChecked =1) Then
				$sRetValue = fn_convertStringTo_DOS_83($g_sMapSelected_path) & $g_sMapSelected_name ;ok. remove space in folder names
			Else
				$sRetValue = $g_sMapSelected_full
			EndIf
			;use string
			If ($sRetValue <>"") Then $iRet = 2
			ConsoleWrite("!check map path="&$sRetValue&@CRLF)
		Else
			Local $sFPath = $sFilePaths[$IDX]
			Local $sIdx = StringInStr($sFPath, "/",0, -1)
			if $sIdx Then
				$sRetValue = StringLeft($sFPath, $sIdx) 						;folder/
				if _IsChecked($Checkbox0_DOS_8_3) Then $sRetValue = fn_convertStringTo_DOS_83($sRetValue)	;And ($sChecked =1)
				If ($iPathID = 1) Then $sRetValue &= StringMid($sFPath, $sIdx)	;folder/file
				If ($iPathID = 2) Then $sRetValue &= $sText						;folder/text
				;use string
				If ($sRetValue <>"") Then $iRet = 2
				ConsoleWrite("!Return path="&$sRetValue&@CRLF) ;todo: check this. file name spaces??
			EndIf
		EndIf
	EndIf

	Return $iRet
EndFunc

Func fn_GetSwitchValue($IDX_GUI, $iIdx, ByRef $iRetEnabled, ByRef $sRetSwitch, ByRef $sRetValue, $iCustom)
	Local $aSplit
	$iRetEnabled = 0
	$sRetSwitch = ""
	$sRetValue = ""

	if ($iCustom = 1) then
		$aSplit= StringSplit($g_asConfigUsed_custom[$IDX_GUI][$iIdx], ",")
	Else
		$aSplit= StringSplit($g_asConfigFile_default[$IDX_GUI][$iIdx], ",")
	EndIf

	if @error Then Return 0

	;compiler uses map name at end
	If $aSplit[0] >= 1 And StringInStr($aSplit[1], "switch_APPENDMAP", 0, 1, 1, 16) Then Return 3

	if $aSplit[0] >=4 Then ;make sure it has a checked value.
		if StringInStr($aSplit[1], "switch_CHECK_BOX", 0, 1, 1, 16) Then
			Return fn_switchType_CheckBox($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue)
		ElseIf StringInStr($aSplit[1], "switch_TEXT_BOX_", 0, 1, 1, 16) Then
			Return fn_switchType_TextBox($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue)
		;use compile path in string
		ElseIf StringInStr($aSplit[1], "switch_PATH_EXE_", 0, 1, 1, 16) Then
			Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $switch_PATH_EXE_)
		ElseIf StringInStr($aSplit[1], "switch_PATH_BASE", 0, 1, 1, 16) Then
			Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $switch_PATH_BASE)
		ElseIf StringInStr($aSplit[1], "switch_PATH_MOD_", 0, 1, 1, 16) Then
			Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $switch_PATH_MOD_)
		ElseIf StringInStr($aSplit[1], "switch_PATH_PRE_", 0, 1, 1, 16) Then
			Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $switch_PATH_PRE_)
		ElseIf StringInStr($aSplit[1], "switch_PATH_BSP_", 0, 1, 1, 16) Then
			Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $switch_PATH_BSP_)
		ElseIf StringInStr($aSplit[1], "switch_PATH_VIS_", 0, 1, 1, 16) Then
			Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $switch_PATH_VIS_)
		ElseIf StringInStr($aSplit[1], "switch_PATH_RAD_", 0, 1, 1, 16) Then
			Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $switch_PATH_RAD_)
		ElseIf StringInStr($aSplit[1], "switch_PATH_MAP_", 0, 1, 1, 16) Then
			Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $switch_PATH_MAP_)
		EndIf
	EndIf
	Return 0
EndFunc


Func fn_buildBatch_CompileString($IDX_GUI, $IDX_PATH, $iComp)
	Local $bRet, $iRetEnabled, $sRetSwitch, $sRetValue, $sPath_EXE, $iAppendMap=0
	Local $iCount_default = $g_aiConfigFile_default_Count[$IDX_GUI]-1
	Local $hChekBoxArrar[4] = [$Checkbox1_pause, $Checkbox2_pause, $Checkbox3_pause, $Checkbox4_pause]
	Local $hRadioArrar_none[4] = [$Radio1_none, $Radio2_none, $Radio3_none, $Radio4_none]
	Local $hRadioArrar_default[4] = [$Radio1_default, $Radio2_default, $Radio3_default, $Radio4_default]
	;Local $hRadioArrar_default[4] = [$Radio1_custom, $Radio2_custom, $Radio3_custom, $Radio4_custom]
	ConsoleWrite("batch count="&$iCount_default&@CRLF)

	$g_as_CompileString[$iComp] = ""
	if _IsChecked($hRadioArrar_none[$iComp]) Then Return ;disabled by user

	;use windows start?
	if _IsChecked($Checkbox0_UseWinStart) Then $g_as_CompileString[$iComp] = "start /B /I /low /wait "

	;add tool executable
	$sPath_EXE = $sFilePaths[$IDX_PATH]
	if _IsChecked($Checkbox0_DOS_8_3) Then $sPath_EXE = fn_convertStringTo_DOS_83($sPath_EXE) ;ok
	$g_as_CompileString[$iComp] &= $sPath_EXE &" " ;default compile.exe

	;use settings in default config
	If _IsChecked($hRadioArrar_default[$iComp]) Then
		For $iIdx = 0 to $iCount_default
			$bRet = fn_GetSwitchValue($IDX_GUI, $iIdx, $iRetEnabled, $sRetSwitch, $sRetValue, 0)
			If ($iRetEnabled = 1) Then
				If ($bRet = 1) Then
					$g_as_CompileString[$iComp] &= $sRetSwitch&" "
				ElseIf ($bRet = 2) Then
					$g_as_CompileString[$iComp] &= $sRetSwitch&" "&$sRetValue&" "
				EndIf
			EndIf
			If ($bRet = 3) Then $iAppendMap = 1
		Next
	Else ;'custom' radio button checked.
		For $iIdx = 0 to $iCount_default
			$bRet = fn_GetSwitchValue($IDX_GUI, $iIdx, $iRetEnabled, $sRetSwitch, $sRetValue, 1)
			If ($iRetEnabled = 1) Then
				If ($bRet = 1) Then
					$g_as_CompileString[$iComp] &= $sRetSwitch&" "
				ElseIf ($bRet = 2) Then
					$g_as_CompileString[$iComp] &= $sRetSwitch&" "&$sRetValue&" "
				EndIf
			EndIf
			If ($bRet = 3) Then $iAppendMap = 1
		Next
	EndIf

	;append .map "switch_APPENDMAP"
	if ($iAppendMap = 1) Then
		if _IsChecked($Checkbox0_DOS_8_3) Then
			$g_as_CompileString[$iComp] &= fn_convertStringTo_DOS_83($g_sMapSelected_path) &$g_sMapSelected_name
		Else
			$g_as_CompileString[$iComp] &= $g_sMapSelected_full
		EndIf
	EndIf
EndFunc

Func fn_BuildMapsPath()
	Local $sDir = "", $iTmp
	if ($sFilePaths[$switch_PATH_MAP_] = 0) Then
		$sDir = $sFilePaths[$switch_PATH_EXE_] ;game.exe folder
		$iTmp = StringInStr($sFilePaths[$switch_PATH_EXE_],"/",0,-1)
		if $iTmp Then $sDir = StringLeft($sFilePaths[$switch_PATH_EXE_], $iTmp)
	ElseIf ($sFilePaths[$switch_PATH_MAP_] = 1) Then
		$sDir = $sFilePaths[$switch_PATH_BASE]	;base/main folder
	Else
		$sDir = $sFilePaths[$switch_PATH_MOD_]	;mod folder
	EndIf

	;append forward slash?
	if Not StringRight($sDir,1) == "/" Then $sDir&="/"

	;appends maps folder if not root
	if Not ($sFilePaths[$switch_PATH_MAP_] = 0) Then $sDir &= "maps/"

	Return $sDir
EndFunc

Func fn_BuildCompileString()
	Local $sOut = ""
	Local $hChekBoxArrar[4] = [$Checkbox1_pause, $Checkbox2_pause, $Checkbox3_pause, $Checkbox4_pause]
	;_ArrayDisplay($hChekBoxArrar)

	For $iIdx = 0 to 3
		if ($g_as_CompileString[$iIdx] <> "") Then
			$sOut &= $g_as_CompileString[$iIdx] & @CRLF
			if _IsChecked($hChekBoxArrar[$iIdx]) Then $sOut &= "pause" & @CRLF
		EndIf
	Next

	if _IsChecked($Checkbox0_play_build) Then $sOut &= $g_as_CompileString[4]

	Return $sOut
EndFunc


Func fn_BatchFile_Run()
	Local $sOut = fn_BuildCompileString()
	Local $sFileTmpName, $hFile, $iI=0

	If _IsChecked($Checkbox0_save_bat) Then
		$sFileTmpName = StringTrimRight($g_sMapSelected_full, 4)&".bat"
	Else
		$sFileTmpName = $g_sFileName_bat_full
	EndIf

	;save backup file
 	If  _IsChecked($Checkbox0_backupMap) Then ;if $sFilePaths[$switch_PATH_SAVE] = 1 Then
		local $sIdx = StringInStr($g_sMapSelected_full, "/",0, -1)
		if $sIdx Then
			Local $sTmp = StringLeft ($g_sMapSelected_full, $sIdx) & "snapshots/"& $g_sMapSelected_name&"."
			ConsoleWrite("save tmpMap dir1="&$sTmp& @CRLF)
			;increment file name
			While(FileExists( String($sTmp & $iI)))
				$iI +=1
			WEnd
			FileCopy($g_sMapSelected_full, String($sTmp& $iI))
			ConsoleWrite("save tmpMap dir2="&String($sTmp & $iI)& @CRLF)
		EndIf
	EndIf

	$hFile = FileOpen($sFileTmpName, $FO_OVERWRITE)
	if $hFile = -1 Then
		ConsoleWrite("!ERROR COMP"&@CRLF)
	Else
		ConsoleWrite(">open bat ok"&@CRLF)
		FileWrite($hFile, $sOut)
		ConsoleWrite(">write to bat"&@CRLF)
		FileClose($hFile)
		ConsoleWrite(">close bat"&@CRLF)
		;Run($sFileTmpName, "")
		;ShellExecute($sFileTmpName,"", "", $SHEX_OPEN )
		ShellExecute(@ComSpec, " /c "& $sFileTmpName, "", $SHEX_OPEN )
		ConsoleWrite(">bat running"&@CRLF)
	EndIf
	ConsoleWrite("$sFileTmpName="&$sFileTmpName&@CRLF)
EndFunc

Func fn_BatchFile_View()
	Local $sOut = fn_BuildCompileString()
	Local $ilineNum =0
	Local $aPos = WinGetPos ( $KingpinMapBuild )
	;_ArrayDisplay($g_asConfigUsed_custom)
	GUISetState(@SW_DISABLE,$KingpinMapBuild)

	$g_ahGUI_ID[$iGUI_REGION_7_BAT] = GUICreate("Batch Compile String", 455, 343, $aPos[0],$aPos[1], BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), -1, $KingpinMapBuild)
	GUISetOnEvent($GUI_EVENT_CLOSE, "Button_opt_closeBat", $g_ahGUI_ID[$iGUI_REGION_7_BAT])

	GUICtrlCreateGroup("", 2, 0, 451, 341)
	GUICtrlCreateEdit($sOut, 10, 16, 435, 316)

	GUICtrlCreateGroup("", -99, -99, 1, 1);end group
	GUISetState(@SW_SHOW, $g_ahGUI_ID[$iGUI_REGION_7_BAT]) ;show gui then load elements
EndFunc

Func Button_opt_closeBat()
	fn_RestoreMainWindow($iGUI_REGION_7_BAT)
EndFunc

Func fn_buildBatch_PlayMap()
	Local $sPath_EXE = $sFilePaths[$switch_PATH_EXE_]
	Local $sParameters = "", $sWorkingDir = ""
	fn_BuildPlayExeString($sParameters, $sWorkingDir)

	if _IsChecked($Checkbox0_DOS_8_3) Then $sPath_EXE = fn_convertStringTo_DOS_83($sPath_EXE)
	$g_as_CompileString[4] = "cd /d "&$sWorkingDir&@CRLF
;~ 	If _IsChecked($Checkbox0_UseWinStart) Then
		$g_as_CompileString[4] &= "start "& $sPath_EXE &" "& $sParameters
;~ 	Else
;~ 		$g_as_CompileString[4] &= $sPath_EXE& " "&$sParameters
;~ 	EndIf

EndFunc

#EndRegion

#Region ;==> Main GUI. maps group
Func fn_Build_Map_Compile_Strings()
	fn_buildBatch_CompileString($iGUI_REGION_1_PRE_GAME, $switch_PATH_PRE_, 0)
	fn_buildBatch_CompileString($iGUI_REGION_2_BSP, $switch_PATH_BSP_, 1)
	fn_buildBatch_CompileString($iGUI_REGION_3_VIS, $switch_PATH_VIS_, 2)
	fn_buildBatch_CompileString($iGUI_REGION_4_LIGHT, $switch_PATH_RAD_, 3)
	fn_buildBatch_PlayMap()
EndFunc


Func List0_mapsClick()
	Local $iIdx = _GUICtrlComboBox_GetCurSel($Combo0_maps)
	$g_sMapSelected_name = StringReplace(GUICtrlRead($List0_maps), "\", "/")
	GUICtrlSetState($Button0_build_map, $GUI_ENABLE)
	GUICtrlSetState($Button0_view_bat, $GUI_ENABLE)
	GUICtrlSetState($Button0_play_map, $GUI_DISABLE) ;disable

	$g_sMapSelected_path = fn_BuildMapsPath()
	$g_sMapSelected_full = $g_sMapSelected_path & $g_sMapSelected_name
	ConsoleWrite("$g_sMapSelected_full="&$g_sMapSelected_full&@CRLF)


	ConsoleWrite("$iIdx="&$iIdx&@CRLF)
	if $iIdx = 0 Then ;*.map 'selected'
		Local $sTmp = GUICtrlRead($Input0_maps)
		$sTmp = $sTmp & StringTrimRight($g_sMapSelected_name, 4) & ".bsp"
		ConsoleWrite("$sTmp="&$sTmp&@CRLF)
		if FileExists($sTmp) Then GUICtrlSetState($Button0_play_map, $GUI_ENABLE)
	Else			;*.bsp 'selected'
		GUICtrlSetState($Button0_play_map, $GUI_ENABLE)
	EndIf

	ConsoleWrite("clicked="&GUICtrlRead($Input0_maps)&@CRLF)
EndFunc

;Global $g_as_RunGameString = ""

Func fn_BuildPlayExeString(ByRef $sParameters, ByRef $sWorkingDir)
	Local $bRet, $iRetEnabled, $sRetSwitch, $sRetValue, $sIdx

	Local $iCount_default = $g_aiConfigFile_default_Count[$iGUI_REGION_5_GAME_OPTIONS]-1

	;$g_as_RunGameString = ""
	;$g_as_RunGameString &= $sFilePaths[$switch_PATH_EXE_]&" " ;default compile.exe

	For $iIdx = 0 to $iCount_default
		$bRet = fn_GetSwitchValue($iGUI_REGION_5_GAME_OPTIONS, $iIdx, $iRetEnabled, $sRetSwitch, $sRetValue, 1)
		if ($iRetEnabled = 1) Then
			If ($bRet = 1) Then
				$sParameters &= $sRetSwitch&" "
			ElseIf ($bRet = 2) Then
				$sParameters &= $sRetSwitch&" "&$sRetValue&" "
			EndIf
		EndIf
	Next

	$sIdx = StringInStr($sFilePaths[$switch_PATH_EXE_], "/",0, -1)
	if $sIdx Then
		$sWorkingDir = StringLeft($sFilePaths[$switch_PATH_EXE_],$sIdx)
		if _IsChecked($Checkbox0_DOS_8_3) Then $sWorkingDir = fn_convertStringTo_DOS_83($sWorkingDir)
	EndIf

	;appent map
	$sParameters &= "+map "& StringTrimRight($g_sMapSelected_name,4) & @CRLF
EndFunc

Func fn_PlayMap()
	Local $sPath_EXE = $sFilePaths[$switch_PATH_EXE_]
	Local $sParameters = "", $sWorkingDir = ""
	fn_BuildPlayExeString($sParameters, $sWorkingDir)

	if _IsChecked($Checkbox0_DOS_8_3) Then $sPath_EXE = fn_convertStringTo_DOS_83($sPath_EXE)
	ShellExecute($sPath_EXE, $sParameters, $sWorkingDir)
	;Run($sPath_EXE, )

	ConsoleWrite("$sPath_EXE"&$sPath_EXE&@CRLF)
	ConsoleWrite("workDir"&$sWorkingDir&@CRLF)
	ConsoleWrite("run="&$sParameters&@CRLF)
EndFunc

;~ Func Checkbox0_play_buildClick()
;~ EndFunc
;~ Func Checkbox0_save_batClick()
;~ EndFunc


Func Button0_build_mapClick()
	fn_Build_Map_Compile_Strings()
	fn_BatchFile_Run()
EndFunc
Func Button0_view_batClick()
	fn_Build_Map_Compile_Strings()
	fn_BatchFile_View()
EndFunc
Func Button0_play_mapClick()
	fn_PlayMap()
EndFunc
Func Button0_refresh_mapClick()
	fn_FillMapsList()
EndFunc
Func Combo0_mapsChange()
	fn_FillMapsList()
EndFunc
#EndRegion

#Region ;==> Main GUI. profile group

Global Static $g_sLastFolder_profile = @ScriptDir

Func Button_p_loadClick()
	Local $sPathWorking = @WorkingDir
	Local $sPathSelecte = FileOpenDialog("Load Profile", $g_sLastFolder_profile, "Text (*.txt)| All Files (*.*)",$FD_FILEMUSTEXIST,"", $KingpinMapBuild)
	If @error Then
		FileChangeDir($sPathWorking)
	Else
		FileChangeDir($sPathWorking)
		fn_ReadConfigFile_Custom($sPathSelecte)
		fn_Build_Custom_Config($iGUI_REGION_1_PRE_GAME)
		fn_Build_Custom_Config($iGUI_REGION_2_BSP)
		fn_Build_Custom_Config($iGUI_REGION_3_VIS)
		fn_Build_Custom_Config($iGUI_REGION_4_LIGHT)
		fn_Build_Custom_Config($iGUI_REGION_5_GAME_OPTIONS)
		;fn_Build_Custom_Config($iGUI_REGION_6_DIRECTORIES) ;todo merge into 1 file?

		$g_sLastFolder_profile = $sPathSelecte
		Local $sIdx = StringInStr($g_sLastFolder_profile,"\",0, -1)
		if $sIdx Then $g_sLastFolder_profile = StringLeft($g_sLastFolder_profile, $sIdx)
	EndIf
EndFunc
Func Button_p_saveClick()
	Local $sPathWorking = @WorkingDir
	Local $sPathSelecte = FileSaveDialog("Save Profile", $g_sLastFolder_profile, "Text (*.txt)| All Files (*.*)", 0,"", $KingpinMapBuild)
	If @error Then
		FileChangeDir($sPathWorking)
	Else
		FileChangeDir($sPathWorking)
		fn_Savefile_CustomConfig($sPathSelecte)
		$g_sLastFolder_profile = $sPathSelecte
		Local $sIdx = StringInStr($g_sLastFolder_profile,"\",0, -1)
		if $sIdx Then $g_sLastFolder_profile = StringLeft($g_sLastFolder_profile, $sIdx)
	EndIf
EndFunc
#EndRegion

#Region ;==> Main GUI. compile tools group
Func Radio1_noneClick()
	If _IsChecked($Radio1_none) Or _IsChecked($Radio1_default) Then
		GUICtrlSetState($Button1_option, $GUI_DISABLE)
	Else
		GUICtrlSetState($Button1_option, $GUI_ENABLE)
	EndIf
EndFunc
Func Radio2_noneClick()
	If _IsChecked($Radio2_none) Or _IsChecked($Radio2_default) Then
		GUICtrlSetState($Button2_option, $GUI_DISABLE)
	Else
		GUICtrlSetState($Button2_option, $GUI_ENABLE)
	EndIf
EndFunc
Func Radio3_noneClick()
	If _IsChecked($Radio3_none) Or _IsChecked($Radio3_default) Then
		GUICtrlSetState($Button3_option, $GUI_DISABLE)
	Else
		GUICtrlSetState($Button3_option, $GUI_ENABLE)
	EndIf
EndFunc
Func Radio4_noneClick()
	If _IsChecked($Radio4_none) Or _IsChecked($Radio4_default) Then
		GUICtrlSetState($Button4_option, $GUI_DISABLE)
	Else
		GUICtrlSetState($Button4_option, $GUI_ENABLE)
	EndIf
EndFunc


Func Button1_optionClick()
	;fn_Build_Custom_Config($iGUI_REGION_1_PRE_GAME)
	fn_Buld_Gui_Options($iGUI_REGION_1_PRE_GAME)
EndFunc
Func Button2_optionClick()
	;fn_Build_Custom_Config($iGUI_REGION_2_BSP)
	fn_Buld_Gui_Options($iGUI_REGION_2_BSP)
EndFunc
Func Button3_optionClick()
	;fn_Build_Custom_Config($iGUI_REGION_3_VIS)
	fn_Buld_Gui_Options($iGUI_REGION_3_VIS)
EndFunc
Func Button4_optionClick()
	;fn_Build_Custom_Config($iGUI_REGION_4_LIGHT)
	fn_Buld_Gui_Options($iGUI_REGION_4_LIGHT)
EndFunc
#EndRegion


#Region ;==> exit
;save custom config internaly, on closed GUI
Func fn_SaveCustomConfig($IDX_GUI)
	Local $iCount = $g_aiConfigFile_default_Count[$IDX_GUI]
	Local $aTmp
	;_ArrayDisplay($g_asConfigUsed_custom)

	For $iI = 0 to $iCount
		;duplicate the orig aray
		$g_asConfigUsed_custom[$IDX_GUI][$iI] = $g_asConfigFile_default[$IDX_GUI][$iI]

		$aTmp = StringSplit($g_asConfigUsed_custom[$IDX_GUI][$iI], ",")
		If Not @error Then
			;ConsoleWrite(">#4="&$g_ahGUI_ID_options[$IDX_GUI][$iI]&" #4="&$g_ahGUI_ID_inputBox[$IDX_GUI][$iI]&@CRLF)
			;checkbox
			If $aTmp[0] > 3 And $g_ahGUI_ID_options[$IDX_GUI][$iI] Then
				if _IsChecked($g_ahGUI_ID_options[$IDX_GUI][$iI]) Then
					$aTmp[4] = 1
				Else
					$aTmp[4] = 0
				EndIf
			EndIf
			;check inputbox
			If $aTmp[0] > 4 And StringCompare($aTmp[4], "switch_CHECK_BOX", 1) And $g_ahGUI_ID_inputBox[$IDX_GUI][$iI] Then
				$aTmp[5] = GUICtrlRead($g_ahGUI_ID_inputBox[$IDX_GUI][$iI])
			EndIf
			;update
			$g_asConfigUsed_custom[$IDX_GUI][$iI] = _ArrayToString($aTmp, ",", 1)
		EndIf
	Next
	;_ArrayDisplay($g_asConfigUsed_custom)

EndFunc


;save config. paths
Func fn_Savefile_ExePaths()
	Local $hTmp_options[5] 		= [$Checkbox0_play_build, $Checkbox0_save_bat, $Checkbox0_UseWinStart, $Checkbox0_DOS_8_3, $Checkbox0_backupMap]
	Local $hTmp_build_none[4] 	= [$Radio1_none, $Radio2_none, $Radio3_none, $Radio4_none]
	Local $hTmp_build_def[4] 	= [$Radio1_default, $Radio2_default, $Radio3_default, $Radio4_default]
	Local $hTmp_pause[4] 		= [$Checkbox1_pause, $Checkbox2_pause, $Checkbox3_pause, $Checkbox4_pause]
	Local $sSavePath[8]  		= ["PATH_EXE,", "PATH_BASE,", "PATH_MOD,","PATH_PRE,", _
									"PATH_BSP,","PATH_VIS,","PATH_RAD,","MAP_INDEX,"]
	Local $sSaveGUI[5]   		= ["GUI_PLAY_AFTER,", "GUI_SAVE_BAT,", "GUI_USEWIN,", "GUI_USE_DOS,", "GUI_BACKUP_MAP,"]
	Local $sSaveBuild[4] 		= ["GUI_BUILD_PRE,", "GUI_BUILD_BSP,", "GUI_BUILD_VIS,", "GUI_BUILD_RAD,"]
	Local $sSavePause[4] 		= ["GUI_PAUSE_PRE,", "GUI_PAUSE_BSP,", "GUI_PAUSE_VIS,", "GUI_PAUSE_RAD,"]


	Local $hFileOpen = FileOpen($g_sFilename_cfg_path_full, $FO_OVERWRITE)
	If $hFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, "", "Error reading file."&@CRLF& $g_sFilename_cfg_paths)
		Return False
	EndIf

	;paths
	For $iI=0 to 6
		$sFilePaths[$iI] = StringReplace($sFilePaths[$iI],"\", "/") ;make all forward slash
		FileWriteLine($hFileOpen, string($sSavePath[$iI]& $sFilePaths[$iI]))
	Next
	FileWriteLine($hFileOpen, string($sSavePath[7]& $sFilePaths[7]))
	;FileWriteLine($hFileOpen, string($sSavePath[8]& $sFilePaths[8]))

	;options
	For $iI=0 to 4
		if _IsChecked($hTmp_options[$iI]) Then
			FileWriteLine($hFileOpen, $sSaveGUI[$iI]&"1")
		Else
			FileWriteLine($hFileOpen, $sSaveGUI[$iI]&"0")
		EndIf
	Next
	;build
	For $iI=0 to 3
		if _IsChecked($hTmp_build_none[$iI]) Then
			FileWriteLine($hFileOpen, $sSaveBuild[$iI]&"0")
		ElseIf  _IsChecked($hTmp_build_def[$iI]) Then
			FileWriteLine($hFileOpen, $sSaveBuild[$iI]&"1")
		Else
			FileWriteLine($hFileOpen, $sSaveBuild[$iI]&"2")
		EndIf
	Next
	;pause
	For $iI=0 to 3
		if _IsChecked($hTmp_pause[$iI]) Then
			FileWriteLine($hFileOpen, $sSavePause[$iI]&"1")
		Else
			FileWriteLine($hFileOpen, $sSavePause[$iI]&"0")
		EndIf
	Next

	FileClose($hFileOpen)
EndFunc

;save config compile options
Func fn_Savefile_CustomConfig($sFilePath)
    Local $iLineCount, $aSplit
	Local $hFileOpen = FileOpen($sFilePath, $FO_OVERWRITE)
	Local $sItemName="ERROR", $sItemSwitch="", $sChecked=0, $sText="", $iPathID=""

	Local Const $sTmpName[7] = ["GUI", "PRE", "BSP", "VIS", "LIGHT", "GAME", "DIR" ]

	If $hFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
		Return False
	EndIf
;~ _ArrayDisplay($g_aiConfigFile_default_Count)
;~ _ArrayDisplay($g_asConfigUsed_custom)

	FileWriteLine($hFileOpen, 	"//Loaded at startup. Rebuilt when closing app" &@CRLF& _
								"//<type>, <compile switch>, <checked(0/1)>, <default text>")

	;loop through all gui configs
	For $IDX_GUI = 1 To 5
		$iLineCount = $g_aiConfigFile_default_Count[$IDX_GUI]-1

		;loop though all elements
		For $iIdx = 0 To $iLineCount
			$sItemSwitch=""
			$sChecked=0
			$sText=""

			$aSplit = StringSplit($g_asConfigUsed_custom[$IDX_GUI][$iIdx], ",")
			if Not @error  Then
				if $aSplit[0] >= 3  And $aSplit[3] <> "" Then $sItemSwitch = $aSplit[3]
				if $aSplit[0] >= 4  And $aSplit[4] <> "" Then $sChecked    = Number($aSplit[4])
				if $aSplit[0] >= 5  And $aSplit[5] <> "" Then $sText       = $aSplit[5]

				;save all valid. skip new lines
				If StringCompare( $aSplit[1], "newcolum", 1) Then
					If StringCompare( $aSplit[1], "switch_CHECK_BOX", 1) = 0 Then $sText="" ; reset text for checkbox
					FileWriteLine($hFileOpen, String($sTmpName[$IDX_GUI]&","& $sItemSwitch&","& $sChecked&","& $sText))
				EndIf
			Else
				ConsoleWrite("!WARNING: cant save "&$g_asConfigUsed_custom[$IDX_GUI][$iIdx]&@CRLF)
			EndIf
		Next

	Next

	FileClose($hFileOpen)

EndFunc

Func KingpinMapBuildClose()
	fn_Savefile_ExePaths()
	fn_Savefile_CustomConfig($g_sFilename_cfg_custom_full)

	For $iI = 0 to 5
		if Not ($g_ahGUI_ID[$iI] = -1) Then GUIDelete($g_ahGUI_ID[$iI])
	Next
	GUIDelete($KingpinMapBuild)
	Exit
EndFunc
#EndRegion


While 1
	Sleep(100)
WEnd
