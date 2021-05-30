; IncludeFile "..\MaterialVector\MaterialVector.pbi" ; Include https://github.com/LastLifeLeft/MaterialVector ahead of this module to autmatically use materialvector icon as image. 

DeclareModule CanvasButton
	EnumerationBinary
		#Default = 0
		CompilerIf Defined(MaterialVector, #PB_Module)
			#MaterialVector
		CompilerEndIf
		#DarkTheme
		#Inline
		#Toggle
		#Outline
		#Rounded
		#Rounded_Left
		#Rounded_Right
		#Rounded_Down
		#Rounded_Up
	EndEnumeration
	
	Enumeration
		#FrontColor_Cold = #PB_Gadget_FrontColor
		#BackColor_Cold  = #PB_Gadget_BackColor 
		#FrontColor_Warm = 10
		#FrontColor_Hot
		#BackColor_Warm
		#BackColor_Hot 
	EndEnumeration

	Declare.i Gadget(Gadget, x, y, Width, Height, Text.s = "", Image = -1 , Flags = #Default)
EndDeclareModule

Module CanvasButton
	EnableExplicit
	
	;{ Variables, structures, constants...
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
	
	Enumeration ;States
		#Cold
		#Warm
		#Hot
	EndEnumeration
	
	Enumeration ; RoundDirection
		#None = 0
		#All
		#Up
		#Down
		#Left
		#Right
	EndEnumeration
	
	Prototype ProtoRedraw(*GadgetData)
	
	Structure GadgetData
		VT.GadgetVT ;Must be the first element of this structure!
		*OriginalVT.GadgetVT
		
		Gadget.i
		Inline.b
		Toggle.b
		Outline.b
		Rounded.b
		
		State.b
		ToggleState.b
		
		Image.i
		ImageWidth.l
		ImageHeight.l
		ImageX.l
		ImageY.l
		
		BackColor.l[3]
		FrontColor.l[3]
		
		Height.l
		Width.l
		
		Font.i
		Text.s
		TextWidth.l
		TextHeight.l
		TextX.l
		TextY.l
		
		CompilerIf Defined(MaterialVector, #PB_Module)
			MaterialVector.b
			Flag.i
		CompilerEndIf
		
		Redraw.ProtoRedraw
	EndStructure
	
	#Style_Dark_BackCold = $2F3136
	#Style_Dark_BackWarm = $34373C
	#Style_Dark_BackHot = $393C43
	
	#Style_Dark_FrontCold = $8E9297
	#Style_Dark_FrontWarm = $DCDDDE
	#Style_Dark_FrontHot = $FFFFFF
	
	#Style_Light_BackCold = $F2F3F5
	#Style_Light_BackWarm = $E8EAED
	#Style_Light_BackHot = $D4D7DC
	
	#Style_Light_FrontCold = $6A7480FF
	#Style_Light_FrontWarm = $2E3338
	#Style_Light_FrontHot = $060607
	
	Global DefaultFont = LoadFont(#PB_Any, "Calibri", 12, #PB_Font_HighQuality)
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
	
	Macro CalculateSizes
		CompilerIf Defined(MaterialVector, #PB_Module)
			\MaterialVector = \Flag & #MaterialVector
			
			If \MaterialVector
				
				If \Image > -1
					If \Width > \Height
						\ImageWidth = \Height * 0.5
					Else
						\ImageWidth = \Width * 0.5
					EndIf
					
					\ImageHeight = \ImageWidth
					\ImageX = (\Width - \ImageWidth) * 0.5
					\imageY = (\Height - \ImageHeight) * 0.5
				EndIf
			Else
		CompilerEndIf
				If \Image > -1
					\ImageWidth = ImageWidth(\Image)
					\ImageHeight = ImageHeight(\Image)
					\ImageX = (\Width - \ImageWidth) * 0.5
					\imageY = (\Height - \ImageHeight) * 0.5
				EndIf
		CompilerIf Defined(MaterialVector, #PB_Module)
			EndIf	
		CompilerEndIf
		
		If \Text <> ""
			CompilerIf Defined(MaterialVector, #PB_Module)
				If \MaterialVector
					StartVectorDrawing(CanvasVectorOutput(\Gadget))
					VectorFont(\Font)
					\TextWidth = VectorTextWidth(\Text)
					\TextHeight = VectorTextHeight(\Text)
					StopVectorDrawing()
				Else
			CompilerEndIf
					StartDrawing(CanvasOutput(\Gadget))
					DrawingFont(\Font)
					\TextWidth = TextWidth(\Text)
					\TextHeight = TextHeight(\Text)
					StopDrawing()
			CompilerIf Defined(MaterialVector, #PB_Module)
				EndIf
			CompilerEndIf
			
			\TextX = (\Width - \TextWidth) * 0.5
			\TextY = (\Height - \TextHeight) * 0.5
			
			If \Image > -1
				Margin = \TextHeight * 0.5
				
				If \Inline
					\ImageX = (\Width - \ImageWidth - \TextWidth - Margin) * 0.5
					\TextX = (\Width - \ImageWidth - \TextWidth) * 0.5 + \ImageWidth + Margin
				Else
					\TextY = \Height - \TextHeight - Margin
					\imageY = (\Height - \ImageHeight - (\Height - \TextY)) * 0.5
				EndIf
			EndIf
		EndIf
	EndMacro
	;}
	
	;{ Private procedures declaration
	Declare Handler()
	Declare Redraw(Gadget)
	CompilerIf Defined(MaterialVector, #PB_Module)
		Declare VectorRedraw(*GadgetData.GadgetData)
	CompilerEndIf
	Declare _ResizeGadget(*this.PB_Gadget, x, y, Width, Height)
	Declare _FreeGadget(*this.PB_Gadget)
	
	Declare _GetGadgetState(*this.PB_Gadget)
	Declare _GetGadgetColor(*this.PB_Gadget, ColorType)
	
	Declare _SetGadgetState(*this.PB_Gadget, State.i)
	Declare _SetGadgetColor(*this.PB_Gadget, ColorType, Color)
	
	Declare _SetGadgetFont(*this.PB_Gadget, Font)
	;}
	
	;{ Public procedures
	Procedure.i Gadget(Gadget, x, y, Width, Height, Text.s = "", Image = -1 , Flags = #Default)
		Protected Result = CanvasGadget(Gadget, x, y, Width, Height), Margin
		
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
				\VT\GetGadgetColor = @_GetGadgetColor()
				
				\VT\SetGadgetState = @_SetGadgetState()
				\VT\SetGadgetColor = @_SetGadgetColor()
				
				\VT\SetGadgetFont = @_SetGadgetFont()
				
				\Gadget = Gadget
				\Inline = Bool(Flags & #Inline)
				\Toggle = Bool(Flags & #Toggle)
				\Outline = Bool(Flags & #Outline) 
				\Rounded = Bool(Flags & #Rounded) * #All + Bool(Flags & #Rounded_Left) * #Left + Bool(Flags & #Rounded_Right) * #Right + Bool(Flags & #Rounded_Up) * #Up+ Bool(Flags & #Rounded_Down) * #Down
				
				\Font = FontID(DefaultFont)
				
				\State = #Cold
				
				If Flags & #DarkTheme
					\BackColor[#Cold] = SetAlpha($FF,  FixColor(#Style_Dark_BackCold))
					\BackColor[#Warm] = SetAlpha($FF,  FixColor(#Style_Dark_BackWarm))
					\BackColor[#Hot] =  SetAlpha($FF,  FixColor( #Style_Dark_BackHot))
					
					\FrontColor[#Cold] = SetAlpha($FF, FixColor(#Style_Dark_FrontCold))
					\FrontColor[#Warm] = SetAlpha($FF, FixColor(#Style_Dark_FrontWarm))
					\FrontColor[#Hot] =  SetAlpha($FF, FixColor( #Style_Dark_FrontHot))
				Else
					\BackColor[#Cold] = SetAlpha($FF,  FixColor(#Style_Light_BackCold))
					\BackColor[#Warm] = SetAlpha($FF,  FixColor(#Style_Light_BackWarm))
					\BackColor[#Hot] = SetAlpha( $FF,  FixColor( #Style_Light_BackHot))
					
					\FrontColor[#Cold] = SetAlpha($FF, FixColor(#Style_Light_FrontCold))
					\FrontColor[#Warm] = SetAlpha($FF, FixColor(#Style_Light_FrontWarm))
					\FrontColor[#Hot] =  SetAlpha($FF, FixColor( #Style_Light_FrontHot))
				EndIf
				
				\Width = Width
				\Height = Height
				\Image = Image
				\Text = Text
				
				\Redraw = @Redraw()
				
				CompilerIf Defined(MaterialVector, #PB_Module)
					\Flag = Flags
					If Flags & #MaterialVector
						\Redraw = @VectorRedraw()
					EndIf
				CompilerEndIf
				
				CalculateSizes
			EndWith
			
			*this\VT = *GadgetData
			
			BindGadgetEvent(Gadget, @Handler())
			*GadgetData\Redraw(*GadgetData)
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure Handler()
		Protected Gadget = EventGadget(), *this.PB_Gadget = IsGadget(Gadget), *GadgetData.GadgetData = *this\vt
		With *GadgetData
			Select EventType()
				Case #PB_EventType_MouseEnter
					\State = #Warm
					\Redraw(*GadgetData)
				Case #PB_EventType_MouseLeave
					If \ToggleState
						\State = #Hot
					Else
						\State = #Cold
					EndIf
					\Redraw(*GadgetData)
				Case #PB_EventType_LeftButtonDown
					If \ToggleState
						\State = #Cold
					Else
						\State = #Hot
					EndIf
					\Redraw(*GadgetData)
				Case #PB_EventType_LeftButtonUp
					Protected MouseX = GetGadgetAttribute(\Gadget, #PB_Canvas_MouseX), MouseY = GetGadgetAttribute(\Gadget, #PB_Canvas_MouseY)
					If MouseX >= 0 And MouseX <= \Width And MouseY >= 0 And MouseY <= \Height
						If \Toggle
							\ToggleState = Bool(Not \ToggleState)
						EndIf
						
						PostEvent(#PB_Event_Gadget, EventWindow(), \Gadget, #PB_EventType_Change)
					EndIf
					If \ToggleState
						\State = #Hot
					Else
						If \Toggle
							\State = #Cold
						Else
							\State = #Warm
						EndIf
					EndIf
					\Redraw(*GadgetData)
			EndSelect
		EndWith
		
	EndProcedure
	
	Procedure Redraw(*GadgetData.GadgetData)
		With *GadgetData
			StartDrawing(CanvasOutput(*GadgetData\Gadget))
			Box(0, 0, \Width, \Height, \BackColor[\State])
			
			If \Image > - 1
				DrawAlphaImage(ImageID(\Image), \ImageX, \imageY)
			EndIf
			
			If \Text <> ""
				DrawingFont(\Font)
				DrawText(\TextX, \TextY, \Text, \FrontColor[\State], \BackColor[\State])
			EndIf
			
			StopDrawing()
		EndWith
	EndProcedure
	
	CompilerIf Defined(MaterialVector, #PB_Module)
		Procedure VectorRedraw(*GadgetData.GadgetData)
			With *GadgetData
				StartVectorDrawing(CanvasVectorOutput(*GadgetData\Gadget))
				
				If \State = #Cold
					VectorSourceColor(\BackColor[#Cold])
					AddPathBox(0, 0, \Width, \Height)
					FillPath()
					
					If \Outline
						Select \Rounded
							Case #None
								AddPathBox(0.5, 0.5, \Width - 1, \Height - 1)
							Case #all
								MaterialVector::AddPathRoundedBox(0.5, 0.5, \Width - 1, \Height - 1, 3)
							Case #Up
							Case #Down
							Case #Left
								MaterialVector::AddPathRoundedBox(0.5, 0.5, \Width + 4, \Height - 1, 3)
								MovePathCursor(\Width-0.5, 0)
								AddPathLine(0,\Height, #PB_Path_Relative)
							Case #Right
								MaterialVector::AddPathRoundedBox(- 4.5, 0.5, \Width + 4, \Height - 1, 3)
								MovePathCursor(0.5, 0)
								AddPathLine(0,\Height, #PB_Path_Relative)
						EndSelect
						
						VectorSourceColor(\FrontColor[#Cold])
						StrokePath(1)
					EndIf
					
				ElseIf \Rounded
					VectorSourceColor(\BackColor[#Cold])
					AddPathBox(0, 0, \Width, \Height)
					FillPath()
					
					Select \Rounded
						Case #all
							MaterialVector::AddPathRoundedBox(0, 0, \Width, \Height, 3)
						Case #Up
						Case #Down
						Case #Left
							MaterialVector::AddPathRoundedBox(0, 0, \Width + 3, \Height, 3)
						Case #Right
							MaterialVector::AddPathRoundedBox(-3, 0, \Width + 3, \Height, 3)
					EndSelect
					
					VectorSourceColor(\BackColor[\State])
					FillPath()
				Else
					VectorSourceColor(\BackColor[\State])
					AddPathBox(0, 0, \Width, \Height)
					FillPath()
				EndIf
				
				
				If \Image > - 1
					MaterialVector::Draw(\Image, \ImageX, \imageY, \ImageWidth, \FrontColor[\State], \BackColor[\State], \Flag)
				EndIf
				
				If \Text <> ""
					VectorFont(\Font)
					VectorSourceColor(\FrontColor[\State])
					MovePathCursor(\TextX, \TextY)
					DrawVectorText(\Text)
				EndIf
				
				StopVectorDrawing()
			EndWith
		EndProcedure
	CompilerEndIf
	
	Procedure _ResizeGadget(*this.PB_Gadget, x, y, Width, Height) ; Ok
		Protected *GadgetData.GadgetData = *this\VT, Margin
		
		*this\VT = *GadgetData\OriginalVT
		ResizeGadget(*GadgetData\Gadget, x, y, Width, Height)
		*this\VT = *GadgetData
		
		With *GadgetData
			\Width = GadgetWidth(\Gadget)
			\Height = GadgetHeight(\Gadget)
			
			CalculateSizes
			\Redraw(*GadgetData)
		EndWith
	EndProcedure
	
	Procedure _FreeGadget(*this.PB_Gadget) ; Ok
		Protected *GadgetData.GadgetData = *this\VT
		
		*this\VT = *GadgetData\OriginalVT
		FreeStructure(*GadgetData)
		CallFunctionFast(*this\vt\FreeGadget, *this)
	EndProcedure
	
	Procedure _GetGadgetState(*this.PB_Gadget) ; Ok
		Protected *GadgetData.GadgetData = *this\VT
		ProcedureReturn *GadgetData\ToggleState
	EndProcedure
	
	Procedure _GetGadgetColor(*this.PB_Gadget, ColorType) ; Ok
		Protected *GadgetData.GadgetData = *this\VT, Result
		
		With *GadgetData
			Select ColorType
				Case #FrontColor_Cold
					Result = \FrontColor[#Cold]
				Case #FrontColor_Warm
					Result = \FrontColor[#Warm]
				Case #FrontColor_Hot 
					Result = \FrontColor[#Hot]
				Case #BackColor_Cold 
					Result = \BackColor[#Cold]
				Case #BackColor_Warm 
					Result = \BackColor[#Warm]
				Case #BackColor_Hot  
					Result = \BackColor[#Hot]
			EndSelect
		EndWith
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure _SetGadgetState(*this.PB_Gadget, State.i) ; Ok
		Protected *GadgetData.GadgetData = *this\VT
		
		If *GadgetData\Toggle
			*GadgetData\ToggleState = State
			
			If *GadgetData\ToggleState
				*GadgetData\State = #Hot
			Else
				*GadgetData\State = #Cold
			EndIf
			
			*GadgetData\Redraw(*GadgetData)
			
		EndIf
	EndProcedure
		
	Procedure _SetGadgetColor(*this.PB_Gadget, ColorType, Color) ; Ok
		Protected *GadgetData.GadgetData = *this\VT, Result
		
		With *GadgetData
			Select ColorType
				Case #FrontColor_Cold
					\FrontColor[#Cold] = Color
				Case #FrontColor_Warm
					\FrontColor[#Warm] = Color
				Case #FrontColor_Hot 
					\FrontColor[#Hot] = Color
				Case #BackColor_Cold 
					\BackColor[#Cold] = Color
				Case #BackColor_Warm 
					\BackColor[#Warm] = Color
				Case #BackColor_Hot  
					\BackColor[#Hot] = Color
			EndSelect
			
			\Redraw(*GadgetData)
		EndWith
	EndProcedure
	
	Procedure _SetGadgetFont(*this.PB_Gadget, Font)
		Protected *GadgetData.GadgetData = *this\VT, Margin
		
		With *GadgetData
			\Font = Font
			CalculateSizes
			\Redraw(*GadgetData)
		EndWith
	EndProcedure
	
	;}
EndModule

CompilerIf #PB_Compiler_IsMainFile
	Procedure HandlerClose()
		End
	EndProcedure
	
	Procedure HandlerButton()
		Debug "Click!"
		Debug GetGadgetState(EventGadget())
	EndProcedure
	
	OpenWindow(0, 0, 0, 400, 300, "CanvasButton example", #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
	
	CreateImage(5, 30, 30, 32, #PB_Image_Transparent)
	StartDrawing(ImageOutput(5))
	DrawingMode(#PB_2DDrawing_AllChannels)
	Circle(15, 15, 13, $FF67BC00)
	StopDrawing()
	
	CanvasButton::Gadget(0, 10, 10, 200, 100, "Testouille", 5, CanvasButton::#DarkTheme | CanvasButton::#Toggle)
	;if materialvector is indluded : 
	CanvasButton::Gadget(0, 10, 10, 200, 100, "Testouille", MaterialVector::#cube , CanvasButton::#DarkTheme | CanvasButton::#Toggle | CanvasButton::#MaterialVector | CanvasButton::#Outline)
	ResizeGadget(0, #PB_Ignore, #PB_Ignore, 380, 150)
	SetGadgetState(0, #True)
	BindGadgetEvent(0, @HandlerButton(), #PB_EventType_Change)
	
	Repeat
		WaitWindowEvent()
	ForEver
	
CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 338
; FirstLine = 84
; Folding = MAEQPAo-
; EnableXP