Module Project
	EnableExplicit
	;{ Private variables, structures, constants...
	Global TaskList
	
	Structure Asset
		Type.i
		UUID.s
		Name.s
	EndStructure
	
	Structure Task
		XMLID.i
		XML.s
	EndStructure
	
	Structure AssetLibrary
		Map ProjectAssets.Asset(2048)
		Map LibraryAsset.Asset(2048)
	EndStructure
	
	Enumeration
		#Asset_Media
		#Asset_Sound
		#Asset_Model
		#Asset_Overlay
		#Asset_Element
	EndEnumeration
	
	
	Global Dim AssetLibrary.AssetLibrary(5)
	
	;Tasks
	#AddAsset = "AddAsset"
	#DeleteAsset = "DeleteAsset"
	
	;}
	
	;{ Private procedures declaration
	Declare _AddImage(Path.s, PreviewImage, UUID.s)
	Declare _AddVideo(Path.s, MainNode)
	Declare _AddSound(Path.s, MainNode)
	Declare _AddModel(Path.s, MainNode)
	Declare _AddOverlay(Path.s, MainNode)
	Declare _AddElement(Path.s, MainNode)
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
		Protected *Task.Task = AllocateStructure(Task), UUID.s = General::UUID(), MainNode, Item
		
		*Task\XMLID = CreateXML(#PB_Any)
 		MainNode = CreateXMLNode(RootXMLNode(*Task\XMLID), "Tasks") 
		
		For Loop = 1 To Count
			Path = StringField(Asset, Loop, #LF$)
			Extension.s = LCase(GetExtensionPart(Path))
			
			Select Extension
				Case "png", "bmp", "jpg"
					
					Image = LoadImage(#PB_Any, Path)
					
					If Image
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
	EndProcedure
	
	Procedure Undo()
		Debug "undo"
	EndProcedure
	
	Procedure Redo()
		Debug "redo"
	EndProcedure
	
	; Get
	Procedure.s GetAssetName(UUID.s, Type)
		Protected Result.s
		If FindMapElement(AssetLibrary(Type)\ProjectAssets(), UUID)
			Result = AssetLibrary(Type)\ProjectAssets()\Name
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	; Set
	
	;}
	
	;{ Private procedures
	Procedure _AddImage(Path.s, Image, UUID.s)
		Protected *Asset.Asset
		If ImageWidth(Image) <> 160 Or ImageHeight(Image) <> 90
			General::ResizeImageEx(Image, 160, 90, General::#PB_Image_KeepAspectRatio)
		EndIf
		
		*Asset = AddMapElement(AssetLibrary(#Asset_Media)\ProjectAssets(), UUID)
		*Asset\UUID = UUID
		*Asset\Type = #Asset_Type_Image
		*Asset\Name = GetFilePart(Path, #PB_FileSystem_NoExtension)
		
		MainWindow::AddAssetButton(#Asset_Type_Image, Image, *Asset\Name, *Asset\UUID)
	EndProcedure
	
	Procedure _AddVideo(Path.s, MainNode)
		
	EndProcedure
	
	Procedure _AddSound(Path.s, MainNode)
		
	EndProcedure
	
	Procedure _AddModel(Path.s, MainNode)
		
	EndProcedure
	
	Procedure _AddOverlay(Path.s, MainNode)
		
	EndProcedure
	
	Procedure _AddElement(Path.s, MainNode)
		
	EndProcedure
	
	;}
	
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 120
; FirstLine = 53
; Folding = -B6-
; EnableXP