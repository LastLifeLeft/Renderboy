DeclareModule FlatMenu
	Enumeration ; Flags
		#Default = 0
		#DarkTheme
		#Toggle
	EndEnumeration
	
	Enumeration ; Colortype
		#colorType_FrontCold = #PB_Gadget_FrontColor
		#colorType_BackCold = #PB_Gadget_BackColor
		#ColorType_LineColor = #PB_Gadget_LineColor
		#colorType_FrontHot = 10
		#colorType_BackHot
		#colorType_FrontDisabled
	EndEnumeration
	
	Declare Create(ParentWindow, Flags = #Default)
	Declare AddItem(Menu, ItemID, Position, Text.s, Flags = #Default)
	Declare AddSubMenu(Menu, Position, Text.s)
	Declare Show(Menu, X = -1, Y = -1)
	Declare DisableItem(Menu, Position, State)
	Declare DeleteItem(Menu, Position)
	
	Declare GetItemState(Menu, Position)
	Declare GetColor(Menu, Colortype)
	Declare GetFont(Menu)
	Declare GetSubMenuID(Menu, Position)
	
	Declare SetColor(Menu, Colortype, Color)
	Declare SetFont(Menu, Font)
	Declare SetItemState(Menu, Position, State)
EndDeclareModule

Module FlatMenu
	EnableExplicit
	;{ Variables, structures, constants...
	Enumeration ;States
		#Cold
		#Hot
		#Disabled
	EndEnumeration
	
	Enumeration ;Types
		#Default
		#SubMenu
		#ToggleOn
		#ToggleOff
	EndEnumeration
	
	#SubMenuTimer = 0
	#CloseMenuTimer = 1
	#SubMenuTimerDuration = 500
	
	Structure MenuItem
		Text.s
		Type.b
		Disabled.b
		ItemID.i
		*SubMenu.MenuData
	EndStructure
	
	Structure MenuData
		MenuWindow.i
		MenuCanvas.i
		ParentWindow.i
		
		BackColor.l[2]
		FrontColor.l[3]
		LineColor.l
		
		MenuWidth.l
		ItemHeight.l
		VMargin.l
		
		Font.i
		
		State.i
		PreviousState.i
		
		SubMenuTimer.i
		CloseMenuTimer.i
		SubMenuWindow.i
		SubMenuItem.i
		
		Active.b
		Visible.b
		
		Flags.i
		
		*ParentMenu.MenuData
		*ChildMenu.MenuData
		
		List MenuItems.MenuItem()
	EndStructure
	
	; Style : 
	#Style_MinimumWidth = 200
	#Style_ItemHeight = 36
	#Style_HMargin = 23
	#Style_Border = 0
	
	#Style_Dark_BackCold = $2F3136
	#Style_Dark_BackHot = $393C43
	
	#Style_Dark_FrontCold = $8E9297
	#Style_Dark_FrontHot = $FFFFFF
	#Style_Dark_FrontDisabled = $464A51
	
	#Style_Light_BackCold = $F2F3F5
	#Style_Light_BackHot = $D4D7DC
	
	#Style_Light_FrontCold = $6A7480
	#Style_Light_FrontDisabled = $C4C5C6
	#Style_Light_FrontHot = $060607
	
	Global DefaultFont = FontID(LoadFont(#PB_Any, "Calibri", 12, #PB_Font_HighQuality))
	;}
	
	;{ Macro
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows ; Fix color
		Macro FixColor(Color)
			RGB(Blue(Color), Green(Color), Red(Color))
		EndMacro
	CompilerElse
		Macro FixColor(Color)
			Color
		EndMacro
	CompilerEndIf
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows ; Set Alpha
		Macro SetAlpha(Alpha, Color)
			Alpha << 24 + Color
		EndMacro
	CompilerElse
		Macro SetAlpha(Alpha, Color) ; You might want to check that...
			Color << 8 + Alpha
		EndMacro
	CompilerEndIf
	;}
	
	;{ Private procedures declaration
	Declare Redraw(Menu)
	Declare Handler_Canvas()
	Declare Handler_WindowFocus()
	Declare Handler_WindowTimer()
	Declare Hide(Window, CloseParents = #False)
	;}
	
	;{ Public procedures
	Procedure Create(ParentWindow, Flags = #Default)
		Protected *MenuData.MenuData, Result = OpenWindow(#PB_Any, 0, 0, #Style_MinimumWidth, #Style_ItemHeight + 2 * #Style_Border, "", #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(ParentWindow))
		Protected ItemHeight
			
		If Result
			*MenuData = AllocateStructure(MenuData)
			
			With *MenuData
				If Flags & #DarkTheme
					\LineColor = #Style_Dark_BackCold
					
					\BackColor[#Cold] = SetAlpha($FF,  FixColor(#Style_Dark_BackCold))
					\BackColor[#Hot] =  SetAlpha($FF,  FixColor( #Style_Dark_BackHot))
					
					\FrontColor[#Cold] = SetAlpha($FF, FixColor(#Style_Dark_FrontCold))
					\FrontColor[#Hot] =  SetAlpha($FF, FixColor( #Style_Dark_FrontHot))
					\FrontColor[#Disabled] = SetAlpha($FF, FixColor( #Style_Dark_FrontDisabled))
				Else
					\LineColor = #Style_Light_BackCold
					
					\BackColor[#Cold] = SetAlpha($FF,  FixColor(#Style_Light_BackCold))
					\BackColor[#Hot] = SetAlpha( $FF,  FixColor( #Style_Light_BackHot))
					
					\FrontColor[#Cold] = SetAlpha($FF, FixColor(#Style_Light_FrontCold))
					\FrontColor[#Hot] =  SetAlpha($FF, FixColor( #Style_Light_FrontHot))
					\FrontColor[#Disabled] = SetAlpha($FF, FixColor( #Style_Light_FrontDisabled))
				EndIf
				
				\Flags = Flags
				\MenuWindow = Result
				\ParentWindow = ParentWindow
				\MenuCanvas = CanvasGadget(#PB_Any, #Style_Border, #Style_Border, #Style_MinimumWidth - 2 * #Style_Border, #Style_ItemHeight, #PB_Canvas_Keyboard)
				\Font = DefaultFont
				
				\State = - 1
				\SubMenuTimer = -1
				\SubMenuItem = -1
				\SubMenuWindow = -1
				
				StartDrawing(CanvasOutput(\MenuCanvas))
				DrawingFont(\Font)
				ItemHeight = TextHeight("Hon Hon Hon! BAGUETTE!")
				StopDrawing()
				
				\MenuWidth = #Style_MinimumWidth
				\ItemHeight = ItemHeight * 1.8
				\VMargin = Round((\ItemHeight - ItemHeight) * 0.5, #PB_Round_Down)
				
				SetWindowColor(\MenuWindow, \LineColor)
				
				SetGadgetData(\MenuCanvas, *MenuData)
				SetWindowData(\MenuWindow, *MenuData)
				
				BindEvent(#PB_Event_DeactivateWindow, @Handler_WindowFocus(), \MenuWindow)
				BindEvent(#PB_Event_Timer, @Handler_WindowTimer(), \MenuWindow)
				BindGadgetEvent(\MenuCanvas, @Handler_Canvas())
				
				Redraw(\MenuWindow)
				
			EndWith
			
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure AddItem(Menu, ItemID, Position, Text.s, Flags = #Default)
		Protected *MenuData.MenuData = GetWindowData(Menu), TextWidth
		
		With *MenuData
			If Position = -1 Or Position >= ListSize(\MenuItems())
				LastElement(\MenuItems())
				AddElement(\MenuItems())
			Else
				SelectElement(\MenuItems(), Position)
				InsertElement(\MenuItems())
			EndIf
			
			\MenuItems()\Text = Text
			\MenuItems()\ItemID = ItemID
			
			If Flags & #Toggle
				\MenuItems()\Type = #ToggleOff
			EndIf
			
			StartDrawing(CanvasOutput(\MenuCanvas))
			DrawingFont(\Font)
			TextWidth = #Style_HMargin * 2 + TextWidth(Text)
			StopDrawing()
			
			If TextWidth > \MenuWidth
				\MenuWidth = TextWidth
			EndIf
			
			ResizeWindow(\MenuWindow, #PB_Ignore, #PB_Ignore, \MenuWidth, ListSize(\MenuItems()) * \ItemHeight + 2 * #Style_Border)
			ResizeGadget(\MenuCanvas, #PB_Ignore, #PB_Ignore, \MenuWidth - 2 * #Style_Border, ListSize(\MenuItems()) * \ItemHeight)
			Redraw(\MenuWindow)
		EndWith
	
	EndProcedure
	
	Procedure AddSubMenu(Menu, Position, Text.s)
		Protected *MenuData.MenuData = GetWindowData(Menu), Result, *SubMenuData.MenuData
		Result = Create(*MenuData\MenuWindow, *MenuData\Flags)
		
		If Result
			AddItem(Menu, -1, Position, Text.s)
			
			*SubMenuData.MenuData = GetWindowData(Result)
			
			*SubMenuData\Font = *MenuData\Font
			*SubMenuData\ItemHeight = *MenuData\ItemHeight
			*SubMenuData\VMargin = *MenuData\VMargin 
			
			*SubMenuData\FrontColor[#Disabled] = *MenuData\FrontColor[#Disabled]
			*SubMenuData\FrontColor[#Cold] = *MenuData\FrontColor[#Cold] 
			*SubMenuData\FrontColor[#Hot] = *MenuData\FrontColor[#Hot] 	
            
			*SubMenuData\BackColor[#Cold] = *MenuData\BackColor[#Cold] 	
			*SubMenuData\BackColor[#Hot] = *MenuData\BackColor[#Hot] 	
			
			*SubMenuData\LineColor = *MenuData\LineColor
			
			SetWindowColor(*SubMenuData\MenuWindow, *SubMenuData\LineColor)
			
			*SubMenuData\ParentMenu = *MenuData
			*MenuData\MenuItems()\SubMenu = *SubMenuData
			*MenuData\MenuItems()\Type = #SubMenu
			Redraw(*MenuData\MenuWindow)
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure Show(Menu, X = -1, Y = -1)
		Protected *MenuData.MenuData = GetWindowData(Menu)
		
		If X = -1 And Y = -1
			X = DesktopMouseX()
			Y = DesktopMouseY()
		EndIf
		
		*MenuData\Visible = #True
		
		ResizeWindow(*MenuData\MenuWindow, X, Y, #PB_Ignore, #PB_Ignore)
		
		If Not *MenuData\ParentMenu
			HideWindow(*MenuData\MenuWindow, #False)
			SetActiveGadget(*MenuData\MenuCanvas)
			*MenuData\Active = #True
		Else
			HideWindow(*MenuData\MenuWindow, #False, #PB_Window_NoActivate)
		EndIf
	EndProcedure
	
	Procedure DisableItem(Menu, Position, State)
		Protected *MenuData.MenuData = GetWindowData(Menu)
		SelectElement(*MenuData\MenuItems(), Position)
		If Not *MenuData\MenuItems()\Disabled = State
			*MenuData\MenuItems()\Disabled = State
			Redraw(*MenuData\MenuWindow)
		EndIf
	EndProcedure
	
	Procedure DeleteItem(Menu, Position)
		Protected *MenuData.MenuData = GetWindowData(Menu), TextWidth
		
		With *MenuData
			SelectElement(\MenuItems(), Position)
			DeleteElement(\MenuItems())
			
			\MenuWidth = #Style_MinimumWidth
			
			StartDrawing(CanvasOutput(\MenuCanvas))
			DrawingFont(\Font)
			ForEach \MenuItems()
				TextWidth = #Style_HMargin * 2 + TextWidth(\MenuItems()\Text)
				
				If TextWidth > \MenuWidth
					\MenuWidth = TextWidth
				EndIf
			Next
			StopDrawing()
			
			ResizeWindow(\MenuWindow, #PB_Ignore, #PB_Ignore, \MenuWidth, ListSize(\MenuItems()) * \ItemHeight + 2 * #Style_Border)
			ResizeGadget(\MenuCanvas, #PB_Ignore, #PB_Ignore, \MenuWidth - 2 * #Style_Border, ListSize(\MenuItems()) * \ItemHeight)
			Redraw(\MenuWindow)
		EndWith
	EndProcedure
	
	; Get
	Procedure GetColor(Menu, ColorType)
		Protected *MenuData.MenuData = GetWindowData(Menu), Result
		
		Select ColorType
			Case #colorType_FrontCold
				Result = *MenuData\FrontColor[#Cold]
			Case #colorType_BackCold 
				Result = *MenuData\BackColor[#Cold]
			Case #ColorType_LineColor
				Result = *MenuData\LineColor
			Case #colorType_FrontHot 
				Result = *MenuData\FrontColor[#Hot]
			Case #colorType_BackHot
				Result = *MenuData\BackColor[#Hot]
		EndSelect
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure GetFont(Menu)
		Protected *MenuData.MenuData = GetWindowData(Menu)
		ProcedureReturn *MenuData\Font
	EndProcedure
	
	Procedure GetItemState(Menu, Position)
		Protected *MenuData.MenuData = GetWindowData(Menu)
		SelectElement(*MenuData\MenuItems(), Position)
		
		If *MenuData\MenuItems()\Type = #ToggleOn
			ProcedureReturn #True
		Else
			ProcedureReturn #False
		EndIf
	EndProcedure
	
	Procedure GetSubMenuID(Menu, Position)
		Protected *MenuData.MenuData = GetWindowData(Menu)
		SelectElement(*MenuData\MenuItems(), Position)
		
		ProcedureReturn *MenuData\MenuItems()\SubMenu\MenuWindow
	EndProcedure
	
	; Set
	Procedure SetColor(Menu, Colortype, Color)
		Protected *MenuData.MenuData = GetWindowData(Menu), Result
		
		Select ColorType
			Case #colorType_FrontCold
				*MenuData\FrontColor[#Cold] = SetAlpha($FF, Color)
			Case #colorType_BackCold 
				*MenuData\BackColor[#Cold] = SetAlpha($FF, Color)
			Case #ColorType_LineColor
				*MenuData\LineColor = Color
				SetWindowColor(*MenuData\MenuWindow, *MenuData\LineColor)
			Case #colorType_FrontHot 
				*MenuData\FrontColor[#Hot] = SetAlpha($FF, Color)
			Case #colorType_BackHot
				*MenuData\BackColor[#Hot] = SetAlpha($FF, Color)
			Case #colorType_FrontDisabled
				*MenuData\FrontColor[#Disabled] = SetAlpha($FF, Color)
		EndSelect
		
		If Not Colortype = #ColorType_LineColor
			Redraw(*MenuData\MenuWindow)
		EndIf
	EndProcedure
	
	Procedure SetFont(Menu, Font)
		Protected *MenuData.MenuData = GetWindowData(Menu), ItemHeight, TextWidth
		
		With *MenuData
			\Font = Font
			
			StartDrawing(CanvasOutput(\MenuCanvas))
			DrawingFont(\Font)
			ItemHeight = TextHeight("Hon Hon Hon! BAGUETTE!")
			
			\MenuWidth = #Style_MinimumWidth
			\ItemHeight = ItemHeight * 1.8
			\VMargin = Round((\ItemHeight - ItemHeight) * 0.5, #PB_Round_Down)
			\MenuWidth = #Style_MinimumWidth
			
			ForEach \MenuItems()
				TextWidth = #Style_HMargin * 2 + TextWidth(\MenuItems()\Text)
				
				If TextWidth > \MenuWidth
					\MenuWidth = TextWidth
				EndIf
			Next
			StopDrawing()
			
			ResizeWindow(\MenuWindow, #PB_Ignore, #PB_Ignore, \MenuWidth, ListSize(\MenuItems()) * \ItemHeight + 2 * #Style_Border)
			ResizeGadget(\MenuCanvas, #PB_Ignore, #PB_Ignore, \MenuWidth - 2 * #Style_Border, ListSize(\MenuItems()) * \ItemHeight)
			Redraw(\MenuWindow)
		EndWith
	EndProcedure
	
	Procedure SetItemState(Menu, Position, State)
		Protected *MenuData.MenuData = GetWindowData(Menu)
		SelectElement(*MenuData\MenuItems(), Position)
		
		If *MenuData\MenuItems()\Type = #ToggleOff 
			If State = #True
				*MenuData\MenuItems()\Type = #ToggleOn
				Redraw(*MenuData\MenuWindow)
			EndIf
		ElseIf  *MenuData\MenuItems()\Type = #ToggleOn
			If State = #False
				*MenuData\MenuItems()\Type = #ToggleOff
				Redraw(*MenuData\MenuWindow)
			EndIf
		EndIf
	EndProcedure
	;}
	
	;{ Private Procedures
	Procedure Redraw(Menu)
		Protected *MenuData.MenuData = GetWindowData(Menu), Item, Width
		
		With *MenuData
			StartDrawing(CanvasOutput(\MenuCanvas))
			Width = OutputWidth()
			Box(0, 0, Width, OutputHeight(), \BackColor[#Cold])
			
			BackColor(\BackColor[#Cold])
			FrontColor(\FrontColor[#Cold])
			
			DrawingFont(\Font)
			
			ForEach \MenuItems()
				If \State = Item
					Box(0, Item * \ItemHeight, Width, \ItemHeight, \BackColor[#Hot])
					
					If \MenuItems()\Disabled
						DrawText(#Style_HMargin, Item * \ItemHeight + \VMargin, \MenuItems()\Text, \FrontColor[#Disabled], \BackColor[#Hot])
					Else
						DrawText(#Style_HMargin, Item * \ItemHeight + \VMargin, \MenuItems()\Text, \FrontColor[#Hot], \BackColor[#Hot])
					EndIf
					
					Select \MenuItems()\Type
						Case #SubMenu
							DrawingFont(#PB_Default )
							DrawText(Width - #Style_HMargin + #Style_Border, Item * \ItemHeight + (\ItemHeight - TextHeight(">")) * 0.5, ">", \FrontColor[#Hot], \BackColor[#Hot])
							DrawingFont(\Font)
						Case #ToggleOn
							DrawingFont(#PB_Default )
							DrawText(Width - #Style_HMargin + #Style_Border, Item * \ItemHeight + (\ItemHeight - TextHeight("✓")) * 0.5, "✓", \FrontColor[#Hot], \BackColor[#Hot])
							DrawingFont(\Font)
					EndSelect
					
					
				Else
					If \MenuItems()\Disabled
						DrawText(#Style_HMargin, Item * \ItemHeight + \VMargin, \MenuItems()\Text, \FrontColor[#Disabled])
					Else
						DrawText(#Style_HMargin, Item * \ItemHeight + \VMargin, \MenuItems()\Text)
					EndIf
					
					Select \MenuItems()\Type
						Case #SubMenu
							DrawingFont(#PB_Default )
							DrawText(Width - #Style_HMargin + #Style_Border, Item * \ItemHeight + (\ItemHeight - TextHeight(">")) * 0.5, ">")
							DrawingFont(\Font)
						Case #ToggleOn
							DrawingFont(#PB_Default )
							DrawText(Width - #Style_HMargin + #Style_Border, Item * \ItemHeight + (\ItemHeight - TextHeight("✓")) * 0.5, "✓")
							DrawingFont(\Font)
					EndSelect
					
				EndIf
				
				Item + 1
			Next
			
			StopDrawing()
		EndWith
	EndProcedure
	
	Procedure Handler_Canvas()
		Protected *MenuData.MenuData = GetGadgetData(EventGadget()), State
		
		With *MenuData
			Select EventType()
				Case #PB_EventType_MouseEnter ;{
					If Not \Active
						
						If \ParentMenu And \ParentMenu\Active
						\ParentMenu\Active = #False
						ElseIf \ChildMenu And \ChildMenu\Active
							\ChildMenu\Active = #False
						EndIf
						
						\Active = #True
						SetActiveWindow(\MenuWindow)
						SetActiveGadget(\MenuCanvas)
					EndIf
					;}
				Case #PB_EventType_MouseMove ;{
					State = GetGadgetAttribute(\MenuCanvas, #PB_Canvas_MouseY) / \ItemHeight
					If State <> \State
						\State = State
						If SelectElement(\MenuItems(), State)
							
							If \SubMenuTimer > -1
								RemoveWindowTimer(\MenuWindow, #SubMenuTimer)
								\SubMenuTimer = -1
							EndIf
							
							If \SubMenuWindow > -1
								AddWindowTimer(\MenuWindow, #CloseMenuTimer, #SubMenuTimerDuration)
								\CloseMenuTimer = \SubMenuItem
							EndIf
							
							If \MenuItems()\SubMenu
								AddWindowTimer(\MenuWindow, #SubMenuTimer, #SubMenuTimerDuration + 1)
								\SubMenuTimer = State
							EndIf
							
							Redraw(\MenuWindow)
						EndIf
					EndIf
					
					If \ParentMenu
						If \ParentMenu\State = -1 And \ParentMenu\Visible
							\ParentMenu\State = \ParentMenu\SubMenuItem
							Redraw(\ParentMenu\MenuWindow)
						EndIf
					EndIf
					;}
				Case #PB_EventType_MouseLeave ;{
					If \SubMenuItem = \State
						AddWindowTimer(\MenuWindow, #CloseMenuTimer, #SubMenuTimerDuration)
						\CloseMenuTimer = \SubMenuItem
					Else
						\State = -1
						Redraw(\MenuWindow)
						If \SubMenuTimer > -1
							RemoveWindowTimer(\MenuWindow, #SubMenuTimer)
							\SubMenuTimer = -1
						EndIf
					EndIf
					;}
				Case #PB_EventType_KeyDown ;{ Keyboard navigation is incomplete
					Select GetGadgetAttribute(\MenuCanvas, #PB_Canvas_Key)
						Case #PB_Shortcut_Up ;{
							\State - 1
							If \State <= -1
								\State = ListSize(\MenuItems()) - 1
							EndIf
							
							SelectElement(\MenuItems(), \State)
							
							If \SubMenuTimer > -1
								RemoveWindowTimer(\MenuWindow, #SubMenuTimer)
								\SubMenuTimer = -1
							EndIf
							
							If \SubMenuWindow > -1
								AddWindowTimer(\MenuWindow, #CloseMenuTimer, #SubMenuTimerDuration)
								\CloseMenuTimer = \SubMenuItem
							EndIf
							
							If \MenuItems()\SubMenu
								AddWindowTimer(\MenuWindow, #SubMenuTimer, #SubMenuTimerDuration + 1)
								\SubMenuTimer = \State
							EndIf
							
							Redraw(\MenuWindow)
							;}
						Case #PB_Shortcut_Down ;{
							\State + 1
							If \State >= ListSize(\MenuItems())
								\State = 0
							EndIf
							
							SelectElement(\MenuItems(), \State)
							
							If \SubMenuTimer > -1
								RemoveWindowTimer(\MenuWindow, #SubMenuTimer)
								\SubMenuTimer = -1
							EndIf
							
							If \SubMenuWindow > -1
								AddWindowTimer(\MenuWindow, #CloseMenuTimer, #SubMenuTimerDuration)
								\CloseMenuTimer = \SubMenuItem
							EndIf
							
							If \MenuItems()\SubMenu
								AddWindowTimer(\MenuWindow, #SubMenuTimer, #SubMenuTimerDuration + 1)
								\SubMenuTimer = \State
							EndIf
							
							Redraw(\MenuWindow)
							;}
						Case #PB_Shortcut_Return ;{
							PostEvent(#PB_Event_Gadget, \MenuWindow, \MenuCanvas, #PB_EventType_LeftButtonDown)
							;}
						Case #PB_Shortcut_Right ;{
							If \State > -1
								
								SelectElement(\MenuItems(), \State)
								
								If \CloseMenuTimer > -1
									PostEvent(#PB_Event_Timer, EventWindow(), 0, 0, #CloseMenuTimer)
								EndIf
								
								If \SubMenuTimer > -1
									PostEvent(#PB_Event_Timer, EventWindow(), 0, 0, #SubMenuTimer)
								EndIf
								
								
								If \MenuItems()\SubMenu
									\Active = #False
									\MenuItems()\SubMenu\Active = #True
									\MenuItems()\SubMenu\State = 0
									Redraw(\MenuItems()\SubMenu\MenuWindow)
									
									SetActiveWindow(\MenuItems()\SubMenu\MenuWindow)
									SetActiveGadget(\MenuItems()\SubMenu\MenuCanvas)
								EndIf
								
							EndIf
							;}
						Case #PB_Shortcut_Left ;{
							If \ParentMenu
								\ParentMenu\Active = #True
								\Active = #False
								Hide(\MenuWindow)
							EndIf
							;}
					EndSelect
					;}
				Case #PB_EventType_LeftButtonDown ;{
					If \State > - 1
						SelectElement(\MenuItems(), \State)
					ElseIf \PreviousState > - 1
						SelectElement(\MenuItems(), \PreviousState)
					EndIf
					
					If Not \MenuItems()\Disabled
						Select \MenuItems()\Type
							Case #Default
								PostEvent(#PB_Event_Menu, \ParentWindow, \MenuItems()\ItemID)
								Hide(\MenuWindow, #True)
							Case #SubMenu
								If \CloseMenuTimer > -1
									PostEvent(#PB_Event_Timer, EventWindow(), 0, 0, #CloseMenuTimer)
								EndIf
								
								If \SubMenuTimer > -1
									PostEvent(#PB_Event_Timer, EventWindow(), 0, 0, #SubMenuTimer)
								EndIf
							Case #ToggleOn
								\MenuItems()\Type = #ToggleOff
								PostEvent(#PB_Event_Menu, \ParentWindow, \MenuItems()\ItemID)
								Redraw(\MenuWindow)
							Case #ToggleOff
								\MenuItems()\Type = #ToggleOn
								PostEvent(#PB_Event_Menu, \ParentWindow, \MenuItems()\ItemID)
								Redraw(\MenuWindow)
						EndSelect
					EndIf
					;}
			EndSelect
		EndWith
	EndProcedure
	
	Procedure Handler_WindowFocus()
		Protected Window = EventWindow(), *MenuData.MenuData = GetWindowData(Window)
		
		If *MenuData\Active
			Hide(Window)
		EndIf
	EndProcedure
	
	Procedure Handler_WindowTimer()
		Protected Window = EventWindow(), Timer = EventTimer(), *MenuData.MenuData = GetWindowData(Window)
		
		With *MenuData
			Select Timer
				Case #SubMenuTimer
					RemoveWindowTimer(Window, #SubMenuTimer)
					If \SubMenuTimer > -1
						\SubMenuItem = \SubMenuTimer
						\SubMenuTimer = -1
						SelectElement(\MenuItems(), \SubMenuItem)
						\SubMenuWindow = \MenuItems()\SubMenu\MenuWindow
						\ChildMenu = \MenuItems()\SubMenu
						Show(\SubMenuWindow, WindowX(\MenuWindow) + \MenuWidth - #Style_Border, WindowY(\MenuWindow) + \ItemHeight * \SubMenuItem)
					EndIf
				Case #CloseMenuTimer
					RemoveWindowTimer(Window, #CloseMenuTimer)
					
					If \CloseMenuTimer <> \State
						If \ChildMenu\State = -1
							Hide(\SubMenuWindow)
						EndIf
					EndIf
			EndSelect
		EndWith
		
	EndProcedure
	
	Procedure Hide(Window, CloseParents = #False)
		Protected *MenuData.MenuData = GetWindowData(Window)
		
		HideWindow(Window, #True)
		RemoveWindowTimer(Window, #SubMenuTimer)
		RemoveWindowTimer(Window, #CloseMenuTimer)
		
		If CloseParents And *MenuData\ParentMenu
			Hide(*MenuData\ParentMenu\MenuWindow, #True)
		ElseIf *MenuData\SubMenuWindow > - 1
			Hide(*MenuData\SubMenuWindow)
			*MenuData\SubMenuWindow = -1
		EndIf
		
		*MenuData\Visible = #False
		*MenuData\Active = #False
		
		If *MenuData\State > - 1
			*MenuData\PreviousState = *MenuData\State
		EndIf
		
		*MenuData\State = - 1
		Redraw(*MenuData\MenuWindow)
	EndProcedure
	;}
EndModule

CompilerIf #PB_Compiler_IsMainFile
	
	Global Menu, Menu2
	
	Procedure Handler_Window()
		End
	EndProcedure
	
	Procedure Menu()
		Protected Item = EventMenu()
		
		If Item = 1
			Debug "Menu Item 2 : " + FlatMenu::GetItemState(Menu, 1)
		ElseIf Item = 7
			FlatMenu::DeleteItem(Menu2, 3)
		Else
			Debug Item
		EndIf
	EndProcedure
	
	OpenWindow(0, 0, 0, 320, 240, "Flat Menu example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
	BindEvent(#PB_Event_CloseWindow, @Handler_Window())
	
	LoadFont(0, "Bebas Neue", 14, #PB_Font_HighQuality)
	
	Menu = FlatMenu::Create(0, FlatMenu::#DarkTheme)
	FlatMenu::SetColor(Menu, FlatMenu::#colorType_FrontHot, $FC70FF)
; 	FlatMenu::SetFont(Menu, 0)
	
	FlatMenu::AddItem(Menu, 0, -1, "Menu Item 1")
	FlatMenu::AddItem(Menu, 1, -1, "Menu Item 2", FlatMenu::#Toggle)
	Menu2 = FlatMenu::AddSubMenu(Menu, - 1, "Wow")
	FlatMenu::AddItem(Menu2, 4, -1, "Many elegant")
	FlatMenu::AddItem(Menu2, 5, -1, "Such flat")
	FlatMenu::AddItem(Menu2, 6, -1, "!!!")
 	FlatMenu::AddItem(Menu2, 7, -1, "Click to delete this very, very, very long item")
	FlatMenu::AddItem(Menu, 3, -1, "Menu Item 3")
	
	
	BindEvent(#PB_Event_Menu,@Menu())
	FlatMenu::DisableItem(Menu2, 1, #True)
	FlatMenu::SetItemState(Menu, 1, #True)
	
	Repeat
		Select WaitWindowEvent()
			Case #PB_Event_RightClick
				FlatMenu::Show(Menu)
		EndSelect
	ForEver
CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 398
; FirstLine = 85
; Folding = HACAZAAy
; EnableXP