Module MainWindow
	EnableExplicit
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
		Macro SetAlpha(Color, Alpha)
			Alpha << 24 + Color
		EndMacro
	CompilerElse
		Macro SetAlpha(Color, Alpha) ; Not tested...
			Color << 8 + Alpha
		EndMacro
	CompilerEndIf
	
	Macro Floor(Number)
		Round(Number, #PB_Round_Down)
	EndMacro
	
	Macro Ceil(Number)
		Round(Number, #PB_Round_Up)
	EndMacro
	;}
	
	;{ Private variables, constants and structures
	;{ UITK Subclass stuff
	; ... This is not the correct way to do it.
	
	#WM_SYSMENU = $313
	#SizableBorder = 8
	#WindowButtonWidth = 45
	#WindowBarHeight = 30
	#Library_ItemTextHeight = 20
	
	Enumeration ;DragState
		#Drag_None
		#Drag_Init
		#Drag_Active
	EndEnumeration
	
	Prototype GetAttribute(*This, Attribute)
	Prototype SetAttribute(*This, Attribute, Value)
	Prototype Redraw(*GadgetData)
	
	Structure GadgetVT
		GadgetType.l
		SizeOf.l
		*GadgetCallback
		*FreeGadget
		*GetGadgetState
		*SetGadgetState.GetAttribute
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
		*GetGadgetAttribute.GetAttribute
		*SetGadgetAttribute.SetAttribute
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
		
		; From here on, custom procedures
		*GetGadgetItemImage
	EndStructure
	
	Structure PB_Gadget
		*Gadget
		*vt.GadgetVT
		UserData.i
		OldCallback.i
		Daten.i[4]
	EndStructure
	
	Structure Event
		EventType.l
		MouseX.l
		MouseY.l
		Param.l
	EndStructure
	
	Prototype EventHandler(*this.PB_Gadget, *Event.Event)
	
	Structure Library_Item
		ImageID.i
		ImageX.i
		ImageY.i
		ImageWidth.i
		ImageHeight.i
		HoverState.b
		Selected.b
		*Section.UITK::Library_Section
		*Data.Project::Asset
		Text.UITK::Text
	EndStructure
	
	Structure GadgetData
		VT.GadgetVT ;Must be the first element of this structure!
		*OriginalVT.GadgetVT
		Gadget.i
		*MetaGadget
		Border.b
		
		OriginX.i
		OriginY.i
		Width.i
		Height.i
		
		State.i
		
		MouseState.b
		
		SupportedEvent.b[UITK::#__EVENTSIZE]
		
		HMargin.w
		VMargin.w
		
		CornerType.a
		
		*ThemeData.UITK::Theme
		
		Redraw.Redraw
		EventHandler.EventHandler
		TextBock.UITK::Text
		ParentWindow.i
		
		Freeze.b
		Enabled.b
		
		*DefaultEventHandler
	EndStructure
	
	Structure ScrollBarData Extends GadgetData
		Min.l
		Max.l
		PageLenght.l
		Vertical.b
		Position.l
		BarSize.l
		Thickness.l
		Drag.b
		DragOffset.l
		ScrollStep.l
		Background.b
	EndStructure
	
	Structure LibraryData Extends GadgetData
		InternalHeight.l
		VisibleScrollbar.b
		
		*RedrawSection.ItemRedraw
		*RedrawItem.ItemRedraw
		*ScrollBar.ScrollBarData
		
		ItemState.i
		SectionHeight.l
		ItemHeight.l
		ItemWidth.l
		ItemPerLine.l
		ItemMinimumHMargin.l
		ItemHMargin.l
		ItemVMargin.l
		
		DragOriginX.l
		DragOriginY.l
		Drag.b
		DragState.b
		
		List Sections.UITK::Library_Section()
		List Items.UITK::Library_Item()
	EndStructure
	
	Structure ThemedWindow
		*Brush
		*OriginalProc
		
		Width.l
		Height.l
		MinWidth.l
		MinHeight.l
		MaxWidth.l
		MaxHeight.l
		
		SizeCursor.l
		Sizable.l
		
		ButtonClose.l
		ButtonMinimize.l
		ButtonMaximize.l
		
		Container.i
		
		Label.i
		LabelWidth.l
		LabelAlign.b
		
		MenuOffset.l
		List MenuList.i()
		
		Theme.UITK::Theme
	EndStructure
	
	Structure WindowContainer
		*Parent
		*OriginalProc
		sizeCursor.l
	EndStructure
	;}
	
	Global Window, Window_Width, Window_Height
	Global Render, TimeLine, HorizontalContainer, HorizontalContainer_State, VerticalContainer, VerticalContainer_State
	Global TabState, LibraryWidth, TimeLineHeight, SplitterOffset
	Global Dim PlusIcon(4)
	Global *OriginalLibraryHandler, *OriginalContainterHandler
	
	PlusIcon(Project::#Media) = ImageID(CatchImage(#PB_Any, ?PlusMedia))
	PlusIcon(Project::#Audio) = ImageID(CatchImage(#PB_Any, ?PlusAudio))
	PlusIcon(Project::#_3D) = ImageID(CatchImage(#PB_Any, ?Plus3D))
	PlusIcon(Project::#Overlay) = ImageID(CatchImage(#PB_Any, ?PlusOverlay))
	PlusIcon(Project::#Modifiers) = ImageID(CatchImage(#PB_Any, ?PlusModifiers))
	
	; Appearance
	#Appearance_Window_Width = 1280
	#Appearance_Window_Height = 700
	#Appearance_Window_Margin = 10
	#Appearance_TimeLine_MinHeight = 300
	#Appearance_Render_MinWidth = 600
	#Appearance_Render_MinHeight = 380
	#Appearance_Library_ButtonHeight = 70
	#Appearance_Library_MinWidth = 560
	;}
	
	; Private procedure declarations
	Prototype OriginEvent(*GadgetData, *Event)
	Declare Handler_Tab()
	Declare Handler_Resize()
	Declare Handler_Close()
	Declare Library_RedrawItem(*Item.UITK::Library_Item, X, Y, Width, Height, State, *Theme.UITK::Theme)
	Declare Library_EventHandler(*GadgetData.LibraryData, *Event.Event)
	Declare HorizontalContainer_Handler(hWnd, Msg, wParam, lParam)
	Declare VerticalContainer_Handler(hWnd, Msg, wParam, lParam)
	
	; Public procedures
	Procedure Open()
		Protected Menu
		
		;{ Window
		Window = UITK::Window(#PB_Any, 0, 0, #Appearance_Window_Width, #Appearance_Window_Height, General::#AppName, UITK::#Window_CloseButton |
		                                                                                                             UITK::#Window_MaximizeButton |
		                                                                                                             UITK::#Window_MinimizeButton |
		                                                                                                             #PB_Window_SizeGadget |
		                                                                                                             #PB_Window_ScreenCentered |
		                                                                                                             #PB_Window_Invisible |
		                                                                                                             UITK::#DarkMode)
		
		UITK::WindowSetColor(Window, UITK::#Color_WindowBorder, SetAlpha(FixColor(#Color_Window_Border), 255))
		UITK::WindowSetColor(Window, UITK::#Color_Parent, SetAlpha(FixColor(#Color_Window_Border), 255))
		UITK::WindowSetColor(Window, UITK::#Color_Shade_Cold, SetAlpha(FixColor(#Color_Gadget_BackCold), 255))
		UITK::SetWindowBounds(Window, #Appearance_Window_Width, #Appearance_Window_Height + 30, -1, -1)
		BindEvent(#PB_Event_SizeWindow, @Handler_Resize(), Window)
		
		UITK::SetWindowIcon(Window, ImageID(CatchImage(#PB_Any, ?Icon)))
		Window_Width = WindowWidth(Window)
		Window_Height = WindowHeight(Window) - 30
		;}
		
		;{ Gadgets
		Tab = UITK::Tab(#PB_Any, #Appearance_Window_Margin * 2, 0, #Appearance_Library_MinWidth, #Appearance_Library_ButtonHeight)
		SetGadgetColor(Tab, UITK::#Color_Shade_Warm, SetAlpha(FixColor($373A56), 255))
		SetGadgetColor(Tab, UITK::#Color_Shade_Hot, SetAlpha(FixColor(#Color_Gadget_BackCold), 255))
		AddGadgetItem(Tab, -1, "Media", ImageID(CatchImage(#PB_Any, ?TabMedia)))
		SetGadgetItemAttribute(tab, 0, UITK::#Tab_Color, SetAlpha(FixColor(#Color_Ressources_Media), 255))
		AddGadgetItem(Tab, -1, "Audio", ImageID(CatchImage(#PB_Any, ?TabAudio)))
		SetGadgetItemAttribute(tab, 1, UITK::#Tab_Color, SetAlpha(FixColor(#Color_Ressources_Audio), 255))
		AddGadgetItem(Tab, -1, "3D", ImageID(CatchImage(#PB_Any, ?Tab3D)))
		SetGadgetItemAttribute(tab, 2, UITK::#Tab_Color, SetAlpha(FixColor(#Color_Ressources_3D), 255))
		AddGadgetItem(Tab, -1, "Overlay", ImageID(CatchImage(#PB_Any, ?TabOverlay)))
		SetGadgetItemAttribute(tab, 3, UITK::#Tab_Color, SetAlpha(FixColor(#Color_Ressources_Overlay), 255))
		AddGadgetItem(Tab, -1, "Modifiers", ImageID(CatchImage(#PB_Any, ?TabModifiers)))
		SetGadgetItemAttribute(tab, 4, UITK::#Tab_Color, SetAlpha(FixColor(#Color_Ressources_Modifiers), 255))
		SetGadgetState(Tab, 0)
		BindGadgetEvent(Tab, @Handler_Tab(), #PB_EventType_Change)
		
		LibraryWidth = #Appearance_Library_MinWidth
		TimeLineHeight = #Appearance_TimeLine_MinHeight
		
		Library = UITK::Library(#PB_Any, #Appearance_Window_Margin, #Appearance_Library_ButtonHeight, LibraryWidth, Window_Height - 2 * #Appearance_Window_Margin - #Appearance_TimeLine_MinHeight - #Appearance_Library_ButtonHeight, UITK::#Drag, @Library_RedrawItem())
		SetGadgetAttribute(Library, UITK::#Attribute_CornerRadius, 5)
		EnableGadgetDrop(Library, #PB_Drop_Files, #PB_Drag_Copy | #PB_Drag_Move)
		*OriginalLibraryHandler = UITK::SubClassFunction(Library, UITK::#SubClass_EventHandler, @Library_EventHandler())
		
		Render = ContainerGadget(#PB_Any, GadgetX(Library) + LibraryWidth + #Appearance_Window_Margin, 0, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, Window_Height - 2 * #Appearance_Window_Margin - #Appearance_TimeLine_MinHeight, #PB_Container_BorderLess)
		SetGadgetColor(Render, #PB_Gadget_BackColor, $000000)
		CloseGadgetList()
		
		HorizontalContainer = ContainerGadget(#PB_Any, #Appearance_Window_Margin, Window_Height - #Appearance_Window_Margin * 2 - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, #Appearance_Window_Margin)
		SetGadgetColor(HorizontalContainer, #PB_Gadget_BackColor, FixColor(#Color_Window_Border))
		*OriginalContainterHandler = SetWindowLongPtr_(GadgetID(HorizontalContainer), #GWL_WNDPROC, @HorizontalContainer_Handler())
		CloseGadgetList()
		
		VerticalContainer = ContainerGadget(#PB_Any, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, 10)
		SetGadgetColor(VerticalContainer, #PB_Gadget_BackColor, FixColor(#Color_Window_Border))
		SetWindowLongPtr_(GadgetID(VerticalContainer), #GWL_WNDPROC, @VerticalContainer_Handler())
		CloseGadgetList()
		
		
		TimeLine = TimeLine::Gadget(#Appearance_Window_Margin, GadgetY(Library) + GadgetHeight(Library) + #Appearance_Window_Margin, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight)
		;}
		
		;{ Menu
		Menu = UITK::FlatMenu(UITK::#DarkMode)
		UITK::AddFlatMenuItem(Menu, 0, -1, "Item 2")
		UITK::AddFlatMenuItem(Menu, 0, -1, "Item 3")
		UITK::AddFlatMenuItem(Menu, 0, 0, "Item 1")
		UITK::AddFlatMenuSeparator(Menu, -1)
		UITK::AddFlatMenuItem(Menu, 0, -1, "Variable Viewer")
		UITK::AddFlatMenuItem(Menu, 0, -1, "Compare Files/Folder")
		UITK::AddFlatMenuItem(Menu, 0, -1, "Procedure Browser")
		
		UITK::AddWindowMenu(Window, Menu, "File")
		;}
		
		Project::New()
		Handler_Tab()
		HideWindow(Window, #False)
	EndProcedure
	
	; Private procedures
	Procedure Handler_Tab()
		UITK::Freeze(Library, #True)
		ClearGadgetItems(Library)
		Select GetGadgetState(Tab)
			Case Project::#Media
				TabState = Project::#Media
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Media), 255))
				AddGadgetColumn(Library, 0, "Video", 0)
				AddGadgetColumn(Library, 1, "Images", 0)
				
				ForEach Project::Project\Assets[Project::#Media]\List()
					SetGadgetItemData(Library, AddGadgetItem(Library, -1, Project::Project\Assets[Project::#Media]\List()\Name, ImageID(Project::Project\Assets[Project::#Media]\List()\PreviewImage), Project::Project\Assets[Project::#Media]\List()\Type), Project::@Project\Assets[Project::#Media]\list())
				Next
				
			Case Project::#Audio
				TabState = Project::#Audio
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Audio), 255))
				AddGadgetColumn(Library, 0, "Music", 0)
				AddGadgetColumn(Library, 1, "Sound", 0)
				AddGadgetColumn(Library, 2, "Voice clip", 0)
			Case Project::#_3D
				TabState = Project::#_3D
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_3D), 255))
				AddGadgetColumn(Library, 0, "Models", 0)
				AddGadgetColumn(Library, 1, "Particles", 0)
			Case Project::#Overlay
				TabState = Project::#Overlay
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Overlay), 255))
				AddGadgetColumn(Library, 0, "Text", 0)
				AddGadgetColumn(Library, 1, "Shape", 0)
				AddGadgetColumn(Library, 2, "???", 0)
			Case Project::#Modifiers
				TabState = Project::#Modifiers
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Modifiers), 255))
				AddGadgetColumn(Library, 0, "Transitions", 0)
				AddGadgetColumn(Library, 1, "Post processing", 0)
				AddGadgetColumn(Library, 1, "Colors", 0)
				AddGadgetColumn(Library, 2, "Effects", 0)
		EndSelect
				
		UITK::Freeze(Library, #False)
	EndProcedure
	
	Procedure Handler_Resize()
		Protected TempHeight = WindowHeight(Window) - 30, VerticalGrowth = Bool(TempHeight > Window_Height)
		Window_Width = WindowWidth(Window)
		Window_Height = TempHeight
		
		If Window_Height - TimeLineHeight - 2 * #Appearance_Window_Margin < #Appearance_Render_MinHeight
			TimeLineHeight = Window_Height - 2 * #Appearance_Window_Margin - #Appearance_Render_MinHeight
		EndIf
		
		If Window_Width - LibraryWidth - 3 * #Appearance_Window_Margin < #Appearance_Render_MinWidth
			LibraryWidth = Window_Width - 3 * #Appearance_Window_Margin - #Appearance_Render_MinWidth
		EndIf
		
; 		PosX = General::Max(GadgetX(VerticalContainer) + PosX, #Appearance_Library_MinWidth + #Appearance_Window_Margin)
; 						LibraryWidth = PosX - #Appearance_Window_Margin
		
		TempHeight = Window_Height - TimeLineHeight - 2 * #Appearance_Window_Margin
		
		SendMessage_(GadgetID(Library), #WM_SETREDRAW, #False, 0)
		
		If VerticalGrowth
			ResizeGadget(TimeLine, #PB_Ignore, TempHeight + #Appearance_Window_Margin, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight)
			ResizeGadget(HorizontalContainer, #PB_Ignore, Window_Height - #Appearance_Window_Margin * 2 - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, #PB_Ignore)
			ResizeGadget(Library, #PB_Ignore, #PB_Ignore, LibraryWidth, TempHeight - #Appearance_Library_ButtonHeight)
			SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
			RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
			ResizeGadget(VerticalContainer, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, TempHeight)
			ResizeGadget(Render, LibraryWidth + 2 * #Appearance_Window_Margin, #PB_Ignore, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, TempHeight)
		Else
			ResizeGadget(Library, #PB_Ignore, #PB_Ignore, LibraryWidth, TempHeight - #Appearance_Library_ButtonHeight)
			SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
			RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
			ResizeGadget(VerticalContainer, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, TempHeight)
			ResizeGadget(Render, LibraryWidth + 2 * #Appearance_Window_Margin, #PB_Ignore, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, TempHeight)
			ResizeGadget(HorizontalContainer, #PB_Ignore, Window_Height - #Appearance_Window_Margin * 2 - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, #PB_Ignore)
			ResizeGadget(TimeLine, #PB_Ignore, TempHeight + #Appearance_Window_Margin, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight)
		EndIf
		
	EndProcedure
	
	Procedure Handler_Close()
		
	EndProcedure
	
	Procedure Library_RedrawItem(*Item.Library_Item, X, Y, Width, Height, State, *Theme.UITK::Theme)
		Protected TextHeight = Height - *Item\Text\Height
		
		With *Item
			If \Text\FontScale
				VectorFont(\Text\FontID, \Text\FontScale)
			Else
				VectorFont(\Text\FontID)
			EndIf
			
			MovePathCursor(X + \ImageX, Y + \ImageY)
			DrawVectorImage(\ImageID)
						
			UITK::DrawVectorTextBlock(@\Text, X, Y + TextHeight + 2)
			
			If \HoverState
				UITK::AddPathRoundedBox(X, Y, 160, TextHeight, 5)
				VectorSourceColor(SetAlpha($FFFFFF, 35))
				FillPath()
				VectorSourceColor(*Theme\TextColor[UITK::#Cold])
			EndIf
			
			If \Selected
				UITK::AddPathRoundedBox(X - 0.5, Y - 0.5, 160 + 1, TextHeight + 1, 5)
				VectorSourceColor(*Theme\Special3[UITK::#Cold])
				StrokePath(3)
				VectorSourceColor(*Theme\TextColor[UITK::#Cold])
			EndIf
			
			MovePathCursor(X + 8, Y + 8)
			DrawVectorImage(Project::AssetIcon(\Data\Type))
			
			MovePathCursor(X + 120, Y + 50)
			DrawVectorImage(PlusIcon(TabState))
			
		EndWith
	EndProcedure
	
	Procedure Library_EventHandler(*GadgetData.LibraryData, *Event.Event)
		Protected Redraw, Y, NewItem = -1, ItemRow, Image, Cursor
		
		With *GadgetData
			Select *Event\EventType
				Case UITK::#MouseMove ;{
					If \DragState = #Drag_None
						If \VisibleScrollbar And (*Event\MouseX >= \ScrollBar\OriginX Or \ScrollBar\Drag = #True)
							Redraw = \ScrollBar\EventHandler(\ScrollBar, *Event)
						ElseIf \ScrollBar\MouseState
							\ScrollBar\MouseState = #False
							Redraw = #True
						EndIf
						
						If Not \ScrollBar\MouseState
							If ListSize(\Sections())
								ForEach \Sections()
									If \ScrollBar\State + *Event\MouseY> Y + \Sections()\Height
										Y + \Sections()\Height
									Else
										Break
									EndIf
								Next
								
								*Event\MouseY - Y + \ScrollBar\State
								
								If *Event\MouseY > \SectionHeight
									*Event\MouseY - \SectionHeight
									If *Event\MouseY % (\ItemHeight + \ItemVMargin ) < \ItemHeight - #Library_ItemTextHeight
										If (*Event\MouseX % (\ItemHMargin + \ItemWidth)) > \ItemHMargin
											If SelectElement(\Sections()\Items(), Floor(*Event\MouseY / (\ItemHeight + \ItemVMargin )) * \ItemPerLine + Floor(*Event\MouseX / (\ItemHMargin + \ItemWidth)))
												*Event\MouseY % (\ItemHeight + \ItemVMargin )
												*Event\MouseX % (\ItemHMargin + \ItemWidth) - \ItemHMargin
												
												If *Event\MouseX > 122 And *Event\MouseY > 52 And *Event\MouseX < 150 And *Event\MouseY < 80
													Cursor = #True
												EndIf
												
												ChangeCurrentElement(\Items(), \Sections()\Items())
												NewItem = ListIndex(\Items())
											EndIf
										EndIf
									EndIf
								EndIf
								
							EndIf
						EndIf
						
						If \ItemState <> NewItem
							If NewItem > -1
								\Items()\HoverState = #True
							EndIf
							If \ItemState > -1
								SelectElement(\Items(), \ItemState)
								\Items()\HoverState = #False
							EndIf
							\ItemState = NewItem
							Redraw = #True
						EndIf
						
						If Cursor
							SetGadgetAttribute(\Gadget, #PB_Canvas_Cursor, #PB_Cursor_Hand)
						Else
							SetGadgetAttribute(\Gadget, #PB_Canvas_Cursor, #PB_Cursor_Default)
						EndIf
						
					ElseIf \DragState = #Drag_Init
						If Abs(\DragOriginX - *Event\MouseX) > 7 Or Abs(\DragOriginY - *Event\MouseY) > 7
							SelectElement(\Items(), \State)
							UITK::AdvancedDragPrivate(UITK::#Drag_LibraryItem, \Items()\ImageID)
							\DragState = #Drag_None
						EndIf
					EndIf
					;}
				Case UITK::#LeftButtonDown ;{
					If \ScrollBar\MouseState
						Redraw = \ScrollBar\EventHandler(\ScrollBar, *Event)
					ElseIf \ItemState > -1
						If GetGadgetAttribute(\Gadget, #PB_Canvas_Cursor)
							
						Else
							If \State > -1
								SelectElement(\Items(), \State)
								\Items()\Selected = #False
							EndIf
							\State = \ItemState
							
							SelectElement(\Items(), \State)
							\Items()\Selected = #True
							Redraw = #True
							
							If \Drag
								\DragState = #Drag_Init
								\DragOriginX = *Event\MouseX
								\DragOriginY = *Event\MouseY
							EndIf
						EndIf
					EndIf
					;}
				Case UITK::#LeftDoubleClick ;{
					;}
				Default ;{
					CallFunctionFast(*OriginalLibraryHandler, *GadgetData, *Event)
					;}
			EndSelect
			
			If Redraw
				StartVectorDrawing(CanvasVectorOutput(*GadgetData\Gadget))
				AddPathBox(*GadgetData\OriginX, *GadgetData\OriginY, *GadgetData\Width, *GadgetData\Height, #PB_Path_Default)
				ClipPath(#PB_Path_Preserve)
				VectorSourceColor(*GadgetData\ThemeData\WindowColor)
				FillPath()
				*GadgetData\Redraw(*GadgetData)
				StopVectorDrawing()
			EndIf
		EndWith
		
		ProcedureReturn Redraw
	EndProcedure
	
	Procedure HorizontalContainer_Handler(hWnd, Msg, wParam, lParam)
		Protected PosY
		
		Select Msg
			Case #WM_MOUSEMOVE
				If HorizontalContainer_State
					PosY = ((lParam >> 16) & $FFFF) - SplitterOffset
					If PosY > 30000
						PosY - 65535
					EndIf
					
					If PosY > 0
						PosY = General::Min(GadgetY(HorizontalContainer) + PosY, Window_Height - #Appearance_TimeLine_MinHeight - 2 * #Appearance_Window_Margin)
						TimeLineHeight = Window_Height - posy - 2 * #Appearance_Window_Margin
						
						SetWindowPos_(GadgetID(TimeLine), 0, #Appearance_Window_Margin, Window_Height - #Appearance_Window_Margin - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight, #SWP_NOZORDER | #SWP_NOREDRAW)
						
						SetWindowPos_(hWnd, 0, #Appearance_Window_Margin, PosY, 0, 0, #SWP_NOSIZE | #SWP_NOZORDER)
						
						SetWindowPos_(GadgetID(Render), 0, 0, 0, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight, #SWP_NOZORDER | #SWP_NOMOVE | #SWP_NOREDRAW)
						
						ResizeGadget(VerticalContainer, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight)
						
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #False, 0)
						ResizeGadget(Library, #PB_Ignore, #PB_Ignore, #PB_Ignore, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight - #Appearance_Library_ButtonHeight)
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
						
						RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(TimeLine), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(Render), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
					Else
						PosY = General::Max(GadgetY(HorizontalContainer) + PosY, #Appearance_Render_MinHeight)
						TimeLineHeight = Window_Height - PosY - 2 * #Appearance_Window_Margin
						
						SetWindowPos_(GadgetID(Render), 0, 0, 0, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight,#SWP_NOZORDER |  #SWP_NOMOVE | #SWP_NOREDRAW)
						
						ResizeGadget(VerticalContainer, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight)
						
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #False, 0)
						ResizeGadget(Library, #PB_Ignore, #PB_Ignore, #PB_Ignore, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight - #Appearance_Library_ButtonHeight)
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
						
						SetWindowPos_(hWnd, 0, #Appearance_Window_Margin, PosY, 0, 0, #SWP_NOSIZE | #SWP_NOZORDER)
						
						SetWindowPos_(GadgetID(TimeLine), 0, #Appearance_Window_Margin, Window_Height - #Appearance_Window_Margin - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight, #SWP_NOZORDER | #SWP_NOREDRAW)
						
						RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(TimeLine), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(Render), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
					EndIf
				EndIf
				
				SetCursor_(LoadCursor_(0, #IDC_SIZENS))
				ProcedureReturn
			Case #WM_LBUTTONDOWN
				HorizontalContainer_State = #True
				SetCapture_(hWnd)
				SetCursor_(LoadCursor_(0, #IDC_SIZENS))
				SplitterOffset = (lParam >> 16) & $FFFF
				ProcedureReturn
			Case #WM_LBUTTONUP
				HorizontalContainer_State = #False
				ReleaseCapture_()
				SetCursor_(LoadCursor_(0, #IDC_SIZENS))
				SetActiveGadget(Library)
				ProcedureReturn
		EndSelect
		
		ProcedureReturn CallWindowProc_(*OriginalContainterHandler, hWnd, Msg, wParam, lParam)
	EndProcedure
	
	Procedure VerticalContainer_Handler(hWnd, Msg, wParam, lParam)
		Protected PosX, Height
		
		Select Msg
			Case #WM_MOUSEMOVE
				If HorizontalContainer_State
					PosX = (lParam & $FFFF) - SplitterOffset
					If PosX > 30000
						PosX - 65535
					EndIf
					
					Height = Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight
					
					If PosX > 0
						PosX = General::Min(GadgetX(VerticalContainer) + PosX, Window_Width - #Appearance_Render_MinWidth - #Appearance_Window_Margin)
						LibraryWidth = PosX - #Appearance_Window_Margin
						
						SetWindowPos_(GadgetID(Render), 0, LibraryWidth + #Appearance_Window_Margin * 2, 0, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, Height, #SWP_NOZORDER | #SWP_NOREDRAW)
						
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #False, 0)
; 						SetWindowPos_(GadgetID(Library), 0, 0, 0, LibraryWidth, Height - #Appearance_Library_ButtonHeight, #SWP_NOZORDER | #SWP_NOREDRAW | #SWP_NOMOVE)
						ResizeGadget(Library, #PB_Ignore, #PB_Ignore, LibraryWidth, #PB_Ignore)
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
						
						RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(Render), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						
						SetWindowPos_(GadgetID(VerticalContainer), 0, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, Height, #SWP_NOZORDER)
						
					Else
						PosX = General::Max(GadgetX(VerticalContainer) + PosX, #Appearance_Library_MinWidth + #Appearance_Window_Margin)
						LibraryWidth = PosX - #Appearance_Window_Margin
						
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #False, 0)
						ResizeGadget(Library, #PB_Ignore, #PB_Ignore, LibraryWidth, #PB_Ignore)
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
						
						SetWindowPos_(GadgetID(Render), 0, LibraryWidth + #Appearance_Window_Margin * 2, 0, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, Height, #SWP_NOZORDER | #SWP_NOREDRAW)

						RedrawWindow_(GadgetID(Render), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						
						SetWindowPos_(GadgetID(VerticalContainer), 0, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, Height, #SWP_NOZORDER)
					EndIf
				EndIf
				
				SetCursor_(LoadCursor_(0, #IDC_SIZEWE))
				ProcedureReturn
			Case #WM_LBUTTONDOWN
				HorizontalContainer_State = #True
				SetCapture_(hWnd)
				SetCursor_(LoadCursor_(0, #IDC_SIZEWE))
				SplitterOffset = lParam & $FFFF
				ProcedureReturn
			Case #WM_LBUTTONUP
				HorizontalContainer_State = #False
				ReleaseCapture_()
				SetCursor_(LoadCursor_(0, #IDC_SIZEWE))
				SetActiveGadget(Library)
				ProcedureReturn
		EndSelect
		
		ProcedureReturn CallWindowProc_(*OriginalContainterHandler, hWnd, Msg, wParam, lParam)
	EndProcedure
	
	DataSection ;{
		Icon:
		IncludeBinary "../Media/Logo.png"
		
		Tab3D:
		IncludeBinary "../Media/Tab-3D.png"
		
		TabAudio:
		IncludeBinary "../Media/Tab-Audio.png"
		
		TabModifiers:
		IncludeBinary "../Media/Tab-Modifiers.png"
		
		TabMedia:
		IncludeBinary "../Media/Tab-Media.png"
		
		TabOverlay:
		IncludeBinary "../Media/Tab-Overlay.png"
		
		Plus3D:
		IncludeBinary "../Media/Plus-3D.png"
		
		PlusAudio:
		IncludeBinary "../Media/Plus-Audio.png"
		
		PlusModifiers:
		IncludeBinary "../Media/Plus-Modifiers.png"
		
		PlusMedia:
		IncludeBinary "../Media/Plus-Media.png"
		
		PlusOverlay:
		IncludeBinary "../Media/Plus-Overlay.png"
	EndDataSection ;}
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 695
; FirstLine = 130
; Folding = ZflA1
; EnableXP
; DPIAware