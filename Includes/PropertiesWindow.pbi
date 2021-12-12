Module PropertiesWindow
	EnableExplicit
	;{ Private variables, structures, constants...
	#Style_Header_Height = 30
	#Style_Window_Width = 800
	#Style_Window_Height = 600
	#Style_Border_Thickness = 1
	#Style_TitleBar_ButtonWidth = 45
	#Style_TitleBar_ButtonHeight = 36
	
	Global DWMEnabled, WindowID
	;}
	
	;{ Private procedures declaration
	Declare HandlerWindow(hWnd, Msg, wParam, lParam)
	;}
	
	;{ Public procedures
	Procedure Open()
		WindowID = OpenWindow(#Window, 0, 0, #Style_Window_Width, #Style_Window_Height, "Properties", #PB_Window_WindowCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(MainWindow::#Window))
		SetWindowColor(#Window, General::FixColor(General::#Color_Window_Back_Cold))
		
		ContainerGadget(#Container, #Style_Border_Thickness, #Style_Border_Thickness, #Style_Window_Width - 2 * #Style_Border_Thickness, #Style_Window_Height - 2 * #Style_Border_Thickness, #PB_Container_BorderLess)
		SetProp_(GadgetID(#Container), "oldproc", SetWindowLongPtr_(GadgetID(#Container), #GWL_WNDPROC, @HandlerWindow()))
		SetGadgetColor(#Container, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		
		CanvasButton::Gadget(#CloseButton, #Style_Window_Width - 2 * #Style_Border_Thickness - #Style_TitleBar_ButtonWidth, 0, #Style_TitleBar_ButtonWidth, #Style_Header_Height, "󰅖", -1, CanvasButton::#DarkTheme)
		SetGadgetFont(#CloseButton, MainWindow::MaterialIcon)
		SetGadgetColor(#CloseButton, CanvasButton::#BackColor_Cold, General::FixColor(General::#Color_Content_Back_Cold))
		SetGadgetColor(#CloseButton, CanvasButton::#BackColor_Warm, General::FixColor($E00000))
		SetGadgetColor(#CloseButton, CanvasButton::#BackColor_Hot, General::FixColor($E00000))
		SetGadgetColor(#CloseButton, CanvasButton::#FrontColor_Warm, General::FixColor($FFFFFF))
		SetGadgetColor(#CloseButton, CanvasButton::#FrontColor_Hot, General::FixColor($FFFFFF))
		
		TextGadget(#Text_Title, 10, 8, 200, 20, "Properties")
		SetGadgetColor(#Text_Title, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		SetGadgetColor(#Text_Title, #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
		
		Accordion::Gadget(#Accordion, 0, #Style_Header_Height, #Style_Window_Width - 2 * #Style_Border_Thickness, #Style_Window_Height - #Style_Header_Height - #Style_Border_Thickness)
		
		SetGadgetColor(#Accordion, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		SetGadgetColor(#Accordion, #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Cold))
		SetGadgetColor(#Accordion, Accordion::#ColdColor, General::FixColor(General::#Color_Window_Back_Cold))
		SetGadgetColor(#Accordion, Accordion::#WarmColor, $5A433D)
		
		AddGadgetItem(#Accordion, -1, "General")
		AddGadgetItem(#Accordion, -1, "Testouille 2")
		
		SetGadgetItemState(#Accordion, 0, #True)
		
		HideWindow(#Window, #False)
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure HandlerWindow(hWnd, Msg, wParam, lParam)
		
		If Msg = #WM_LBUTTONDOWN 
			If lParam >> 16 < #Style_Header_Height
				SendMessage_(WindowID, #WM_NCLBUTTONDOWN, #HTCAPTION, 0)
			EndIf
		EndIf
		
		ProcedureReturn CallWindowProc_(GetProp_(hWnd, "oldproc"), hWnd, Msg, wParam, lParam)
	EndProcedure
	;}
EndModule
; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 48
; Folding = --
; EnableXP