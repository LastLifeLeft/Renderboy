DeclareModule ScrollBar
	#Default = 0
	#Vertical = #PB_ScrollBar_Vertical
	
	#Attribute_Minimum = #PB_ScrollBar_Minimum
	#Attribute_Maximum = #PB_ScrollBar_Maximum
	#Attribute_PageLength = #PB_ScrollBar_PageLength
	
	#Color_Back = #PB_Gadget_BackColor
	#Color_Line = #PB_Gadget_LineColor
	#Color_Front = #PB_Gadget_FrontColor
	#Color_FrontWarm = 10
	#Color_FrontHot = 11
	
	Declare.i Gadget(Gadget, x, y, Width, Height, Minimum, Maximum, PageLength, Flags = #Default)
EndDeclareModule

Module ScrollBar
	EnableExplicit
	
	Enumeration ; PageState
		#Cold
		#Warm
		#Hot
	EndEnumeration
	
	#Style_Margin = 2
	
	CompilerSelect #PB_Compiler_OS
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
			Structure GadgetVT
				SizeOf.l
				GadgetType.l
				*ActivateGadget
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
				*SetGadgetFont
				*OpenGadgetList2
				*AddGadgetColumn
				*GetGadgetAttribute
				*SetGadgetAttribute
				*GetGadgetItemAttribute2
				*SetGadgetItemAttribute2
				*RemoveGadgetColumn
				*SetGadgetColor
				*GetGadgetColor
				*SetGadgetItemColor2
				*GetGadgetItemColor2
				*SetGadgetItemData
				*GetGadgetItemData
				*GetGadgetFont
				*SetGadgetItemImage
				*HideGadget ;Mac & Windows only
			EndStructure
			
			Structure PB_Gadget
				*Gadget
				*GadgetContainer
				*vt.GadgetVT
				UserData.i
				Daten.i[4]
			EndStructure ;}
		CompilerCase #PB_OS_MacOS ;{
			Structure PB_Gadget
				*Gadget
				*Container
				*Functions	; ??
				UserData.i
				WindowID.i
				Type.l
				Flags.l
			EndStructure
			CompilerError "MacOS isn't supported, sorry."
			;}
	CompilerEndSelect
	
	Structure GadgetData
		VT.GadgetVT ;Must be the first element of this structure!
		*OriginalVT.GadgetVT
		
		Gadget.i
		Minimum.i
		Maximum.i
		PageLength.i
		Vertical.b
		
		State.i
		
		Width.i
		Height.i
		
		PageSize.i
		PagePosition.i
		PageState.i
		PageUpperLimit.i
		
		PreviousMouse.i
		
		StepSize.f
		
		BackColor.l
		FrontColor.l[3]
		LineColor.l
	EndStructure
	
	Procedure Min(a, b)
		If b < a
			ProcedureReturn b
		EndIf
		ProcedureReturn a
	EndProcedure
	Procedure Max(a, b)
		If b > a
			ProcedureReturn b
		EndIf
		ProcedureReturn a
	EndProcedure
	Declare AddPathRoundedBox(x, y, Width, Height, Radius, Flag = #PB_Path_Default)
	Declare Redraw(*This.PB_Gadget)
	Declare Handler()
	Declare _ResizeGadget(*this.PB_Gadget, x, y, w, h)
	Declare _GetGadgetColor(*this.PB_Gadget, ColorType)
	Declare _SetGadgetColor(*this.PB_Gadget, ColorType, Color)
	Declare _GetGadgetState(*this.PB_Gadget)
	Declare _SetGadgetState(*this.PB_Gadget, State.i)
	Declare _SetGadgetAttribute(*this.PB_Gadget, Attribute, Value)
	Declare _GetGadgetAttribute(*this.PB_Gadget, Attribute)
	Declare _FreeGadget(*this.PB_Gadget)
	Macro CalculateSize
		If \Vertical
			\PageSize = Round(\PageLength / (\Maximum - \Minimum + 1) * (\Height - #Style_Margin * 2 ), #PB_Round_Nearest)
			\StepSize = (\Height - #Style_Margin * 2 ) / (\Maximum - \Minimum + 1)
			\PageUpperLimit = max((\Height - #Style_Margin * 2 ) - \PageSize, 0)
		Else
			\PageSize = Round(\PageLength / (\Maximum - \Minimum + 1) * (\Width - #Style_Margin * 2 ), #PB_Round_Nearest)
			\StepSize = (\Width - #Style_Margin * 2 ) / (\Maximum - \Minimum + 1)
			\PageUpperLimit = max((\Width - #Style_Margin * 2 ) - \PageSize, 0)
		EndIf
	EndMacro
	
	Procedure.i Gadget(Gadget, x, y, Width, Height, Minimum, Maximum, PageLength, Flags = #Default)
		Protected Result = CanvasGadget(Gadget, x, y, Width, Height)
		If Result
			If Gadget = #PB_Any
				Gadget = result
			EndIf
			
			Protected *this.PB_Gadget = IsGadget(Gadget)
			Protected *GadgetData.GadgetData = AllocateStructure(GadgetData)
 			CopyMemory(*this\vt, *GadgetData\vt, SizeOf(GadgetVT))
			
			With *GadgetData
				\OriginalVT = *this\VT
				
				\VT\FreeGadget = @_FreeGadget()
				\VT\ResizeGadget = @_ResizeGadget()
				\VT\GetGadgetState = @_GetGadgetState()
				\VT\SetGadgetState = @_SetGadgetState()
				\VT\GetGadgetColor = @_GetGadgetColor()
				\VT\SetGadgetColor = @_SetGadgetColor()
				\VT\GetGadgetAttribute = @_GetGadgetAttribute()
				\VT\SetGadgetAttribute = @_SetGadgetAttribute()   
				
				\Gadget = Gadget
				\Minimum = Minimum
				\Maximum = Max(Maximum, \Minimum + 1)
				\PageLength = PageLength
				
				\PageState = #Cold
				
				\Vertical = Bool(Flags & #PB_ScrollBar_Vertical)
				
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					\BackColor = $FF << 24 + GetSysColor_(#COLOR_3DFACE)
					\FrontColor[#Cold] = $FF << 24 + GetSysColor_(#COLOR_SCROLLBAR)
					\FrontColor[#Warm] = $FF << 24 + GetSysColor_(#COLOR_3DSHADOW)
					\FrontColor[#Hot]  = $FF << 24 + GetSysColor_(#COLOR_3DDKSHADOW)
					\LineColor = $FF << 24 + GetSysColor_(#COLOR_3DFACE)
				CompilerElse
					\BackColor = $F0F0F0 << 8 + $FF
					\FrontColor[#Cold] = $C8C8C8 << 8 + $FF
					\FrontColor[#Warm] = $A0A0A0 << 8 + $FF
					\FrontColor[#Hot]  = $696969 << 8 + $FF
					\LineColor = $F0F0F0 << 8 + $FF
				CompilerEndIf
				
				\Width = Width
				\Height = Height
				
				CalculateSize
			EndWith
			
			*this\VT = *GadgetData
			
			BindGadgetEvent(Gadget, @Handler())
			Redraw(*GadgetData)
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	
	;{ Private procedures
	Procedure AddPathRoundedBox(x, y, Width, Height, Radius, Flag = #PB_Path_Default)
		MovePathCursor(x, y + Radius, Flag)
		
		AddPathArc(0, Height - radius, Width, Height - radius, Radius, #PB_Path_Relative)
		AddPathArc(Width - Radius, 0, Width - Radius, - Height, Radius, #PB_Path_Relative)
		AddPathArc(0, Radius - Height, -Width, Radius - Height, Radius, #PB_Path_Relative)
		AddPathArc(Radius - Width, 0, Radius - Width, Height, Radius, #PB_Path_Relative)
		ClosePath()
		
		MovePathCursor(-x,-y-Radius, Flag)
	EndProcedure
	
	Procedure Redraw(*GadgetData.GadgetData)
		With *GadgetData
			StartVectorDrawing(CanvasVectorOutput(\Gadget))
			AddPathBox(0, 0, \Width, \Height)
			VectorSourceColor(\BackColor)
			FillPath()
			
			If \Vertical
				AddPathRoundedBox(#Style_Margin, #Style_Margin, \Width - 2 * #Style_Margin, \Height - 2 * #Style_Margin, (\Width - 2 * #Style_Margin) * 0.5)
				VectorSourceColor(\LineColor)
				FillPath()
				AddPathRoundedBox(#Style_Margin, #Style_Margin + \PagePosition, \Width - 2 * #Style_Margin, \PageSize, (\Width - 2 * #Style_Margin) * 0.5)
			Else
				AddPathRoundedBox(#Style_Margin, #Style_Margin, \Width - 2 * #Style_Margin, \Height - 2 * #Style_Margin, (\Height - 2 * #Style_Margin) * 0.5)
				VectorSourceColor(\LineColor)
				FillPath()
				AddPathRoundedBox(#Style_Margin + \PagePosition, #Style_Margin, \PageSize, \Height - 2 * #Style_Margin, (\Height - 2 * #Style_Margin) * 0.5)
			EndIf

			VectorSourceColor(\FrontColor[\PageState])
			FillPath()
			
		EndWith
		StopVectorDrawing()
	EndProcedure
	
	Procedure Handler()
		Protected Mouse, Gadget = EventGadget()
		Protected *this.PB_Gadget = IsGadget(Gadget), *GadgetData.GadgetData = *this\vt, PageState = *GadgetData\PageState, State
		
		Select EventType()
			Case #PB_EventType_MouseMove ;{
				If *GadgetData\Vertical
					Mouse = CallFunctionFast(*GadgetData\OriginalVT\GetGadgetAttribute, *this, #PB_Canvas_MouseY)
				Else
					Mouse = CallFunctionFast(*GadgetData\OriginalVT\GetGadgetAttribute, *this, #PB_Canvas_MouseX)
				EndIf
				
				If *GadgetData\PageState = #Hot
					*GadgetData\PagePosition = *GadgetData\PagePosition + (Mouse - *GadgetData\PreviousMouse)
					
					If *GadgetData\PagePosition < 0
						*GadgetData\PagePosition = 0
					ElseIf *GadgetData\PagePosition > *GadgetData\PageUpperLimit
						*GadgetData\PagePosition = *GadgetData\PageUpperLimit
					Else
						*GadgetData\PreviousMouse = Mouse
					EndIf
					
					Redraw(*GadgetData)
					
					State = Round(*GadgetData\PagePosition / *GadgetData\StepSize, #PB_Round_Nearest)
					If Not *GadgetData\State = State 
						*GadgetData\State = State 
						PostEvent(#PB_Event_Gadget, EventWindow(), *GadgetData\Gadget, #PB_EventType_Change, *GadgetData\State)
					EndIf
				Else
					If Mouse >= *GadgetData\PagePosition And Mouse <= *GadgetData\PagePosition + *GadgetData\PageSize
						PageState = #Warm
					Else
						PageState = #Cold
					EndIf
				EndIf
				;}
			Case #PB_EventType_MouseLeave ;{
				If PageState = #Warm
					PageState = #Cold
				EndIf
				;}
			Case #PB_EventType_LeftButtonDown ;{
				If *GadgetData\PageState = #Warm
					PageState = #Hot
					
					If *GadgetData\Vertical
						*GadgetData\PreviousMouse = CallFunctionFast(*GadgetData\OriginalVT\GetGadgetAttribute, *this, #PB_Canvas_MouseY)
					Else
						*GadgetData\PreviousMouse = CallFunctionFast(*GadgetData\OriginalVT\GetGadgetAttribute, *this, #PB_Canvas_MouseX)
					EndIf
				Else
					If *GadgetData\Vertical
						Mouse = CallFunctionFast(*GadgetData\OriginalVT\GetGadgetAttribute, *this, #PB_Canvas_MouseY)
					Else
						Mouse = CallFunctionFast(*GadgetData\OriginalVT\GetGadgetAttribute, *this, #PB_Canvas_MouseX)
					EndIf
					
					If Mouse > *GadgetData\PagePosition
						*GadgetData\State = min(*GadgetData\State + 10, *GadgetData\Maximum - *GadgetData\PageLength + 1)
					Else
						*GadgetData\State = max(*GadgetData\State - 10, 0)
					EndIf
					
					
					*GadgetData\PagePosition = *GadgetData\State * *GadgetData\StepSize
					Redraw(*GadgetData)
					
					PostEvent(#PB_Event_Gadget, EventWindow(), *GadgetData\Gadget, #PB_EventType_Change, *GadgetData\State)
				EndIf
				;}
			Case #PB_EventType_LeftButtonUp ;{
				If *GadgetData\PageState = #Hot
					PageState = #Warm
					*GadgetData\PagePosition = *GadgetData\State * *GadgetData\StepSize
				EndIf
				;}
		EndSelect
		
		If *GadgetData\PageState <> PageState
			*GadgetData\PageState = PageState
			Redraw(*GadgetData)
		EndIf
	EndProcedure
	
	Procedure _ResizeGadget(*this.PB_Gadget, x, y, Width, Height) ; Ok
		Protected *GadgetData.GadgetData = *this\VT
		
		*this\VT = *GadgetData\OriginalVT
		ResizeGadget(*GadgetData\Gadget, x, y, Width, Height)
		*this\VT = *GadgetData
		
		With *GadgetData
			\Width = GadgetWidth(*GadgetData\Gadget)
			\Height = GadgetHeight(*GadgetData\Gadget)
			
			CalculateSize
		EndWith
		
		Redraw(*GadgetData)
		
	EndProcedure
	
	Procedure _GetGadgetColor(*this.PB_Gadget, ColorType)
		Protected *GadgetData.GadgetData = *this\VT, Result
		
		With *GadgetData
			Select ColorType
				Case #Color_Back
					Result =  \BackColor
				Case #Color_Line
					Result = \LineColor
				Case #Color_Front
					Result = \FrontColor[#Cold]
				Case #Color_FrontWarm
					Result = \FrontColor[#Warm]
				Case #Color_FrontHot
					Result = \FrontColor[#Hot]
			EndSelect
		EndWith
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure _SetGadgetColor(*this.PB_Gadget, ColorType, Color) ; Ok
		Protected *GadgetData.GadgetData = *this\VT, Result
		
		With *GadgetData
			Select ColorType
				Case #Color_Back
					\BackColor = Color
				Case #Color_Line
					\LineColor = Color
				Case #Color_Front
					\FrontColor[#Cold] = Color
				Case #Color_FrontWarm
					\FrontColor[#Warm] = Color
				Case #Color_FrontHot
					\FrontColor[#Hot] = Color
			EndSelect
		EndWith
	EndProcedure
	
	Procedure _GetGadgetState(*this.PB_Gadget) ; Ok
		Protected *GadgetData.GadgetData = *this\VT
		ProcedureReturn *GadgetData\State
	EndProcedure
	
	Procedure _SetGadgetState(*this.PB_Gadget, State.i) ; Ok
		Protected *GadgetData.GadgetData = *this\VT
		
		With *GadgetData
			State = Max(State, 0)
			\PagePosition = State * \StepSize
			
			If \PagePosition < 0
				\PagePosition = 0
			ElseIf \PagePosition > \PageUpperLimit
				\PagePosition = \PageUpperLimit
			EndIf
			
			\State = \PagePosition / \StepSize
		EndWith
		
		Redraw(*GadgetData)
	EndProcedure
	
	Procedure _SetGadgetAttribute(*this.PB_Gadget, Attribute, Value) ; Ok
		Protected *GadgetData.GadgetData = *this\vt
		
		With *GadgetData
			Select Attribute
				Case #PB_ScrollBar_Minimum
					\Minimum = Min(Value, \Maximum - 1)
				Case #PB_ScrollBar_Maximum
					\Maximum = Max(Value, \Minimum + 1)
				Case #PB_ScrollBar_PageLength
					\PageLength = Value
			EndSelect
			
			CalculateSize
			
			If \PagePosition < 0
				\PagePosition = 0
			ElseIf \PagePosition > \PageUpperLimit
				\PagePosition = \PageUpperLimit
			EndIf
			
			\State = \PagePosition / \StepSize
			
		EndWith
	
		Redraw(*GadgetData)
	EndProcedure
	
	Procedure _GetGadgetAttribute(*this.PB_Gadget, Attribute) ; Ok
		Protected *GadgetData.GadgetData = *this\vt, Result
		
		Select Attribute
			Case #PB_ScrollBar_Minimum
				Result = *GadgetData\Minimum
			Case #PB_ScrollBar_Maximum
				Result = *GadgetData\Maximum
			Case #PB_ScrollBar_PageLength
				Result = *GadgetData\PageLength
		EndSelect
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure _FreeGadget(*this.PB_Gadget) ; Ok
		Protected *GadgetData.GadgetData = *this\VT
		
		*this\VT = *GadgetData\OriginalVT
		FreeStructure(*GadgetData)
		CallFunctionFast(*this\vt\FreeGadget, *this)
	EndProcedure
EndModule

CompilerIf #PB_Compiler_IsMainFile
	Procedure Testouille()
	EndProcedure
	
	OpenWindow(0, 0, 0, 600, 400, "Material ScrollBar Demo", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
	
	ScrollBar::Gadget(1, 0, 388, 588, 12, 0, 2, 1)
	ScrollBar::Gadget(2, 588, 0, 12, 388, 0, 4, 1, #PB_ScrollBar_Vertical)
	
	Repeat
	Until WaitWindowEvent() = #PB_Event_CloseWindow
CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 457
; FirstLine = 37
; Folding = CASE59
; EnableXP