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
		*DropHandler
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
		
		DropHover.i
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
	
	Structure Tree_Item
		Text.UITK::Text
		Level.b
		*Data.Project::AssetFolder
	EndStructure
	
	Structure TreeData Extends GadgetData
		InternalHeight.l
		ItemHeight.l
		BranchWidth.l
		VisibleScrollbar.b
		MaxLevel.b
		DrawLine.l
		*ScrollBar.ScrollBarData
		List Items.Tree_Item()
	EndStructure
	;}
	
	Enumeration 1 ;Menu
		#Menu_Undo
		#Menu_Redo
		#Menu_AddFolder
		#Menu_RemoveFolder
		#Menu_RenameFolder
	EndEnumeration
	
	Global Window, Window_Width, Window_Height
	Global Tree_Menu, Render, HorizontalContainer, HorizontalContainer_State, VerticalContainer, VerticalContainer_State
	Global LibraryWidth, TimeLineHeight, SplitterOffset
	Global ButtonNewLine, ButtonRemoveLine, ButtonLineUp, ButtonLineDown, ButtonLineRename, IconFolderOpen
	Global IconFont = FontID(LoadFont(#PB_Any, "Font Awesome 5 Pro Regular", 20))
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
	#Appearance_Tree_Width = 160
	;}
	
	; Private procedure declarations
	Prototype OriginEvent(*GadgetData, *Event)
	Declare Handler_Tab()
	Declare Handler_Resize()
	Declare Handler_Close()
	Declare Library_RedrawItem(*Item.UITK::Library_Item, X, Y, Width, Height, State, *Theme.UITK::Theme)
	Declare Library_EventHandler(*GadgetData.LibraryData, *Event.Event)
	Declare Tree_Populate(*Folder.Project::AssetFolder, Depth)
	Declare Handler_Tree_Changer()
	Declare Handler_Tree_RightClick()
	Declare Handler_Tree_Drop(*GadgetData.TreeData, State, Format, Action, x, y)
	Declare HorizontalContainer_Handler(hWnd, Msg, wParam, lParam)
	Declare VerticalContainer_Handler(hWnd, Msg, wParam, lParam)
	
	; Public procedures
	Procedure Open()
		Protected Menu_File
		
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
		
		UITK::WindowSetColor(Window, UITK::#Color_Back_Cold, SetAlpha(FixColor(#Color_Gadget_ButtonCold), 255))
		UITK::WindowSetColor(Window, UITK::#Color_Back_Warm, SetAlpha(FixColor(#Color_Gadget_ButtonWarm), 255))
		UITK::WindowSetColor(Window, UITK::#Color_Back_Hot, SetAlpha(FixColor(#Color_Gadget_ButtonWarm), 255))
		
		
		UITK::SetWindowBounds(Window, #Appearance_Window_Width, #Appearance_Window_Height + 30, -1, -1)
		BindEvent(#PB_Event_SizeWindow, @Handler_Resize(), Window)
		
		UITK::SetWindowIcon(Window, ImageID(CatchImage(#PB_Any, ?Icon)))
		Window_Width = WindowWidth(Window)
		Window_Height = WindowHeight(Window) - 30
		;}
		
		;{ Gadgets
		Tab = UITK::Tab(#PB_Any, #Appearance_Window_Margin * 2, 0, #Appearance_Library_MinWidth, #Appearance_Library_ButtonHeight)
		SetGadgetColor(Tab, UITK::#Color_Shade_Warm, SetAlpha(FixColor(#Color_Gadget_ButtonCold), 255))
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
		IconFolder = ImageID(CatchImage(#PB_Any, ?IconFolder))
		IconFolderOpen = ImageID(CatchImage(#PB_Any, ?IconFolderOpen))
		
		LibraryWidth = #Appearance_Library_MinWidth
		TimeLineHeight = #Appearance_TimeLine_MinHeight
		
		Tree = UITK::Tree(#PB_Any, #Appearance_Window_Margin, #Appearance_Library_ButtonHeight, #Appearance_Tree_Width, Window_Height - 2 * #Appearance_Window_Margin - #Appearance_TimeLine_MinHeight - #Appearance_Library_ButtonHeight)
		EnableGadgetDrop(Tree, #PB_Drop_Private, #PB_Drag_Copy | #PB_Drag_Move, UITK::#Drag_LibraryItem)
		SetGadgetColor(Tree, UITK::#Color_Shade_Hot, SetAlpha(FixColor(#Color_Gadget_ButtonCold), 255))
		BindGadgetEvent(Tree, @Handler_Tree_Changer(), #PB_EventType_Change)
		BindGadgetEvent(Tree, @Handler_Tree_RightClick(), UITK::#EventType_ItemRightClick)
		UITK::SubClassFunction(Tree, UITK::#SubClass_DropHandler, @Handler_Tree_Drop())
		
		Library = UITK::Library(#PB_Any, #Appearance_Window_Margin + #Appearance_Tree_Width, #Appearance_Library_ButtonHeight, LibraryWidth - #Appearance_Tree_Width, Window_Height - 2 * #Appearance_Window_Margin - #Appearance_TimeLine_MinHeight - #Appearance_Library_ButtonHeight, UITK::#Drag, @Library_RedrawItem())
		SetGadgetAttribute(Library, UITK::#Attribute_CornerRadius, #Appearance_CornerSize)
		SetGadgetAttribute(Library, UITK::#Attribute_CornerType, UITK::#Corner_Right)
		SetGadgetAttribute(Library, UITK::#Attribute_Library_SectionHeight, 9)
		EnableGadgetDrop(Library, #PB_Drop_Files, #PB_Drag_Copy | #PB_Drag_Move)
		*OriginalLibraryHandler = UITK::SubClassFunction(Library, UITK::#SubClass_EventHandler, @Library_EventHandler())
		
		Render = ContainerGadget(#PB_Any, GadgetX(Library) + LibraryWidth + #Appearance_Window_Margin, 0, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, Window_Height - 2 * #Appearance_Window_Margin - #Appearance_TimeLine_MinHeight, #PB_Container_BorderLess)
		SetGadgetColor(Render, #PB_Gadget_BackColor, #Black)
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
		ButtonNewLine = UITK::Button(#PB_Any, 10, 10, 40, 40, "")
		SetGadgetAttribute(ButtonNewLine, UITK::#Attribute_CornerType, UITK::#Corner_Left)
		SetGadgetAttribute(ButtonNewLine, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		SetGadgetColor(ButtonNewLine, UITK::#Color_Parent, SetAlpha(FixColor(#Color_Gadget_BackCold), 255))
		SetGadgetFont(ButtonNewLine, IconFont)
		BindGadgetEvent(ButtonNewLine, Project::@AddLine(), #PB_EventType_Change)
		
		ButtonRemoveLine = UITK::Button(#PB_Any, 50, 10, 40, 40, "")
		SetGadgetAttribute(ButtonRemoveLine, UITK::#Attribute_CornerRadius, 0)
		SetGadgetAttribute(ButtonRemoveLine, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		SetGadgetColor(ButtonRemoveLine, UITK::#Color_Back_Warm, SetAlpha(FixColor($E81123), 255))
		SetGadgetFont(ButtonRemoveLine, IconFont)
		BindGadgetEvent(ButtonRemoveLine, Project::@RemoveLine(), #PB_EventType_Change)
		
		ButtonLineRename = UITK::Button(#PB_Any, 90, 10, 40, 40, "")
		SetGadgetAttribute(ButtonLineRename, UITK::#Attribute_CornerRadius, 0)
		SetGadgetAttribute(ButtonLineRename, UITK::#Attribute_TextScale, 18)
		SetGadgetAttribute(ButtonLineRename, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		SetGadgetFont(ButtonLineRename, IconFont)
		
		ButtonLineDown = UITK::Button(#PB_Any, 130, 10, 40, 40, "")
		SetGadgetAttribute(ButtonLineDown, UITK::#Attribute_CornerRadius, 0)
		SetGadgetAttribute(ButtonLineDown, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		SetGadgetFont(ButtonLineDown, IconFont)
		
		ButtonLineUp = UITK::Button(#PB_Any, 170, 10, 40, 40, "")
		SetGadgetAttribute(ButtonLineUp, UITK::#Attribute_CornerType, UITK::#Corner_Right)
		SetGadgetAttribute(ButtonLineUp, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		SetGadgetColor(ButtonLineUp, UITK::#Color_Parent, SetAlpha(FixColor(#Color_Gadget_BackCold), 255))
		SetGadgetFont(ButtonLineUp, IconFont)
		
		CloseGadgetList()
		;}
		
		;{ Menu
		CreatePopupMenu(0)
		Menu_File = UITK::FlatMenu(UITK::#DarkMode)
		UITK::AddFlatMenuItem(Menu_File, 0, -1, "Item 2")
		UITK::AddFlatMenuItem(Menu_File, 0, -1, "Item 3")
		UITK::AddFlatMenuItem(Menu_File, 0, 0, "Item 1")
		UITK::AddFlatMenuSeparator(Menu_File, -1)
		UITK::AddFlatMenuItem(Menu_File, 0, -1, "Variable Viewer")
		UITK::AddFlatMenuItem(Menu_File, 0, -1, "Compare Files/Folder")
		UITK::AddFlatMenuItem(Menu_File, 0, -1, "Procedure Browser")
		
		UITK::AddWindowMenu(Window, Menu_File, "File")
		
		AddKeyboardShortcut(Window, #PB_Shortcut_Control | #PB_Shortcut_Z, #Menu_Undo)
		AddKeyboardShortcut(Window, #PB_Shortcut_Control | #PB_Shortcut_Y, #Menu_Redo)

		BindMenuEvent(0, #Menu_Undo, Project::@Undo())
		BindMenuEvent(0, #Menu_Redo, Project::@Redo())
		
		Tree_Menu = UITK::FlatMenu(UITK::#DarkMode)
		UITK::SetFlatMenuColor(Tree_Menu, UITK::#Color_WindowBorder, SetAlpha(FixColor(#Color_Menu_Border), 255))
		UITK::SetFlatMenuColor(Tree_Menu, UITK::#Color_Back_Cold, SetAlpha(FixColor(#Color_Gadget_ButtonCold), 255))
		UITK::SetFlatMenuColor(Tree_Menu, UITK::#Color_Back_Warm, SetAlpha(FixColor(#Color_Gadget_ButtonWarm), 255))
		UITK::AddFlatMenuItem(Tree_Menu, #Menu_AddFolder, -1, "Add sub folder")
		UITK::AddFlatMenuItem(Tree_Menu, #Menu_RemoveFolder, -1, "Delete")
		UITK::AddFlatMenuItem(Tree_Menu, #Menu_RenameFolder, -1, "Rename")
		
		BindMenuEvent(0, #Menu_AddFolder, Project::@AddFolder())
		BindMenuEvent(0, #Menu_RemoveFolder, Project::@RemoveFolder())
		BindMenuEvent(0, #Menu_RenameFolder, Project::@RenameFolder())
		
		;}
		
		Project::New()
		Handler_Tab()
		HideWindow(Window, #False)
	EndProcedure
	
	; Private procedures
	Procedure Handler_Tab()
		UITK::Freeze(Tree, #True)
		ClearGadgetItems(Tree)
		
		Select GetGadgetState(Tab)
			Case Project::#Media
				TabState = Project::#Media
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Media), 255))
				
			Case Project::#Audio
				TabState = Project::#Audio
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Audio), 255))
				
			Case Project::#_3D
				TabState = Project::#_3D
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_3D), 255))
				
			Case Project::#Overlay
				TabState = Project::#Overlay
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Overlay), 255))
				
			Case Project::#Modifiers
				TabState = Project::#Modifiers
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Modifiers), 255))
		EndSelect
		
		ForEach Project::Project\FoldersStructure[TabState]\List()
			Tree_Populate(Project::Project\FoldersStructure[TabState]\List(), 0)
		Next
		SetGadgetState(Tree, 0)
		Handler_Tree_Changer()
		
		UITK::Freeze(Tree, #False)
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
		SendMessage_(GadgetID(Tree), #WM_SETREDRAW, #False, 0)
		
		If VerticalGrowth
			TimeLine::Resize(TimeLine, #Appearance_Window_Margin, TempHeight + #Appearance_Window_Margin, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight)
			RedrawWindow_(GadgetID(TimeLine), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
			ResizeGadget(HorizontalContainer, #PB_Ignore, Window_Height - #Appearance_Window_Margin * 2 - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, #PB_Ignore)
			ResizeGadget(Library, #PB_Ignore, #PB_Ignore, LibraryWidth - #Appearance_Tree_Width, TempHeight - #Appearance_Library_ButtonHeight)
			ResizeGadget(Tree, #PB_Ignore, #PB_Ignore, #PB_Ignore, TempHeight - #Appearance_Library_ButtonHeight)
			SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
			RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
			SendMessage_(GadgetID(Tree), #WM_SETREDRAW, #True, 0)
			RedrawWindow_(GadgetID(Tree), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
			ResizeGadget(VerticalContainer, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, TempHeight)
			ResizeGadget(Render, LibraryWidth + 2 * #Appearance_Window_Margin, #PB_Ignore, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, TempHeight)
		Else
			ResizeGadget(Library, #PB_Ignore, #PB_Ignore, LibraryWidth - #Appearance_Tree_Width, TempHeight - #Appearance_Library_ButtonHeight)
			ResizeGadget(Tree, #PB_Ignore, #PB_Ignore, #PB_Ignore, TempHeight - #Appearance_Library_ButtonHeight)
			SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
			RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
			SendMessage_(GadgetID(Tree), #WM_SETREDRAW, #True, 0)
			RedrawWindow_(GadgetID(Tree), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
			ResizeGadget(VerticalContainer, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, TempHeight)
			ResizeGadget(Render, LibraryWidth + 2 * #Appearance_Window_Margin, #PB_Ignore, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, TempHeight)
			ResizeGadget(HorizontalContainer, #PB_Ignore, Window_Height - #Appearance_Window_Margin * 2 - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, #PB_Ignore)
			TimeLine::Resize(TimeLine, #Appearance_Window_Margin, TempHeight + #Appearance_Window_Margin, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight)
			RedrawWindow_(GadgetID(TimeLine), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
		EndIf
		
	EndProcedure
	
	Procedure Handler_Close()
		
	EndProcedure
	
	Procedure Library_RedrawItem(*Item.Library_Item, X, Y, Width, Height, State, *Theme.UITK::Theme)
		Protected TextHeight = Height - *Item\Text\Height
		
		With *Item
			If \Data
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
					MovePathCursor(X + 120, Y + 50)
					DrawVectorImage(PlusIcon(TabState))
				EndIf
				
				If \Selected
					UITK::AddPathRoundedBox(X - 0.5, Y - 0.5, 160 + 1, TextHeight + 1, 5)
					VectorSourceColor(*Theme\Special3[UITK::#Cold])
					StrokePath(3)
					VectorSourceColor(*Theme\TextColor[UITK::#Cold])
				EndIf
				
				MovePathCursor(X + 8, Y + 8)
				DrawVectorImage(Project::AssetIcon(\Data\Type))
			Else
				If \Text\FontScale
					VectorFont(\Text\FontID, \Text\FontScale)
				Else
					VectorFont(\Text\FontID)
				EndIf
				
				UITK::DrawVectorTextBlock(@\Text, X, Y + TextHeight + 2)
				
				If \HoverState
					UITK::AddPathRoundedBox(X, Y, 160, TextHeight, 5)
					VectorSourceColor(SetAlpha($FFFFFF, 35))
					FillPath()
					VectorSourceColor(*Theme\TextColor[UITK::#Cold])
					
					MovePathCursor(X + \ImageX, Y + \ImageY)
					DrawVectorImage(IconFolderOpen)
				Else
					MovePathCursor(X + \ImageX, Y + \ImageY)
					DrawVectorImage(IconFolder)
				EndIf
				
				If \Selected
					UITK::AddPathRoundedBox(X - 0.5, Y - 0.5, 160 + 1, TextHeight + 1, 5)
					VectorSourceColor(*Theme\Special3[UITK::#Cold])
					StrokePath(3)
					VectorSourceColor(*Theme\TextColor[UITK::#Cold])
				EndIf
			EndIf
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
								*Event\MouseY + \ScrollBar\State
								ForEach \Sections()
									If *Event\MouseY > \Sections()\Height
										*Event\MouseY - \Sections()\Height
									Else
										If *Event\MouseY > \SectionHeight
											*Event\MouseY - \SectionHeight
											If (*Event\MouseY % (\ItemHeight + \ItemVMargin ) < \ItemHeight - #Library_ItemTextHeight) And(*Event\MouseX % (\ItemHMargin + \ItemWidth) > \ItemHMargin)
												If SelectElement(\Sections()\Items(), Floor(*Event\MouseY / (\ItemHeight + \ItemVMargin )) * \ItemPerLine + Floor(*Event\MouseX / (\ItemHMargin + \ItemWidth)))
													*Event\MouseY % (\ItemHeight + \ItemVMargin )
													*Event\MouseX % (\ItemHMargin + \ItemWidth) - \ItemHMargin
													
													ChangeCurrentElement(\Items(), \Sections()\Items())
													
													If *Event\MouseX > 120 And *Event\MouseY > 50 And *Event\MouseX < 148 And *Event\MouseY < 78
														Cursor = #True
													ElseIf \Items()\Data = 0
														Cursor = #True
													EndIf
													
													NewItem = ListIndex(\Items())
												EndIf
											EndIf
										EndIf
										Break
									EndIf
								Next
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
							SelectElement(\Items(), \ItemState)
							
							If \Items()\Data
								
							Else
								SetGadgetState(Tree, GetGadgetState(Tree) + \ItemState + 1)
								\ItemState = -1
								Handler_Tree_Changer()
							EndIf
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
				Case UITK::#KeyDown ;{
					If GetGadgetAttribute(\Gadget, #PB_Canvas_Key) = #PB_Shortcut_Delete
						If \State > -1
							Project::RemoveAsset()
						EndIf
					Else
						CallFunctionFast(*OriginalLibraryHandler, *GadgetData, *Event)
					EndIf
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
	
	Procedure Tree_Populate(*Folder.Project::AssetFolder, Depth)
		SetGadgetItemData(Tree, AddGadgetItem(Tree, -1, *Folder\Name, 0, Depth), *Folder)
		
		ForEach *Folder\Childrens()
			Tree_Populate(*Folder\Childrens(), Depth + 1)
		Next
	EndProcedure
	
	Procedure Handler_Tree_Changer()
		*CurrentFolder = GetGadgetItemData(Tree, GetGadgetState(Tree))
		
		UITK::Freeze(Library, #True)
		ClearGadgetItems(Library)
		AddGadgetColumn(Library, 0, "", 0)
		
		ForEach *CurrentFolder\Childrens()
			AddGadgetItem(Library, -1, *CurrentFolder\Childrens()\Name, IconFolder, 0)
		Next
		
		ForEach Project::Project\Assets[TabState]\Map()
			If Project::Project\Assets[TabState]\Map()\Folder = *CurrentFolder
				SetGadgetItemData(Library, AddGadgetItem(Library, -1, Project::Project\Assets[TabState]\Map()\Name, ImageID(Project::Project\Assets[TabState]\Map()\PreviewImage), 0), Project::@Project\Assets[TabState]\Map())
			EndIf
		Next
		
		UITK::Freeze(Library, #False)
	EndProcedure
	
	Procedure Handler_Tree_RightClick()
		Protected *Folder.Project::AssetFolder = GetGadgetItemData(Tree, GetGadgetState(Tree))
		
		If *Folder\Parent
			UITK::DisableFlatMenuItem(Tree_Menu, 1, #False)
			UITK::DisableFlatMenuItem(Tree_Menu, 2, #False)
		Else
			UITK::DisableFlatMenuItem(Tree_Menu, 1, #True)
			UITK::DisableFlatMenuItem(Tree_Menu, 2, #True)
		EndIf
		
		UITK::ShowFlatMenu(Tree_Menu)
	EndProcedure
	
	Procedure Handler_Tree_Drop(*GadgetData.TreeData, State, Format, Action, x, y)
		Protected Hover = -1, *Asset.Project::Asset, LibraryState
		With *GadgetData
			Select State
				Case #PB_Drag_Enter, #PB_Drag_Update
					If SelectElement(\Items(), Floor((y + \ScrollBar\State) / \ItemHeight))
						If (x > \Border + \BranchWidth * (\Items()\Level + 1)) And (x < \Border + \BranchWidth * (\Items()\Level + 1) + \Items()\Text\RequieredWidth)
							LibraryState = GetGadgetState(Library)
							If LibraryState > -1
								*Asset = GetGadgetItemData(Library, LibraryState)
								If \Items()\Data\Type = *Asset\Type And \Items()\Data <> *Asset\Folder
									Hover = ListIndex(\Items())
								EndIf
							EndIf
						EndIf
					EndIf
					
					If Hover <> \DropHover
						\DropHover = Hover
						StartVectorDrawing(CanvasVectorOutput(*GadgetData\Gadget))
						AddPathBox(*GadgetData\OriginX, *GadgetData\OriginY, *GadgetData\Width, *GadgetData\Height, #PB_Path_Default)
						ClipPath(#PB_Path_Preserve)
						VectorSourceColor(*GadgetData\ThemeData\WindowColor)
						FillPath()
						*GadgetData\Redraw(*GadgetData)
						StopVectorDrawing()
					EndIf
					
					If \DropHover > -1
						ProcedureReturn #True
					EndIf
				Case #PB_Drag_Leave, #PB_Drag_Finish
					If \DropHover > -1
						If State = #PB_Drag_Finish
							SelectElement(\Items(), \DropHover)
							Project::MoveAsset(GetGadgetItemData(Library, GetGadgetState(Library)), \Items()\Data)
						EndIf
						
						\DropHover = -1
						StartVectorDrawing(CanvasVectorOutput(*GadgetData\Gadget))
						AddPathBox(*GadgetData\OriginX, *GadgetData\OriginY, *GadgetData\Width, *GadgetData\Height, #PB_Path_Default)
						ClipPath(#PB_Path_Preserve)
						VectorSourceColor(*GadgetData\ThemeData\WindowColor)
						FillPath()
						*GadgetData\Redraw(*GadgetData)
						StopVectorDrawing()
					EndIf
			EndSelect
		EndWith
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
						
						TimeLine::Resize(TimeLine, #Appearance_Window_Margin, Window_Height - #Appearance_Window_Margin - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight)
						
						SetWindowPos_(hWnd, 0, #Appearance_Window_Margin, PosY, 0, 0, #SWP_NOSIZE | #SWP_NOZORDER)
						
						SetWindowPos_(GadgetID(Render), 0, 0, 0, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight, #SWP_NOZORDER | #SWP_NOMOVE | #SWP_NOREDRAW)
						
						ResizeGadget(VerticalContainer, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight)
						
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #False, 0)
						ResizeGadget(Library, #PB_Ignore, #PB_Ignore, #PB_Ignore, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight - #Appearance_Library_ButtonHeight)
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
						
						SendMessage_(GadgetID(Tree), #WM_SETREDRAW, #False, 0)
						ResizeGadget(Tree, #PB_Ignore, #PB_Ignore, #PB_Ignore, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight - #Appearance_Library_ButtonHeight)
						SendMessage_(GadgetID(Tree), #WM_SETREDRAW, #True, 0)
						
						RedrawWindow_(GadgetID(Tree), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(Render), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
					Else
						PosY = General::Max(GadgetY(HorizontalContainer) + PosY, #Appearance_Render_MinHeight)
						TimeLineHeight = Window_Height - PosY - 2 * #Appearance_Window_Margin
						
						SetWindowPos_(GadgetID(Render), 0, 0, 0, Window_Width - 3 * #Appearance_Window_Margin - LibraryWidth, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight,#SWP_NOZORDER |  #SWP_NOMOVE | #SWP_NOREDRAW)
						
						ResizeGadget(VerticalContainer, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight)
						
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #False, 0)
						ResizeGadget(Library, #PB_Ignore, #PB_Ignore, #PB_Ignore, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight - #Appearance_Library_ButtonHeight)
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
						
						SendMessage_(GadgetID(Tree), #WM_SETREDRAW, #False, 0)
						ResizeGadget(Tree, #PB_Ignore, #PB_Ignore, #PB_Ignore, Window_Height - 2 * #Appearance_Window_Margin - TimeLineHeight - #Appearance_Library_ButtonHeight)
						SendMessage_(GadgetID(Tree), #WM_SETREDRAW, #True, 0)
						
						SetWindowPos_(hWnd, 0, #Appearance_Window_Margin, PosY, 0, 0, #SWP_NOSIZE | #SWP_NOZORDER)
						
						TimeLine::Resize(TimeLine, #Appearance_Window_Margin, Window_Height - #Appearance_Window_Margin - TimeLineHeight, Window_Width - 2 * #Appearance_Window_Margin, TimeLineHeight)
						
						RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(Tree), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
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
						ResizeGadget(Library, #PB_Ignore, #PB_Ignore, LibraryWidth - #Appearance_Tree_Width, #PB_Ignore)
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #True, 0)
						
						RedrawWindow_(GadgetID(Library), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						RedrawWindow_(GadgetID(Render), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
						
						SetWindowPos_(GadgetID(VerticalContainer), 0, LibraryWidth + #Appearance_Window_Margin, 0, #Appearance_Window_Margin, Height, #SWP_NOZORDER)
						
					Else
						PosX = General::Max(GadgetX(VerticalContainer) + PosX, #Appearance_Library_MinWidth + #Appearance_Window_Margin)
						LibraryWidth = PosX - #Appearance_Window_Margin
						
						SendMessage_(GadgetID(Library), #WM_SETREDRAW, #False, 0)
						ResizeGadget(Library, #PB_Ignore, #PB_Ignore, LibraryWidth - #Appearance_Tree_Width, #PB_Ignore)
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
		
		IconFolder:
		IncludeBinary "../Media/Icon-Folder.png"
		
		IconFolderOpen:
		IncludeBinary "../Media/Icon-FolderOpen.png"
	EndDataSection ;}
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 833
; FirstLine = 317
; Folding = Z-DAg5
; EnableXP
; DPIAware