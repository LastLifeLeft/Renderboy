IncludePath "Libaries"
IncludeFile "MemoryStreamModule.pbi"
IncludeFile "ImagePlugin.pbi"

ImagePlugin::UseSystemImageDecoder()
ImagePlugin::UseSystemImageEncoder()

IncludeFile "Ease.pbi"
IncludeFile "TaskList.pbi"
IncludeFile "GadgetTimer.pbi"
IncludeFile "Textbox.pbi"
IncludeFile "MaterialVector.pbi"
IncludeFile "CanvasButton.pbi"
IncludeFile "ScrollBar.pbi"
IncludeFile "FlatMenu.pbi"
IncludeFile "PureTimeline.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "Project.pbi"
IncludeFile "AssetButton.pbi"

EnableExplicit

Global *UUIDData = AllocateMemory(33)
Global *Result = AllocateMemory(1)

CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
	
	Global Event_UUID.s
	
	; Communication API
	ProcedureCDLL.d Init(*WindowName)
		General::WindowName = PeekS(*WindowName, -1, #PB_UTF8)
		ImagePlugin::UseSystemImageDecoder()
		ImagePlugin::UseSystemImageEncoder()
		
		MainWindow::Open()
		Project::New()
		ProcedureReturn #True
	EndProcedure
	
	ProcedureCDLL.d Tick()
		Protected Result
		
		Repeat : Until Not WindowEvent()
		
		If ListSize(General::EventList())
			FirstElement(General::EventList())
			Result = General::EventList()\EventType
			Event_UUID = General::EventList()\UUID
			DeleteElement(General::EventList())
			LastElement(General::EventList())
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	
	ProcedureCDLL.d GetHeight()
		ProcedureReturn MainWindow::RendererHeight
	EndProcedure
	
	ProcedureCDLL.d GetWidth()
		ProcedureReturn MainWindow::RendererWidth
	EndProcedure
	
	ProcedureCDLL.d ExamineLayer(Layer.d)
		ProcedureReturn PureTL::LayerContent(0, Layer)
	EndProcedure
	
	ProcedureCDLL NextMediaBlock()
		Protected UUID.s, Len
		UUID = PureTL::NextMediaBlockUUID(0)
		Len = StringByteLength(UUID, #PB_UTF8) + 1
		
		*Result = ReAllocateMemory(*Result, Len, #PB_Memory_NoClear)
		PokeS(*Result, UUID, Len, #PB_UTF8)
		
		ProcedureReturn *Result
	EndProcedure
	
	ProcedureCDLL.d GetMediaBlockType(*Object)
		ProcedureReturn PureTL::GetMediaBlockType(0, PeekS(*Object, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL GetAssetUUID(*MediablockUUID)
		Protected UUID.s, Len
		UUID = PureTL::GetAssetUUID(0, PeekS(*MediablockUUID, -1, #PB_UTF8))
		Len = StringByteLength(UUID, #PB_UTF8) + 1
		
		*Result = ReAllocateMemory(*Result, Len, #PB_Memory_NoClear)
		PokeS(*Result, UUID, Len, #PB_UTF8)
		
		ProcedureReturn *Result
	EndProcedure
	
	ProcedureCDLL.d GetAssetWidth(*AssetUUID)
		ProcedureReturn Project::GetAssetWidth(PeekS(*AssetUUID, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL.d GetAssetHeight(*AssetUUID)
		ProcedureReturn Project::GetAssetHeight(PeekS(*AssetUUID, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL GetAssetPath(*AssetUUID)
		Protected path.s = Project::GetAssetPath(PeekS(*AssetUUID, -1, #PB_UTF8)), Len = StringByteLength(path, #PB_UTF8) + 1
		*Result = ReAllocateMemory(*Result, Len, #PB_Memory_NoClear)
		PokeS(*Result, path, Len, #PB_UTF8)
		ProcedureReturn *Result
	EndProcedure
	
	ProcedureCDLL GetAssetState(*AssetUUID)
		Protected State.s = PureTL::GetMediaBlockState(0, PeekS(*AssetUUID, -1, #PB_UTF8)), Len = StringByteLength(State, #PB_UTF8) + 1
		*Result = ReAllocateMemory(*Result, Len, #PB_Memory_NoClear)
		PokeS(*Result, State, Len, #PB_UTF8)
		ProcedureReturn *Result
	EndProcedure
	
	ProcedureCDLL GetEventMediablock()
		Protected Len = StringByteLength(Event_UUID, #PB_UTF8) + 1
		*Result = ReAllocateMemory(*Result, Len, #PB_Memory_NoClear)
		PokeS(*Result, Event_UUID, Len, #PB_UTF8)
		ProcedureReturn *Result
	EndProcedure
	
CompilerElse
	MainWindow::Open()
	Project::New()
	
	Repeat
		WaitWindowEvent()
	ForEver
CompilerEndIf
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 122
; Folding = BA-
; EnableXP