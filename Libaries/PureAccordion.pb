CompilerIf Not Defined(ScrollBar, #PB_Module)
	IncludeFile "FlatScrollBar/ScrollBar.pbi"
CompilerEndIf

DeclareModule Accordion
	; Public variables and constants
	Enumeration
		#FrontColor = #PB_Gadget_FrontColor
		#BackColor = #PB_Gadget_BackColor
		#ColdColor
		#WarmColor
	EndEnumeration
	
	; Public procedures declaration
	Declare Gadget(Gadget, x, y, Width, Height)
	Declare AddSubGadget(Gadget, SubGadget, Text.s = "")
	
EndDeclareModule

Module Accordion
	EnableExplicit
	; Private variables and constants
	CompilerSelect #PB_Compiler_OS ; PB Gadget structure
		CompilerCase #PB_OS_Windows ;{
			Structure GadgetVT
				GadgetType.l
				SizeOf.l
				*GadgetCallback
				*FreeGadget
				*GetGadgetState
				*SetGadgetState
				*GetGadgetText
				*SetGadgetText
				*AddGadgetItem2
				*AddGadgetItem3
				*RemoveGadgetItem
				*ClearGadgetItemList
				*ResizeGadget
				*CountGadgetItems
				*GetGadgetItemState
				*SetGadgetItemState
				*GetGadgetItemText
				*SetGadgetItemText
				*OpenGadgetList2
				*GadgetX
				*GadgetY
				*GadgetWidth
				*GadgetHeight
				*HideGadget
				*AddGadgetColumn
				*RemoveGadgetColumn
				*GetGadgetAttribute
				*SetGadgetAttribute
				*GetGadgetItemAttribute2
				*SetGadgetItemAttribute2
				*SetGadgetColor
				*GetGadgetColor
				*SetGadgetItemColor2
				*GetGadgetItemColor2
				*SetGadgetItemData
				*GetGadgetItemData
				*GetRequiredSize
				*SetActiveGadget
				*GetGadgetFont
				*SetGadgetFont
				*SetGadgetItemImage
			EndStructure
			
			Structure PB_Gadget
				*Gadget
				*vt.GadgetVT
				UserData.i
				OldCallback.i
				Daten.i[4]
			EndStructure
			;}
		CompilerCase #PB_OS_Linux ;{
			CompilerError "Pleaze help?"
			;}
		CompilerCase #PB_OS_MacOS ;{
			CompilerError "Pleaze help?"
			;}
	CompilerEndSelect
	
	Enumeration ; Color scheme
		#Cold
		#Warm
		#Hot
	EndEnumeration
	
	Enumeration ; State
		#Folded
		#Unfolded
	EndEnumeration
	
	Structure Gadget
		Gadget.i
		Title.i
	EndStructure
	
	Structure Item
		Text.s
		Warm.b
		HoveringButton.b
		Canvas.i
		State.i
		YPos.i
		ContentHeight.i
		List GadgetList.Gadget()
		*Parent.GadgetData
	EndStructure
	
	Structure GadgetData
		VT.GadgetVT ;Must be the first element of this structure!
		*OriginalVT.GadgetVT
		Gadget.i
		ScrollArea.i
		
		Width.i
		Height.i
		InnerHeight.i
		
		ScrollBar.i
		ScrollBarVisible.i
		
		WindowColor.l
		TextColor.l
		FrontColor.l[3]
		
		GadgetListItem.l
		
		List ItemList.Item()
	EndStructure
	
	; Style
	#Style_Header_VMargin = 10
	#Style_Header_HMargin = 15
	#Style_Header_Height = 45
	#Style_Header_Icon_Height = #Style_Header_Height - 2 * #Style_Header_VMargin
	#Style_Header_Icon_Width = #Style_Header_Icon_Height / 5 * 3
	
	#Style_Header_FoldedIcon_VOffset = (#Style_Header_Height - #Style_Header_Icon_Height) * 0.5
	#Style_Header_FoldedIcon_HOffset = #Style_Header_HMargin + #Style_Header_Icon_Width
	
	#Style_Header_UnfoldedIcon_VOffset = (#Style_Header_Height - #Style_Header_Icon_Width) * 0.5
	#Style_Header_UnfoldedIcon_HOffset = #Style_Header_HMargin + #Style_Header_Icon_Height
	
	#Style_ScrollBar_Width = 12
	
	#Style_Content_VMargin = 10
	#Style_Content_HMargin = 15
	
	#Scroll_Step = 20
	
	Global Font= FontID(LoadFont(#PB_Any, "Rubik", 16, #PB_Font_HighQuality | #PB_Font_Bold))
	
	; Private procedures declaration
	Declare _FreeGadget(*this.PB_Gadget)
	Declare _ResizeGadget(*this.PB_Gadget, x, y, Width, Height)
	Declare _AddGadgetItem(*this.PB_Gadget, Position.l, Text.s, ImageID, Flag)
	Declare _OpenGadgetList(*this.PB_Gadget, GadgetItem)
	Declare _ClearGadgetItemList(*this.PB_Gadget)
	Declare _SetGadgetColor(*this.PB_Gadget, ColorType, Color)
	
	Declare HeightCheck(*GadgetData.GadgetData)
	Declare Fold(*Item.Item)
	Declare Redraw(*GadgetData.GadgetData, *Item.Item)
	Declare HandlerScrollArea(hWnd, Msg, wParam, lParam)
	Declare HandlerScrollBar()
	Declare HandlerCanvas()
	
	; Public procedures 
	Procedure Gadget(Gadget, x, y, Width, Height)
		Protected Result = ContainerGadget(Gadget, x, y, Width, Height, #PB_Container_BorderLess)
		
		If Result
			If Gadget = #PB_Any
				Gadget = Result
			EndIf
			
			Protected *this.PB_Gadget = IsGadget(Gadget)
			Protected *GadgetData.GadgetData = AllocateStructure(GadgetData)
 			CopyMemory(*this\vt, *GadgetData\vt, SizeOf(GadgetVT))
			
 			With *GadgetData
 				\ScrollArea = ScrollAreaGadget(#PB_Any, 0, 0, Width + GetSystemMetrics_(#SM_CXVSCROLL), Height, Width, Height, #Scroll_Step, #PB_ScrollArea_BorderLess)
 				
 				\OriginalVT = *this\VT
 				
 				; Procedures
 				\VT\FreeGadget = @_FreeGadget()
 				\VT\ResizeGadget = @_ResizeGadget()
 				\VT\AddGadgetItem2 = @_AddGadgetItem()
 				\VT\OpenGadgetList2 = @_OpenGadgetList()
 				\VT\ClearGadgetItemList = @_ClearGadgetItemList()
 				\VT\SetGadgetColor = @_SetGadgetColor()
 				; Data
 				\Width = Width
 				\Height = Height
 				\Gadget = Gadget
 				
				CloseGadgetList()
				CloseGadgetList()
 				
				\ScrollBar = ScrollBar::Gadget(#PB_Any, x + Width - #Style_ScrollBar_Width, y, #Style_ScrollBar_Width, Height, 0, Height, Height, #PB_ScrollBar_Vertical)
 				
 				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
 					; /!\ Those constants are depreciated : https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor
 					\WindowColor = $FF << 24 + GetSysColor_(#COLOR_WINDOW)
 					\TextColor = $000000
					\FrontColor[#Cold] = $FF << 24 + GetSysColor_(#COLOR_SCROLLBAR)
					\FrontColor[#Warm] = $FF << 24 + GetSysColor_(#COLOR_3DSHADOW)
					\FrontColor[#Hot]  = $FF << 24 + GetSysColor_(#COLOR_3DDKSHADOW)
					
					SetGadgetColor(\ScrollBar, #PB_Gadget_FrontColor, $FF << 24 + $867B78)
				CompilerElse
					\FrontColor[#Cold] = $C8C8C8 << 8 + $FF
					\FrontColor[#Warm] = $A0A0A0 << 8 + $FF
					\FrontColor[#Hot]  = $696969 << 8 + $FF
					
					SetGadgetColor(\ScrollBar, #PB_Gadget_FrontColor, $FF << 24 + $787B86)
				CompilerEndIf
			
				*this\VT = *GadgetData
				
				
				BindGadgetEvent(\ScrollBar, @HandlerScrollBar(), #PB_EventType_Change)
				SetGadgetData(\ScrollBar, *GadgetData)
				HideGadget(\ScrollBar, #True)
				
				SetProp_(GadgetID(\ScrollArea), "oldproc", SetWindowLongPtr_(GadgetID(\ScrollArea), #GWL_WNDPROC, @HandlerScrollArea()))
				SetProp_(GadgetID(\ScrollArea), "GadgetData", *GadgetData)
				SetGadgetData(\ScrollArea, *GadgetData)
				
				BindGadgetEvent(\ScrollBar, @HandlerScrollBar(), #PB_EventType_Change)
			EndWith
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure AddSubGadget(Gadget, SubGadget, Text.s = "")
		Protected *this.PB_Gadget = IsGadget(Gadget), *GadgetData.GadgetData = *this\VT, TitleGadget
		
		With *GadgetData
			If \GadgetListItem >= 0 And SelectElement(\ItemList(), \GadgetListItem)
				
				If Text = ""
					ResizeGadget(SubGadget, #Style_Content_HMargin, #Style_Header_Height + \ItemList()\ContentHeight + \ItemList()\YPos, \Width - 2 * #Style_Content_HMargin, #PB_Ignore)
				Else
					ResizeGadget(SubGadget, \Width - GadgetWidth(SubGadget) - #Style_Content_HMargin, #Style_Header_Height + \ItemList()\ContentHeight + \ItemList()\YPos, #PB_Ignore, #PB_Ignore)
					TitleGadget = TextGadget(#PB_Any, #Style_Content_HMargin, #Style_Header_Height + \ItemList()\ContentHeight + \ItemList()\YPos, \Width - GadgetWidth(SubGadget) - #Style_Content_HMargin * 2 - #Style_ScrollBar_Width, 15, Text)
					SetGadgetColor(TitleGadget, #PB_Gadget_BackColor, \WindowColor)
					SetGadgetColor(TitleGadget, #PB_Gadget_FrontColor, \TextColor)
				EndIf
				
				*GadgetData\ItemList()\ContentHeight + (#Style_Content_VMargin + GadgetHeight(SubGadget))
				
				HideGadget(SubGadget, #True)
				LastElement(\ItemList()\GadgetList())
				AddElement(\ItemList()\GadgetList())
				\ItemList()\GadgetList()\Gadget = SubGadget
				
				If TitleGadget
					\ItemList()\GadgetList()\Title = TitleGadget
					HideGadget(TitleGadget, #True)
				EndIf
				
			EndIf
		EndWith
		
	EndProcedure
	
	; Private procedures
	Procedure _FreeGadget(*this.PB_Gadget)
		Protected *GadgetData.GadgetData = *this\VT
		
		*this\VT = *GadgetData\OriginalVT
		FreeStructure(*GadgetData)
		CallFunctionFast(*this\vt\FreeGadget, *this)
	EndProcedure
	
	Procedure _ResizeGadget(*this.PB_Gadget, x, y, Width, Height)
		Protected *GadgetData.GadgetData = *this\VT
		
		*this\VT = *GadgetData\OriginalVT
		ResizeGadget(*GadgetData\Gadget, x, y, Width, Height)
		*this\VT = *GadgetData
		
		With *GadgetData
			\Width = GadgetWidth(*GadgetData\Gadget)
			\Height = GadgetHeight(*GadgetData\Gadget)
		EndWith
		
	EndProcedure
	
	Procedure _AddGadgetItem(*this.PB_Gadget, Position.l, Text.s, ImageID, Flag)
		Protected *GadgetData.GadgetData = *this\VT, *Item.Item
		
		With *GadgetData
			If Position < 0 Or Not SelectElement(\ItemList(), Position)
				LastElement(\ItemList())
			EndIf
			*Item = AddElement(\ItemList())
			*Item\Text = Text
			*Item\Parent = *GadgetData
			*Item\ContentHeight = #Style_Content_VMargin
			
			If ListIndex(\ItemList()) = 0
				*Item\YPos = 0
			Else
				PreviousElement(\ItemList())
				*Item\YPos = \ItemList()\YPos + #Style_Header_Height + \ItemList()\ContentHeight * \ItemList()\State
			EndIf
			
			OpenGadgetList(\ScrollArea)
			*Item\Canvas = CanvasGadget(#PB_Any, 0, *Item\YPos, \Width, #Style_Header_Height)
			SetGadgetData(*Item\Canvas, *Item)
			BindGadgetEvent(*Item\Canvas, @HandlerCanvas())
			Redraw(*GadgetData, *Item)
			
			\InnerHeight + #Style_Header_Height
			SetGadgetAttribute(\ScrollArea, #PB_ScrollArea_InnerHeight, \InnerHeight)
			
			CloseGadgetList()
		EndWith
	EndProcedure
	
	Procedure _OpenGadgetList(*this.PB_Gadget, GadgetItem)
		Protected *GadgetData.GadgetData = *this\VT
		
		OpenGadgetList(*GadgetData\ScrollArea)
		
		*GadgetData\GadgetListItem = GadgetItem
	EndProcedure
	
	Procedure _ClearGadgetItemList(*this.PB_Gadget)
		Protected *GadgetData.GadgetData = *this\VT
		
		With *GadgetData
			ForEach *GadgetData\ItemList()
				ForEach \ItemList()\GadgetList()
					FreeGadget(\ItemList()\GadgetList()\Gadget)
					If \ItemList()\GadgetList()\Title
						FreeGadget(\ItemList()\GadgetList()\Title)
					EndIf
				Next
				UnbindGadgetEvent(\ItemList()\Canvas, @HandlerCanvas())
				FreeGadget(\ItemList()\Canvas)
			Next
			
			ClearList(*GadgetData\ItemList())
		EndWith
	EndProcedure
	
	Procedure _SetGadgetColor(*this.PB_Gadget, ColorType, Color)
		Protected *GadgetData.GadgetData = *this\VT
		
		Select ColorType
			Case #FrontColor
				*GadgetData\TextColor = Color
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					*GadgetData\FrontColor[#Hot] = $FF << 24 + Color
				CompilerElse
					*GadgetData\FrontColor[#Hot] = Color << 8 + $FF
				CompilerEndIf
				
				ForEach *GadgetData\ItemList()
					Redraw(*GadgetData, @*GadgetData\ItemList())
				Next
			Case #BackColor 
				*GadgetData\WindowColor = Color
				SetGadgetColor(*GadgetData\ScrollArea, #PB_Gadget_BackColor, Color)
				
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					SetGadgetColor(*GadgetData\ScrollBar, ScrollBar::#Color_Back, $FF << 24 + Color)
				CompilerElse
					SetGadgetColor(*GadgetData\ScrollBar, ScrollBar::#Color_Back, Color << 8 + $FF)
				CompilerEndIf
				
				
			Case #ColdColor
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					*GadgetData\FrontColor[#Cold] = $FF << 24 + Color
				CompilerElse
					*GadgetData\FrontColor[#Cold] = Color << 8 + $FF
				CompilerEndIf
				
				SetGadgetColor(*GadgetData\ScrollBar, ScrollBar::#Color_Line, $FF << 24 + Color)
				
				ForEach *GadgetData\ItemList()
					Redraw(*GadgetData, @*GadgetData\ItemList())
				Next
			Case #WarmColor
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					*GadgetData\FrontColor[#Warm] = $FF << 24 + Color
				CompilerElse
					*GadgetData\FrontColor[#Warm] = Color << 8 + $FF
				CompilerEndIf
				
				ForEach *GadgetData\ItemList()
					Redraw(*GadgetData, @*GadgetData\ItemList())
				Next
		EndSelect
	EndProcedure
	
	Procedure Redraw(*GadgetData.GadgetData, *Item.Item)
		With *Item
			StartVectorDrawing(CanvasVectorOutput(\Canvas))
			AddPathBox(0, 0, *GadgetData\Width, *GadgetData\Height)
			
			If \Warm
				VectorSourceColor(*GadgetData\FrontColor[#Warm])
				FillPath()
				VectorSourceColor(*GadgetData\FrontColor[#Cold])
			Else
				VectorSourceColor(*GadgetData\FrontColor[#Cold])
				FillPath()
				VectorSourceColor(*GadgetData\FrontColor[#Warm])
			EndIf
			
			If \State = #Folded
				MovePathCursor(*GadgetData\Width - #Style_Header_FoldedIcon_HOffset, #Style_Header_FoldedIcon_VOffset)
				AddPathLine(0, #Style_Header_Icon_Height, #PB_Path_Relative)
				AddPathLine(#Style_Header_Icon_Width, #Style_Header_Icon_Height * -0.5, #PB_Path_Relative)
			Else
				MovePathCursor(*GadgetData\Width - #Style_Header_UnfoldedIcon_HOffset, #Style_Header_UnfoldedIcon_VOffset)
				AddPathLine(#Style_Header_Icon_Height, 0, #PB_Path_Relative)
				AddPathLine(#Style_Header_Icon_Height * -0.5, #Style_Header_Icon_Width, #PB_Path_Relative)
			EndIf
			
			ClosePath()
			FillPath()
			
			MovePathCursor(20, 11)
			VectorFont(Font)
			VectorSourceColor(*GadgetData\FrontColor[#Hot])
			DrawVectorText(\Text)
			
			StopVectorDrawing()
		EndWith
	EndProcedure
	
	Procedure HeightCheck(*GadgetData.GadgetData)
		With *GadgetData
			If \InnerHeight > \Height
				If Not \ScrollBarVisible
					\Width - #Style_ScrollBar_Width
					ForEach \ItemList()
						ResizeGadget(\ItemList()\Canvas, #PB_Ignore, #PB_Ignore, \Width, #PB_Ignore)
						Redraw(*GadgetData, @\ItemList())
						
						ForEach \ItemList()\GadgetList()
							If \ItemList()\GadgetList()\Title
								ResizeGadget(\ItemList()\GadgetList()\Gadget, GadgetX(\ItemList()\GadgetList()\Gadget) - #Style_ScrollBar_Width, #PB_Ignore, #PB_Ignore, #PB_Ignore)
							Else
								ResizeGadget(\ItemList()\GadgetList()\Gadget, #PB_Ignore, #PB_Ignore, \Width - 2 * #Style_Content_HMargin, #PB_Ignore)
							EndIf
						Next
					Next
					\ScrollBarVisible = #True
					ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, \Width, #PB_Ignore)
					HideGadget(\ScrollBar, #False)
				EndIf
			Else
				If \ScrollBarVisible
					\Width + #Style_ScrollBar_Width
					
					ForEach \ItemList()
						ResizeGadget(\ItemList()\Canvas, #PB_Ignore, #PB_Ignore, \Width, #PB_Ignore)
						Redraw(*GadgetData, @\ItemList())
						
						ForEach \ItemList()\GadgetList()
							If \ItemList()\GadgetList()\Title
								ResizeGadget(\ItemList()\GadgetList()\Gadget, GadgetX(\ItemList()\GadgetList()\Gadget) + #Style_ScrollBar_Width, #PB_Ignore, #PB_Ignore, #PB_Ignore)
							Else
								ResizeGadget(\ItemList()\GadgetList()\Gadget, #PB_Ignore, #PB_Ignore, \Width - 2 * #Style_Content_HMargin, #PB_Ignore)
							EndIf
						Next
					Next
					\ScrollBarVisible = #False
					ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, \Width, #PB_Ignore)
					HideGadget(\ScrollBar, #True)
					SetGadgetState(\ScrollBar, 0)
				EndIf
			EndIf
			
			SetGadgetAttribute(\ScrollBar, #PB_ScrollBar_Maximum, \InnerHeight)
			SetGadgetAttribute(*GadgetData\ScrollArea, #PB_ScrollArea_InnerHeight, *GadgetData\InnerHeight)

		EndWith
	EndProcedure
	
	Procedure Fold(*Item.Item)
		Protected *GadgetData.GadgetData = *Item\Parent
		
		With *Item
			ChangeCurrentElement(*GadgetData\ItemList(), *Item)
			
			
			ForEach *Item\GadgetList()
				HideGadget(\GadgetList()\Gadget, \State)
				If \GadgetList()\Title
					HideGadget(\GadgetList()\Title, \State)
				EndIf
			Next
			
			; So, we have to move the gadget in a different order to avoid overlapping and (drawing bugs)
			; In my tests, it was only a problem with the web gadget; InvalidateRect_ didn't help either (webgadget didn't redraw either, it seems to refresh as it pleases)
			If \State 
				*GadgetData\InnerHeight - \ContentHeight
				While NextElement(*GadgetData\ItemList())
					ForEach *GadgetData\ItemList()\GadgetList()
						ResizeGadget(*GadgetData\ItemList()\GadgetList()\Gadget, #PB_Ignore, GadgetY(*GadgetData\ItemList()\GadgetList()\Gadget) - \ContentHeight, #PB_Ignore, #PB_Ignore)
						If *GadgetData\ItemList()\GadgetList()\Title
							ResizeGadget(*GadgetData\ItemList()\GadgetList()\Title, #PB_Ignore, GadgetY(*GadgetData\ItemList()\GadgetList()\Title) - \ContentHeight, #PB_Ignore, #PB_Ignore)
						EndIf
					Next
					
					ResizeGadget(*GadgetData\ItemList()\Canvas, #PB_Ignore, GadgetY(*GadgetData\ItemList()\Canvas) - \ContentHeight, #PB_Ignore, #PB_Ignore)
				Wend
			Else
				*GadgetData\InnerHeight + \ContentHeight
				LastElement(*GadgetData\ItemList())
				Repeat
					If *Item = @*GadgetData\ItemList()
						Break
					EndIf
					
					LastElement(*GadgetData\ItemList()\GadgetList())
					
					Repeat
						ResizeGadget(*GadgetData\ItemList()\GadgetList()\Gadget, #PB_Ignore, GadgetY(*GadgetData\ItemList()\GadgetList()\Gadget) + \ContentHeight, #PB_Ignore, #PB_Ignore)
						If *GadgetData\ItemList()\GadgetList()\Title
							ResizeGadget(*GadgetData\ItemList()\GadgetList()\Title, #PB_Ignore, GadgetY(*GadgetData\ItemList()\GadgetList()\Title) + \ContentHeight, #PB_Ignore, #PB_Ignore)
						EndIf
					Until Not PreviousElement(*GadgetData\ItemList()\GadgetList())
					
					ResizeGadget(*GadgetData\ItemList()\Canvas, #PB_Ignore, GadgetY(*GadgetData\ItemList()\Canvas) + \ContentHeight, #PB_Ignore, #PB_Ignore)
					
				Until Not PreviousElement(*GadgetData\ItemList())
			EndIf
			
			HeightCheck(*GadgetData.GadgetData)
			
			\State = Bool(Not \State)
			
			Redraw(\Parent, *Item)
		EndWith
	EndProcedure
	
	Procedure HandlerScrollArea(hWnd, Msg, wParam, lParam)
		Protected oldproc = GetProp_(hWnd, "oldproc")
		
		If Msg = #WM_VSCROLL
			Protected *GadgetData.GadgetData = GetProp_(hWnd, "GadgetData")
			SetGadgetState(*GadgetData\ScrollBar, (wParam >> 16) & $FFFF)
		EndIf
		
		ProcedureReturn CallWindowProc_(oldproc, hWnd, Msg, wParam, lParam)
	EndProcedure
	
	Procedure HandlerScrollBar()
		Protected Gadget = EventGadget(), *GadgetData.GadgetData = GetGadgetData(Gadget)
		
		SetGadgetAttribute(*GadgetData\ScrollArea, #PB_ScrollArea_Y, GetGadgetState(Gadget))
		
	EndProcedure
	
	Procedure HandlerCanvas()
		Protected Gadget = EventGadget(), *Item.Item = GetGadgetData(Gadget)
		Protected MouseX, MouseY
		
		With *Item
			Select EventType()
				Case #PB_EventType_MouseEnter ;{
					\Warm = #True
					Redraw(\Parent, *Item)
					;}
				Case #PB_EventType_MouseLeave ;{
					\Warm = #False
					Redraw(\Parent, *Item)
					;}
				Case #PB_EventType_MouseMove ;{
					MouseX = GetGadgetAttribute(\Canvas, #PB_Canvas_MouseX)
					MouseY = GetGadgetAttribute(\Canvas, #PB_Canvas_MouseY)
					If (MouseX > \Parent\Width - #Style_Header_UnfoldedIcon_HOffset And
					   MouseX < \Parent\Width - #Style_Header_HMargin And
					   MouseY > #Style_Header_foldedIcon_VOffset And
					   MouseY < #Style_Header_foldedIcon_VOffset + #Style_Header_Icon_Height)
					   
						If \HoveringButton = #False
							\HoveringButton = #True
							SetGadgetAttribute(\Canvas, #PB_Canvas_Cursor, #PB_Cursor_Hand)
						EndIf
					Else
						If \HoveringButton = #True
							\HoveringButton = #False
							SetGadgetAttribute(\Canvas, #PB_Canvas_Cursor, #PB_Cursor_Default)
						EndIf
					EndIf
					;}
				Case #PB_EventType_LeftDoubleClick ;{
					If Not \HoveringButton
						Fold(*Item)
					EndIf
					;}
				Case #PB_EventType_LeftClick ;{
					If \HoveringButton
						Fold(*Item)
					EndIf
					;}
				Case #PB_EventType_MouseWheel ;{
					If *Item\Parent\ScrollBarVisible
						; Doesn't work. Is it a bug? Did I do something stupid?
						SetGadgetAttribute(*Item\Parent\ScrollArea, #PB_ScrollArea_X, GetGadgetAttribute(*Item\Parent\ScrollArea, #PB_ScrollArea_X) - #Scroll_Step * GetGadgetAttribute(*Item\Canvas, #PB_Canvas_WheelDelta))
					EndIf
					;}
			EndSelect
		EndWith
	EndProcedure
EndModule

CompilerIf #PB_Compiler_IsMainFile
	OpenWindow(0, 0, 0 , 800, 600, "Accordion demo", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
	
	Accordion::Gadget(0, 10, 10, WindowWidth(0) - 20, WindowHeight(0) - 20)
	
	SetGadgetColor(0, #PB_Gadget_BackColor, $482E27)
	SetGadgetColor(0, #PB_Gadget_FrontColor, $D0D0D0)
	SetGadgetColor(0, Accordion::#ColdColor, $3A231A)
	SetGadgetColor(0, Accordion::#WarmColor, $5A433D)
	
	AddGadgetItem(0, -1, "Testouille")
	AddGadgetItem(0, -1, "Testouille 2")
	OpenGadgetList(0, 0)
	Accordion::AddSubGadget(0, StringGadget(#PB_Any, 0, 0, 200, 20, "Un truc seul? Automatiquement étiré (￣_,￣ )"))
	Accordion::AddSubGadget(0, StringGadget(#PB_Any, 0, 0, 200, 20, "Oooooh! Fancy!"), "Avec un label?")
	CloseGadgetList()
	
	OpenGadgetList(0, 1)
	
	Accordion::AddSubGadget(0, SpinGadget(#PB_Any, 0, 0, 200, 20, 100, 500), "Plus complexe?")
	CloseGadgetList()
	
	AddGadgetItem(0, -1, "Testouille 3")
	OpenGadgetList(0, 2)
	Accordion::AddSubGadget(0, CalendarGadget(#PB_Any, 0, 0, 230, 180), "Affiche moi un calendrier")
	Accordion::AddSubGadget(0, WebGadget(#PB_Any, 0, 0, 250, 235, "https://lastlife.net/"), "Et du web?")
	CloseGadgetList()
	
	
	Repeat
	Until WaitWindowEvent() = #PB_Event_CloseWindow
CompilerEndIf
; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 202
; FirstLine = 175
; Folding = -D9BB+
; EnableXP