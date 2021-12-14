Module PropertiesWindow
	EnableExplicit
	;{ Private variables, structures, constants...
	#Style_Header_Height = 30
	#Style_Window_Width = 500
	#Style_Window_Height = 600
	#Style_Border_Thickness = 1
	#Style_TitleBar_ButtonWidth = 45
	#Style_TitleBar_ButtonHeight = 36
	
	
	#Style_Container_Margin = 5
	#Style_Label_Width = 50
	#Style_String_Width = 72
	
	
	#Properties = PureTL::#Properties_Count - 2
	
	Global DWMEnabled, WindowID, MediaBlockType.i
	Global MediablockData.PureTL::DataPoint
	Global Dim GadgetArray(#Properties)
	
	;}
	
	;{ Private procedures declaration
	Declare HandlerWindow(hWnd, Msg, wParam, lParam)
	Declare HandlerCloseWindow()
	Declare HandlerChange()
	
	Declare BuildStringsContainer(PropertieID, Text1.s, Text2.s = "", Text3.s = "", Text4.s = "")
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
		
		BindEvent(#PB_Event_Gadget, @HandlerChange(), #Window)
		
		CompilerIf #PB_Compiler_Debugger 
			HideWindow(#Window, #False)
		CompilerEndIf
	EndProcedure
	
	Procedure Update(JsonString.s)
		Protected Loop, Json
		
		Json = ParseJSON(#PB_Any, JsonString.s)
		
		If Json
			ExtractJSONStructure(JSONValue(Json), @MediablockData, PureTL::DataPoint)
			FreeJSON(Json)
			
			For Loop = 0 To #Properties
				If GadgetArray(Loop)
					SetGadgetText(GadgetArray(Loop), StrD(PeekD(@MediablockData+ Loop * SizeOf(Double))))
				EndIf
			Next
		Else
			MediaBlockUUID = ""
			ClearGadgetItems(#Accordion)
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
		
		Select PureTL::GetMediaBlockType(0, UUID)
			Case Project::#Asset_Type_Image
				AddGadgetItem(#Accordion, -1, "General")
				OpenGadgetList(#Accordion, 0)
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(PureTL::#Properties_X, "X:", "Y:"), "Position:")
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(PureTL::#Properties_Width, "Width:", "Height:"), "Height:")
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(PureTL::#Properties_Transparency, ""), "Opacity:")
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(PureTL::#Properties_Angle, ""), "Rotation:")
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
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(PureTL::#Properties_X, "X:", "Y:"), "Position:")
				Accordion::AddSubGadget(#Accordion, BuildStringsContainer(PureTL::#Properties_Angle, ""), "Rotation:")
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
	
	Procedure HandlerChange()
		Protected Gadget, GadgetData, Json
		
		Select EventType()
			Case #PB_EventType_Change
				Gadget = EventGadget()
				If Gadget > - 1
					GadgetData = GetGadgetData(Gadget) - 1
					If GadgetData > -1 And GadgetData <= #Properties
						PokeD(@MediablockData + GadgetData * SizeOf(Double), ValD(GetGadgetText(Gadget)))
						
						Json = CreateJSON(#PB_Any)
						InsertJSONStructure(JSONValue(json), @MediablockData, PureTL::DataPoint)
						PureTL::UpdateMediaBlockState(0, MediaBlockUUID, ComposeJSON(json))
						FreeJSON(Json)
						PostEvent(#PB_Event_Gadget, 0, 0, PureTL::#EventType_ForceUpdate)
					EndIf
				EndIf
		EndSelect
	EndProcedure
	
	Procedure BuildStringsContainer(PropertieID, Text1.s, Text2.s = "", Text3.s = "", Text4.s = "")
		Protected Result, ItemCount, ItemWidth, Loop, TextGadget, Width
		Protected Dim Text.s(3)
		
		Text(0) = Text1
		Text(1) = Text2
		Text(2) = Text3
		Text(3) = Text4
		
		If Text4 <> ""
			ItemCount = 4
		ElseIf Text3 <> ""
			ItemCount = 3
		ElseIf Text2 <> ""
			ItemCount = 2
		Else
			GadgetArray(PropertieID) = StringGadget(#PB_Any, 0, 0, #Style_String_Width, 20, StrD(PeekD(@MediablockData + PropertieID * SizeOf(Double))), #PB_String_Numeric)
			SetGadgetData(GadgetArray(PropertieID), PropertieID + 1)
			SetGadgetColor(GadgetArray(PropertieID), #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
			SetGadgetColor(GadgetArray(PropertieID), #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
			ProcedureReturn GadgetArray(PropertieID)
		EndIf
		
		ItemWidth = #Style_String_Width + #Style_Label_Width
		Width = ItemWidth * ItemCount + (ItemCount - 1) * #Style_Container_Margin
		ItemWidth + #Style_Container_Margin
		
		Result = ContainerGadget(#PB_Any, 0, 0, Width, 20, #PB_Container_BorderLess)
		SetGadgetColor(Result, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		
		ItemCount - 1
		
		For Loop = 0 To ItemCount
			TextGadget = TextGadget(#PB_Any, Loop * ItemWidth, 2, #Style_Label_Width - #Style_Container_Margin, 15, Text(Loop), #PB_Text_Right)
			SetGadgetColor(TextGadget, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
			SetGadgetColor(TextGadget, #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
			GadgetArray(PropertieID + Loop) = StringGadget(#PB_Any, Loop * ItemWidth + #Style_Label_Width, 0, #Style_String_Width, 20, StrD(PeekD(@MediablockData + (PropertieID + Loop) * SizeOf(Double))), #PB_String_Numeric)
			SetGadgetData(GadgetArray(PropertieID + Loop), PropertieID + Loop + 1)
			SetGadgetColor(GadgetArray(PropertieID + Loop), #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
			SetGadgetColor(GadgetArray(PropertieID + Loop), #PB_Gadget_FrontColor, General::FixColor(General::#Color_Window_Front_Warm))
		Next
		
		CloseGadgetList()
		ProcedureReturn Result
	EndProcedure
	;}
	
EndModule










; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 173
; FirstLine = 110
; Folding = vn-
; EnableXP