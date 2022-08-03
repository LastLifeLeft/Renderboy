DeclareModule General
	; Public variables, constants and structures
	#AppName = "Renderboy"
	
	; Public procedure declarations
	Declare Init()
	Declare Min(A, B)
	Declare Max(A, B)
EndDeclareModule

DeclareModule Project
	Enumeration 1 ; Asset types
		#Asset_Image
		#Asset_Video
		
		#__Asset_Type_Count
	EndEnumeration
	
	Enumeration AssetGenre
		#Media
		#Audio
		#_3D
		#Overlay
		#Modifiers
	EndEnumeration
	
	Global Dim AssetIcon(#__Asset_Type_Count - 1)
	
	Structure AssetFolder
		Name.s
		UUID.s
		Type.i
		*Parent.AssetFolder
		List *Childrens.AssetFolder()
	EndStructure
	
	Structure Asset
		Type.i
		Name.s
		PreviewImage.i
		Path.s
		UUID.s
		*Folder.AssetFolder
	EndStructure
	
	Structure AssetArray
		Map Map.Asset()
	EndStructure
	
	Structure FolderStructureArray
		List *List.AssetFolder()
	EndStructure
	
	Structure FolderArray
		Map Map.AssetFolder()
	EndStructure
	
	Structure Project
		Assets.AssetArray[5]
		Folders.FolderArray[5]
		FoldersStructure.FolderStructureArray[5]
	EndStructure
	
	Global Project.Project
	
	;{ Public procedure declarations
	; Misc
	Declare New()
	Declare Undo()
	Declare Redo()
	
	; Asset
	Declare AddAsset(Assets.s)
	Declare RemoveAsset()
	Declare MoveAsset(*Asset.Asset, *Folder.AssetFolder)
	Declare AddFolder()
	Declare RemoveFolder()
	Declare RenameFolder()
	
	; TimeLine
	Declare AddLine()
	Declare RemoveLine()
	;}
	
EndDeclareModule

DeclareModule MainWindow
	; Public procedure declarations
	;{ Colors
	#Color_Window_Border = $2F3C50
	#Color_Menu_Border = $111E32
	#Color_Gadget_BackCold = $3D4D65
	#Color_Gadget_ButtonCold = $576A83
	#Color_Gadget_ButtonWarm = $708096
	
	#Color_Ressources_Media = $4ABF10
	#Color_Ressources_Audio = $FF0F84
	#Color_Ressources_3D = $8E0FEF
	#Color_Ressources_Overlay = $FFAC65
	#Color_Ressources_Modifiers = $0FCAEF
	;}
	
	#Appearance_CornerSize = 5
	Global Library, TimeLine, Tab, Tree, IconFolder
	Global TabState								; The asset type currently selected
	Global *CurrentFolder.Project::AssetFolder			; The folder currently selected
	
	
	; Public procedure declarations
	Declare Open()
EndDeclareModule

DeclareModule TimeLine
	Declare Gadget(x, y, Width, Height)
	Declare Resize(Gadget, x, y, Width, Height)
	Declare AddLine(Gadget, Position, Name.s, UUID.s)
	Declare RemoveLine(Gadget, Position)
EndDeclareModule

Module General
	EnableExplicit
	UsePNGImageDecoder()
	
	
	; Public procedures
	Procedure Init()
		UsePNGImageDecoder()
		UseJPEGImageDecoder()
		UseJPEG2000ImageDecoder()
		
		MainWindow::Open()
	EndProcedure
	
	Procedure Min(A, B)
		If A > B
			ProcedureReturn B
		EndIf
		ProcedureReturn A
	EndProcedure
	
	Procedure Max(A, B)
		If A < B
			ProcedureReturn B
		EndIf
		ProcedureReturn A
	EndProcedure
	
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 74
; FirstLine = 15
; Folding = e+
; EnableXP
; DPIAware