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
	
	; Communication API
	ProcedureCDLL.d CountLayer()
		ProcedureReturn PureTL::CountLine(MainWindow::#TimeLine)
	EndProcedure
	
	ProcedureCDLL.d Init(*WindowName)
		General::WindowName = PeekS(*WindowName, -1, #PB_UTF8)
		ImagePlugin::UseSystemImageDecoder()
		ImagePlugin::UseSystemImageEncoder()
		
		MainWindow::Open()
		Project::New()
		ProcedureReturn #True
	EndProcedure
	
	ProcedureCDLL GetCurrentAsset(Line.d)
		PokeS(*UUIDData, PureTL::GetAsset(MainWindow::#TimeLine, Line), 32, #PB_UTF8)
		
		ProcedureReturn *UUIDData
	EndProcedure
	
	ProcedureCDLL GetAssetState(Line.d)
		Protected State.s = PureTL::GetMediaBlockState(MainWindow::#TimeLine, Line), Len = StringByteLength(State, #PB_UTF8) + 1
		*Result = ReAllocateMemory(*Result, Len, #PB_Memory_NoClear)
		PokeS(*Result, State, Len, #PB_UTF8)
		ProcedureReturn *Result
	EndProcedure
	
	ProcedureCDLL.d GetAssetType(*Object)
		ProcedureReturn Project::GetAssetType(PeekS(*Object, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL.d Tick()
		Protected Result
		
		Repeat : Until Not WindowEvent()
		
		If ListSize(General::EventList())
			FirstElement(General::EventList())
			Result = General::EventList()
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
	
	ProcedureCDLL.d GetImageWidth(*Object)
		ProcedureReturn Project::GetAssetWidth(PeekS(*Object, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL.d GetImageHeigt(*Object)
		ProcedureReturn Project::GetAssetHeight(PeekS(*Object, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL GetAssetPath(*Object)
		Protected path.s = Project::GetAssetPath(PeekS(*Object, -1, #PB_UTF8)), Len = StringByteLength(path, #PB_UTF8) + 1
		*Result = ReAllocateMemory(*Result, Len, #PB_Memory_NoClear)
		PokeS(*Result, path, Len, #PB_UTF8)
		ProcedureReturn *Result
	EndProcedure
	
	ProcedureCDLL.d UpdateAssetState(Line.d, *Json)
		PureTL::UpdateMediaBlockState(MainWindow::#TimeLine, Line, PeekS(*Json, -1, #PB_UTF8))
	EndProcedure
	
	ProcedureCDLL.d GetEditedLine()
		ProcedureReturn PureTL::GetEditedLine(MainWindow::#TimeLine)
	EndProcedure
CompilerElse
	MainWindow::Open()
	Project::New()
	
	Repeat
		WaitWindowEvent()
	ForEver
CompilerEndIf
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 11
; Folding = RQ-
; EnableXP