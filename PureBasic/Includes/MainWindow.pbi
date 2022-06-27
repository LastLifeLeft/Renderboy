Module MainWindow
	EnableExplicit
	;{ Private variables, constants and structures
	Global Window
	
	; Appearance
	#Appearance_Window_Width = 1200
	#Appearance_Window_Height = 700
	
	;}
	
	; Public procedures
	Procedure Open()
		Window = UITK::Window(#PB_Any, 0, 0, #Appearance_Window_Width, #Appearance_Window_Height, General::#AppName, UITK::#Window_CloseButton |
		                                                                                                             UITK::#Window_MaximizeButton |
		                                                                                                             UITK::#Window_MinimizeButton |
		                                                                                                             #PB_Window_SizeGadget |
		                                                                                                             #PB_Window_ScreenCentered |
		                                                                                                             #PB_Window_Invisible)
		
		
		HideWindow(Window, #False)
	EndProcedure
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 20
; Folding = -
; EnableXP
; DPIAware