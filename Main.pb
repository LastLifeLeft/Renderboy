IncludePath "Libaries"
IncludeFile "MemoryStreamModule.pbi"
IncludeFile "ImagePlugin.pbi"

ImagePlugin::UseSystemImageDecoder()
ImagePlugin::UseSystemImageEncoder()

IncludeFile "TaskList.pbi"
IncludeFile "GadgetTimer.pbi"
IncludeFile "Textbox.pbi"
IncludeFile "MaterialVector.pbi"
IncludeFile "CanvasButton.pbi"
IncludeFile "ScrollBar.pbi"
IncludeFile "PureTimeline.pbi"
IncludeFile "FlatMenu.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "Project.pbi"
IncludeFile "AssetButton.pbi"

EnableExplicit

CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
	; Communication API
	ProcedureCDLL.d CountLayer()
		ProcedureReturn PureTL::CountLine(MainWindow::#TimeLine)
	EndProcedure
	
	ProcedureCDLL.d Init(*Data)
		General::WindowName = PeekS(*Data, -1, #PB_UTF8)
		ImagePlugin::UseSystemImageDecoder()
		ImagePlugin::UseSystemImageEncoder()
		
		MainWindow::Open()
		Project::New()
		ProcedureReturn #True
	EndProcedure
	
; 	Procedure GetCurrentAsset(Line.d)
; 		
; 	EndProcedure
	
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
	
CompilerElse
	MainWindow::Open()
	Project::New()
	
	Repeat
		WaitWindowEvent()
	ForEver
CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 42
; Folding = P-
; EnableXP