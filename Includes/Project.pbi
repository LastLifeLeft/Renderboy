Module Project
	EnableExplicit
	;{ Private variables, structures, constants...
	Global TaskList
	
	Structure Asset
		Type.i
		UUID.s
		Path.s
		PreviewImage.i
		UsageCount.i
		Width.i
		Height.i
	EndStructure
	
	Structure AssetTypeLibrary
		*Asset.Asset
	EndStructure
	
	Structure Task
		XMLID.i
		XML.s
	EndStructure
	
	Enumeration ; Fixed assets
		#Effect2D_Blur
		#Effect2D_Tiled
		#Effect2D_FadeIn
		#Effect2D_FadeOut
		
		#Overlay_Text
	EndEnumeration
	
	Prototype Delete(UUID.s)
	Prototype Add(Path.s, Image, UUID.s)
	
	Structure AssetProcedure
		Add.Add
	EndStructure
	
	#_Add = 0
	#_Delete = 1
	
	; 	Global Dim AssetLibrary.AssetLibrary(5)
	Global NewMap AssetLibrary.Asset(2048)
	Global NewMap AssetLibrary_Media.AssetTypeLibrary(2048)
	Global NewMap AssetLibrary_Elements.AssetTypeLibrary(2048)
	Global NewMap AssetLibrary_Overlay.AssetTypeLibrary(2048)
	Global Dim AssetProcedures.AssetProcedure(#__Asset_Type_Count)
	
	;Tasks
	#AddAsset = "AddAsset"
	#DeleteAsset = "DeleteAsset"
	;}
	
	;{ Private procedures declaration
	; Add Assets
	Declare _AddImage(Path.s, PreviewImage, UUID.s)
	Declare _AddVideo(Path.s, PreviewImage, UUID.s)
	Declare _AddSound(Path.s, PreviewImage, UUID.s)
	Declare _AddModel(Path.s, PreviewImage, UUID.s)
	Declare _AddOverlay(Path.s, PreviewImage, UUID.s)
	Declare _AddElement(Path.s, PreviewImage, UUID.s)
	
	; Delete Assets
	Declare _DeleteAsset(UUID.s)
	
	AssetProcedures(#Asset_Type_Image)\Add = @_AddImage()
	AssetProcedures(#Asset_Type_Video)\Add = @_AddVideo()
	AssetProcedures(#Asset_Type_Sound)\Add = @_AddSound()
	AssetProcedures(#Asset_Type_Music)\Add = @_AddSound()
	AssetProcedures(#Asset_Type_Voice)\Add = @_AddSound()
	AssetProcedures(#Asset_Type_Model)\Add = @_AddModel()
	AssetProcedures(#Asset_Type_Character)\Add = @_AddModel()
	
	; Misc
	Declare HandlerUndoRedo(*Task.Task, Redo)
	;}
	
	_AddElement("Tiled", CatchImage(#PB_Any, ?Tiled), Str(#Effect2D_Tiled))
	_AddElement("Blur", CatchImage(#PB_Any, ?Blur), Str(#Effect2D_Blur))
	_AddElement("Fade In", CatchImage(#PB_Any, ?FadeIn), Str(#Effect2D_FadeIn))
	_AddElement("Fade Out", CatchImage(#PB_Any, ?FadeOut), Str(#Effect2D_FadeOut))
	
 	_AddOverlay("Text", CatchImage(#PB_Any, ?Text), Str(#Overlay_Text))
	
	;{ Public procedures
	Procedure New()
		TaskList = TaskList::Create()
		PureTL::SetTaskList(0, TaskList)
	EndProcedure
	
	Procedure Load(File.s)
	
	EndProcedure
	
	Procedure Save()
	
	EndProcedure
	
	Procedure Export()
	
	EndProcedure
	
	Procedure Archive()
		
	EndProcedure
	
	Procedure AddAsset(Asset.s)
		Protected Count = CountString(Asset, #LF$) + 1, Loop, Extension.s, Path.s, Image
		Protected *Task.Task = AllocateStructure(Task), UUID.s, MainNode, Item
		
		*Task\XMLID = CreateXML(#PB_Any)
 		MainNode = CreateXMLNode(RootXMLNode(*Task\XMLID), "Tasks") 
		
		For Loop = 1 To Count
			Path = StringField(Asset, Loop, #LF$)
			Extension.s = LCase(GetExtensionPart(Path))
			
			Select Extension
				Case "png", "bmp", "jpg"
					
					Image = LoadImage(#PB_Any, Path)
					
					If Image
						UUID.s = General::UUID()
						Item = CreateXMLNode(MainNode, #AddAsset)
						SetXMLAttribute(Item, "Type", Str(#Asset_Type_Image))
						SetXMLAttribute(Item, "UUID", UUID)
						SetXMLAttribute(Item, "Path", Path)
						
						_AddImage(Path.s, Image, UUID.s)
					EndIf
				Case "mp4", "mkv"
					
				Case "mp3", "wave"
					
				Default
					
			EndSelect
		Next
		
		If XMLChildCount(MainNode)
			
			*Task\XML = ComposeXML(*Task\XMLID, #PB_XML_NoDeclaration)
			FreeXML(*Task\XMLID)
			TaskList::NewTask(TaskList, *Task, @HandlerUndoRedo())
		Else
			FreeStructure(*Task)
		EndIf
		
	EndProcedure
	
	Procedure DeleteAsset(UUID.s)
		Protected *Task.Task = AllocateStructure(Task), MainNode, Item, MediaBlocks.s
		Protected *DeletionProcedure
		
		*Task\XMLID = CreateXML(#PB_Any)
 		MainNode = CreateXMLNode(RootXMLNode(*Task\XMLID), "Tasks") 
 		Item = CreateXMLNode(MainNode, #DeleteAsset)
 		FindMapElement(AssetLibrary(), UUID)
 		
 		If AssetLibrary()\UsageCount
 			; Delete any mediablock using this asset
 			MediaBlocks = PureTL::DeleteMediaBlockByAsset(MainWindow::#TimeLine, UUID)
 		EndIf
 		
 		FindMapElement(AssetLibrary(), UUID)
 		
 		SetXMLAttribute(Item, "Type", Str(AssetLibrary()\Type))
 		SetXMLAttribute(Item, "UUID", UUID)
 		SetXMLAttribute(Item, "MediaBlocks", MediaBlocks)
 		SetXMLAttribute(Item, "Path", AssetLibrary()\Path)
 		
 		*Task\XML = ComposeXML(*Task\XMLID, #PB_XML_NoDeclaration)
 		FreeXML(*Task\XMLID)
 		TaskList::NewTask(TaskList, *Task, @HandlerUndoRedo())
 		
 		_DeleteAsset(UUID)
	EndProcedure
	
	Procedure Undo()
		TaskList::Undo(TaskList)
	EndProcedure
	
	Procedure Redo()
		TaskList::Redo(TaskList)
	EndProcedure
	
	Procedure AssetUse(UUID.s)
		AssetLibrary(UUID)\UsageCount + 1
	EndProcedure
	
	Procedure AssetUnUse(UUID.s)
		AssetLibrary(UUID)\UsageCount - 1
	EndProcedure
	
	; Library
	Procedure RePopulateMediaLibrary()
		ForEach AssetLibrary_Media()
			MainWindow::AddAssetButton(AssetLibrary_Media()\Asset\Type, AssetLibrary_Media()\Asset\PreviewImage, GetFilePart(AssetLibrary_Media()\Asset\Path, #PB_FileSystem_NoExtension), AssetLibrary_Media()\Asset\UUID)
		Next
	EndProcedure
	
	Procedure RePopulateElementLibrary()
		ForEach AssetLibrary_Elements()
			MainWindow::AddAssetButton(AssetLibrary_Elements()\Asset\Type, AssetLibrary_Elements()\Asset\PreviewImage, GetFilePart(AssetLibrary_Elements()\Asset\Path, #PB_FileSystem_NoExtension), AssetLibrary_Elements()\Asset\UUID)
		Next
	EndProcedure
	
	Procedure RePopulateOverlayLibrary()
		ForEach AssetLibrary_Overlay()
			MainWindow::AddAssetButton(AssetLibrary_Overlay()\Asset\Type, AssetLibrary_Overlay()\Asset\PreviewImage, GetFilePart(AssetLibrary_Overlay()\Asset\Path, #PB_FileSystem_NoExtension), AssetLibrary_Overlay()\Asset\UUID)
		Next
	EndProcedure
	
	; Get
	Procedure.s GetAssetName(UUID.s)
		Protected Result.s
		
		Result = GetFilePart(AssetLibrary(UUID)\Path, #PB_FileSystem_NoExtension)
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure GetAssetType(UUID.s)
		ProcedureReturn AssetLibrary(UUID)\Type
	EndProcedure
	
	Procedure.s GetAssetPath(UUID.s)
		ProcedureReturn AssetLibrary(UUID)\Path
	EndProcedure
	
	Procedure GetAssetWidth(UUID.s)
		ProcedureReturn AssetLibrary(UUID)\Width
	EndProcedure
	
	Procedure GetAssetHeight(UUID.s)
		ProcedureReturn AssetLibrary(UUID)\Height
	EndProcedure
	
	Procedure.s GetAssetDefaultState(UUID.s)
		Protected Result.s, State.PureTL::DataPoint, Json
		FindMapElement(AssetLibrary(), UUID)
		
		Select AssetLibrary()\Type
			Case #Asset_Type_Image
				State\x = Round(AssetLibrary()\Width * 0.5, #PB_Round_Down)
				State\y = Round(AssetLibrary()\Height * 0.5, #PB_Round_Down)
				State\width = AssetLibrary()\Width
				State\height = AssetLibrary()\height
				State\Transparency = 1
			Case #Asset_Type_Video
			Case #Asset_Type_Sound
			Case #Asset_Type_Music
			Case #Asset_Type_Voice
			Case #Asset_Type_Character
			Case #Asset_Type_Model
				
		EndSelect
		
		Json = CreateJSON(#PB_Any)
		InsertJSONStructure(JSONValue(Json), @State, PureTL::DataPoint)
		Result = ComposeJSON(Json)
		FreeJSON(Json)
		
		ProcedureReturn Result
	EndProcedure
	; Set
	
	;}
	
	;{ Private procedures
	; Add Assets
	Procedure _AddImage(Path.s, Image, UUID.s)
		Protected *Asset.Asset
		If Image = 0
			Image = LoadImage(#PB_Any, Path)
		EndIf
		
		*Asset = AddMapElement(AssetLibrary(), UUID)
		*Asset\Width = ImageWidth(Image)
		*Asset\Height = ImageHeight(Image)
		
		If *Asset\Width <> 160 Or *Asset\Height <> 90
			General::ResizeImageEx(Image, 160, 90, General::#PB_Image_KeepAspectRatio)
		EndIf
		
		*Asset\UUID = UUID
		*Asset\Type = #Asset_Type_Image
		*Asset\Path = Path
		*Asset\PreviewImage = Image
		
		AddMapElement(AssetLibrary_Media(), UUID)
		AssetLibrary_Media()\Asset = *Asset
		
		MainWindow::AddAssetButton(#Asset_Type_Image, Image, GetFilePart(*Asset\Path, #PB_FileSystem_NoExtension), *Asset\UUID)
	EndProcedure
	
	Procedure _AddVideo(Path.s, Image, UUID.s)
		
	EndProcedure
	
	Procedure _AddSound(Path.s, Image, UUID.s)
		
	EndProcedure
	
	Procedure _AddModel(Path.s, Image, UUID.s)
		
	EndProcedure
	
	Procedure _AddOverlay(Path.s, Image, UUID.s)
		Protected *Asset.Asset
		
		*Asset = AddMapElement(AssetLibrary(), UUID)
		*Asset\Width = -1
		*Asset\Height = -1
		
		*Asset\UUID = UUID
		*Asset\Type = #Asset_Type_Overlay
		*Asset\Path = Path
		*Asset\PreviewImage = Image
		
		AddMapElement(AssetLibrary_Overlay(), UUID)
		AssetLibrary_Overlay()\Asset = *Asset
	EndProcedure
	
	Procedure _AddElement(Path.s, Image, UUID.s)
		Protected *Asset.Asset
		
		*Asset = AddMapElement(AssetLibrary(), UUID)
		*Asset\Width = 100
		*Asset\Height = 100
		
		*Asset\UUID = UUID
		*Asset\Type = #Asset_Type_2DEffect
		*Asset\Path = Path
		*Asset\PreviewImage = Image
		
		AddMapElement(AssetLibrary_Elements(), UUID)
		AssetLibrary_Elements()\Asset = *Asset
	EndProcedure
	
	; Delete Assets
	
	Procedure _DeleteAsset(UUID.s)
		FindMapElement(AssetLibrary(), UUID)
		
		Select AssetLibrary()\Type
			Case #Asset_Type_Image, #Asset_Type_Video
				DeleteMapElement(AssetLibrary_Media(), UUID)
		EndSelect
		
		FreeImage(AssetLibrary()\PreviewImage)
		MainWindow::DeleteAssetButton(UUID)
		DeleteMapElement(AssetLibrary())
	EndProcedure
	
	; Misc
	Procedure HandlerUndoRedo(*Task.Task, Redo)
		Protected XML = ParseXML(#PB_Any, *Task\XML), TaskNode = ChildXMLNode(RootXMLNode(XML)), TaskCount = XMLChildCount(TaskNode), Task
		Protected Loop, SubTaskCount, SubLoop, MediaBlocks.s, *MediaBLock.Task
		
		If Redo ;{ Redo
			For Loop = 1 To TaskCount
				Task = ChildXMLNode(TaskNode, Loop)
				Select GetXMLNodeName(Task)
					Case #AddAsset ;{
						AssetProcedures(Val(GetXMLAttribute(Task, "Type")))\Add(GetXMLAttribute(Task, "Path"), 0, GetXMLAttribute(Task, "UUID"))
						;}
					Case #DeleteAsset ;{
						_DeleteAsset(GetXMLAttribute(Task, "UUID"))
						MediaBlocks = GetXMLAttribute(Task, "MediaBlocks")
						
						If MediaBlocks
							*MediaBLock = AllocateStructure(Task)
							*MediaBLock\XML = MediaBlocks
							
							PureTL::Handler_UndoRedo(*MediaBLock, #True)
						EndIf
						;}
				EndSelect
			Next
			;}
		Else ;{ Undo
			For Loop = TaskCount To 1 Step -1
				Task = ChildXMLNode(TaskNode, Loop)
				Select GetXMLNodeName(Task)
					Case #AddAsset ;{
						_DeleteAsset(GetXMLAttribute(Task, "UUID"))
						;}
					Case #DeleteAsset ;{
						MediaBlocks = GetXMLAttribute(Task, "MediaBlocks")
						
						If MediaBlocks
							*MediaBLock = AllocateStructure(Task)
							*MediaBLock\XML = MediaBlocks
							
							PureTL::Handler_UndoRedo(*MediaBLock, #False)
						EndIf
						AssetProcedures(Val(GetXMLAttribute(Task, "Type")))\Add(GetXMLAttribute(Task, "Path"), 0, GetXMLAttribute(Task, "UUID"))
						
						;}
				EndSelect
			Next
			;}
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	;}
	
	DataSection
		
		Blur:
		IncludeBinary "..\Media\Asset icons\Blur.png"
		
		FadeIn:
		IncludeBinary "..\Media\Asset icons\Fade In.png"
		
		FadeOut:
		IncludeBinary "..\Media\Asset icons\Fade Out.png"
		
		Tiled:
		IncludeBinary "..\Media\Asset icons\Tiled.png"
		
		Text:
		IncludeBinary "..\Media\Asset icons\Text.png"
	EndDataSection
EndModule
; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 204
; FirstLine = 112
; Folding = PAwABB7
; EnableXP