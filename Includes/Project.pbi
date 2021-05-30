Module Project
	EnableExplicit
	;{ Private variables, structures, constants...
	Global TaskList
	
	Structure Asset
		Type.i
		UUID.s
		Path.s
		Image.i
		UsageCount.i
	EndStructure
	
	Structure Task
		XMLID.i
		XML.s
	EndStructure
	
	Structure AssetLibrary
		Map ProjectAssets.Asset(2048)
		Map LibraryAsset.Asset(2048)
	EndStructure
	
	Prototype Delete(UUID.s)
	Prototype Add(Path.s, Image, UUID.s)
	
	Structure AssetProcedure
		Add.Add
		Delete.Delete
	EndStructure
		
	Enumeration
		#Asset_Media
		#Asset_Sound
		#Asset_Model
		#Asset_Overlay
		#Asset_Element
	EndEnumeration
	
	#_Add = 0
	#_Delete = 1
	
	Global Dim AssetLibrary.AssetLibrary(5)
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
	Declare _DeleteImage(UUID.s)
	
	AssetProcedures(#Asset_Type_Image)\Add = @_AddImage()
	AssetProcedures(#Asset_Type_Video)\Add = @_AddVideo()
	AssetProcedures(#Asset_Type_Sound)\Add = @_AddSound()
	AssetProcedures(#Asset_Type_Music)\Add = @_AddSound()
	AssetProcedures(#Asset_Type_Voice)\Add = @_AddSound()
	AssetProcedures(#Asset_Type_Model)\Add = @_AddModel()
	AssetProcedures(#Asset_Type_Character)\Add = @_AddModel()
	
	AssetProcedures(#Asset_Type_Image)\Delete = @_DeleteImage()
	
	; Misc
	Declare HandlerUndoRedo(*Task.Task, Redo)
	;}
	
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
						SetXMLAttribute(Item, "Asset", Str(#Asset_Media))
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
	
	Procedure DeleteAsset(Type, UUID.s)
		Protected *Task.Task = AllocateStructure(Task), MainNode, Item, MediaBlocks.s
		Protected Asset, *DeletionProcedure
		
		Select Type
			Case #Asset_Type_Image, #Asset_Type_Video
				Asset = #Asset_Media
			Case #Asset_Type_Sound, #Asset_Type_Music, #Asset_Type_Voice
				Asset = #Asset_Sound
			Case #Asset_Type_Character, #Asset_Type_Model
				Asset = #Asset_Model
		EndSelect
		
		*Task\XMLID = CreateXML(#PB_Any)
 		MainNode = CreateXMLNode(RootXMLNode(*Task\XMLID), "Tasks") 
 		Item = CreateXMLNode(MainNode, #DeleteAsset)
 		FindMapElement(AssetLibrary(Asset)\ProjectAssets(), UUID)
 		
 		If AssetLibrary(Asset)\ProjectAssets()\UsageCount
 			; Delete any mediablock using this asset
 			MediaBlocks = PureTL::DeleteMediaBlockByAsset(MainWindow::#TimeLine, UUID)
 		EndIf
 		
 		SetXMLAttribute(Item, "Asset", Str(Asset))
 		SetXMLAttribute(Item, "Type", Str(Type))
 		SetXMLAttribute(Item, "UUID", UUID)
 		SetXMLAttribute(Item, "MediaBlocks", MediaBlocks)
 		SetXMLAttribute(Item, "Path", AssetLibrary(Asset)\ProjectAssets()\Path)
 		
 		*Task\XML = ComposeXML(*Task\XMLID, #PB_XML_NoDeclaration)
 		FreeXML(*Task\XMLID)
 		TaskList::NewTask(TaskList, *Task, @HandlerUndoRedo())
 		
 		AssetProcedures(Type)\Delete(UUID)
	EndProcedure
	
	Procedure Undo()
		TaskList::Undo(TaskList)
	EndProcedure
	
	Procedure Redo()
		TaskList::Redo(TaskList)
	EndProcedure
	
	Procedure AssetUse(Type, UUID.s)
		AssetLibrary(Type)\ProjectAssets(UUID)\UsageCount + 1
	EndProcedure
	
	Procedure AssetUnUse(Type, UUID.s)
		AssetLibrary(Type)\ProjectAssets(UUID)\UsageCount - 1
	EndProcedure
	
	; Get
	Procedure.s GetAssetName(UUID.s, Type)
		Protected Result.s
		
		Result = GetFilePart(AssetLibrary(Type)\ProjectAssets(UUID)\Path)
		
		ProcedureReturn Result
	EndProcedure
	; Set
	
	;}
	
	;{ Private procedures
	; Add Assets
	Procedure _AddImage(Path.s, Image, UUID.s)
		Protected *Asset.Asset
		If ImageWidth(Image) <> 160 Or ImageHeight(Image) <> 90
			General::ResizeImageEx(Image, 160, 90, General::#PB_Image_KeepAspectRatio)
		EndIf
		
		*Asset = AddMapElement(AssetLibrary(#Asset_Media)\ProjectAssets(), UUID)
		*Asset\UUID = UUID
		*Asset\Type = #Asset_Type_Image
		*Asset\Path = Path
		*Asset\Image = Image
		
		MainWindow::AddAssetButton(#Asset_Type_Image, Image, GetFilePart(*Asset\Path, #PB_FileSystem_NoExtension), *Asset\UUID)
	EndProcedure
	
	Procedure _AddVideo(Path.s, Image, UUID.s)
		
	EndProcedure
	
	Procedure _AddSound(Path.s, Image, UUID.s)
		
	EndProcedure
	
	Procedure _AddModel(Path.s, Image, UUID.s)
		
	EndProcedure
	
	Procedure _AddOverlay(Path.s, Image, UUID.s)
		
	EndProcedure
	
	Procedure _AddElement(Path.s, Image, UUID.s)
		
	EndProcedure
	
	; Delete Assets
	
	Procedure _DeleteImage(UUID.s)
		FindMapElement(AssetLibrary(#Asset_Media)\ProjectAssets(), UUID)
		FreeImage(AssetLibrary(#Asset_Media)\ProjectAssets()\Image)
		DeleteMapElement(AssetLibrary(#Asset_Media)\ProjectAssets())
		MainWindow::DeleteAssetButton(#Asset_Media, UUID)
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
						AssetProcedures(Val(GetXMLAttribute(Task, "Type")))\Add(GetXMLAttribute(Task, "Path"), LoadImage(#PB_Any, GetXMLAttribute(Task, "Path")), GetXMLAttribute(Task, "UUID"))
						;}
					Case #DeleteAsset ;{
						AssetProcedures(Val(GetXMLAttribute(Task, "Type")))\Delete(GetXMLAttribute(Task, "UUID"))
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
						AssetProcedures(Val(GetXMLAttribute(Task, "Type")))\Delete(GetXMLAttribute(Task, "UUID"))
						;}
					Case #DeleteAsset ;{
						MediaBlocks = GetXMLAttribute(Task, "MediaBlocks")
						
						If MediaBlocks
							*MediaBLock = AllocateStructure(Task)
							*MediaBLock\XML = MediaBlocks
							
							PureTL::Handler_UndoRedo(*MediaBLock, #False)
						EndIf
						AssetProcedures(Val(GetXMLAttribute(Task, "Type")))\Add(GetXMLAttribute(Task, "Path"), LoadImage(#PB_Any, GetXMLAttribute(Task, "Path")), GetXMLAttribute(Task, "UUID"))
						
						;}
				EndSelect
			Next
			;}
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	;}
	
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 282
; FirstLine = 151
; Folding = -DkH5-
; EnableXP