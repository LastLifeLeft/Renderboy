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

MainWindow::Open()
Project::New()

Repeat
	WaitWindowEvent()
ForEver

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 26
; EnableXP