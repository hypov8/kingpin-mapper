#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=D:\_code_\icon\kp_map_compile.ico
#AutoIt3Wrapper_Outfile=KingpinMapper.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Fileversion=1.0.9.2
#AutoIt3Wrapper_AU3Check_Parameters=-d
#Au3Stripper_Parameters=/so /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#pragma compile(inputboxres, true)

Global Const $GUI_VERSION = "1.0.9" ;

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
;v1.0.8 2023-02-7
;added Q3/kingpinQ3 config
;changed config file to set title on tool group (TOOL1_XYZ. XYZ=name displayed)
;added *.* file type
;added a game comboBox (search subfolder for config files)

;v1.0.9 2023-12-26
; fixed link in about
; add note to tooltop for profiles
; fix bug in muted checkboxes

;v1.0.9.1 2024-04-14
; removed esc key exits script
; fix for 'forced' switches being changable

;v1.0.9.2 2025-02-06
; cleaned up arrays
; removed whitespaces when reading/writing configs
; renamed pre/bsp/vis/rad to tool1/tool2/tool3/tool4 (backward comptable)


;todo
; =========================
; patch DPI scale
; add .bsp file switch in config
; check for incompatable forward slash?
; find cause of delay when pressing build for the first time
; add switch_PATH_TEXT
; added search bar to maps
; loading profile sets custom option?


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
#include <GuiEdit.au3>
Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)
AutoItSetOption("GUICloseOnESC", 0)


#Region ### START Koda GUI section ### Form=kingpinmapbuild.kxf
Global $KingpinMapBuild = GUICreate("Kingpin-Mapper by HypoV8", 455, 343, -1, -1)
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
GUICtrlSetData(-1, "*.map|*.bsp|*.*", "*.map")
GUICtrlSetOnEvent(-1, "Combo0_mapsChange")
Global $Input0_maps = GUICtrlCreateInput("", 8, 204, 261, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
GUICtrlSetLimit(-1, 250);char limit
Global $Button6_dir_options = GUICtrlCreateButton("Directory Options", 272, 204, 97, 21)
GUICtrlSetTip(-1, "Setup paths to game and compilers")
GUICtrlSetOnEvent(-1, "Button6_dir_optionsClick")
Global $Button0_play_map = GUICtrlCreateButton("&Play", 316, 84, 53, 29)
GUICtrlSetTip(-1, "Play selected map using the play game 'options'")
GUICtrlSetOnEvent(-1, "Button0_play_mapClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_prebuild = GUICtrlCreateGroup("TOOL1", 136, 235, 77, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
Global $Radio1_none = GUICtrlCreateRadio("None", 144, 251, 61, 15)
GUICtrlSetOnEvent(-1, "Radio1_noneClick")
Global $Radio1_default = GUICtrlCreateRadio("Default", 144, 267, 61, 15)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Radio1_noneClick")
Global $Radio1_custom = GUICtrlCreateRadio("Custom", 144, 283, 61, 15)
GUICtrlSetOnEvent(-1, "Radio1_noneClick")
Global $Button1_option = GUICtrlCreateButton("Options", 144, 301, 61, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button1_optionClick")
Global $Checkbox1_pause = GUICtrlCreateCheckbox("Pause", 144, 321, 53, 13)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_bsp = GUICtrlCreateGroup("TOOL2", 216, 235, 77, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
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
Global $Group_vis = GUICtrlCreateGroup("TOOL3", 296, 235, 77, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
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
Global $Group_light = GUICtrlCreateGroup("TOOL4", 376, 235, 77, 105, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
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


Global $Label1 = GUICtrlCreateLabel("Game", 384, 8, 32, 13)
Global $Combo0_game = GUICtrlCreateCombo("", 380, 24, 73, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetResizing(-1, $GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlSetOnEvent(-1, "Combo0_gameChange")

Global $Label2 = GUICtrlCreateLabel("Profile", 384, 56, 33, 13)
Global $Button_p_load = GUICtrlCreateButton("Load", 380, 72, 73, 21)
GUICtrlSetTip(-1, "Load a previous saved profile")
GUICtrlSetOnEvent(-1, "Button_p_loadClick")
Global $Button_p_save = GUICtrlCreateButton("Save", 380, 93, 73, 21)
GUICtrlSetTip(-1, "Save current profile to disk")
GUICtrlSetOnEvent(-1, "Button_p_saveClick")

;Global $Label3 = GUICtrlCreateLabel("Game Play", 384, 128, 55, 13)
Global $Button5_game_options = GUICtrlCreateButton("Play Game"&@CRLF&"Options", 380, 128, 73, 41, BitOR($BS_CENTER,$BS_VCENTER,$BS_MULTILINE)); 380, 144, 73, 21
GUICtrlSetTip(-1, "Configure game options for playing map")
GUICtrlSetOnEvent(-1, "Button5_game_optionsClick")

Global $Button0_about = GUICtrlCreateButton("About", 380, 182, 73, 22)
GUICtrlSetOnEvent(-1, "Button0_aboutClick")
Global $Button0_exit = GUICtrlCreateButton("Exit", 380, 204, 73, 22)
GUICtrlSetOnEvent(-1, "Button0_exitClick")

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


#Region ;==> global defines
;gui region indexes
Global Enum _
	$iGUI_REGION_0_MAIN, _         ;main gui
	$iGUI_REGION_1_TOOL1, _        ;build tool1
	$iGUI_REGION_2_TOOL2, _        ;build tool2
	$iGUI_REGION_3_TOOL3, _        ;build tool3
	$iGUI_REGION_4_TOOL4, _        ;build tool4
	$iGUI_REGION_5_GAME_OPTIONS, _ ;game options
	$iGUI_REGION_6_DIRECTORIES, _  ;directory's
	$iGUI_REGION_7_BAT, _          ;
	$iGUI_REGION_8_ABOUT, _        ;
	$iGUI_REGION_9_PROFILE, _      ;PROFILE POPUP
	$COUNT_GUIREG

Global Enum _
	$POP_ID_GUI, _
	$POP_ID_SAVE, _
	$POP_ID_CANCEL, _
	$POP_ID_RESET, _
	$POP_ID_CLOSE, _
	$POP_ID_OK, _
	$POP_ID_IN, _
	$POP_ID_COMBO, _
	$COUNT_POP

;control ID for popup
Global $g_ahGUID_Pupup[$COUNT_POP]

Global Enum _
	$OPT_CHK, _
	$OPT_IN, _
	$COUNT_OPT
;gui id array's
Global $g_asGUI_toolTip[100][$COUNT_OPT] ;allow 100 lines
Global $g_ahGUI_ID_options[100][$COUNT_OPT] ;allow 100 lines

Global $g_ahGUI_ID_MapPaths[3] ;radio buttin selection
Global $g_ahGUI_ID_MapSave[2] ;check box save map snapshots

Global $g_aiConfigFile_default_Count[7] ;count elements in default config
Global $g_aiConfigFile_custom_Count[7] ;count elements in custom config
Global $g_asConfigFile_default[7][100] ;allow 100 lines
Global $g_asConfigFile_custom[7][100] ;allow 100 lines
Global $g_asConfigUsed_custom[7][100] ;custom compile strings to be used

;generated compile strings
Global $g_aCompileSettings[4][100]

;switch return types
Global Enum _
	$SWITCH_0_NONE, _
	$SWITCH_1_KEY, _
	$SWITCH_2_KEYVAL, _
	$SWITCH_3_APPENDMAP, _
	$SWITCH_4_NEW_COL, _
	$SWITCH_5_COMMENT, _
	$SWITCH_6

;custom cfg file order. 1-based
Global Enum _
	$CFG_0_COUNT, _
	$CFG_1_TOOL, _
	$CFG_2_KEY, _
	$CFG_3_CHECKED, _
	$CFG_4_VALUE


;filepath indexes
Global Enum _
	$switch_PATH_EXE_, _ ;insert kingpin.exe folder/file after switch
	$switch_PATH_BASE, _ ;insert /main folder after switch
	$switch_PATH_MOD_, _ ;insert /gunrace folder  after switch//todo just use string?
	$switch_PATH_PRE_, _ ;insert img2wal.exe folder/file after switch
	$switch_PATH_BSP_, _ ;insert kpbsp.exe folder/file after switch
	$switch_PATH_VIS_, _ ;insert kpvis.exe folder/file after switch
	$switch_PATH_RAD_, _ ;insert kprad.exe folder/file after switch
	$switch_PATH_MAP_, _ ;insert folder/map.map after switch
	$COUNT_SWITCH
Global Enum _
	$STR_SWITCH, _ ;config file switch names
	$STR_SAVE, _   ;save filenames
	$STR_TIP, _    ;tooltip
	$COUNT_STR
Global Const $g_asSwitchNames[$COUNT_SWITCH][$COUNT_STR] = [ _
	["switch_PATH_EXE_", "PATH_EXE"], _
	["switch_PATH_BASE", "PATH_BASE"], _
	["switch_PATH_MOD_", "PATH_MOD"], _
	["switch_PATH_PRE_", "PATH_PRE"], _
	["switch_PATH_BSP_", "PATH_BSP"], _
	["switch_PATH_VIS_", "PATH_VIS"], _
	["switch_PATH_RAD_", "PATH_RAD"], _
	["switch_PATH_MAP_", "MAP_INDEX"]]

Global Enum _
	$TOOL1, _
	$TOOL2, _
	$TOOL3, _
	$TOOL4, _
	$COUNT_TOOL
Global Enum _
	$GUI_BUILD_NAME, _
	$GUI_BUILD_NAME_NEW, _ ;save new name
	$GUI_BUILD_RADIO1, _
	$GUI_BUILD_RADIO2, _
	$GUI_BUILD_RADIO3, _
	$GUI_PAUSE_NAME, _
	$GUI_PAUSE_NAME_NEW, _ ;save new name
	$GUI_PAUSE_ID, _
	$COUNT_BUILD
Global const $sSaveBuild[$COUNT_TOOL][$COUNT_BUILD] = [ _
	["GUI_BUILD_PRE", "GUI_BUILD_TOOL1", $Radio1_none, $Radio1_default, $Radio1_custom, "GUI_PAUSE_PRE", "GUI_PAUSE_TOOL1", $Checkbox1_pause], _
	["GUI_BUILD_BSP", "GUI_BUILD_TOOL2", $Radio2_none, $Radio2_default, $Radio2_custom, "GUI_PAUSE_BSP", "GUI_PAUSE_TOOL2", $Checkbox2_pause], _
	["GUI_BUILD_VIS", "GUI_BUILD_TOOL3", $Radio3_none, $Radio3_default, $Radio3_custom, "GUI_PAUSE_VIS", "GUI_PAUSE_TOOL3", $Checkbox3_pause], _
	["GUI_BUILD_RAD", "GUI_BUILD_TOOL4", $Radio4_none, $Radio4_default, $Radio4_custom, "GUI_PAUSE_RAD", "GUI_PAUSE_TOOL4", $Checkbox4_pause]]

Global Enum _
	$GUIOPT_NAME, _
	$GUIOPT_ID, _
	$COUNT_GUIOPT
Global const $sSaveGUI[5][$COUNT_GUIOPT] = [  _
	["GUI_PLAY_AFTER",	$Checkbox0_play_build], _
	["GUI_SAVE_BAT",	$Checkbox0_save_bat], _
	["GUI_USEWIN",		$Checkbox0_UseWinStart], _
	["GUI_USE_DOS",		$Checkbox0_DOS_8_3], _
	["GUI_BACKUP_MAP",	$Checkbox0_backupMap]]


;store exe/game paths
Global $g_sFilePaths[$COUNT_SWITCH] ;PATH_EXE, PATH_BASE, PATH_MOD, PATH_PRE, PATH_BSP, PATH_VIS, PATH_RAD, MAP_INDEX
Global $g_sMapSelected_name = ""	;map name
Global $g_sMapSelected_path = "" 	;map folder
Global $g_sMapSelected_full = "" 	;map folder/name

Global $g_as_CompileString[5] ; pre, bsp, vis, rad, game

Global Const $g_sFilename_cfg_paths =	"KingpinMapper_path.txt"
Global Const $g_sFilename_cfg_default =	"KingpinMapper_default.txt"
Global Const $g_sFilename_cfg_custom = 	"KingpinMapper_custom.txt"
Global Const $g_sFileName_bat_full = 	@TempDir &"\hypov8_Mapper.bat" ; todo rand file name?
Global $g_sFilename_cfg_path_game = 	@ScriptDir &"\kingpin\"
Global $g_sFilename_cfg_path_full = 	@ScriptDir &"\kingpin\"& $g_sFilename_cfg_paths
Global $g_sFilename_cfg_default_full = 	@ScriptDir &"\kingpin\"& $g_sFilename_cfg_default
Global $g_sFilename_cfg_custom_full = 	@ScriptDir &"\kingpin\"& $g_sFilename_cfg_custom
Global $g_sLastFolder_profile = 		@ScriptDir

Global Enum _
	$MAPPATH_0_EXE, _
	$MAPPATH_1_BASE, _
	$MAPPATH_2_MOD

Global $GUI_MapPathType = $MAPPATH_1_BASE ;default base path
Global $GUI_StringType = 0 ; default kingpin. 1=quake1, 2=quake2, 3=quake3, 4=half-life


Global Const $GUI_Title[5][2] =[ _
	["Kingpin-Mapper by HypoV8", 	"KINGPIN"], _
	["Quake1-Mapper by HypoV8",  	"QUAKE1"], _
	["Quake2-Mapper by HypoV8",  	"QUAKE2"], _
	["Quake3-Mapper by HypoV8",  	"QUAKE3"], _
	["Half-Life-Mapper by HypoV8",  "HALFLIFE"]]

;TOOL NAME in main GUI
Global Const $UI_build_ID[4] = [$Group_prebuild, $Group_bsp, $Group_vis, $Group_light]
Global $UI_build_TITLE[4] = ["TOOL1", "TOOL2", "TOOL3", "TOOL4"] ;updated when loading cfg

WinSetTitle($KingpinMapBuild,"", string($GUI_Title[0][0] &"  (v"& $GUI_VERSION&")"))
ControlSetText($KingpinMapBuild, "", $UI_build_ID[0], $UI_build_TITLE[0])
ControlSetText($KingpinMapBuild, "", $UI_build_ID[1], $UI_build_TITLE[1])
ControlSetText($KingpinMapBuild, "", $UI_build_ID[2], $UI_build_TITLE[2])
ControlSetText($KingpinMapBuild, "", $UI_build_ID[3], $UI_build_TITLE[3])

#EndRegion


#Region ;==> global hot keys
;^=CONTROL !=ALT +=SHIFT
Global $aHotKeys[4][2] = [	_
	["^c", $Button0_build_map], _ ;build map
	["^p", $Button0_play_map], _ ;play map
	["^v", $Button0_view_bat], _ ;view bat
	["^r", $Button0_refresh_map]] ;refresh maps list
GUISetAccelerators($aHotKeys, $KingpinMapBuild)
#EndRegion


#Region ;==> global functions
Func fn_AppendForwardSlash(ByRef $sInStr)
	local $cChar
	if StringLen($sInStr) < 1 Then Return
	$cChar = StringRight($sInStr, 1)
	If StringCompare($cChar, "/") Then $sInStr &="/"
	return $sInStr
EndFunc

Func fn_TrimPathTo_ForwardSlash(ByRef $sInStr)
	local $iIdx
	if StringLen($sInStr) < 1 Then Return
	$iIdx = StringInStr($sInStr,"/", 0, -1)
	If $iIdx Then $sInStr = StringLeft($sInStr, $iIdx)
	return $sInStr
EndFunc

Func fn_Trim_FileExtension(ByRef $sInStr)
	local $iIdx
	if StringLen($sInStr) < 1 Then Return
	$iIdx = StringInStr($sInStr,".", 0, -1)
	If $iIdx Then $sInStr = StringLeft($sInStr, $iIdx-1)
	return $sInStr
EndFunc


Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func _IsDisabled($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_DISABLE) = $GUI_DISABLE
EndFunc   ;==>_IsDisabled

Func fn_toggleCheck($iNum)
	If $iNum = 1 Then
		Return $GUI_CHECKED
	EndIf
	Return $GUI_UNCHECKED
EndFunc
#EndRegion


#Region ;==> startup
fn_Startup()
Func fn_Startup()
	For $i = 0 To $COUNT_POP -1
		$g_ahGUID_Pupup[$i] = -1
	Next

	fn_ReadGameFolders()
	fn_SetupMainWindow()
EndFunc

;set defauly radio buttons
Func fn_Reset_UI_Switch()
	for $iI = 0 to 3
		fn_SetCompileRadioTypes($iI, 1) ;1= <default>
	Next
	ConsoleWrite("!reset ui"&@CRLF)
	GUICtrlSetState($Checkbox1_pause, $GUI_UNCHECKED)
	GUICtrlSetState($Checkbox2_pause, $GUI_UNCHECKED)
	GUICtrlSetState($Checkbox3_pause, $GUI_UNCHECKED)
	GUICtrlSetState($Checkbox4_pause, $GUI_CHECKED)
EndFunc

Func fn_SetupMainWindow()
	;set path to config text files <mapper.exe/kingpin/>
	fn_SetupFilenames()

	;set defauly radio buttons
	fn_Reset_UI_Switch()

	;read _default.txt (required)
	fn_ReadConfigFile_Default()
	;read _path.txt (generated on 1st run)
	fn_ReadConfigFile_ExePaths()
	;read _custom.txt (generated on 1st run)
	fn_ReadConfigFile_Custom($g_sFilename_cfg_custom_full)

	;read maps folder
	fn_FillMapsList()
	;build from config files
	fn_Build_All_Config()
EndFunc

;store game combo string in registry
Func fn_writeRegString()
	Local $sTmp = GUICtrlRead($Combo0_game, 0)
	if $sTmp <> "" and not $sTmp = 0 then
		RegWrite("HKEY_CURRENT_USER\Software\hypov8\mapper", "Game", "REG_SZ", $sTmp)
	endif
EndFunc

Func fn_SetupFilenames()
	Local $sTmp = GUICtrlRead($Combo0_game, 0)
	ConsoleWrite(">ui=" &$sTmp&@CRLF)
	$g_sFilename_cfg_path_game =  	@ScriptDir &"\"&$sTmp&"\"
	$g_sFilename_cfg_path_full = 	@ScriptDir &"\"&$sTmp&"\"& $g_sFilename_cfg_paths
	$g_sFilename_cfg_default_full = @ScriptDir &"\"&$sTmp&"\"& $g_sFilename_cfg_default
	$g_sFilename_cfg_custom_full = 	@ScriptDir &"\"&$sTmp&"\"& $g_sFilename_cfg_custom

	for $iI = 0 to 7
		$g_sFilePaths[$iI] = ""
	Next
	;$g_sFilePaths[$switch_PATH_MAP_] = 1
	$GUI_MapPathType = $MAPPATH_1_BASE

	$g_sMapSelected_name = ""	;map name
	$g_sMapSelected_path = "" 	;map folder
	$g_sMapSelected_full = "" 	;map folder/name
EndFunc

Func fn_ReadGameFolders()
	Local $sDir = @ScriptDir & "\"
	Local $sTmp = "", $iCount = 0
	Local $aTmp = _FileListToArray($sDir, "*", $FLTA_FOLDERS)
	if Not @error Then
		;_ArrayDisplay($aTmp)
		for $iI = 1 to $aTmp[0]
			if FileExists($sDir&$aTmp[$iI]&"\"& $g_sFilename_cfg_default) Then
				$iCount += 1
				$sTmp = ($sTmp <>"")? ($sTmp & "|" & $aTmp[$iI]) : ($aTmp[$iI])
			EndIf
		Next
		GUICtrlSetData($Combo0_game, $sTmp)
		_GUICtrlComboBox_SetCurSel($Combo0_game, 0)
		Local $sgame = RegRead("HKEY_CURRENT_USER\Software\hypov8\mapper", "Game")
		if NOT @error Then
			Local $iIdx = _ArraySearch(StringSplit($sTmp, "|", 2), $sgame)
			if NOT @error Then
				_GUICtrlComboBox_SetCurSel($Combo0_game, $iIdx)
			EndIf
		EndIf
	Else
		MsgBox("", "Error", "Cant find any folders in mapper directory.",0, $KingpinMapBuild)
		KingpinMapBuildClose() ;exit
	EndIf
	ConsoleWrite("-str="&$sTmp&@CRLF)
EndFunc

Func fn_DisableGUI()
	;show loading message.
	GUICtrlSetData($List0_maps,"Loading...")
	;disable GUI
	GUICtrlSetState($List0_maps,$GUI_DISABLE)
	GUICtrlSetState($Button0_build_map, $GUI_DISABLE)
	GUICtrlSetState($Button0_play_map, $GUI_DISABLE)
	GUICtrlSetState($Button0_refresh_map, $GUI_DISABLE)
	GUICtrlSetState($Button0_view_bat, $GUI_DISABLE)
	GUICtrlSetState($Combo0_maps, $GUI_DISABLE)
	GUICtrlSetState($Combo0_game, $GUI_DISABLE)
	GUICtrlSetState($Input0_maps,$GUI_DISABLE)
EndFunc

Func fn_EnableGUI()
	GUICtrlSetState($List0_maps,$GUI_ENABLE)
	GUICtrlSetState($Combo0_maps, $GUI_ENABLE)
	GUICtrlSetState($Combo0_game, $GUI_ENABLE)
	GUICtrlSetState($Button0_refresh_map, $GUI_ENABLE)
	GUICtrlSetState($Input0_maps,$GUI_ENABLE)
EndFunc

;read _default.txt (required)
Func fn_ReadConfigFile_Default()
	ConsoleWrite("!read cfg"&@CRLF)
    Local $iLineCount, $iLine, $sKey, $sValue
    Local $aTmpArray = FileReadToArray($g_sFilename_cfg_default_full)

    If @error Then
        MsgBox($MB_SYSTEMMODAL, "Error", "Error: Can't read file..." &@CRLF&@CRLF&$g_sFilename_cfg_default)
		KingpinMapBuildClose() ;exit
	Else
		$iLineCount = @extended
		;ConsoleWrite("script name="&$g_sFilename_cfg_default_full&@CRLF)
		;_ArrayDisplay($aTmpArray)
		For $iLine = 0 to ($iLineCount -1)
			$sKey = StringLeft($aTmpArray[$iLine], 4)
			if StringCompare($sKey, "GAME", 0) = 0 Then
				$iLine = fn_FillConfigFile_Default_Array($iGUI_REGION_5_GAME_OPTIONS, $iLine+1, $iLineCount, $aTmpArray)
			elseIf StringCompare($sKey, "TOOL", 0) = 0 Then
				$sKey = Number(StringMid($aTmpArray[$iLine], 5, 1))-1 ;1-4
				$sValue = StringMid($aTmpArray[$iLine], 7)
				if $sKey >= 0 and $sKey <= 3  Then ;0-3
					$iLine = fn_FillConfigFile_Default_Array($iGUI_REGION_1_TOOL1 + $sKey, $iLine+1, $iLineCount, $aTmpArray)
					;ConsoleWrite(">====" & $sValue & @CRLF)
					ControlSetText($KingpinMapBuild, "", $UI_build_ID[$sKey], $sValue) ; StringMid($aTmpArray[$iLine], 6)
					$UI_build_TITLE[$sKey] = $sValue
				EndIf
			ElseIf StringCompare($sKey, "GUI_", 0) = 0 Then
				$sKey = StringMid($aTmpArray[$iLine], 5)
				ConsoleWrite(">====" & $sKey & @CRLF)
				;DEFAULT TITLE
				WinSetTitle($KingpinMapBuild,"", string($GUI_Title[0][0] &"  (v"& $GUI_VERSION&")"))
				for $iJ = 0 to UBound($GUI_Title)-1
					if StringCompare($sKey, $GUI_Title[$iJ][1]) = 0 Then
						ConsoleWrite("!match=" & @CRLF)
						WinSetTitle($KingpinMapBuild,"", string($GUI_Title[$iJ][0] &"  (v"&$GUI_VERSION&")"))
						$GUI_StringType = $iJ
						ExitLoop
					EndIf
				Next
			EndIf
		Next
	EndIf
	$aTmpArray = 0
EndFunc
Func fn_CleanupWS(byref $sConfigLine, $bCheckToolTip = False)
	local $iCount
	Local $aTmp = StringSplit($sConfigLine, ",")

	if $aTmp[0] >0 Then ; Not @error Then
		;remove space between values
		$aTmp[1] = StringStripWS($aTmp[1], 3)
		$iCount = $aTmp[0]
		if $bCheckToolTip Then
			If StringInStr($aTmp[1], "switch_CHECK", $STR_NOCASESENSEBASIC, 1, 1, 12) Then
				if $iCount > 4 Then
					$iCount = 4 ;skip tooltip
					$aTmp[$iCount+1] = StringStripWS($aTmp[$iCount+1], 1) ;strip leading spaces
				EndIf
			ElseIf StringInStr($aTmp[1], "switch_TEXT_", $STR_NOCASESENSEBASIC, 1, 1, 12) Then
				if $iCount > 5 Then
					$iCount = 5 ;skip tooltip
					$aTmp[$iCount+1] = StringStripWS($aTmp[$iCount+1], 1) ;strip leading spaces
				EndIf
			ElseIf StringInStr($aTmp[1], "switch_PATH_", $STR_NOCASESENSEBASIC, 1, 1, 12) Then
				if $iCount > 6 Then
					$iCount = 6 ;skip tooltip
					$aTmp[$iCount+1] = StringStripWS($aTmp[$iCount+1], 1) ;strip leading spaces
				EndIf
			EndIf
		EndIf

		;clean up gaps. not inc tooltip
		For $iI = 2 to $iCount
			$aTmp[$iI] = StringStripWS($aTmp[$iI], 3)
		Next

		;rebuild array
		$sConfigLine = $aTmp[1]
		For $iI = 2 to $aTmp[0]
			$sConfigLine &= ","&$aTmp[$iI]
		Next
	EndIf
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
			$g_asConfigFile_default[$IDX][$iCount] = StringStripWS( $aTmpArray[$iIdx], 3); & "," ;append comma. todo ok? fix blank lines?
			fn_CleanupWS($g_asConfigFile_default[$IDX][$iCount], True)
			$iCount +=1
		EndIf
		$iIdx +=1
	WEnd

	$g_aiConfigFile_default_Count[$IDX] = $iCount

	Return $iIdx
EndFunc

;read _path.txt (generated on 1st run)
Func fn_ReadConfigFile_ExePaths()
	Local $sTmp
    Local $iLineCount, $iIdx, $aSplit, $hFile, $iLine
    local $aTmpArray = FileReadToArray($g_sFilename_cfg_path_full)

    If @error Then
		if FileExists($g_sFilename_cfg_path_full) Then
			MsgBox($MB_SYSTEMMODAL, "Warning", "Warning: Can't read file..." &@CRLF&@CRLF&$g_sFilename_cfg_paths)
		Else
			MsgBox($MB_SYSTEMMODAL, "Warning", "Warning: File missing."&@CRLF& _
			                                   "First time running game?" &@CRLF&@CRLF&$g_sFilename_cfg_paths)
		EndIf
	Else
		$iLineCount = @extended
		;ConsoleWrite("script name="&$g_sFilename_cfg_path_full&@CRLF)
		For $iLine = 0 to ($iLineCount -1)
			$aSplit = StringSplit($aTmpArray[$iLine], ",")
			; check array has 2 values
			if not @error And $aSplit[0] >= 2 then
				if StringInStr($aSplit[1], "PATH_", $STR_NOCASESENSEBASIC, 1, 1, 5) Then
					for $iI = 0 to $switch_PATH_RAD_
						;find match
						if StringCompare($aSplit[1], $g_asSwitchNames[$iI][$STR_SAVE], $STR_NOCASESENSEBASIC) = 0 Then
							$g_sFilePaths[$iI] = StringReplace($aSplit[2],"\", "/") ;make all forward slash
							if $iI = $switch_PATH_BASE Or $iI = $switch_PATH_MOD_ Then
								fn_AppendForwardSlash($g_sFilePaths[$iI]) ;add forward slash to paths
							EndIf
							ExitLoop
						EndIf
					Next
				ElseIf StringCompare($aSplit[1], $g_asSwitchNames[$switch_PATH_MAP_][$STR_SAVE], $STR_NOCASESENSEBASIC) = 0 Then ; MAP_INDEX
					$GUI_MapPathType = Number($aSplit[2])
				ElseIf StringInStr($aSplit[1], "GUI_BUILD_", $STR_NOCASESENSEBASIC, 1, 1, 10) Then
					;build radiobuttons
					for $iI = 0 to $COUNT_TOOL -1
						If StringCompare($aSplit[1], $sSaveBuild[$iI][$GUI_BUILD_NAME], $STR_NOCASESENSEBASIC) = 0 _ ;check old/new names
						Or StringCompare($aSplit[1], $sSaveBuild[$iI][$GUI_BUILD_NAME_NEW], $STR_NOCASESENSEBASIC) = 0 Then
							fn_SetCompileRadioTypes($iI, int(Number($aSplit[2]))) ;compile type: <none, default, custom>
							ExitLoop
						EndIf
					Next
				ElseIf StringInStr($aSplit[1], "GUI_PAUSE_", $STR_NOCASESENSEBASIC, 1, 1, 10) Then
					;pause checkbox
					for $iI = 0 to $COUNT_TOOL -1
						If StringCompare($aSplit[1], $sSaveBuild[$iI][$GUI_PAUSE_NAME], $STR_NOCASESENSEBASIC) = 0 _ ;check old/new names
						Or StringCompare($aSplit[1], $sSaveBuild[$iI][$GUI_PAUSE_NAME_NEW], $STR_NOCASESENSEBASIC) = 0 Then
							GUICtrlSetState($sSaveBuild[$iI][$GUI_PAUSE_ID], fn_toggleCheck(int(Number($aSplit[2]))))
							ExitLoop
						EndIf
					Next
				ElseIf StringInStr($aSplit[1], "GUI_", $STR_NOCASESENSEBASIC, 1, 1, 4) Then
					;main gui checkbox
					for $iI = 0 to UBound($sSaveGUI)-1
						If StringCompare($aSplit[1], $sSaveGUI[$iI][$GUIOPT_NAME], 1) = 0 Then
							GUICtrlSetState($sSaveGUI[$iI][$GUIOPT_ID], fn_toggleCheck(int(Number($aSplit[2]))))
							ExitLoop
						EndIf
					Next
				EndIf
			Else
				ConsoleWrite("!Warning: cant read line: " &$iLine& " in: " &$g_sFilename_cfg_paths&@CRLF)
			EndIf
		Next

		$g_sFilePaths[$switch_PATH_MAP_] = fn_BuildMapsPath() ; fn_GetMaps_Folder()
	EndIf
	$aTmpArray = 0

	;if missing, prompt user to setup atleast game.exe
	;if $g_sFilePaths[0] = "" then fn_Buld_Gui_Directories() ;popup select folder
EndFunc

Func fn_SetCompileRadioTypes($iToolID, $iType)
	Local const $hGUI_ID_build_opt[4] = [$Button1_option, $Button2_option, $Button3_option, $Button4_option]

	If $iType > 2 Then
		$iType = 2
	ElseIf $iType < 0 Then
		$iType = 0
	EndIf

	;uncheck all radio buttons
	GUICtrlSetState($sSaveBuild[$iToolID][$GUI_BUILD_RADIO1], $GUI_UNCHECKED) ;<none>
	GUICtrlSetState($sSaveBuild[$iToolID][$GUI_BUILD_RADIO2], $GUI_UNCHECKED) ;<default>
	GUICtrlSetState($sSaveBuild[$iToolID][$GUI_BUILD_RADIO3], $GUI_UNCHECKED) ;<custom>
	;check radio button
	GUICtrlSetState($sSaveBuild[$iToolID][$GUI_BUILD_RADIO1 + $iType], $GUI_CHECKED)

	If $iType = 2 Then ;activate custom compile button
		GUICtrlSetState($hGUI_ID_build_opt[$iToolID], $GUI_ENABLE)
	Else
		GUICtrlSetState($hGUI_ID_build_opt[$iToolID], $GUI_DISABLE)
	EndIf
EndFunc

;read _custom.txt (generated on 1st run)
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
				if StringCompare($aSplit[1], "GAME",1) = 0  Then
					$g_asConfigFile_custom[$iGUI_REGION_5_GAME_OPTIONS][$iCount_GAME] = StringStripWS( $aTmpArray[$iIdx], 3)
					fn_CleanupWS($g_asConfigFile_custom[$iGUI_REGION_5_GAME_OPTIONS][$iCount_GAME])
					$iCount_GAME += 1
				elseIf StringCompare($aSplit[1], "TOOL1",1) = 0 Or StringCompare($aSplit[1], "PRE",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_1_TOOL1][$iCount_PRE] = StringStripWS( $aTmpArray[$iIdx], 3)
					fn_CleanupWS($g_asConfigFile_custom[$iGUI_REGION_1_TOOL1][$iCount_PRE])
					$iCount_PRE += 1
				elseif StringCompare($aSplit[1], "TOOL2",1) = 0 Or  StringCompare($aSplit[1], "BSP",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_2_TOOL2][$iCount_BSP] = StringStripWS( $aTmpArray[$iIdx], 3)
					fn_CleanupWS($g_asConfigFile_custom[$iGUI_REGION_2_TOOL2][$iCount_BSP])
					$iCount_BSP += 1
				elseIf StringCompare($aSplit[1], "TOOL3",1) = 0 Or StringCompare($aSplit[1], "VIS",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_3_TOOL3][$iCount_VIS] = StringStripWS( $aTmpArray[$iIdx], 3)
					fn_CleanupWS($g_asConfigFile_custom[$iGUI_REGION_3_TOOL3][$iCount_VIS])
					$iCount_VIS += 1
				elseIf StringCompare($aSplit[1], "TOOL4",1) = 0 Or StringCompare($aSplit[1], "LIGHT",1) = 0 Then
					$g_asConfigFile_custom[$iGUI_REGION_4_TOOL4][$iCount_LIGHT] = StringStripWS( $aTmpArray[$iIdx], 3)
					fn_CleanupWS($g_asConfigFile_custom[$iGUI_REGION_4_TOOL4][$iCount_LIGHT])
					$iCount_LIGHT += 1
				EndIf
			EndIf
		Next
	EndIf

	ConsoleWrite("custom count PRE="&$iCount_PRE& " BSP="&$iCount_BSP& " VIS="&$iCount_VIS& " RAD="&$iCount_LIGHT& " GAME=" &$iCount_GAME&@CRLF)

	$g_aiConfigFile_custom_Count[$iGUI_REGION_1_TOOL1] = $iCount_PRE
	$g_aiConfigFile_custom_Count[$iGUI_REGION_2_TOOL2] = $iCount_BSP
	$g_aiConfigFile_custom_Count[$iGUI_REGION_3_TOOL3] = $iCount_VIS
	$g_aiConfigFile_custom_Count[$iGUI_REGION_4_TOOL4] = $iCount_LIGHT
	$g_aiConfigFile_custom_Count[$iGUI_REGION_5_GAME_OPTIONS] = $iCount_GAME

	;missing. popup select folders
	if $g_sFilePaths[0] = "" Or $g_sFilePaths[1] = "" then fn_Buld_Gui_Directories() ;todo querry mod?
EndFunc

;read maps folder
Func fn_FillMapsList()
	Local $iIdx = _GUICtrlComboBox_GetCurSel($Combo0_maps)
	Local $aTmp, $sDir, $iTmp, $sTmp = ""
	local $sTmp2 = ["*.map", "*.bsp", "*.*"]
	Local $sTmpMapDir = $sTmp2[$iIdx]

	;ConsoleWrite("++++="&$sTmpMapDir&@CRLF)

	;skip, GUI open
	if Not ($g_ahGUID_Pupup[$POP_ID_GUI] = -1) Then Return

	;$sDir =
	$g_sMapSelected_path = fn_BuildMapsPath()

	if ($g_sMapSelected_path == "") or ($g_sMapSelected_path == "maps/") Then
		MsgBox("", "Note:", "Setup folder for maps" )
		fn_Buld_Gui_Directories() ;popup select folder
		Return
	EndIf

	ConsoleWrite("Maps search folder="&$g_sMapSelected_path&@CRLF)
	fn_DisableGUI()

	if ($GUI_MapPathType = $MAPPATH_0_EXE) Then ;if ($g_sFilePaths[$switch_PATH_MAP_] = 0) Then
		$aTmp = _FileListToArrayRec($g_sMapSelected_path, $sTmpMapDir, $FLTA_FILES, $FLTAR_RECUR ,$FLTAR_SORT, $FLTAR_RELPATH)
	Else
		$aTmp = _FileListToArray($g_sMapSelected_path, $sTmpMapDir, $FLTA_FILES)
	EndIf

	if @error Then
		If @extended = 1 Then
			MsgBox($MB_SYSTEMMODAL, "Maps List", "ERROR 1:"&@CRLF&"Map path not found or invalid"&@CRLF&$g_sMapSelected_path,0, $KingpinMapBuild)
		ElseIf @extended = 9 Then
			MsgBox($MB_SYSTEMMODAL, "Maps List", "ERROR 9:"&@CRLF&"No files/folders found in"&@CRLF&$g_sMapSelected_path,0, $KingpinMapBuild)
		Else
			MsgBox($MB_SYSTEMMODAL, "Maps List", "ERROR "&@extended&":"&@CRLF&"In map search folder"&@CRLF&$g_sMapSelected_path,0, $KingpinMapBuild)
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

	;fill maps
	GUICtrlSetData($Input0_maps, $g_sMapSelected_path)
	;enable GUI
	fn_EnableGUI()
EndFunc

Func fn_appendSwitchValue($bRet, ByRef $sRetString, $iRetEnabled, $sRetSwitch, $sRetValue)
	;fn_GetSwitchValue
	If $iRetEnabled > 0 Then
		If ($bRet = $SWITCH_1_KEY) Then
			$sRetString &= $sRetSwitch&" "
		ElseIf ($bRet = $SWITCH_2_KEYVAL) Then
			$sRetString &= $sRetSwitch&" "&$sRetValue&" "
		EndIf
	EndIf
EndFunc


;build internal custom arrays
Func fn_Build_Custom_Config($IDX_GUI)
	Local $aTmp
	Local $iRet, $iRetEnabled, $sRetSwitch, $sRetValue, $sRetValueCust, $iRetEnabledCust
	Local $iCount_default = $g_aiConfigFile_default_Count[$IDX_GUI]-1 ;count elements in default config

	For $iI = 0 To $iCount_default
		;copy default array to custom
		$g_asConfigUsed_custom[$IDX_GUI][$iI] = $g_asConfigFile_default[$IDX_GUI][$iI]

		;get <enabled> <switch> <value>
		$iRet = fn_GetSwitchValue($IDX_GUI, $iI, $iRetEnabled, $sRetSwitch, $sRetValue, 0)

		;find match
		If $iRet Then
			if fn_compare_custom($IDX_GUI, $iI, $sRetSwitch, $sRetValueCust, $iRetEnabledCust) Then
				$aTmp = StringSplit($g_asConfigUsed_custom[$IDX_GUI][$iI], ",")
				;update checked and new value
				If not @error And $aTmp[0] >= 4 Then
					$aTmp[4] = $iRetEnabledCust
					if ($aTmp[0] >= 5) And ($sRetValueCust <> "") Then $aTmp[5] = $sRetValueCust
					if $iRetEnabled = 2 Then $aTmp[4] = $iRetEnabled ;todo ok?
					$g_asConfigUsed_custom[$IDX_GUI][$iI] = _ArrayToString($aTmp, ",", 1)
				EndIf
			ElseIf $sRetSwitch <> "" Then
				ConsoleWrite ("-Warning: no match found in custom config. RetType="&$iRet& " Switch="&$sRetSwitch& @CRLF)
			EndIf
		Else
			ConsoleWrite ("-Warning: invalid entry in default config file. RetType="& $iRet&" Switch="&$sRetSwitch& @CRLF)
			ConsoleWrite("custom cfg  str="&$g_asConfigFile_default[$IDX_GUI][$iI]&@CRLF)
		EndIf
	Next
EndFunc

Func fn_compare_custom($IDX_GUI, ByRef $iIdx, ByRef $sRetSwitch, ByRef $sRetValueCust, ByRef $iRetEnabledCust)
	Local $aTmp
	Local $iCount_custom = $g_aiConfigFile_custom_Count[$IDX_GUI]-1
	$iRetEnabledCust = 0

	if $sRetSwitch = "" Then Return 0 ;comment line etc..

	For $iI = 0 To $iCount_custom
		$aTmp = StringSplit($g_asConfigFile_custom[$IDX_GUI][$iI], ",")
		if not @error and $aTmp[0] >= $CFG_2_KEY And StringCompare($aTmp[$CFG_2_KEY], $sRetSwitch, 1) = 0 Then
			If $aTmp[0] >= $CFG_3_CHECKED Then $iRetEnabledCust = Number($aTmp[$CFG_3_CHECKED]) ;checked?
			If $aTmp[0] >= $CFG_4_VALUE Then $sRetValueCust = $aTmp[$CFG_4_VALUE]
			Return 1 ;found match
		EndIf
	Next

	Return 0 ;missing
EndFunc

#EndRegion ;end starup
;==> end startup

#Region ;==> popup GUI for compile options
Func fn_Create_Element_CheckBox($IDX, $iIdx, $iXPos, $iYPos)
	Local $sItemName = "ERROR", $sItemSwitch = "", $iChecked = 0
	Local $aSwitch = StringSplit($g_asConfigUsed_custom[$IDX][$iIdx], ',');$g_asConfigFile_default

	If not @error Then
		Local $iCount = ($aSwitch[0] > 4)? (4):($aSwitch[0])
		For $i = 2 to $iCount
			$aSwitch[$i] = StringStripWS($aSwitch[$i], 3)
		Next
		if ($aSwitch[0] >= 2)  And ($aSwitch[2] <> "") Then $sItemName   = $aSwitch[2]
		if ($aSwitch[0] >= 3)  And ($aSwitch[3] <> "") Then $sItemSwitch = $aSwitch[3]
		if ($aSwitch[0] >= 4)  And ($aSwitch[4] <> "") Then $iChecked    = Number($aSwitch[4])

		;append tool tip/s
		$g_asGUI_toolTip[$iIdx][$OPT_CHK] = $sItemSwitch
		for $i = 5 to $aSwitch[0]
			$g_asGUI_toolTip[$iIdx][$OPT_CHK] &= ","&$aSwitch[$i]
		Next

		;build GUI
		fn_CreateCheckBox_Opt($IDX, $iIdx, $sItemName, $iChecked, $iXPos, $iYPos, 0)
	Else
		ConsoleWrite ("!ERROR: cant split line "&$iIdx&@CRLF)
	EndIf
EndFunc

Func fn_Create_Element_TextBox($IDX, $iIdx, $iXPos, $iYPos)
	Local $sInputText=""
	Local $sItemName = "ERROR", $sItemSwitch = "", $iChecked = 0, $sText= ""
	Local $aSwitch = StringSplit($g_asConfigUsed_custom[$IDX][$iIdx], ',', 0);$g_asConfigFile_default ;StringStripWS

	If Not @error Then
		Local $iCount = ($aSwitch[0] > 4)? (4):($aSwitch[0])
		Local $iStyle = $ES_LEFT

		For $i = 2 to $iCount
			$aSwitch[$i] = StringStripWS($aSwitch[$i], 3)
		Next

		if ($aSwitch[0] >= 2)  And ($aSwitch[2] <> "") Then $sItemName   = $aSwitch[2]
		if ($aSwitch[0] >= 3)  And ($aSwitch[3] <> "") Then $sItemSwitch = $aSwitch[3]
		if ($aSwitch[0] >= 4)  And ($aSwitch[4] <> "") Then $iChecked    = Number($aSwitch[4])
		if ($aSwitch[0] >= 5)  And ($aSwitch[5] <> "") Then $sText       = $aSwitch[5]

		;append tool tip/s
		$g_asGUI_toolTip[$iIdx][$OPT_IN] = $sItemSwitch
		for $iI = 6 to $aSwitch[0]
			$g_asGUI_toolTip[$iIdx][$OPT_IN] &= ","&$aSwitch[$iI]
		Next
		$g_asGUI_toolTip[$iIdx][$OPT_CHK] = $g_asGUI_toolTip[$iIdx][$OPT_IN]

		$sInputText = $sText
		;build GUI
		fn_CreateCheckBox_Opt($IDX, $iIdx, $sItemName,  $iChecked, $iXPos, $iYPos, 0,       12)
		fn_CreateInputBox_Opt($IDX, $iIdx, $sInputText, $iChecked, $iXPos, $iYPos, $iStyle, 12)
	EndIf
EndFunc

Func fn_Create_Element_TextPath($IDX, $iIdx, $iXPos, ByRef $iYPos, $IDX_PATH)
	Local $iStyle=$ES_LEFT, $sFile, $sIdx, $aSwitch
	Local $sItemName="ERROR", $sItemSwitch="", $iChecked=0, $iPathID=0, $sText=""
	Local Const $g_asToolTip_Folder[8] = [ _
				"  ( Using '\Game.exe' path )", _ 		; $switch_PATH_EXE_
				"  ( Using '\base\' path )", _			; $switch_PATH_BASE
				"  ( Using '\mod\' path )", _ 			; $switch_PATH_MOD_
				"  ( Using '\tool1.exe' path )", _ 		; $switch_PATH_PRE_
				"  ( Using '\tool2.exe' path )", _ 		; $switch_PATH_BSP_
				"  ( Using '\tool3.exe' path )", _ 		; $switch_PATH_VIS_
				"  ( Using '\tool4.exe' path )", _ 		; $switch_PATH_RAD_
				"  ( Using '\xyz.map' path )" ]			; $switch_PATH_MAP_

	$aSwitch = StringSplit($g_asConfigUsed_custom[$IDX][$iIdx],",",0) ;$g_asConfigFile_default
	If not @error Then
		Local $iCount = ($aSwitch[0] >=4)? (4):($aSwitch[0])
		For $i = 2 to $iCount
			$aSwitch[$i] = StringStripWS($aSwitch[$i], 3)
		Next

		if ($aSwitch[0]) >= 2  And ($aSwitch[2] <> "") Then $sItemName   = $aSwitch[2]
		if ($aSwitch[0]) >= 3  And ($aSwitch[3] <> "") Then $sItemSwitch = $aSwitch[3]
		if ($aSwitch[0]) >= 4  And ($aSwitch[4] <> "") Then $iChecked    = Number($aSwitch[4])
		if ($aSwitch[0]) >= 5  And ($aSwitch[5] <> "") Then $sText       = $aSwitch[5]
		if ($aSwitch[0]) >= 6  And ($aSwitch[6] <> "") Then $iPathID     = Number($aSwitch[6])

		;ToolTip/s. append the rest
		$g_asGUI_toolTip[$iIdx][$OPT_IN] = $sItemSwitch & $g_asToolTip_Folder[$IDX_PATH]
		for $iI = 7 to $aSwitch[0]
			$g_asGUI_toolTip[$iIdx][$OPT_IN] &= ","&$aSwitch[$iI]
		Next

		;Note: <pathname(0/1/2/3)> 0=folder, 1=folder/filename, 2=folder/text, 3=filename
		Local $sFPath = fn_getSwitchPath($IDX_PATH, $iPathID, $sText, false, false)

		;text to display in input-box
		If ($iPathID = 0 or $iPathID = 1 or $iPathID = 3) Then
			$iStyle = BitOR($iStyle, $ES_READONLY)
		EndIf

		ConsoleWrite("+type=" &$iPathID& " split=" &$sFPath&@CRLF)

		;build GUI
		fn_CreateCheckBox_Opt($IDX, $iIdx, $sItemName, $iChecked, $iXPos, $iYPos, 0,       12)
		fn_CreateInputBox_Opt($IDX, $iIdx, $sFPath,    $iChecked, $iXPos, $iYPos, $iStyle, 12)
	EndIf

	$iYPos+= 16
EndFunc

; create checkboxes. $iChecked=2 is locked
Func fn_CreateCheckBox_Opt($IDX, $iIdx, $sItemName, $iChecked, $iX, $iY, $iStyle, $off=0)
	if $iChecked = 2 Then $iStyle = BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_CHECKBOX, $BS_FLAT, $iStyle) ;disable use changing checkbox
	$g_ahGUI_ID_options[$iIdx][$OPT_CHK] = GUICtrlCreateCheckbox($sItemName, $iX, $iY, 100-$off, 16, $iStyle)
	if $iChecked     Then GUICtrlSetState($g_ahGUI_ID_options[$iIdx][$OPT_CHK], $GUI_CHECKED)
	;if $iChecked = 2 Then GUICtrlSetState($g_ahGUI_ID_options[$iIdx][$OPT_CHK], $GUI_DISABLE)
EndFunc
; create inputbox
Func fn_CreateInputBox_Opt($IDX, $iIdx, $sInputText, $iChecked, $iX, $iY, $iStyle, $off=0)
	if $iChecked = 2 Then $iStyle = BitOR($iStyle, $ES_READONLY)
	$g_ahGUI_ID_options[$iIdx][$OPT_IN] = GUICtrlCreateInput($sInputText, $iX+100-$off, $iY, 55+$off, 16, BitOR($iStyle, $GUI_SS_DEFAULT_INPUT)) ;, $WS_EX_STATICEDGE)
	GUICtrlSetLimit(-1, 250);char limit
	;if $iChecked = 2 Then GUICtrlSetStyle($g_ahGUI_ID_options[$iIdx][$OPT_IN], )
EndFunc

Global $g_iLastPopup_ID = 0;

;load popup GUI with custom settings
Func fn_Buld_Gui_Options($IDX)
	;Local $iXMAX = 455, $iYMAX = 343
	Local Const $iButtonYPos = 318
	Local const $iXMAX = 451, $iYMAX = 341
	Local $iXPos= 8, $iYPos = 10, $iOffXXtra = 0, $iOffYXtra = 32 ; button height
	Local $iXOffs = $iXMAX, $iYOffs = $iYMAX
	Local $ilineNum = 0
	Local $sTmp, $iIdx, $hGroup, $aTmp
	Local $aPos = WinGetPos ( $KingpinMapBuild )
	Local $sTitle = "MAIN"

	$g_iLastPopup_ID = $IDX
	Switch $IDX
		Case $iGUI_REGION_1_TOOL1 to $iGUI_REGION_4_TOOL4
			$sTitle = $UI_build_TITLE[$IDX - $iGUI_REGION_1_TOOL1] & " Options"
		Case $iGUI_REGION_5_GAME_OPTIONS
			$sTitle = "Game Options"
		Case $iGUI_REGION_6_DIRECTORIES
			$sTitle = "GAME"
	EndSwitch

	GUISetState(@SW_DISABLE,$KingpinMapBuild) ;faster
	;add  gui
	$g_ahGUID_Pupup[$POP_ID_GUI] = GUICreate($sTitle, $iXMAX+4, $iYMAX+2, $aPos[0],$aPos[1], BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), -1, $KingpinMapBuild) ;BitOR($WS_CLIPCHILDREN,$WS_BORDER ,$WS_POPUP
	GUISetOnEvent($GUI_EVENT_CLOSE, "Button_opt_cancel", $g_ahGUID_Pupup[$POP_ID_GUI])
	;add group
	$hGroup = GUICtrlCreateGroup("", 2, 0, $iXMAX, $iYMAX-27)
	GUICtrlSetResizing($hGroup, $GUI_DOCKBORDERS)
	;button save (right)
	$g_ahGUID_Pupup[$POP_ID_SAVE] = GUICtrlCreateButton("Save", 350, $iButtonYPos, 50,22, BitOR($GUI_DOCKWIDTH, $GUI_DOCKHEIGHT, $GUI_DOCKLEFT, $GUI_DOCKBOTTOM,-1))
	GUICtrlSetOnEvent($g_ahGUID_Pupup[$POP_ID_SAVE], "Button_opt_save")
	;button cancel (right)
	$g_ahGUID_Pupup[$POP_ID_CANCEL] = GUICtrlCreateButton("Cancel", 400, $iButtonYPos, 50,22, BitOR($GUI_DOCKWIDTH, $GUI_DOCKHEIGHT, $GUI_DOCKLEFT, $GUI_DOCKBOTTOM,-1))
	GUICtrlSetOnEvent($g_ahGUID_Pupup[$POP_ID_CANCEL], "Button_opt_cancel")
	;button reset (left)
	$g_ahGUID_Pupup[$POP_ID_RESET] = GUICtrlCreateButton("Reset", 5, $iButtonYPos, 50,22, BitOR($GUI_DOCKWIDTH, $GUI_DOCKHEIGHT, $GUI_DOCKLEFT, $GUI_DOCKBOTTOM,-1))
	GUICtrlSetOnEvent($g_ahGUID_Pupup[$POP_ID_RESET], "Button_opt_reset")

	for $iCount = 0 to ($g_aiConfigFile_default_Count[$IDX]-1)
		$sTmp = $g_asConfigUsed_custom[$IDX][$iCount]
		$g_ahGUI_ID_options[$iCount][$OPT_CHK] = 0
		$g_asGUI_toolTip[$iCount][$OPT_CHK] = ""
		$g_ahGUI_ID_options[$iCount][$OPT_IN] = 0
		$g_asGUI_toolTip[$iCount][$OPT_IN] = ""

		If StringInStr($sTmp, "newcolum", 0, 1, 1, 8) Then ;$g_asConfigFile_default
			if Not ($iYPos = 10) Then
				$iYPos = 10
				$iXPos += 100 + $iOffXXtra
				$ilineNum = 0
				$iOffXXtra = 0
			EndIf
		Elseif StringInStr($sTmp, "switch_CHECK_BOX", 0, 1, 1, 16) Then ;$g_asConfigFile_default
			fn_Create_Element_CheckBox($IDX, $iCount, $iXPos, $iYPos)
			$iYPos+= 16
			$ilineNum += 1
		ElseIf StringInStr($sTmp, "switch_TEXT_BOX_", 0, 1, 1, 16) Then
			fn_Create_Element_TextBox($IDX, $iCount, $iXPos, $iYPos)
			$iYPos += 16
			$iOffXXtra = 60
			$ilineNum += 1
		ElseIf StringInStr($sTmp, "switch_PATH", 0, 1, 1, 11) Then
			for $iI = 0 to $COUNT_SWITCH-1 ; UBound($g_asSwitchNames)-1
				if StringInStr($sTmp, $g_asSwitchNames[$iI][$STR_SWITCH], 0, 1, 1, 16) Then
					fn_Create_Element_TextPath($IDX, $iCount, $iXPos, $iYPos, $iI)
					exitloop
				EndIf
			next
			$iOffXXtra = 60
			$ilineNum += 1
		EndIf
		if ($iXPos + 100 + $iOffXXtra +4) > $iXOffs Then $iXOffs = ($iXPos +100 + $iOffXXtra)
		if ($iYPos + $iOffYXtra) > $iYOffs Then $iYOffs = ($iYPos + $iOffYXtra)
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1);end group
	GUISetState(@SW_SHOW, $g_ahGUID_Pupup[$POP_ID_GUI]) ;show gui then load elements

	;resize window if there is to many elements
	if $iXOffs > $iXMAX Or $iYOffs > $iYMAX Then
		;dock elements b4 resize
		for $iCount = 0 to ($g_aiConfigFile_default_Count[$IDX]-1)
			if ($g_ahGUI_ID_options[$iCount][$OPT_CHK] > 0) Then GUICtrlSetResizing($g_ahGUI_ID_options[$iCount][$OPT_CHK], $GUI_DOCKALL)
			if ($g_ahGUI_ID_options[$iCount][$OPT_IN]> 0) Then GUICtrlSetResizing($g_ahGUI_ID_options[$iCount][$OPT_IN], $GUI_DOCKALL)
		Next
		WinMove($g_ahGUID_Pupup[$POP_ID_GUI],"", Default,Default, $iXOffs+10, $iYOffs+27) ;+header
	EndIf

	;set tool tip last. very slow
	for $iCount = 0 to ($g_aiConfigFile_default_Count[$IDX]-1)
		For $i = 0 To 1
			if $g_asGUI_toolTip[$iCount][$i] <> "" Then
				$aTmp = StringSplit($g_asGUI_toolTip[$iCount][$i], ",")
				if not @error and $aTmp[0] >= 2 then
					$sTmp = $aTmp[2]
					For $iIdx = 3 to $aTmp[0]
						$sTmp &= @CRLF&$aTmp[$iIdx]
					Next
					GUICtrlSetTip($g_ahGUI_ID_options[$iCount][$i], $sTmp, $aTmp[1])
				EndIf
			EndIf
		Next
	Next
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
	static local $aPathTip_quake3[7] = [ _ ;quake3
		"Game.exe path. [eg. C:/Quake3/quake3.exe]", _
		"Base path. [eg. C:/Quake3/baseq3/]", _
		"Mod path(optional) [eg. C:/Quake3/ctf/]", _
		"Q3Map2.exe path. [eg. C:/Quake3/_tools/q3map2.exe]", _
		"Q3Map2.exe path. [eg. C:/Quake3/_tools/q3map2.exe]", _
		"Q3Map2.exe path. [eg. C:/Quake3/_tools/q3map2.exe]", _
		"BSPC.exe path. [eg. C:/Quake3/_tools/bspc.exe]" ]
	static local $aPathTip_halflife[7] = [ _ ;halflife
		"Game.exe path. [eg. C:/HL/hl.exe]", _
		"Base path. [eg. C:/HL/valve/]", _
		"Mod path(optional) [eg. C:/HL/cs/]", _
		"csg.exe path. [eg. C:/HL/_tools/hlcsg.exe]", _
		"bsp.exe path. [eg. C:/HL/_tools/hlbsp.exe]", _
		"vis.exe path. [eg. C:/HL/_tools/hlvis.exe]", _
		"rad.exe path. [eg. C:/HL/_tools/hlrad.exe]" ]


	if ($GUI_StringType = 1) Then
		$aPathDescriptions = $aPathTip_quake1
	ElseIf ($GUI_StringType = 2) Then
		$aPathDescriptions = $aPathTip_quake2
	ElseIf ($GUI_StringType = 3) Then
		$aPathDescriptions = $aPathTip_quake3
	ElseIf ($GUI_StringType = 4) Then
		$aPathDescriptions = $aPathTip_halflife
	EndIf

	;create GUI
	GUISetState(@SW_DISABLE,$KingpinMapBuild)
	$g_ahGUID_Pupup[$POP_ID_GUI] = GUICreate("Setup Directory's", 455, 343, $aPos[0],$aPos[1],  BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), -1, $KingpinMapBuild) ;BitOR($WS_CLIPCHILDREN,$WS_BORDER, $WS_POPUP
	GUISetOnEvent($GUI_EVENT_CLOSE, "Button_opt_cancel_6", $g_ahGUID_Pupup[$POP_ID_GUI])
	GUISetState(@SW_SHOW, $g_ahGUID_Pupup[$POP_ID_GUI]) ;show gui then load elements


	;folder paths
	GUICtrlCreateGroup("Game Paths", 2, 0, 349, 137)
	For $iIdx = 0 to 2
		GUICtrlCreateLabel($aPathDescriptions[$iIdx], 30, $iYPos, 300, 15)
		GUICtrlCreateButton("...", 10, $iYPos+16, 20, 18)
		GUICtrlSetOnEvent(-1, "Button_path_"&$iIdx)
		$g_ahGUI_ID_options[$iIdx][$OPT_IN] = GUICtrlCreateInput($g_sFilePaths[$iIdx],30, $iYPos+16, 310, 18)
		GUICtrlSetLimit(-1, 250);char limit
		$iYPos += 40 ;36
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)


	;maps folder buttons (radio button group)
	GUICtrlCreateGroup("Path for Maps", 355, 0, 97, 137)
	$iYPos = 16
	For $iIdx = 0 to 2
		$g_ahGUI_ID_MapPaths[$iIdx] = GUICtrlCreateRadio($EXE_Names[$iIdx], 360, $iYPos+14, 88, 22, BitOR($GUI_SS_DEFAULT_RADIO,$BS_PUSHLIKE,$BS_FLAT))
		$iYPos += 40 ;36
	Next
	GUICtrlSetState($g_ahGUI_ID_MapPaths[$GUI_MapPathType], $GUI_CHECKED) ;todo check this ;$g_ahGUI_ID_MapPaths[$g_sFilePaths[$switch_PATH_MAP_]
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	;exe paths
	GUICtrlCreateGroup("Tools Path", 2, 138, 451, 203)
	$iYPos = 154
	For $iIdx = 3 to 6
		GUICtrlCreateLabel($aPathDescriptions[$iIdx], 30, $iYPos, 300, 15)
		GUICtrlCreateButton("...", 10, $iYPos+16, 20, 18)
		GUICtrlSetOnEvent(-1, "Button_path_"&$iIdx)
		$g_ahGUI_ID_options[$iIdx][$OPT_IN] = GUICtrlCreateInput($g_sFilePaths[$iIdx],30, $iYPos+16, 412, 18)
		GUICtrlSetLimit(-1, 250);char limit
		$iYPos += 40 ;36
	Next

	; save/cancel
	$g_ahGUID_Pupup[$POP_ID_SAVE] = GUICtrlCreateButton("Save", 350,316,50,22,-1,-1)
	GUICtrlSetOnEvent($g_ahGUID_Pupup[$POP_ID_SAVE], "Button_opt_save_6")
	$g_ahGUID_Pupup[$POP_ID_CANCEL] = GUICtrlCreateButton("Cancel", 400,316,50,22,-1,-1)
	GUICtrlSetOnEvent($g_ahGUID_Pupup[$POP_ID_CANCEL], "Button_opt_cancel_6")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc

;popup GUI. save directories
Func fn_UpdateConfig_filePaths()
	;save to internal array..
	For $iI = 0 to 6
		$g_sFilePaths[$iI] = GUICtrlRead($g_ahGUI_ID_options[$iI][$OPT_IN])
		$g_sFilePaths[$iI] = StringReplace($g_sFilePaths[$iI],"\", "/") ;make all forward slash
	Next

	;append "/" on folders
	fn_AppendForwardSlash($g_sFilePaths[1])
	fn_AppendForwardSlash($g_sFilePaths[2])

	If  _IsChecked($g_ahGUI_ID_MapPaths[0]) Then
		$GUI_MapPathType = $MAPPATH_0_EXE	;exe path
	ElseIf _IsChecked($g_ahGUI_ID_MapPaths[1]) Then
		$GUI_MapPathType = $MAPPATH_1_BASE 	;base path
	Else
		$GUI_MapPathType = $MAPPATH_2_MOD 	;mod path
	EndIf

	;set path based on radio button
	$g_sFilePaths[$switch_PATH_MAP_] = fn_BuildMapsPath() ;fn_GetMaps_Folder()
EndFunc

;handle file open paths/buttons in GUI 0 (directories)
Func fn_GetFolderPath($IDX)
	Local Static $sLastFolder=@ScriptDir
	Local Const $sFNames[7] = ["game.exe","","","tool1.exe","tool2.exe","tool3.exe","tool4.exe"]
	Local $sFileOpenDialog, $sIdx
	Local $sImputValue = GUICtrlRead($g_ahGUI_ID_options[$IDX][$OPT_IN])

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
		$sIdx = StringInStr($sLastFolder,"\",0, -1) ;todo check this
		if $sIdx Then $sLastFolder = StringLeft($sLastFolder, $sIdx)
		ConsoleWrite("!begin4="&$sLastFolder&@CRLF)
	EndIf

	;trim last "\"
	if (StringRight($sLastFolder,1) == "\") Then $sLastFolder = StringTrimRight($sLastFolder,1)
	FileChangeDir($sLastFolder)
	ConsoleWrite("!begin5="&$sLastFolder&@CRLF)


	if ($IDX = $switch_PATH_BASE) Or ($IDX = $switch_PATH_MOD_)  Then ;insert /gunrace folder  after switch
		$sFileOpenDialog = FileSelectFolder("select folder",$sLastFolder,0,"", $g_ahGUID_Pupup[$POP_ID_GUI])
	Else
		$sFileOpenDialog = FileOpenDialog("select file/path", $sLastFolder & "\", _
			"exe (*.exe)|All (*.*)", $FD_FILEMUSTEXIST, $sFNames[$IDX], $g_ahGUID_Pupup[$POP_ID_GUI])
	EndIf


	If @error Then
		;MsgBox($MB_SYSTEMMODAL, "", "No file/folder selected.",0, $KingpinMapBuild)
	Else
		$sFileOpenDialog = StringReplace($sFileOpenDialog,"\", "/")
		if ($IDX = $switch_PATH_BASE) Or ($IDX = $switch_PATH_MOD_)  Then
			if Not (StringRight($sFileOpenDialog,1) == "/") Then $sFileOpenDialog &= "/"
		EndIf
		GUICtrlSetData($g_ahGUI_ID_options[$IDX][$OPT_IN], $sFileOpenDialog)
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
#EndRegion : end popup gui folders


#Region ;==> popup GUI. save/cancel buttons
;close popup. show main window
Func fn_RestoreMainWindow($IDX)
	if Not ($g_ahGUID_Pupup[$POP_ID_GUI] = -1) And WinExists($g_ahGUID_Pupup[$POP_ID_GUI]) Then
		;ConsoleWrite("Close IDX=" &$IDX& " ID=" &$g_ahGUID_Pupup[$POP_ID_GUI]&@CRLF)
		GUIDelete($g_ahGUID_Pupup[$POP_ID_GUI])
		sleep(100)
		For $i = 0 To $COUNT_POP -1
			$g_ahGUID_Pupup[$i] = -1
		Next
	Else
		;trying to close a destroyed window. windows delayed event?
		ConsoleWrite("ERROR: IDX="&$IDX& " ID=" &$g_ahGUID_Pupup[$POP_ID_GUI]&@CRLF)
	EndIf

	GUISetState(@SW_ENABLE, $KingpinMapBuild)
	GUISetState(@SW_RESTORE, $KingpinMapBuild)
EndFunc

Func Button_opt_save()
	fn_UpdateConfig_Custom($g_iLastPopup_ID)
	fn_RestoreMainWindow($g_iLastPopup_ID)
EndFunc
Func Button_opt_cancel()
	fn_RestoreMainWindow($g_iLastPopup_ID)
EndFunc
Func fn_Reset_GIU_toDefault($IDX_GUI)
	Local $iCount = $g_aiConfigFile_default_Count[$IDX_GUI]-1
	ConsoleWrite("$iCount="&$iCount&@CRLF)
	For $iI = 0 To $iCount
		$g_asConfigUsed_custom[$IDX_GUI][$iI] = $g_asConfigFile_default[$IDX_GUI][$iI]
	Next
EndFunc
Func Button_opt_reset()
	fn_RestoreMainWindow($g_iLastPopup_ID)
	fn_Reset_GIU_toDefault($g_iLastPopup_ID)
	fn_Buld_Gui_Options($g_iLastPopup_ID)
EndFunc

; directory options
Func Button_opt_save_6()
	fn_UpdateConfig_filePaths()
	fn_RestoreMainWindow($iGUI_REGION_6_DIRECTORIES)
	fn_FillMapsList()
EndFunc
Func Button_opt_cancel_6()
	fn_RestoreMainWindow($iGUI_REGION_6_DIRECTORIES)
EndFunc

#EndRegion


#Region ;==> Main GUI. GameOption, about, exit buttons
;Game Dropdown comboBox
Func fn_UI_ChangeGame()
	;save cfg files
	fn_SaveConfigFile_Paths()
	fn_SaveConfigFile_Custom($g_sFilename_cfg_custom_full)

	;reeload all configs and setup UI
	fn_SetupMainWindow()
EndFunc

;game selection combo
Func Combo0_gameChange()
	fn_UI_ChangeGame()
EndFunc

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
						"kingpin.info/hosted/hypov8" &@CRLF& _
						"hypov8.pages.dev" &@CRLF& _
						"hypov8@hotmail.com" &@CRLF& _
						"Support Me: https://buymeacoffee.com/hypov8"

	GUISetState(@SW_DISABLE,$KingpinMapBuild)

	$g_ahGUID_Pupup[$POP_ID_GUI] = GUICreate("About", 455, 343, $aPos[0],$aPos[1], BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), -1, $KingpinMapBuild)
	GUISetOnEvent($GUI_EVENT_CLOSE, "Button_opt_closeAbout", $g_ahGUID_Pupup[$POP_ID_GUI])

	GUICtrlCreateGroup("", 2, 0, 451, 341)
	GUICtrlCreateEdit($sOut, 10, 16, 435, 316, BitOR($ES_READONLY,$ES_MULTILINE ))

	GUICtrlCreateGroup("", -99, -99, 1, 1);end group
	GUISetState(@SW_SHOW, $g_ahGUID_Pupup[$POP_ID_GUI]) ;show gui then load elements
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
	KingpinMapBuildClose() ;exit
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
	Local $iRet = $SWITCH_0_NONE ;0

	if $aSplit[0] >= 3 And $aSplit[3] <> "" Then
		$sRetSwitch = $aSplit[3] ;<compile switch>
		$sRetValue = "" ;<default text>
		$iRet = $SWITCH_1_KEY ;1
	EndIf
	if $aSplit[0] >= 4 Then $iRetEnabled = Number($aSplit[4]) ;checked

	Return $iRet
EndFunc
;checkbos with text
Func fn_switchType_TextBox(ByRef $aSplit, ByRef $iRetEnabled, ByRef $sRetSwitch, ByRef $sRetValue)
	Local $iRet = $SWITCH_0_NONE ;0

	if $aSplit[0] >= 3 And $aSplit[3] <> "" Then
		$sRetSwitch = $aSplit[3] ;<compile switch>
		$iRet = $SWITCH_1_KEY ;1
		if $aSplit[0] >= 5 And $aSplit[5] <> "" Then
			$sRetValue = $aSplit[5] ;<default text>
			$iRet = $SWITCH_2_KEYVAL ;2
		EndIf
		;if (Number($aSplit[4]) = 1) Then $iRetEnabled =  1 ;checked
	EndIf
	if $aSplit[0] >= 4 Then $iRetEnabled = Number($aSplit[4]) ;checked

	Return $iRet
EndFunc

Func fn_getSwitchPath($IDX_PATH, ByRef $iPathID, $sText, $bDOS, $bFullPath)
	Local $sFPath = $g_sFilePaths[$IDX_PATH]
	Local $bNoExt = False
	Local $sMap = $g_sMapSelected_name
	if $iPathID >= 16 Then
		$iPathID -= 16
		fn_Trim_FileExtension($sMap)
	EndIf

	fn_TrimPathTo_ForwardSlash($sFPath)
	if  $bDOS and _IsChecked($Checkbox0_DOS_8_3) Then $sFPath = fn_convertStringTo_DOS_83($sFPath)	;And ($sChecked =1)

	if ($iPathID = 0) Then
		return $sFPath									;folder/
	elseif ($iPathID = 1) Then
		return  $sFPath & $sMap							;folder/file
	elseIf ($iPathID = 2) Then
		return ($bFullPath)? ($sFPath & $sText):($sText);folder/text
	ElseIf ($iPathID = 3) Then
		Return  $sMap									;bsp-filename
	EndIf

	Return ""
EndFunc

;checkbox+compile paths in switch
Func fn_switchType_TextPath(ByRef $aSplit, ByRef $iRetEnabled, ByRef $sRetSwitch, ByRef $sRetValue, $IDX_PATH)
	Local $sItemName="ERROR", $iPathID=0, $sText="", $iRet = 0

	if $aSplit[0] >= 3 And $aSplit[3] <> "" Then
		$sRetSwitch =  $aSplit[3]	;<compile switch>
		;$sRetValue = "" 			;<default text>
		$iRet = $SWITCH_1_KEY ;1	;return use switch

		if ($aSplit[0] >= 4) And ($aSplit[4] <> "") Then $iRetEnabled = Number($aSplit[4]) ;checked
		if ($aSplit[0] >= 5) And ($aSplit[5] <> "") Then $sText       = $aSplit[5]
		if ($aSplit[0] >= 6) And ($aSplit[6] <> "") Then $iPathID     = Number($aSplit[6])

		;get path string
		;Local $sFPath = $g_sFilePaths[$IDX_PATH]
		$sRetValue = fn_getSwitchPath($IDX_PATH, $iPathID, $sText, True, True)

		;ConsoleWrite(">$iPathID="&$iPathID&" $sRetSwitch=" &$sRetSwitch&" $sFPath="&$sRetValue&@CRLF)

		;use string
		If ($sRetValue <> "") Then $iRet = $SWITCH_2_KEYVAL ;2 ;return use switch+path
	EndIf

	Return $iRet
EndFunc


;read value from settings.txt (array)
;return
Func fn_GetSwitchValue($IDX_GUI, $iIdx, ByRef $iRetEnabled, ByRef $sRetSwitch, ByRef $sRetValue, $iCustom)
	Local $aSplit
	$iRetEnabled = 0
	$sRetSwitch = ""
	$sRetValue = ""

	;skip comments
	if StringInStr($g_asConfigUsed_custom[$IDX_GUI][$iIdx], "/",                2, 1, 1, 2) Then Return $SWITCH_5_COMMENT; 4 ;invalid todo skip blank lines?
	;compiler uses map name at end
	If StringInStr($g_asConfigUsed_custom[$IDX_GUI][$iIdx], "switch_APPENDMAP", 2, 1, 1, 16) Then Return $SWITCH_3_APPENDMAP ; 3
	;skip
	If StringInStr($g_asConfigUsed_custom[$IDX_GUI][$iIdx], "newcolum",         2, 1, 1, 8)  Then Return $SWITCH_4_NEW_COL;4 ;invalid

	; load default config
	if $iCustom = 1 then
		$aSplit = StringSplit($g_asConfigUsed_custom[$IDX_GUI][$iIdx], ",")
	Else
		$aSplit = StringSplit($g_asConfigFile_default[$IDX_GUI][$iIdx], ",")
	EndIf
	if @error Then
		Return $SWITCH_0_NONE; 0
	EndIf

	if $aSplit[0] >= 4 Then ;make sure it has a checked value.
		if StringInStr($aSplit[1], "switch_CHECK_BOX", 0, 1, 1, 16) Then
			Return fn_switchType_CheckBox($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue)
		ElseIf StringInStr($aSplit[1], "switch_TEXT_BOX_", 0, 1, 1, 16) Then
			Return fn_switchType_TextBox($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue)
		;use compile path in string
		ElseIf StringInStr($aSplit[1], "switch_PATH", 0, 1, 1, 11) Then
			for $iI = 0 to $COUNT_SWITCH -1 ; UBound($g_asSwitchNames)-1
				if StringInStr($aSplit[1], $g_asSwitchNames[$iI][$STR_SWITCH], 2, 1, 1, 16) Then
					Return fn_switchType_TextPath($aSplit, $iRetEnabled, $sRetSwitch, $sRetValue, $iI)
				EndIf
			next
		EndIf
	EndIf
	Return $SWITCH_0_NONE ;0
EndFunc

Func fn_buildBatch_CompileString($IDX_GUI, $IDX_PATH, $iToolID)
	Local $bRet, $iRetEnabled, $sRetSwitch, $sRetValue, $sPath_EXE, $iAppendMap=0, $iIsCustom
	Local $iCount_default = $g_aiConfigFile_default_Count[$IDX_GUI]-1

	$g_as_CompileString[$iToolID] = "" ;reset string
	if _IsChecked($sSaveBuild[$iToolID][$GUI_BUILD_RADIO1]) Then Return ;disabled by user

	;use windows start? low priority
	if _IsChecked($Checkbox0_UseWinStart) Then $g_as_CompileString[$iToolID] = "start /B /I /low /wait "

	;add tool executable
	$sPath_EXE = $g_sFilePaths[$IDX_PATH]
	if _IsChecked($Checkbox0_DOS_8_3) Then $sPath_EXE = fn_convertStringTo_DOS_83($sPath_EXE) ;ok
	if $sPath_EXE <> "" Then
		$g_as_CompileString[$iToolID] &= $sPath_EXE &" " ;default compile.exe
	EndIf

	;use settings in default config
	$iIsCustom = _IsChecked($sSaveBuild[$iToolID][$GUI_BUILD_RADIO3])
	For $iIdx = 0 to $iCount_default
		$bRet = fn_GetSwitchValue($IDX_GUI, $iIdx, $iRetEnabled, $sRetSwitch, $sRetValue, $iIsCustom)
		If ($bRet = $SWITCH_3_APPENDMAP) Then
			$iAppendMap = 1 ;switch_APPENDMAP
		Else
			fn_appendSwitchValue($bRet, $g_as_CompileString[$iToolID], $iRetEnabled, $sRetSwitch, $sRetValue)
		EndIf
	Next

	;append .map "switch_APPENDMAP"
	if ($iAppendMap = 1) Then
		;ConsoleWrite(">write map=" & $g_sMapSelected_full & @CRLF)
		if _IsChecked($Checkbox0_DOS_8_3) Then
			$g_as_CompileString[$iToolID] &= fn_convertStringTo_DOS_83($g_sMapSelected_path) &$g_sMapSelected_name
		Else
			$g_as_CompileString[$iToolID] &= $g_sMapSelected_full
		EndIf
	EndIf
EndFunc

Func fn_GetMaps_Folder()
	Local $sOutDir = ""

	if ($GUI_MapPathType = $MAPPATH_0_EXE) Then
		$sOutDir = $g_sFilePaths[$switch_PATH_EXE_] ;game.exe folder
		fn_TrimPathTo_ForwardSlash($sOutDir)
	ElseIf ($GUI_MapPathType = $MAPPATH_1_BASE) Then
		$sOutDir = $g_sFilePaths[$switch_PATH_BASE] ;base/main folder
	Else
		$sOutDir = $g_sFilePaths[$switch_PATH_MOD_] ;mod folder
	EndIf
	fn_AppendForwardSlash($sOutDir)

	Return $sOutDir
EndFunc

;map path changed. update with selected (0,1,2)
Func fn_BuildMapsPath()
	Local $sDir = fn_GetMaps_Folder()

	;appends maps folder if not root
	if Not ($GUI_MapPathType = $MAPPATH_0_EXE) Then $sDir &= "maps/"

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

;todo check this
Func fn_BatchFile_Run()
	Local $sOut = fn_BuildCompileString()
	Local $sBatchFileName, $hFile, $iI=0

	;save batch file to maps folder
	If _IsChecked($Checkbox0_save_bat) Then
		$sBatchFileName = $g_sMapSelected_full
		fn_Trim_FileExtension($sBatchFileName)
		$sBatchFileName &= ".bat"
	Else
		;use temp folder name
		$sBatchFileName = $g_sFileName_bat_full
	EndIf

	;save backup file
 	If  _IsChecked($Checkbox0_backupMap) Then ;if $g_sFilePaths[$switch_PATH_SAVE] = 1 Then
	 	Local $sTmp = $g_sMapSelected_full
		fn_TrimPathTo_ForwardSlash($sTmp)
		$sTmp &= "snapshots/"& $g_sMapSelected_name&"."
		;increment file name
		While(FileExists( String($sTmp & $iI)))
			$iI +=1
		WEnd
		FileCopy($g_sMapSelected_full, String($sTmp& $iI))
		ConsoleWrite("save tmpMap dir2="&String($sTmp & $iI)& @CRLF)
	EndIf

	$hFile = FileOpen($sBatchFileName, $FO_OVERWRITE)
	if $hFile = -1 Then
		ConsoleWrite("!ERROR COMP"&@CRLF)
	Else
		FileWrite($hFile, $sOut)
		FileClose($hFile)
		ShellExecute(@ComSpec, " /c "& $sBatchFileName, "", $SHEX_OPEN );ShellExecute($sBatchFileName,"", "", $SHEX_OPEN );Run($sBatchFileName, "")
	EndIf
	ConsoleWrite("$sBatchFileName="&$sBatchFileName&@CRLF)
EndFunc

Func fn_BatchFile_View()
	Local $sOut = fn_BuildCompileString()
	Local $ilineNum =0
	Local $aPos = WinGetPos ( $KingpinMapBuild )

	GUISetState(@SW_DISABLE,$KingpinMapBuild)

	$g_ahGUID_Pupup[$POP_ID_GUI] = GUICreate("Batch Compile String", 455, 343, $aPos[0],$aPos[1], BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), -1, $KingpinMapBuild)
	GUISetOnEvent($GUI_EVENT_CLOSE, "Button_opt_closeBat", $g_ahGUID_Pupup[$POP_ID_GUI])

	GUICtrlCreateGroup("", 2, 0, 451, 341)
	GUICtrlCreateEdit($sOut, 10, 16, 435, 316)

	GUICtrlCreateGroup("", -99, -99, 1, 1);end group
	GUISetState(@SW_SHOW, $g_ahGUID_Pupup[$POP_ID_GUI]) ;show gui then load elements
EndFunc

Func Button_opt_closeBat()
	fn_RestoreMainWindow($iGUI_REGION_7_BAT)
EndFunc

Func fn_buildBatch_PlayMap()
	Local $sPath_EXE = $g_sFilePaths[$switch_PATH_EXE_]
	Local $sParameters = "", $sWorkingDir = ""
	fn_BuildPlayExeString($sParameters, $sWorkingDir)

	if _IsChecked($Checkbox0_DOS_8_3) Then $sPath_EXE = fn_convertStringTo_DOS_83($sPath_EXE)
	$g_as_CompileString[4] = "cd /d "&$sWorkingDir&@CRLF
	$g_as_CompileString[4] &= "start "& $sPath_EXE &" "& $sParameters
EndFunc

#EndRegion

#Region ;==> Main GUI. maps group
Func fn_Build_Map_Compile_Strings()
	fn_buildBatch_CompileString($iGUI_REGION_1_TOOL1, $switch_PATH_PRE_, 0)
	fn_buildBatch_CompileString($iGUI_REGION_2_TOOL2, $switch_PATH_BSP_, 1)
	fn_buildBatch_CompileString($iGUI_REGION_3_TOOL3, $switch_PATH_VIS_, 2)
	fn_buildBatch_CompileString($iGUI_REGION_4_TOOL4, $switch_PATH_RAD_, 3)
	fn_buildBatch_PlayMap()
EndFunc

;build map string from selected "list"
Func List0_mapsClick()
	Local $sTmp
	;Local $iIdx = _GUICtrlComboBox_GetCurSel($Combo0_maps) ;"*.map|*.bsp|*.*"
	$g_sMapSelected_name = StringReplace(GUICtrlRead($List0_maps), "\", "/")
	GUICtrlSetState($Button0_build_map, $GUI_ENABLE)
	GUICtrlSetState($Button0_view_bat, $GUI_ENABLE)
	GUICtrlSetState($Button0_play_map, $GUI_DISABLE) ;disable

	;$g_sMapSelected_path = fn_BuildMapsPath()
	$g_sMapSelected_full = $g_sMapSelected_path & $g_sMapSelected_name ;switch_PATH_MAP_
	ConsoleWrite("$g_sMapSelected_full="&$g_sMapSelected_full&@CRLF)
	;ConsoleWrite("$iIdx="&$iIdx&@CRLF)

	;Local $sTmp = GUICtrlRead($Input0_maps)
	Local $iIdx = StringInStr($g_sMapSelected_name, '.', 1, -1)
	if $iIdx Then $sTmp = StringLeft($g_sMapSelected_name, $iIdx-1)
	$sTmp = $g_sMapSelected_path & $sTmp & ".bsp"
	if FileExists($sTmp) Then GUICtrlSetState($Button0_play_map, $GUI_ENABLE)

EndFunc


Func fn_BuildPlayExeString(ByRef $sParameters, ByRef $sWorkingDir)
	Local $bRet, $iRetEnabled, $sRetSwitch, $sRetValue, $sIdx, $iAppendMap = 0

	Local $iCount_default = $g_aiConfigFile_default_Count[$iGUI_REGION_5_GAME_OPTIONS]-1

	;$g_as_RunGameString = ""
	;$g_as_RunGameString &= $g_sFilePaths[$switch_PATH_EXE_]&" " ;default compile.exe

	For $iIdx = 0 to $iCount_default
		$bRet = fn_GetSwitchValue($iGUI_REGION_5_GAME_OPTIONS, $iIdx, $iRetEnabled, $sRetSwitch, $sRetValue, 1)
		If ($bRet = $SWITCH_3_APPENDMAP) Then
			$iAppendMap = 1 ;switch_APPENDMAP
		Else
			fn_appendSwitchValue($bRet, $sParameters, $iRetEnabled, $sRetSwitch, $sRetValue)
		EndIf
	Next

	$sWorkingDir = $g_sFilePaths[$switch_PATH_EXE_]
	fn_TrimPathTo_ForwardSlash($sWorkingDir)
	if _IsChecked($Checkbox0_DOS_8_3) Then $sWorkingDir = fn_convertStringTo_DOS_83($sWorkingDir)

	;append .map "switch_APPENDMAP"
	if ($iAppendMap = 1) Then
		Local $sTmp = $g_sMapSelected_name
		fn_Trim_FileExtension($sTmp)
		$sParameters &= "+map "& $sTmp & @CRLF ;todo
	EndIf
EndFunc

Func fn_PlayMap()
	Local $sPath_EXE = $g_sFilePaths[$switch_PATH_EXE_]
	Local $sParameters = "", $sWorkingDir = ""
	fn_BuildPlayExeString($sParameters, $sWorkingDir)

	if _IsChecked($Checkbox0_DOS_8_3) Then $sPath_EXE = fn_convertStringTo_DOS_83($sPath_EXE)
	ShellExecute($sPath_EXE, $sParameters, $sWorkingDir)
	;Run($sPath_EXE, )

	ConsoleWrite(">$sPath_EXE"&$sPath_EXE&@CRLF)
	ConsoleWrite(">workDir"&$sWorkingDir&@CRLF)
	ConsoleWrite(">run="&$sParameters&@CRLF)
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

Func fn_Build_All_Config()
	fn_Build_Custom_Config($iGUI_REGION_1_TOOL1)
	fn_Build_Custom_Config($iGUI_REGION_2_TOOL2)
	fn_Build_Custom_Config($iGUI_REGION_3_TOOL3)
	fn_Build_Custom_Config($iGUI_REGION_4_TOOL4)
	fn_Build_Custom_Config($iGUI_REGION_5_GAME_OPTIONS)
EndFunc

Func fn_BuildProfile_list()
	Local $sOut = ""
	Local $aTmp0[3] = [$g_sFilename_cfg_paths, $g_sFilename_cfg_default, $g_sFilename_cfg_custom]
	Local $aTmp1 = _FileListToArray($g_sFilename_cfg_path_game, "*.txt", $FLTA_FILES)
	if Not @error Then
		Local $iCount = $aTmp1[0]
		for $iI = 0 to 2
			for $ij = $iCount to 1 Step -1
				if StringCompare($aTmp1[$ij], $aTmp0[$iI], 0) = 0 Then
					$iCount = _ArrayDelete($aTmp1, $ij)-1
					ExitLoop
				EndIf
			Next
		Next
	Else
		return ""
	EndIf

	for $iI = 1 to $iCount
		$sOut = ($iI = 1)? ($aTmp1[$iI]) : ($sOut &"|"& $aTmp1[$iI])
	Next

	return $sOut
EndFunc

Func button9_profile_OKClick()
	Local $sTmp = GUICtrlRead($g_ahGUID_Pupup[$POP_ID_COMBO], 0)
	If Not @error and $sTmp <> "" Then
		$sTmp = $g_sFilename_cfg_path_game &$sTmp
		ConsoleWrite("-file=" &$sTmp&@CRLF)
		if FileExists($sTmp) Then
			fn_ReadConfigFile_Custom($sTmp)
			fn_Build_All_Config()
		EndIf
	EndIf
	fn_RestoreMainWindow($iGUI_REGION_9_PROFILE)
EndFunc
Func popup9_filesClose()
	fn_RestoreMainWindow($iGUI_REGION_9_PROFILE)
EndFunc
;new load profile
Func fn_Popup_profile_list()
	Local $sOut = fn_BuildProfile_list()
	Local $aPos = WinGetPos ( $KingpinMapBuild )
	Local $iXpos = $apos[0] + Int($apos[2]/2) - 75
	Local $iYpos = $apos[1] + Int($apos[3]/2) - 50
	if $sOut = "" Then
		MsgBox(0, "Warning", "No Profiles detected", 0, $KingpinMapBuild)
		Return
	EndIf
	GUISetState(@SW_DISABLE,$KingpinMapBuild)

	#Region ### START Koda GUI section ### Form=kingpinmapbuild_files.kxf
	$g_ahGUID_Pupup[$POP_ID_GUI] = GUICreate("Load Existing Profile", 179, 89, $iXpos, $iYpos, -1, -1, $KingpinMapBuild) ;Global $popup9_files =
	GUISetOnEvent($GUI_EVENT_CLOSE, "popup9_filesClose", $g_ahGUID_Pupup[$POP_ID_GUI])
	GUICtrlCreateLabel("Select Profile", 12, 12, 118, 13)
	$g_ahGUID_Pupup[$POP_ID_OK] = GUICtrlCreateButton("OK", 12, 56, 73, 25)	;Global $button9_profile_OK =
	GUICtrlSetOnEvent($g_ahGUID_Pupup[$POP_ID_OK], "button9_profile_OKClick")
	$g_ahGUID_Pupup[$POP_ID_CANCEL] = GUICtrlCreateButton("Cancel", 96, 56, 73, 25) ;Global $button9_profile_Cancel
	GUICtrlSetOnEvent(-1, "popup9_filesClose")
	$g_ahGUID_Pupup[$POP_ID_COMBO] = GUICtrlCreateCombo("", 12, 28, 157, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL)) ;Global $Combo9_files
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	GUICtrlSetData($g_ahGUID_Pupup[$POP_ID_COMBO], $sOut)
	_GUICtrlComboBox_SetCurSel($g_ahGUID_Pupup[$POP_ID_COMBO], 0)
EndFunc

;old load profile
Func fn_Popup_profile_fileDialog()
 	Local $sPathWorking = @WorkingDir
	Local $sPathSelecte = FileOpenDialog("Load Profile", $g_sLastFolder_profile, "Text (*.txt)| All Files (*.*)",$FD_FILEMUSTEXIST,"", $KingpinMapBuild)
	If @error Then
		FileChangeDir($sPathWorking)
	Else
		FileChangeDir($sPathWorking)
		fn_ReadConfigFile_Custom($sPathSelecte)
		fn_Build_All_Config()

		$g_sLastFolder_profile = $sPathSelecte
		Local $sIdx = StringInStr($g_sLastFolder_profile,"\",0, -1)
		if $sIdx Then
			$g_sLastFolder_profile = StringLeft($g_sLastFolder_profile, $sIdx)
		EndIf
	EndIf
EndFunc

; new save profile
Func fn_Button_p_saveClick_list()
	Local $apos = WinGetPos($KingpinMapBuild)
	Local $iXpos = $apos[0] + Int($apos[2]/2) - 75
	Local $iYpos = $apos[1] + Int($apos[3]/2) - 50

    Local $sFileName = InputBox("Save New Profile", "Profile Name?", "", "", 150, 120, $iXpos, $iYpos,0, $KingpinMapBuild)
	if Not @error And  $sFileName <> "" Then
		Local $iIdx = StringInStr($sFileName, ".", 1, -1)
		if $iIdx Then
			$sFileName = StringMid($sFileName, 1, $iIdx) ;trim extension
		EndIf
		$sFileName = $g_sFilename_cfg_path_game & $sFileName& ".txt"
		Local $iTmp = 0
		If FileExists($sFileName) Then
			$iTmp = MsgBox(($MB_YESNO + $MB_ICONWARNING), "Warning: File exists", "Overwrite config file?", 0, $KingpinMapBuild)
			if Not ($iTmp = $IDYES) Then
				return ; (6)
			EndIf
		EndIf
		ConsoleWrite(">file="&$sFileName&@CRLF)
		fn_SaveConfigFile_Custom($sFileName)
	EndIf
EndFunc
; old save profile
Func fn_Button_p_saveClick_fileDialog()
 	Local $sPathWorking = @WorkingDir
	Local $sPathConfig = $g_sFilename_cfg_path_game
	Local $sPathSelecte = FileSaveDialog("Save Profile", $g_sLastFolder_profile, "Text (*.txt)| All Files (*.*)", 0,"", $KingpinMapBuild)
	If @error Then
		FileChangeDir($sPathWorking)
	Else
		FileChangeDir($sPathWorking)
		fn_SaveConfigFile_Custom($sPathSelecte)
		$g_sLastFolder_profile = $sPathSelecte
		Local $sIdx = StringInStr($g_sLastFolder_profile,"\",0, -1)
		if $sIdx Then
			$g_sLastFolder_profile = StringLeft($g_sLastFolder_profile, $sIdx)
		EndIf
	EndIf
EndFunc


;load custom config file
Func Button_p_loadClick()
	;fn_Popup_profile_fileDialog() ; old load profile
	fn_Popup_profile_list() ; new load profile
EndFunc
;save custom config file
Func Button_p_saveClick()
	; fn_Button_p_saveClick_fileDialog() ; old save profile
	fn_Button_p_saveClick_list() ; new save profile
EndFunc
#EndRegion

#Region ;==> Main GUI. compile tools group

Func Radio1_noneClick()
	If _IsChecked($Radio1_custom)  Then
		GUICtrlSetState($Button1_option, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button1_option, $GUI_DISABLE)
	EndIf
EndFunc
Func Radio2_noneClick()
	If _IsChecked($Radio2_custom) Then
		GUICtrlSetState($Button2_option, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button2_option, $GUI_DISABLE)
	EndIf
EndFunc
Func Radio3_noneClick()
	If _IsChecked($Radio3_custom) Then
		GUICtrlSetState($Button3_option, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button3_option, $GUI_DISABLE)
	EndIf
EndFunc
Func Radio4_noneClick()
	If _IsChecked($Radio4_custom) Then
		GUICtrlSetState($Button4_option, $GUI_ENABLE)
	Else
		GUICtrlSetState($Button4_option, $GUI_DISABLE)
	EndIf
EndFunc

Func Button1_optionClick()
	;fn_Build_Custom_Config($iGUI_REGION_1_TOOL1)
	fn_Buld_Gui_Options($iGUI_REGION_1_TOOL1)
EndFunc
Func Button2_optionClick()
	;fn_Build_Custom_Config($iGUI_REGION_2_TOOL2)
	fn_Buld_Gui_Options($iGUI_REGION_2_TOOL2)
EndFunc
Func Button3_optionClick()
	;fn_Build_Custom_Config($iGUI_REGION_3_TOOL3)
	fn_Buld_Gui_Options($iGUI_REGION_3_TOOL3)
EndFunc
Func Button4_optionClick()
	;fn_Build_Custom_Config($iGUI_REGION_4_TOOL4)
	fn_Buld_Gui_Options($iGUI_REGION_4_TOOL4)
EndFunc
#EndRegion





#Region ;==> exit
;save custom config internaly, used on closed GUI
Func fn_UpdateConfig_Custom($IDX_GUI)
	Local $iCount = $g_aiConfigFile_default_Count[$IDX_GUI] -1
	Local $aTmp
	Local Enum _
		$CFG_0_Count, _
		$CFG_1_SW_TYPE, _
		$CFG_2_UI_NAME, _
		$CFG_3_SWITCH, _
		$CFG_4_CHEKED, _ ; 2=DISABLE CHANGE
		$CFG_5_INPUT, _
		$CFG_6

	For $iI = 0 to $iCount
		;duplicate the orig aray
		$g_asConfigUsed_custom[$IDX_GUI][$iI] = $g_asConfigFile_default[$IDX_GUI][$iI]

		$aTmp = StringSplit($g_asConfigUsed_custom[$IDX_GUI][$iI], ",")
		If Not @error Then
			;ConsoleWrite(">#4="&$g_ahGUI_ID_options[$iI][$OPT_CHK]&" #4="&$g_ahGUI_ID_options[$iI][$OPT_IN]&@CRLF)
			;ConsoleWrite("val=" & $aTmp[0] &", " & $aTmp[1]&", " & $aTmp[2]&", " &$aTmp[3]&", " &$aTmp[4] &@CRLF)

			;get checkbox value
			If $aTmp[$CFG_0_Count] >= $CFG_4_CHEKED And Not ($aTmp[$CFG_4_CHEKED] = 2) Then
				$aTmp[$CFG_4_CHEKED] = 0
				if _IsDisabled($g_ahGUI_ID_options[$iI][$OPT_CHK]) Then
					$aTmp[$CFG_4_CHEKED] = 2 ; set checkbox value (2= checked+disabled)
				ElseIf _IsChecked($g_ahGUI_ID_options[$iI][$OPT_CHK]) Then
					$aTmp[$CFG_4_CHEKED] = 1 ; set checkbox value
				Endif
			EndIf

			;get inputbox string (not a checkbox)
			If $aTmp[$CFG_0_Count] >= $CFG_5_INPUT And Not ($aTmp[$CFG_4_CHEKED] = 2) _
			And $g_ahGUI_ID_options[$iI][$OPT_IN] And StringCompare($aTmp[$CFG_1_SW_TYPE], "switch_CHECK_BOX", 0) Then
				;update input
				$aTmp[$CFG_5_INPUT] = GUICtrlRead($g_ahGUI_ID_options[$iI][$OPT_IN]) ;set inputbox value
			EndIf
			;update internal array
			$g_asConfigUsed_custom[$IDX_GUI][$iI] = _ArrayToString($aTmp, ",", 1)
		EndIf
	Next
EndFunc


;save config. paths
Func fn_SaveConfigFile_Paths()
	Local $hFileOpen = FileOpen($g_sFilename_cfg_path_full, $FO_OVERWRITE)
	If $hFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, "", "Error reading file."&@CRLF& $g_sFilename_cfg_paths)
		Return False
	EndIf

	;paths
	For $i = 0 to $switch_PATH_RAD_
		$g_sFilePaths[$i] = StringReplace($g_sFilePaths[$i],"\", "/") ;make all forward slash
		FileWriteLine($hFileOpen, StringFormat("%s,%s", $g_asSwitchNames[$i][$STR_SAVE], $g_sFilePaths[$i]))
	Next
	;MAP_INDEX
	FileWriteLine($hFileOpen, StringFormat("%s,%i",$g_asSwitchNames[$switch_PATH_MAP_][$STR_SAVE], $GUI_MapPathType))

	;gui options
	For $i = 0 to 4
		if _IsChecked($sSaveGUI[$i][$GUIOPT_ID]) Then
			FileWriteLine($hFileOpen, StringFormat("%s,1", $sSaveGUI[$i][$GUIOPT_NAME]))
		Else
			FileWriteLine($hFileOpen, StringFormat("%s,0", $sSaveGUI[$i][$GUIOPT_NAME]))
		EndIf
	Next

	;tool pause
	For $i = 0 to $COUNT_TOOL -1
		if _IsChecked($sSaveBuild[$i][$GUI_PAUSE_ID]) Then
			FileWriteLine($hFileOpen, StringFormat("%s,1", $sSaveBuild[$i][$GUI_PAUSE_NAME_NEW]))
		Else
			FileWriteLine($hFileOpen, StringFormat("%s,0", $sSaveBuild[$i][$GUI_PAUSE_NAME_NEW]))
		EndIf
	Next

	;build radio button <none, default, custom>
	For $i = 0 to $COUNT_TOOL-1
		if _IsChecked($sSaveBuild[$i][$GUI_BUILD_RADIO1]) Then
			FileWriteLine($hFileOpen, StringFormat("%s,0", $sSaveBuild[$i][$GUI_BUILD_NAME_NEW])) ;none
		ElseIf  _IsChecked($sSaveBuild[$i][$GUI_BUILD_RADIO2]) Then
			FileWriteLine($hFileOpen, StringFormat("%s,1", $sSaveBuild[$i][$GUI_BUILD_NAME_NEW])) ;default
		Else
			FileWriteLine($hFileOpen, StringFormat("%s,2", $sSaveBuild[$i][$GUI_BUILD_NAME_NEW])) ;custom
		EndIf
	Next

	FileClose($hFileOpen)
EndFunc

;save config compile options
Func fn_SaveConfigFile_Custom($sFilePath)
    Local $iLineCount, $aSplit, $iCount
	Local $sItemName="ERROR", $sItemSwitch="", $sChecked=0, $sText="", $iPathID=""
	Local Const $sSaveName[7] = ["_GUI_", "TOOL1", "TOOL2", "TOOL3", "TOOL4", "GAME", "DIR"]
	Local $hFileOpen = FileOpen($sFilePath, $FO_OVERWRITE)

	If $hFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file." &@CRLF& $sFilePath)
		Return False
	EndIf

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
			if Not @error Then
				$iCount = ($aSplit[0] > 5)? (5):($aSplit[0])
				For $i = 1 to $iCount
					$aSplit[$i] = StringStripWS($aSplit[$i], 3)
				Next
				If StringInStr($aSplit[1], "/", 0, 1, 1, 1) Then ContinueLoop
				If StringInStr($aSplit[1], "switch_APPENDMAP", 0, 1, 1, 16) Then ContinueLoop
				If StringInStr($aSplit[1], "newcolum", 0, 1, 1, 8) Then ContinueLoop

				if $aSplit[0] >= 3  And $aSplit[3] <> "" Then $sItemSwitch = $aSplit[3]
				if $aSplit[0] >= 4  And $aSplit[4] <> "" Then $sChecked    = Number($aSplit[4])
				if $aSplit[0] >= 5  And $aSplit[5] <> "" Then $sText       = $aSplit[5]
				;clear checkbox string(not used)
				If StringCompare($aSplit[1], "switch_CHECK_BOX", 1) = 0 Then $sText = "" ; reset text for checkbox
				;save all valid.
				FileWriteLine($hFileOpen, StringFormat("%s,%s,%i,%s", $sSaveName[$IDX_GUI], $sItemSwitch, $sChecked, $sText))
			Else
				If StringInStr($aSplit[1], "/", 0, 1, 1, 1) Then ContinueLoop
				If StringInStr($aSplit[1], "switch_APPENDMAP", 0, 1, 1, 16) Then ContinueLoop
				If StringInStr($aSplit[1], "newcolum", 0, 1, 1, 8) Then ContinueLoop
				ConsoleWrite("!WARNING: setting not saved: "&$g_asConfigUsed_custom[$IDX_GUI][$iIdx] & @CRLF)
			EndIf
			;EndIf
		Next
	Next
	FileClose($hFileOpen)
EndFunc

Func KingpinMapBuildClose()
	;todo check if UI is valid
	fn_SaveConfigFile_Paths()
	fn_SaveConfigFile_Custom($g_sFilename_cfg_custom_full)
	fn_writeRegString()

	;For $iI = 0 to $iGUI_REGION_5_GAME_OPTIONS
	if Not ($g_ahGUID_Pupup[$POP_ID_GUI] = -1) Then GUIDelete($g_ahGUID_Pupup[$POP_ID_GUI])
	;Next
	GUIDelete($KingpinMapBuild)
	Exit
EndFunc

#EndRegion


While 1
	Sleep(100)
WEnd
