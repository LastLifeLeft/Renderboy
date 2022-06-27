DeclareModule General
	; Public variables, constants and structures
	#AppName = "Renderboy"
	
	; Public procedure declarations
	Declare Init()
EndDeclareModule

DeclareModule MainWindow
	; Public procedure declarations
	
	
	
	; Public procedure declarations
	Declare Open()
EndDeclareModule

DeclareModule Project
EndDeclareModule

Module General
	EnableExplicit
	
	; Public procedures
	Procedure Init()
		MainWindow::Open()
	EndProcedure
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 25
; Folding = -
; EnableXP
; DPIAware