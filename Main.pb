UseJPEG2000ImageDecoder()
UseJPEGImageDecoder()
UsePNGImageDecoder()
UseGIFImageDecoder()
UseTGAImageDecoder()
UseTIFFImageDecoder()

IncludePath "Libaries"

IncludeFile "Ease.pbi"
IncludeFile "TaskList.pbi"
IncludeFile "GadgetTimer.pbi"
IncludeFile "Textbox.pbi"
IncludeFile "MaterialVector.pbi"
IncludeFile "CanvasButton.pbi"
IncludeFile "ScrollBar.pbi"
IncludeFile "FlatMenu.pbi"
IncludeFile "PureTimeline.pbi"
IncludeFile "PureAccordion.pb"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "Project.pbi"
IncludeFile "AssetButton.pbi"
IncludeFile "PropertiesWindow.pbi"

EnableExplicit

Global *UUIDData = AllocateMemory(33)
Global *Result = AllocateMemory(1)

CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
	
	Global Event_UUID.s
	
	; Communication API
	ProcedureCDLL.d Init(*WindowName)
		General::WindowName = PeekS(*WindowName, -1, #PB_UTF8)
		
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
	
	ProcedureCDLL.d ExamineSubMedia(*MediablockUUID)
		Protected UUID.s = PeekS(*MediablockUUID, -1, #PB_UTF8)
		ProcedureReturn PureTL::ExamineSubMedia(0, UUID)
	EndProcedure
	
	ProcedureCDLL NextSubMedia(*MediablockUUID)
		Protected Len, UUID.s = PeekS(*MediablockUUID, -1, #PB_UTF8)
		UUID = PureTL::NextSubMedia(0, UUID)
		Len = StringByteLength(UUID, #PB_UTF8) + 1
		
		*Result = ReAllocateMemory(*Result, Len, #PB_Memory_NoClear)
		PokeS(*Result, UUID, Len, #PB_UTF8)
		
		ProcedureReturn *Result
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
	
	ProcedureCDLL.d GetModifierControl()
		ProcedureReturn MainWindow::ModifierControl
	EndProcedure
	
	ProcedureCDLL.d GetModifierShift()
		ProcedureReturn MainWindow::ModifierShift
	EndProcedure
	
	ProcedureCDLL UpdateMediaBlockState(*MediablockUUID, *Json)
		PureTL::UpdateMediaBlockState(0, PeekS(*MediablockUUID, -1, #PB_UTF8), PeekS(*Json, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL UpdateProperties(*Json)
		PropertiesWindow::Update(PeekS(*Json, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL.d GetPlayerPosition()
		ProcedureReturn PureTL::GetPlayerPosition(0)
	EndProcedure
	
	ProcedureCDLL.d GetMediaBlockDuration(*MediablockUUID)
		ProcedureReturn PureTL::GetMediaBlockDuration(0, PeekS(*MediablockUUID, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL.d GetMediaBlockPosition(*MediablockUUID)
		ProcedureReturn PureTL::GetMediaBlockPosition(0, PeekS(*MediablockUUID, -1, #PB_UTF8))
	EndProcedure
	
CompilerElse
	MainWindow::Open()
	Project::New()
	
	Repeat
		WaitWindowEvent()
	ForEver
CompilerEndIf
; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 122
; FirstLine = 14
; Folding = BAAj
; EnableXP