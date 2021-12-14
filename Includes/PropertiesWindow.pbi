Module PropertiesWindow
	EnableExplicit
	;{ Private variables, structures, constants...
	#Style_Header_Height = 30
	#Style_Window_Width = 500
	#Style_Window_Height = 600
	#Style_Border_Thickness = 1
	#Style_TitleBar_ButtonWidth = 45
	#Style_TitleBar_ButtonHeight = 36
	
	#Properties = PureTL::#Properties_Count - 2
	
	Global DWMEnabled, WindowID, MediaBlockUUID.s, MediaBlockType.i
	Global MediablockData.PureTL::DataPoint
	Global Dim GadgetArray(#Properties)
	
	;}
	
	;{ Private procedures declaration
	Declare HandlerWindow(hWnd, Msg, wParam, lParam)
	Declare HandlerCloseWindow()
	
	Declare BuildStringsContainer(Width, PropertieID, Text1.s, Val1.d, Text2.s, Val2.d, Text3.s = "", Val3.d = 0, Text4.s = "", Val4.d = 0)
	;}
	
	;{ Public procedures
	Procedure Open()
		WindowID = OpenWindow(#Window, 0, 0, #Style_Window_Width, #Style_Window_Height, "Properties", #PB_Window_WindowCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(MainWindow::#Window))
		SetWindowColor(#Window, 0)
		
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
		BindGadgetEvent(#CloseButton, @HandlerCloseWindow(), #PB_EventType_Change)
		
		TextGadget(#Text_Title, 10, 8, 200, 20, "Properties")
		SetGadgetColor(#Text_Title, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		SetGadgetColor(#Text_Title, #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
		
		Accordion::Gadget(#Accordion, 0, #Style_Header_Height, #Style_Window_Width - 2 * #Style_Border_Thickness, #Style_Window_Height - #Style_Header_Height - #Style_Border_Thickness)
		
		SetGadgetColor(#Accordion, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		SetGadgetColor(#Accordion, #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Cold))
		SetGadgetColor(#Accordion, Accordion::#ColdColor, General::FixColor(General::#Color_Window_Back_Cold))
		SetGadgetColor(#Accordion, Accordion::#WarmColor, $5A433D)
		
		CompilerIf #PB_Compiler_Debugger 
			HideWindow(#Window, #False)
		CompilerEndIf
	EndProcedure
	
	Procedure Update()
		Protected Loop
		
		If MediaBlockUUID <> ""
			Protected Json
			Json = ParseJSON(#PB_Any, PureTL::GetMediaBlockState(0, MediaBlockUUID))
			
			If Json
				ExtractJSONStructure(JSONValue(Json), @MediablockData, PureTL::DataPoint)
				FreeJSON(Json)
				
; 				Select PureTL::GetMediaBlockType(0, UUID)
; 					Case Project::#Asset_Type_Image
						For Loop = 0 To #Properties
							If GadgetArray(Loop)
								SetGadgetText(GadgetArray(Loop), StrD(PeekD(@MediaBlockType + Loop * SizeOf(Double))))
							EndIf
						Next
; 					Case Project::#Asset_Type_Video
; 					Case Project::#Asset_Type_Sound
; 					Case Project::#Asset_Type_Music
; 					Case Project::#Asset_Type_Voice
; 					Case Project::#Asset_Type_Character
; 					Case Project::#Asset_Type_Model
; 					Case Project::#Asset_Type_Text
; 					Case Project::#Asset_Type_Overlay
; 					Case Project::#Asset_Type_2DEffect
; 				EndSelect
			Else
				MediaBlockUUID = ""
				ClearGadgetItems(#Accordion)
			EndIf
		EndIf
	EndProcedure
	
	Procedure SetUp(UUID.s)
		Protected Json
		HideGadget(#Accordion, #True)
		ClearGadgetItems(#Accordion)
		
		MediaBlockUUID = UUID
		Json = ParseJSON(#PB_Any, PureTL::GetMediaBlockState(0, MediaBlockUUID))
		ExtractJSONStructure(JSONValue(Json), @MediablockData, PureTL::DataPoint)
		FreeJSON(Json)
		
		; Sizes : 72 for 1 numeric stringgadgets, 249 for 2, 375 for 3.
		
		Select PureTL::GetMediaBlockType(0, UUID)
			Case Project::#Asset_Type_Image
				AddGadgetItem(#Accordion, -1, "General")
				OpenGadgetList(#Accordion, 0)
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(249, PureTL::#Properties_X, "X:", MediablockData\X, "Y:", MediablockData\Y), "Position:")
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(249, PureTL::#Properties_Width, "Width:", MediablockData\Width, "Height:", MediablockData\Height), "Height:")
				GadgetArray(PureTL::#Properties_Transparency) = StringGadget(#PB_Any, 0, 0, 72, 20, StrD(MediablockData\Transparency), #PB_String_Numeric)
				SetGadgetColor(GadgetArray(PureTL::#Properties_Transparency), #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
				SetGadgetColor(GadgetArray(PureTL::#Properties_Transparency), #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
				Accordion::AddSubGadget(#Accordion, GadgetArray(PureTL::#Properties_Transparency), "Opacity :")
				GadgetArray(PureTL::#Properties_Angle) = StringGadget(#PB_Any, 0, 0, 72, 20, StrD(MediablockData\Angle), #PB_String_Numeric)
				SetGadgetColor(GadgetArray(PureTL::#Properties_Angle), #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
				SetGadgetColor(GadgetArray(PureTL::#Properties_Angle), #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
				Accordion::AddSubGadget(#Accordion, GadgetArray(PureTL::#Properties_Angle), "Rotation :")
				CloseGadgetList()
			Case Project::#Asset_Type_Video
				
			Case Project::#Asset_Type_Sound
				
			Case Project::#Asset_Type_Music
				
			Case Project::#Asset_Type_Voice
				
			Case Project::#Asset_Type_Character
				
			Case Project::#Asset_Type_Model
				
			Case Project::#Asset_Type_Text
				AddGadgetItem(#Accordion, -1, "General")
				OpenGadgetList(#Accordion, 0)
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(249, PureTL::#Properties_X, "X:", MediablockData\X, "Y:", MediablockData\Y), "Position:")
				
				GadgetArray(PureTL::#Properties_Angle) = StringGadget(#PB_Any, 0, 0, 72, 20, StrD(MediablockData\Angle), #PB_String_Numeric)
				SetGadgetColor(GadgetArray(PureTL::#Properties_Angle), #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
				SetGadgetColor(GadgetArray(PureTL::#Properties_Angle), #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
				Accordion::AddSubGadget(#Accordion, GadgetArray(PureTL::#Properties_Angle), "Rotation :")
				CloseGadgetList()
				
				AddGadgetItem(#Accordion, -1, "Text")
				
				
				AddGadgetItem(#Accordion, -1, "Special")
				
				
				SetGadgetItemState(#Accordion, 0, #True)
			Case Project::#Asset_Type_Overlay
				
			Case Project::#Asset_Type_2DEffect
				
		EndSelect
		
		SetGadgetItemState(#Accordion, 0, #True)
		HideGadget(#Accordion, #False)
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
	
	Procedure HandlerCloseWindow()
		HideWindow(#Window, #True)
	EndProcedure
	
	#StringContainer_Margin = 5
	#StringContainer_LabelWidth = 50
	
	Procedure BuildStringsContainer(Width, PropertieID, Text1.s, Val1.d, Text2.s, Val2.d, Text3.s = "", Val3.d = 0, Text4.s = "", Val4.d = 0)
		Protected Result, ItemCount, ItemWidth, loop, TextGadget
		Protected Dim Text.s(3), Dim Value.d(3)
		
		Text(0) = Text1
		Text(1) = Text2
		Value(0) = Val1
		Value(1) = Val2
		
		If Text4 <> ""
			ItemCount = 4
			Text(2) = Text3
			Text(3) = Text4
			Value(2) = Val3
			Value(3) = Val4
		ElseIf Text3 <> ""
			ItemCount = 3
			Text(2) = Text3
			Value(2) = Val3
		Else
			ItemCount = 2
		EndIf
		
		ItemWidth = Round((Width - (ItemCount - 1) * #StringContainer_Margin) / ItemCount, #PB_Round_Nearest)
		Width = ItemWidth * ItemCount + (ItemCount - 1) * #StringContainer_Margin
		
		Result = ContainerGadget(#PB_Any, 0, 0, Width, 20, #PB_Container_BorderLess)
		SetGadgetColor(Result, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		
		ItemCount - 1
		
		For loop = 0 To ItemCount
			TextGadget = TextGadget(#PB_Any, loop * (ItemWidth + #StringContainer_Margin), 2, #StringContainer_LabelWidth - #StringContainer_Margin, 15, Text(loop), #PB_Text_Right)
			SetGadgetColor(TextGadget, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
			SetGadgetColor(TextGadget, #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
			GadgetArray(PropertieID + loop) = StringGadget(#PB_Any, loop * (ItemWidth + #StringContainer_Margin) + #StringContainer_LabelWidth, 0, ItemWidth - #StringContainer_LabelWidth, 20, StrD(Value(loop)), #PB_String_Numeric)
			SetGadgetColor(GadgetArray(PropertieID + loop), #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
			SetGadgetColor(GadgetArray(PropertieID + loop), #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
		Next
		
		CloseGadgetList()
		ProcedureReturn Result
	EndProcedure
	;}
	
EndModule







; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 74
; FirstLine = 56
; Folding = -n-
; EnableXP