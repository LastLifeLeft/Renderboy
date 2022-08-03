Module Project
	EnableExplicit
	;{ Macro
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows ; Fix color
		Macro FixColor(Color)
			RGB(Blue(Color), Green(Color), Red(Color))
		EndMacro
	CompilerElse
		Macro FixColor(Color)
			Color
		EndMacro
	CompilerEndIf
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows ; Set Alpha
		Macro SetAlpha(Color, Alpha)
			Alpha << 24 + Color
		EndMacro
	CompilerElse
		Macro SetAlpha(Color, Alpha) ; Not tested...
			Color << 8 + Alpha
		EndMacro
	CompilerEndIf
	
	Macro TestForExistingFile(Type)
		ExistingFile = #False
		ForEach Project\Assets[Type]\map()
			If Project\Assets[Type]\map()\Path = File
				ExistingFile = #True
				Break
			EndIf
		Next
		
		If ExistingFile
			Continue
		EndIf
	EndMacro
	
	;}
	
	;{ Variable, structures and constants
	#MaximumUndo = 100
	
	#Redo = 0
	#Undo = 1
	
	Enumeration 1 ;Action type
		#Action_AddAsset
		#Action_RemoveAsset
		#Action_AddFolder
		#Action_RemoveFolder
		#Action_RenameFolder
		#Action_MoveAsset
	EndEnumeration
	
	Structure Action_AddRemoveAsset
		Name.s
		Type.i
		Path.s
		UUID.s
		FolderUUID.s
	EndStructure
	
	Structure Action_AddRemoveFolder
		Name.s
		Type.i
		Parent.s
		UUID.s
		Depth.w
		Position.i
		ParentPosition.i
	EndStructure
	
	Structure Action_MoveAsset
		Asset.s
		NewFolder.s
		OldFolder.s
		Type.i
	EndStructure
	
	Structure Do
		Type.l
		Parameters.s
	EndStructure
	
	Structure DoList
		List Action.Do()
	EndStructure
	
	Global DoPosition, DoCount, RedoCount
	Global Dim ActionArray.DoList(#MaximumUndo - 1)
	;}
	
	;{ Private procedure declarations
	Declare.s UUID()
	
	;{ Action
	; Assets
	Declare Prepare_AddAsset(Name.s, Type, Path.s)
	Declare Prepare_RemoveAsset(Name.s, Type, Path.s, UUID.s, FolderUUID.s)
	Declare Prepare_RemoveFolder(UUID.s)
	Declare Prepare_MoveAsset(Asset.s, NewFolder.s, OldFolder.s, Type.i)
	
	Declare Action_AddAsset(Parameters.s, Mode.b)
	Declare Action_RemoveAsset(Parameters.s, Mode.b)
	Declare Action_AddFolder(Parameters.s, Mode.b)
	Declare Action_RemoveFolder(Parameters.s, Mode.b)
	Declare Action_MoveAsset(Parameters.s, Mode.b)
	
	; Timeline
	Declare Action_AddLine(Parameters.s)
	Declare Action_RemoveLine(Parameters.s)
	;}
	;}
	
	;{ Public procedures
	;{ Misc
	Procedure New()
		; Clear everything
		ClearMap(Project\Assets[#Media]\Map())
		ClearMap(Project\Assets[#Audio]\Map())
		ClearMap(Project\Assets[#_3D]\Map())
		ClearMap(Project\Assets[#Overlay]\Map())
		ClearMap(Project\Assets[#Modifiers]\Map())
		
		ClearMap(Project\Folders[#Media]\Map())
		ClearMap(Project\Folders[#Audio]\Map())
		ClearMap(Project\Folders[#_3D]\Map())
		ClearMap(Project\Folders[#Overlay]\Map())
		ClearMap(Project\Folders[#Modifiers]\Map())
		
		ClearList(Project\FoldersStructure[#Media]\List())
		ClearList(Project\FoldersStructure[#Audio]\List())
		ClearList(Project\FoldersStructure[#_3D]\List())
		ClearList(Project\FoldersStructure[#Overlay]\List())
		ClearList(Project\FoldersStructure[#Modifiers]\List())
		
		; Load the built in assets
		;Media
		AddElement(Project\FoldersStructure[#Media]\List())
		Project\FoldersStructure[#Media]\List() = AddMapElement(Project\Folders[#Media]\Map(), UUID())
		Project\Folders[#Media]\Map()\Name = "Video"
		Project\Folders[#Media]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		Project\Folders[#Media]\Map()\Type = #Asset_Video
		
		AddElement(Project\FoldersStructure[#Media]\List())
		Project\FoldersStructure[#Media]\List() = AddMapElement(Project\Folders[#Media]\Map(), UUID())
		Project\Folders[#Media]\Map()\Name = "Images"
		Project\Folders[#Media]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		Project\Folders[#Media]\Map()\Type = #Asset_Image
		
		;Audio
		AddElement(Project\FoldersStructure[#Audio]\List())
		Project\FoldersStructure[#Audio]\List() = AddMapElement(Project\Folders[#Audio]\Map(), UUID())
		Project\Folders[#Audio]\Map()\Name = "Music"
		Project\Folders[#Audio]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		AddElement(Project\FoldersStructure[#Audio]\List())
		Project\FoldersStructure[#Audio]\List() = AddMapElement(Project\Folders[#Audio]\Map(), UUID())
		Project\Folders[#Audio]\Map()\Name = "Sound"
		Project\Folders[#Audio]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		AddElement(Project\FoldersStructure[#Audio]\List())
		Project\FoldersStructure[#Audio]\List() = AddMapElement(Project\Folders[#Audio]\Map(), UUID())
		Project\Folders[#Audio]\Map()\Name = "Voice clip"
		Project\Folders[#Audio]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		;3D
		AddElement(Project\FoldersStructure[#_3D]\List())
		Project\FoldersStructure[#_3D]\List() = AddMapElement(Project\Folders[#_3D]\Map(), UUID())
		Project\Folders[#_3D]\Map()\Name = "Models"
		Project\Folders[#_3D]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		AddElement(Project\FoldersStructure[#_3D]\List())
		Project\FoldersStructure[#_3D]\List() = AddMapElement(Project\Folders[#_3D]\Map(), UUID())
		Project\Folders[#_3D]\Map()\Name = "Particles"
		Project\Folders[#_3D]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		;Overlay
		AddElement(Project\FoldersStructure[#Overlay]\List())
		Project\FoldersStructure[#Overlay]\List() = AddMapElement(Project\Folders[#Overlay]\Map(), UUID())
		Project\Folders[#Overlay]\Map()\Name = "Text"
		Project\Folders[#Overlay]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		AddElement(Project\FoldersStructure[#Overlay]\List())
		Project\FoldersStructure[#Overlay]\List() = AddMapElement(Project\Folders[#Overlay]\Map(), UUID())
		Project\Folders[#Overlay]\Map()\Name = "Shape"
		Project\Folders[#Overlay]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		;Moddifiers
		AddElement(Project\FoldersStructure[#Modifiers]\List())
		Project\FoldersStructure[#Modifiers]\List() = AddMapElement(Project\Folders[#Modifiers]\Map(), UUID())
		Project\Folders[#Modifiers]\Map()\Name = "Transitions"
		Project\Folders[#Modifiers]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		AddElement(Project\FoldersStructure[#Modifiers]\List())
		Project\FoldersStructure[#Modifiers]\List() = AddMapElement(Project\Folders[#Modifiers]\Map(), UUID())
		Project\Folders[#Modifiers]\Map()\Name = "Post processing"
		Project\Folders[#Modifiers]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		AddElement(Project\FoldersStructure[#Modifiers]\List())
		Project\FoldersStructure[#Modifiers]\List() = AddMapElement(Project\Folders[#Modifiers]\Map(), UUID())
		Project\Folders[#Modifiers]\Map()\Name = "Colors"
		Project\Folders[#Modifiers]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		AddElement(Project\FoldersStructure[#Modifiers]\List())
		Project\FoldersStructure[#Modifiers]\List() = AddMapElement(Project\Folders[#Modifiers]\Map(), UUID())
		Project\Folders[#Modifiers]\Map()\Name = "Effects"
		Project\Folders[#Modifiers]\Map()\UUID = MapKey(Project\Folders[#Media]\Map())
		
		; Load icons if they aren't loaded
		If AssetIcon(#Asset_Image) = 0
			AssetIcon(#Asset_Image) = ImageID(CatchImage(#PB_Any, ?LibraryImage))
			AssetIcon(#Asset_Video) = ImageID(CatchImage(#PB_Any, ?LibraryVideo))
		EndIf
		
		TimeLine::AddLine(MainWindow::TimeLine, -1, "Line 0", UUID())
		
		DoPosition = 0
		DoCount = 0
		RedoCount = 0
	EndProcedure
	
	Procedure Undo()
		If DoCount
			DoPosition - 1
			DoCount - 1
			RedoCount + 1
			If DoPosition < 0
				DoPosition + #MaximumUndo
			EndIf
			
			LastElement(ActionArray(DoPosition)\Action())
			UITK::Freeze(MainWindow::Library, #True)
			Repeat
				Select ActionArray(DoPosition)\Action()\Type
					Case #Action_AddAsset
						Action_RemoveAsset(ActionArray(DoPosition)\Action()\Parameters, #Undo)
					Case #Action_RemoveAsset
						Action_AddAsset(ActionArray(DoPosition)\Action()\Parameters, #Undo)
					Case #Action_AddFolder
						Action_RemoveFolder(ActionArray(DoPosition)\Action()\Parameters, #Undo)
					Case #Action_RemoveFolder
						Action_AddFolder(ActionArray(DoPosition)\Action()\Parameters, #Undo)
					Case #Action_MoveAsset
						Action_MoveAsset(ActionArray(DoPosition)\Action()\Parameters, #Undo)
				EndSelect
			Until Not PreviousElement(ActionArray(DoPosition)\Action())
			UITK::Freeze(MainWindow::Library, #False)
		EndIf
	EndProcedure
	
	Procedure Redo()
		If RedoCount
			UITK::Freeze(MainWindow::Library, #True)
			ForEach ActionArray(DoPosition)\Action()
				Select ActionArray(DoPosition)\Action()\Type
					Case #Action_AddAsset
						Action_AddAsset(ActionArray(DoPosition)\Action()\Parameters, #Redo)
					Case #Action_RemoveAsset
						Action_RemoveAsset(ActionArray(DoPosition)\Action()\Parameters, #Redo)
					Case #Action_AddFolder
						Action_AddFolder(ActionArray(DoPosition)\Action()\Parameters, #Redo)
					Case #Action_RemoveFolder
						Action_RemoveFolder(ActionArray(DoPosition)\Action()\Parameters, #Redo)
					Case #Action_MoveAsset
						Action_MoveAsset(ActionArray(DoPosition)\Action()\Parameters, #Redo)
				EndSelect
			Next
			UITK::Freeze(MainWindow::Library, #False)
			
			DoPosition = (DoPosition + 1) % #MaximumUndo
			DoCount + 1
			RedoCount - 1
		EndIf
	EndProcedure
	;}
	
	;{ Assets
	Procedure AddAsset(Assets.s)
		Protected Loop, Count, File.s, Extension.s, ExistingFile
		Protected Image, Result
		
		ClearList(ActionArray(DoPosition)\Action())
		
		Count = CountString(Assets, #LF$) + 1
		UITK::Freeze(MainWindow::Library, #True)
		For Loop = 1 To Count
			File = StringField(Assets, Loop, #LF$)
			Extension = LCase(GetExtensionPart(File))
			
			Select Extension
				Case "jpg", "jpeg", "png", "bmp" ;{
					TestForExistingFile(#Media)
					Prepare_AddAsset(GetFilePart(File, #PB_FileSystem_NoExtension), #Asset_Image, File)
					;}
				Case "mp4", "mkv";{
					TestForExistingFile(#Media)
					Prepare_AddAsset(GetFilePart(File, #PB_FileSystem_NoExtension), #Asset_Video, File)
					;}
			EndSelect
			
		Next
		
		If ListSize(ActionArray(DoPosition)\Action())
			DoPosition = (DoPosition + 1) % #MaximumUndo
			If DoCount < #MaximumUndo - 1
				DoCount + 1
			EndIf
		EndIf	
		
		UITK::Freeze(MainWindow::Library, #False)
	EndProcedure
	
	Procedure RemoveAsset()
		Protected *Asset.Asset = GetGadgetItemData(MainWindow::Library, GetGadgetState(MainWindow::Library))
		
		ClearList(ActionArray(DoPosition)\Action())
		
		Prepare_RemoveAsset(*Asset\Name, *Asset\Type, *Asset\Path, *Asset\UUID, *Asset\Folder\UUID)
		
		If ListSize(ActionArray(DoPosition)\Action())
			DoPosition = (DoPosition + 1) % #MaximumUndo
			If DoCount < #MaximumUndo - 1
				DoCount + 1
			EndIf
		EndIf	
	EndProcedure
	
	Procedure MoveAsset(*Asset.Asset, *Folder.AssetFolder)
		ClearList(ActionArray(DoPosition)\Action())
		
		Prepare_MoveAsset(*Asset\UUID, *Folder\UUID, *Asset\Folder\UUID, MainWindow::TabState)
		
		If ListSize(ActionArray(DoPosition)\Action())
			DoPosition = (DoPosition + 1) % #MaximumUndo
			If DoCount < #MaximumUndo - 1
				DoCount + 1
			EndIf
		EndIf
	EndProcedure
	
	Procedure AddFolder()
		Protected Action.Action_AddRemoveFolder, Json
		Protected GadgetState = GetGadgetState(MainWindow::Tree), *ParentFolder.AssetFolder = GetGadgetItemData(MainWindow::Tree, GadgetState), Depth = GetGadgetItemAttribute(MainWindow::Tree, GadgetState, UITK::#Attribute_Tree_ItemDepth), Loop, ItemCount = CountGadgetItems(MainWindow::Tree)
		
		Action\Name = InputRequester(General::#AppName, "New folder name:", "New Folder")
		Action\Parent = *ParentFolder\UUID
		Action\ParentPosition = ListSize(*ParentFolder\Childrens())
		Action\Type = MainWindow::TabState
		Action\UUID = UUID()
		
		For Loop = GadgetState + 1 To ItemCount
			If GetGadgetItemAttribute(MainWindow::Tree, Loop, UITK::#Attribute_Tree_ItemDepth) <= Depth
				Break
			EndIf
		Next
		
		Action\Position = Loop
		Action\Depth = Depth + 1
		
		Json = CreateJSON(#PB_Any)
		InsertJSONStructure(JSONValue(Json), @Action, Action_AddRemoveFolder)
		
		ClearList(ActionArray(DoPosition)\Action())
		
		AddElement(ActionArray(DoPosition)\Action())
		ActionArray(DoPosition)\Action()\Type = #Action_AddFolder
		ActionArray(DoPosition)\Action()\Parameters = ComposeJSON(Json)
		
		FreeJSON(Json)
		
		Action_AddFolder(ActionArray(DoPosition)\Action()\Parameters, #Null)
		
		DoPosition = (DoPosition + 1) % #MaximumUndo
		If DoCount < #MaximumUndo - 1
			DoCount + 1
		EndIf
		
	EndProcedure
	
	Procedure RemoveFolder()
		Protected *Folder.AssetFolder = GetGadgetItemData(MainWindow::Tree, GetGadgetState(MainWindow::Tree))
		
		ClearList(ActionArray(DoPosition)\Action())
		
		Prepare_RemoveFolder(*Folder\UUID)
		
		DoPosition = (DoPosition + 1) % #MaximumUndo
		If DoCount < #MaximumUndo - 1
			DoCount + 1
		EndIf
		
	EndProcedure
	
	Procedure RenameFolder()
; 		Protected Action.Action_AddRemoveFolder, Json
	EndProcedure
	;}
	
	;{ Timeline
	Procedure AddLine()
		Debug "add"
	EndProcedure
	
	Procedure RemoveLine()
		Debug "remove"
	EndProcedure
	;}
	;}
	
	;{ Private procedures
	;{ Misc
	Procedure ResizePreview(Image)
		Protected FinalImage, OriginalWidth, OriginalHeight, ImageWidth, ImageHeight
		
		OriginalWidth = ImageWidth(Image)
		OriginalHeight = ImageHeight(Image)
		FinalImage = CreateImage(#PB_Any, 160, 90, 24, #Black)
		
		If OriginalWidth <= 160 And OriginalHeight <= 90
			ImageWidth = OriginalWidth
			ImageHeight = OriginalHeight
		Else
			If Round(OriginalWidth / 160, #PB_Round_Nearest) < Round(OriginalHeight / 90, #PB_Round_Nearest)
				ImageWidth = General::Max(1, Round(90 / OriginalHeight * OriginalWidth, #PB_Round_Nearest))
				ImageHeight = General::Min(90, OriginalHeight)
			Else
				ImageWidth = General::Min(160, OriginalWidth)
				ImageHeight = General::Max(1, Round(160 / OriginalWidth * OriginalHeight, #PB_Round_Nearest))
			EndIf
			ResizeImage(Image, ImageWidth, ImageHeight, #PB_Image_Smooth)
		EndIf
		
		StartVectorDrawing(ImageVectorOutput(FinalImage))
		MovePathCursor((160 - ImageWidth) * 0.5, (90 - ImageHeight) * 0.5)
		DrawVectorImage(ImageID(Image))
		AddPathBox(0, 0, 160, 90)
		UITK::AddPathRoundedBox(0, 0, 160, 90, 5)
		VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Gadget_BackCold), 255))
		FillPath()
		StopVectorDrawing()
		FreeImage(Image)
		
		ProcedureReturn FinalImage
	EndProcedure
	
	Procedure.s UUID()
		Protected Index, Byte.a, UUID_String.s
		For Index = 0 To 15
			
			If Index = 7 
				Byte = 64 + Random(15)
			ElseIf Index = 9
				Byte = 128 + Random(63)
			Else
				Byte = Random(255)
			EndIf
			
			If Index = 4 Or Index = 6 Or Index = 8 Or Index = 10
				UUID_String + "-"
			EndIf
			
			UUID_String + RSet(Hex(Byte, #PB_Ascii), 2, "0")
		Next
		
		ProcedureReturn UUID_String
	EndProcedure
	;}
	
	; Action
	;{ Asset
	Procedure Prepare_AddAsset(Name.s, Type, Path.s)
		Protected Action.Action_AddRemoveAsset, Json, *Folder.AssetFolder
		RedoCount = 0
		
		Select Type
			Case #Asset_Image
				SelectElement(Project\FoldersStructure[#Media]\List(), 1)
				*Folder = Project\FoldersStructure[#Media]\List()
			Case #Asset_Video
				FirstElement(Project\FoldersStructure[#Media]\List())
				*Folder = Project\FoldersStructure[#Media]\List()
			Default
				Debug "Unsupported type!"
		EndSelect
		
		If MainWindow::*CurrentFolder\Type = Type
			*Folder = MainWindow::*CurrentFolder
		EndIf
		
		Action\Name = Name
		Action\Type = Type
		Action\Path = Path
		Action\UUID = UUID()
		Action\FolderUUID = *Folder\UUID
		
		Json = CreateJSON(#PB_Any)
		InsertJSONStructure(JSONValue(Json), @Action, Action_AddRemoveAsset)
		
		AddElement(ActionArray(DoPosition)\Action())
		ActionArray(DoPosition)\Action()\Type = #Action_AddAsset
		ActionArray(DoPosition)\Action()\Parameters = ComposeJSON(Json)
		
		FreeJSON(Json)
		
		Action_AddAsset(ActionArray(DoPosition)\Action()\Parameters, #Null)
	EndProcedure
	
	Procedure Prepare_RemoveAsset(Name.s, Type, Path.s, UUID.s, FolderUUID.s)
		Protected Action.Action_AddRemoveAsset, Json
		RedoCount = 0
		
		Action\Name = Name
		Action\Type = Type
		Action\Path = Path
		Action\UUID = UUID
		Action\FolderUUID = FolderUUID
		
		Json = CreateJSON(#PB_Any)
		InsertJSONStructure(JSONValue(Json), @Action, Action_AddRemoveAsset)
		
		AddElement(ActionArray(DoPosition)\Action())
		ActionArray(DoPosition)\Action()\Type = #Action_RemoveAsset
		ActionArray(DoPosition)\Action()\Parameters = ComposeJSON(Json)
		
		FreeJSON(Json)
		
		Action_RemoveAsset(ActionArray(DoPosition)\Action()\Parameters, #Null)
	EndProcedure
	
	Procedure Prepare_RemoveFolder(UUID.s)
		Protected Action.Action_AddRemoveFolder, Json, *Folder.AssetFolder, Loop, ItemCount = CountGadgetItems(MainWindow::Tree) - 1
		
		*Folder = FindMapElement(Project\Folders[MainWindow::TabState]\Map(), UUID)
		
		Action\UUID = UUID
		Action\Type = MainWindow::TabState
		Action\Name = *Folder\Name
		Action\Parent = *Folder\Parent\UUID
		
		For Loop = 1 To ItemCount
			If GetGadgetItemData(MainWindow::Tree, Loop) = *Folder
				Action\Position = Loop
				Break
			EndIf
		Next
		
		ForEach *Folder\Parent\Childrens()
			If *Folder\Parent\Childrens() = *Folder
				Action\ParentPosition = ListIndex(*Folder\Parent\Childrens())
				Break
			EndIf
		Next
		
		Action\Depth = GetGadgetItemAttribute(MainWindow::Tree, Action\Position, UITK::#Attribute_Tree_ItemDepth)
		
		ForEach Project\Assets[Action\Type]\Map()
			If Project\Assets[Action\Type]\Map()\Folder = *Folder
				Prepare_RemoveAsset(Project\Assets[Action\Type]\Map()\Name,
				                    Project\Assets[Action\Type]\Map()\Type,
				                    Project\Assets[Action\Type]\Map()\Path,
				                    Project\Assets[Action\Type]\Map()\UUID,
				                    *Folder\UUID)
			EndIf
		Next
		
		ForEach *Folder\Childrens()
			Prepare_RemoveFolder(*Folder\Childrens()\UUID)
		Next
		
		Json = CreateJSON(#PB_Any)
		InsertJSONStructure(JSONValue(Json), @Action, Action_AddRemoveFolder)
		
		AddElement(ActionArray(DoPosition)\Action())
		ActionArray(DoPosition)\Action()\Type = #Action_RemoveFolder
		ActionArray(DoPosition)\Action()\Parameters = ComposeJSON(Json)
		
		FreeJSON(Json)
		
		Action_RemoveFolder(ActionArray(DoPosition)\Action()\Parameters, #Null)
		
	EndProcedure
	
	Procedure Prepare_MoveAsset(Asset.s, NewFolder.s, OldFolder.s, Type.i)
		Protected Json, Action.Action_MoveAsset
		
		Action\Asset = Asset
		Action\NewFolder = NewFolder
		Action\OldFolder = OldFolder
		Action\Type = Type
		
		Json = CreateJSON(#PB_Any)
		InsertJSONStructure(JSONValue(Json), @Action, Action_MoveAsset)
		AddElement(ActionArray(DoPosition)\Action())
		ActionArray(DoPosition)\Action()\Type = #Action_MoveAsset
		ActionArray(DoPosition)\Action()\Parameters = ComposeJSON(Json)
		FreeJSON(Json)
		
		Action_MoveAsset(ActionArray(DoPosition)\Action()\Parameters, #Redo)
	EndProcedure
	
	Procedure Action_AddAsset(Parameters.s, Mode.b)
		Protected Action.Action_AddRemoveAsset, Json, Image, *Asset.Asset, Type
		Json = ParseJSON(#PB_Any, Parameters)
		
		ExtractJSONStructure(JSONValue(Json), @Action, Action_AddRemoveAsset)
		FreeJSON(Json)
		
		Select Action\Type
			Case #Asset_Image	
				Image = LoadImage(#PB_Any, Action\Path)
			Default
				Image = CreateImage(#PB_Any, 160, 90, 24, #Black)
		EndSelect
		
		Image = ResizePreview(Image)
		
		Select Action\Type
			Case #Asset_Image, #Asset_Video
				Type = #Media
			Default
				Debug "Unsupported type!"
		EndSelect
		
		*Asset = AddMapElement(Project\Assets[Type]\Map(), Action\UUID)
		*Asset\Name = Action\Name
		*Asset\PreviewImage = Image
		*Asset\Type = Action\Type
		*Asset\Path = Action\Path
		*Asset\UUID = Action\UUID
		*Asset\Folder = FindMapElement(Project\Folders[Type]\Map(), Action\FolderUUID)
		
		If MainWindow::*CurrentFolder = *Asset\Folder
			SetGadgetItemData(MainWindow::Library, AddGadgetItem(MainWindow::Library, -1, *Asset\Name, ImageID(*Asset\PreviewImage), 0), *Asset)
		EndIf
	EndProcedure
	
	Procedure Action_RemoveAsset(Parameters.s, Mode.b)
		Protected Action.Action_AddRemoveAsset, Json, Image, AssetType, Loop, ItemCount, *Adress
		Json = ParseJSON(#PB_Any, Parameters)
		
		ExtractJSONStructure(JSONValue(Json), @Action, Action_AddRemoveAsset)
		FreeJSON(Json)
		
		Select Action\Type
			Case #Asset_Image, #Asset_Video
				AssetType = #Media
		EndSelect
		
		*Adress = FindMapElement(Project\Assets[AssetType]\Map(), Action\UUID)
		FreeImage(Project\Assets[AssetType]\Map()\PreviewImage)
		DeleteMapElement(Project\Assets[AssetType]\Map())
		
		If GetGadgetState(MainWindow::Tab) = AssetType
			ItemCount = CountGadgetItems(MainWindow::Library) - 1
			For Loop = 0 To ItemCount
				If *Adress = GetGadgetItemData(MainWindow::Library, Loop)
					RemoveGadgetItem(MainWindow::Library, Loop)
					Break
				EndIf
			Next
		EndIf
	EndProcedure
	
	Procedure Action_AddFolder(Parameters.s, Mode.b)
		Protected Action.Action_AddRemoveFolder, Json, *ParentFolder.AssetFolder, *NewFolder.AssetFolder
		Json = ParseJSON(#PB_Any, Parameters)
		
		ExtractJSONStructure(JSONValue(Json), @Action, Action_AddRemoveFolder)
		FreeJSON(Json)
		
		*ParentFolder = FindMapElement(Project\Folders[Action\Type]\Map(), Action\Parent)
		*NewFolder = AddMapElement(Project\Folders[Action\Type]\Map(), Action\UUID)
		
		*NewFolder\Name = Action\Name
		*NewFolder\Parent = *ParentFolder
		*NewFolder\UUID = Action\UUID
		*NewFolder\Type = *ParentFolder\Type
		
		If Action\ParentPosition >= ListSize(*ParentFolder\Childrens())
			LastElement(*ParentFolder\Childrens())
			AddElement(*ParentFolder\Childrens())
		Else
			SelectElement(*ParentFolder\Childrens(), Action\ParentPosition)
			InsertElement(*ParentFolder\Childrens())
		EndIf
		
		*ParentFolder\Childrens() = *NewFolder
		
		If MainWindow::TabState = Action\Type
			SetGadgetItemData(MainWindow::Tree, AddGadgetItem(MainWindow::Tree, Action\Position, *NewFolder\Name, 0, Action\Depth), *NewFolder)
			
			If MainWindow::*CurrentFolder = *NewFolder\Parent
				AddGadgetItem(MainWindow::Library, Action\ParentPosition, *NewFolder\Name, MainWindow::IconFolder, 0)
			EndIf
		EndIf
		
	EndProcedure
	
	Procedure Action_RemoveFolder(Parameters.s, Mode.b)
		Protected Action.Action_AddRemoveFolder, Json, *ParentFolder.AssetFolder
		Json = ParseJSON(#PB_Any, Parameters)
		
		ExtractJSONStructure(JSONValue(Json), @Action, Action_AddRemoveFolder)
		FreeJSON(Json)
		
		*ParentFolder = FindMapElement(Project\Folders[Action\Type]\Map(), Action\Parent)
		SelectElement(*ParentFolder\Childrens(), Action\ParentPosition)
		DeleteElement(*ParentFolder\Childrens())
		DeleteMapElement(Project\Folders[Action\Type]\Map(), Action\UUID)
		
		If MainWindow::TabState = Action\Type
			RemoveGadgetItem(MainWindow::Tree, Action\Position)
			
			If MainWindow::*CurrentFolder = *ParentFolder
				RemoveGadgetItem(MainWindow::Library, Action\ParentPosition)
			EndIf
		EndIf
		
	EndProcedure
	
	Procedure Action_MoveAsset(Parameters.s, Mode.b)
		Protected Action.Action_MoveAsset, Json, *Folder.AssetFolder, *Asset.Asset, Loop, ItemCount
		
		Json = ParseJSON(#PB_Any, Parameters)
		
		ExtractJSONStructure(JSONValue(Json), @Action, Action_MoveAsset)
		FreeJSON(Json)
		
		If Mode = #Redo
			*Folder = FindMapElement(Project\Folders[Action\Type]\Map(), Action\NewFolder)
		Else
			*Folder = FindMapElement(Project\Folders[Action\Type]\Map(), Action\OldFolder)
		EndIf
		*Asset = FindMapElement(Project\Assets[Action\Type]\Map(), Action\Asset)
		
		If *Asset\Folder = MainWindow::*CurrentFolder
			ItemCount = CountGadgetItems(MainWindow::Library) - 1
			For Loop = 0 To ItemCount
				If *Asset = GetGadgetItemData(MainWindow::Library, Loop)
					RemoveGadgetItem(MainWindow::Library, Loop)
					Break
				EndIf
			Next
		EndIf
		
		*Asset\Folder = *Folder
		
		If *Asset\Folder = MainWindow::*CurrentFolder
			SetGadgetItemData(MainWindow::Library, AddGadgetItem(MainWindow::Library, -1, *Asset\Name, ImageID(*Asset\PreviewImage), 0), *Asset)
		EndIf
	EndProcedure
	;}
	
	;{ Timeline
	Procedure Action_AddLine(Parameters.s)
		
	EndProcedure
	
	Procedure Action_RemoveLine(Parameters.s)
		
	EndProcedure
	;}
	;}
	
	DataSection
		LibraryImage:
		IncludeBinary "../Media/Library-Image.png"
		LibraryVideo:
		IncludeBinary "../Media/Library-Video.png"
	EndDataSection
EndModule







































; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 92
; Folding = DAhAgIAw
; EnableXP
; DPIAware