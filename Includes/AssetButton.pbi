Module AssetButton
	EnableExplicit
	;{ Private variables, structures, constants...
	Structure GadgetData
		Text.s
		Image.i
		TextGadget.i
		Icon.i
		State.b
		MouseOver.b
		Cursor.i
		OriginX.l
		OriginY.l
		ImageX.l
		ImageY.l
		Type.l
		UUID.s
	EndStructure
	
	Global ActiveAssetButton
	AssetButtonMedia = ImageID(CatchImage(#PB_Any, ?IconPlus1))
	AssetButtonSound = ImageID(CatchImage(#PB_Any, ?IconPlus2))
	AssetButtonModel = ImageID(CatchImage(#PB_Any, ?IconPlus3))
	AssetButtonOverlay = ImageID(CatchImage(#PB_Any, ?IconPlus4))
	AssetButtonElement = ImageID(CatchImage(#PB_Any, ?IconPlus5))
	
	PlusImage = AssetButtonMedia
	Color = General::FixColor(MainWindow::#Color_Asset_Media)
	
	Global Dim AssetIcon(20)
	
	AssetIcon(Project::#Asset_Type_Image) = ImageID(CatchImage(#PB_Any, ?IconImage))
	AssetIcon(Project::#Asset_Type_Video) = ImageID(CatchImage(#PB_Any, ?IconVideo))
	
	AssetIcon(Project::#Asset_Type_2DEffect) = ImageID(CatchImage(#PB_Any, ?Icon2DEffect))
	
	AssetIcon(Project::#Asset_Type_Overlay) = ImageID(CatchImage(#PB_Any, ?IconOverlay))
	;}
	
	;{ Private procedures declaration
	Declare HandlerAssetButton()
	Declare Redraw(Gadget)
	;}
	
	;{ Public procedures
	Procedure Gadget(Gadget, X, Y, Width, Height, Image, AssetType, Text.s, UUID.s)
		Protected *GadgetData.GadgetData
		Protected Result = CanvasGadget(Gadget, x, y, Width, Height, #PB_Canvas_Container | #PB_Canvas_Keyboard), Margin
		
		If Result
			If Gadget = #PB_Any
				Gadget = result
			EndIf
			
			*GadgetData = AllocateStructure(GadgetData)
			
			With *GadgetData
				
				\Type = AssetType
				\Image = ImageID(Image)
				\Text = Text
				\TextGadget = TextGadget(#PB_Any, 0, Height - 15, Width, 18, \Text)
 				\Icon = AssetIcon(AssetType)
 				\ImageX = (160 - ImageWidth(Image)) * 0.5
 				\ImageY = (90 - ImageHeight(Image)) * 0.5
 				\UUID.s = UUID
 				
				StartDrawing(CanvasOutput(Gadget))
				Box(0, 0, Width, Height, $482E27)
				StopDrawing()
				
				SetGadgetData(Gadget, *GadgetData)
				BindGadgetEvent(Gadget, @HandlerAssetButton())
				Redraw(Gadget)
				 
				SetGadgetColor(\TextGadget, #PB_Gadget_FrontColor, $FFFFFF)
				SetGadgetColor(\TextGadget, #PB_Gadget_BackColor, $482E27)
			EndWith
			
			CloseGadgetList()
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure Delete(Gadget)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		
		If ActiveAssetButton = Gadget
			ActiveAssetButton = 0
		EndIf
		
		UnbindGadgetEvent(Gadget, @HandlerAssetButton())
		FreeStructure(*GadgetData)
		
		FreeGadget(Gadget)
		SetActiveGadget(MainWindow::#Asset_ScrollArea)
	EndProcedure
	
	Procedure SetState(Gadget, State)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		*GadgetData\State = State
		
		If State 
			ActiveAssetButton = Gadget
		ElseIf ActiveAssetButton = Gadget
			ActiveAssetButton = 0
		EndIf
		
		Redraw(Gadget)
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure HandlerAssetButton()
		Protected Gadget = EventGadget(), *GadgetData.GadgetData = GetGadgetData(Gadget)
		Protected MouseX, MouseY, Line
		
		With *GadgetData
			Select EventType()
				Case #PB_EventType_MouseEnter ;{
					\MouseOver = #True
					Redraw(Gadget)
					;}
				Case #PB_EventType_MouseLeave ;{
					\MouseOver = #False
					Redraw(Gadget)
					If \Cursor = #PB_Cursor_Hand
						\Cursor = 0
						SetGadgetAttribute(Gadget, #PB_Canvas_Cursor, #PB_Cursor_Default)
					EndIf
					;}
				Case #PB_EventType_MouseMove ;{
					MouseX = GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)
					MouseY = GetGadgetAttribute(Gadget, #PB_Canvas_MouseY)
					
					If \State = 1
						If Abs(\OriginX - MouseX) > 10 Or Abs(\OriginY - MouseY) > 10 
							\State = 2
							\OriginX = (160 - 2 * \ImageX) * 0.5 
							\OriginY = ( 90 - 2 * \ImageY) * 0.5
							
							DragType = \Type
 							DragUUID = \UUID
 							MainWindow::DragPreviewVisible = #True
 							
							SetGadgetState(MainWindow::ImagePreview, \Image)
							ResizeWindow(MainWindow::DragPreview, DesktopMouseX() + 10, DesktopMouseY() + 10, 160 - 2 * \ImageX - 1, 90 - 2 * \ImageY - 1)
							HideWindow(MainWindow::DragPreview, #False, #PB_Window_NoActivate)
							
							DragPrivate(1, #PB_Drag_Link)
						EndIf
					Else
						If MouseX >= 126 And MouseY >= 56 And MouseX <= 152 And MouseY <= 82
							If \Cursor = 0
								\Cursor = #PB_Cursor_Hand
								SetGadgetAttribute(Gadget, #PB_Canvas_Cursor, #PB_Cursor_Hand)
							EndIf
						Else
							If \Cursor = #PB_Cursor_Hand
								\Cursor = 0
								SetGadgetAttribute(Gadget, #PB_Canvas_Cursor, #PB_Cursor_Default)
							EndIf
						EndIf
					EndIf
					;}
				Case #PB_EventType_LeftButtonDown ;{
					If ActiveAssetButton
						SetState(ActiveAssetButton, #False)
					EndIf
					
					If Not ActiveAssetButton = Gadget
						ActiveAssetButton = Gadget
						\State = 1
						Redraw(Gadget)
					EndIf
					
					If \Cursor = 0
						\OriginX = GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)
						\OriginY = GetGadgetAttribute(Gadget, #PB_Canvas_MouseY)
					Else
						\State = 2
						Line = PureTL::GetActiveLine(MainWindow::#TimeLine)
						If Line
							DragType = \Type
 							DragUUID = \UUID
							PostEvent(#PB_Event_GadgetDrop, MainWindow::#Window, MainWindow::#TimeLine, Line, PureTL::GetPlayerPosition(MainWindow::#TimeLine))
						EndIf
					EndIf
					;}
				Case #PB_EventType_LeftButtonUp ;{
					If \State = 1
						\State = 2
					EndIf
					;}
				Case #PB_EventType_MouseWheel ;{
					SetGadgetAttribute(MainWindow::#Asset_ScrollArea, #PB_ScrollArea_Y, GetGadgetAttribute(MainWindow::#Asset_ScrollArea, #PB_ScrollArea_Y) - GetGadgetAttribute(Gadget, #PB_Canvas_WheelDelta) * 45)
					SetGadgetState(MainWindow::#Asset_ScrollBar, GetGadgetAttribute(MainWindow::#Asset_ScrollArea, #PB_ScrollArea_Y))
					;}
				Case #PB_EventType_KeyDown ;{
					Select GetGadgetAttribute(Gadget, #PB_Canvas_Key) 
						Case #PB_Shortcut_Delete
							Project::DeleteAsset(\UUID)
						Case #PB_Shortcut_Y
							If GetGadgetAttribute(Gadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
								SendMessage_(WindowID(0), #WM_KEYDOWN, 90, 0)
							EndIf
						Case #PB_Shortcut_Z
							If GetGadgetAttribute(Gadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
								SendMessage_(WindowID(0), #WM_KEYDOWN, 90, 0)
							EndIf
					EndSelect
					;}
			EndSelect
		EndWith
	EndProcedure
	
	Procedure Redraw(Gadget)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		Protected Width, Height
		
		With *GadgetData
			StartDrawing(CanvasOutput(Gadget))
			Width = OutputWidth()
			Height = OutputHeight()
			Box(0, 0, Width, Height - 20, $000000)
			DrawImage(\Image, \ImageX, \ImageY)
 			DrawAlphaImage(\Icon, 10, 10)
			
			If \MouseOver
				DrawAlphaImage(PlusImage, Width - 38, Height - 57)
			EndIf
			
			If \State
				DrawingMode(#PB_2DDrawing_Outlined)
				Box(0, 0, Width, Height - 20, Color)
				Box(1, 1, Width - 2, Height - 22, Color)
				Box(2, 2, Width - 4, Height - 24, Color)
			EndIf
			
			StopDrawing()
		EndWith
	EndProcedure
	;}
	
	DataSection
		IconPlus1:
		IncludeBinary "..\Media\IconPlus1.png"
		
		IconPlus2:
		IncludeBinary "..\Media\IconPlus2.png"
		
		IconPlus3:
		IncludeBinary "..\Media\IconPlus3.png"
		
		IconPlus4:
		IncludeBinary "..\Media\IconPlus4.png"
		
		IconPlus5:
		IncludeBinary "..\Media\IconPlus5.png"
		
		IconCharacter:
		IncludeBinary "..\Media\IconCharacter.png"
		
		IconImage:
		IncludeBinary "..\Media\IconImage.png"
		
		IconMusic:
		IncludeBinary "..\Media\IconMusic.png"
		
		IconObject:
		IncludeBinary "..\Media\IconObject.png"
		
		IconSound:
		IncludeBinary "..\Media\IconSound.png"
		
		IconVideo:
		IncludeBinary "..\Media\IconVideo.png"
		
		IconVoice:
		IncludeBinary "..\Media\IconVoice.png"
		
		Icon2DEffect:
		IncludeBinary "..\Media\Icon2DEffect.png"
		
		IconOverlay:
		IncludeBinary "..\Media\IconOverlay.png"
		
	EndDataSection
EndModule
; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 36
; FirstLine = 16
; Folding = -Dw
; EnableXP