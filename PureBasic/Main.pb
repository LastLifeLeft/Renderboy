IncludePath "UITK/Library"
IncludeFile "UI-Toolkit.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "TimeLine.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "Project.pbi"

General::Init()

Repeat
	If WaitWindowEvent() = #PB_Event_GadgetDrop
		Select EventGadget()
			Case MainWindow::Library	
				Project::AddAsset(EventDropFiles())
		EndSelect
	EndIf	
ForEver
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 15
; EnableXP
; DPIAware