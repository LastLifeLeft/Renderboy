Module MainWindow
	EnableExplicit
	; Macro
	Macro SetMenuButtonAppearence(menu)
		SetGadgetColor(#menu, CanvasButton::#BackColor_Cold, General::FixColor(General::#Color_Window_Back_Cold))
		SetGadgetColor(#menu, CanvasButton::#BackColor_Warm, General::FixColor(General::#Color_Window_Back_Warm))
		SetGadgetColor(#menu, CanvasButton::#BackColor_Hot, General::FixColor(General::#Color_Window_Back_Warm))
		SetGadgetColor(#menu, CanvasButton::#FrontColor_Cold, General::FixColor(General::#Color_Window_Front_Cold))
		SetGadgetColor(#menu, CanvasButton::#FrontColor_Warm, General::FixColor(General::#Color_Window_Front_Warm))
		SetGadgetColor(#menu, CanvasButton::#FrontColor_Hot, General::FixColor(General::#Color_Window_Front_Warm))
		SetGadgetFont(#menu, Font)
		BindGadgetEvent(#menu, @Handler#menu#(), #PB_EventType_Change)
	EndMacro
	
	Macro SetWindowButtonApparence(Button)
		SetGadgetColor(#Button, CanvasButton::#BackColor_Cold, General::FixColor(General::#Color_Window_Back_Cold))
		SetGadgetColor(#Button, CanvasButton::#BackColor_Warm, General::FixColor(General::#Color_Window_Back_Warm))
		SetGadgetColor(#Button, CanvasButton::#BackColor_Hot, General::FixColor(General::#Color_Window_Back_Warm))
		SetGadgetColor(#Button, CanvasButton::#FrontColor_Cold, General::FixColor(General::#Color_Window_Front_Cold))
		SetGadgetColor(#Button, CanvasButton::#FrontColor_Warm, General::FixColor(General::#Color_Window_Front_Warm))
		SetGadgetColor(#Button, CanvasButton::#FrontColor_Hot, General::FixColor(General::#Color_Window_Front_Warm))
		SetGadgetFont(#Button, MaterialIcon)
		BindGadgetEvent(#Button, @Handler#Button#(), #PB_EventType_Change)
	EndMacro
	
	Macro SetMenuAppearance(MenuName)
		FlatMenu::SetFont(MenuName#Menu, Font)
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#ColorType_LineColor, General::FixColor(General::#Color_Window_Back_Cold))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_BackCold, General::FixColor(General::#Color_Window_Back_Warm))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_BackHot, General::FixColor(General::#Color_Window_Back_Hot))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_FrontCold, General::FixColor(General::#Color_Window_Front_Cold))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_FrontHot, General::FixColor(General::#Color_Window_Front_Warm))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_FrontDisabled, General::FixColor($909090))
		BindEvent(#PB_Event_DeactivateWindow, @HandlerCloseMenu(), MenuName#Menu)
		SetProp_(WindowID(MenuName#Menu), "gadget", #MenuName#Button)
	EndMacro
	
	Macro SetAssetBarButtonAppearance(ButtonName)
		*MediaButton\State = #False
		StartDrawing(CanvasOutput(ButtonName))
		Box(0, 0, #Size_Media_Icon, #Size_Media_Icon, General::FixColor(General::#Color_Window_Back_Cold))
		FrontColor($A0A0A0)
		BackColor(General::FixColor(General::#Color_Window_Back_Cold))
		
		DrawingFont(IconLight)
		*MediaButton\IconX = (#Size_Media_Icon - TextWidth(*MediaButton\Icon)) * 0.5
		DrawText(*MediaButton\IconX, 12, *MediaButton\Icon)
		
		DrawingFont(Font)
		*MediaButton\Textx = (#Size_Media_Icon - TextWidth(*MediaButton\Text)) * 0.5
		DrawText(*MediaButton\Textx, 45, *MediaButton\Text)
		
		StopDrawing()
		SetGadgetData(ButtonName, *MediaButton)
		BindGadgetEvent(ButtonName, @HandlerAssetBarButton())
	EndMacro
	
	Macro MAKEWORD(iLo, iHi)
		((iHi<<8)| (iLo& $FF))
	EndMacro
	
	;{ Private variables, structures, constants...
	
	Enumeration
		#Asset_Media
		#Asset_Sound
		#Asset_Model
		#Asset_Overlay
		#Asset_Element
	EndEnumeration
	
	
	;{ Style
	
	; Size
	#Size_Window_Border = 8
	#Size_TitleBar_ButtonHeight = 36
	#Size_TitleBar_ButtonWidth = 45
	#Size_TitleBar_TopMargin = 1
	#Size_Media_Icon = 70
	
	#Size_Timeline_MinimumHeight = 304
	#Size_AssetContainer_MinimumWidth = 572
	
	#Size_RoundedCorner = 4
	;}
	
	;{ Window management stuff
	#WM_SYSMENU = $313
	
	Global CursorSize, DWMEnabled, SplitterCursor, WindowWidth = 1920, WindowHeight = 1080, EditSplitter = 0, SplitterOrigin, MouseOrigin

	;}
	
	; Fonts
	Global FontBold = FontID(LoadFont(#PB_Any, "Rubik Medium", 12, #PB_Font_HighQuality))
	Global Font = FontID(LoadFont(#PB_Any, "Rubik", 10, #PB_Font_HighQuality))
	Global FontTest = FontID(LoadFont(#PB_Any, "Karla", 11, #PB_Font_HighQuality))
	
	Global IconSolid = FontID(LoadFont(#PB_Any, "Font Awesome 5 Pro Solid", 20, #PB_Font_HighQuality))
	Global Icon = FontID(LoadFont(#PB_Any, "Font Awesome 5 Pro Regular", 20, #PB_Font_HighQuality))
	Global IconLight = FontID(LoadFont(#PB_Any, "Font Awesome 5 Pro Light", 16, #PB_Font_HighQuality))
	
	Global Dim MediaContainerBorder(4)
	
	Structure MediaButton
		State.b
		Icon.s
		Text.s
		Color.l
		IconX.i
		Textx.i
		Pos.i
	EndStructure
	;{ Corners
	Procedure ROTATE_90(image)  ; There is a bug with vector rotation in 5.73, so I grabbed that from here : https://www.purebasic.fr/english/viewtopic.php?p=437174#p437174
		Protected a,b,c,e,f,h,s,w,x,y,ym,xm,tempImg,depth, Result
		
		If IsImage(image) = 0 : ProcedureReturn 0 : EndIf
		
		StartDrawing(ImageOutput(image))
		w = OutputWidth()
		h = OutputHeight()
		f = DrawingBufferPixelFormat() & $7F
		StopDrawing()
		
		If f = #PB_PixelFormat_32Bits_RGB Or f = #PB_PixelFormat_32Bits_BGR
			depth = 32
		ElseIf f = #PB_PixelFormat_24Bits_RGB Or f = #PB_PixelFormat_24Bits_BGR
			depth = 24
		Else
			ProcedureReturn 0
		EndIf
		
		If w > h : s = w : Else : s = h : EndIf ; find the largest dimension
		
		tempImg = CreateImage(#PB_Any,s,s,depth) ; make a square working area
		
		StartDrawing(ImageOutput(tempImg))
		If depth = 32 : DrawingMode(#PB_2DDrawing_AllChannels) : EndIf
		
		DrawImage(ImageID(image),0,0)
		
		ym = s/2-1 ; max y loop value
		xm = s/2-(s!1&1) ; max x value, subtract 1 if 's' is even
		s-1
		
		For y = 0 To ym
			For x = 0 To xm
				e = Point(x,y)
				a = s-x : Plot(x,y,Point(y,a))
				b = s-y : Plot(y,a,Point(a,b))
				c = s-a : Plot(a,b,Point(b,c))
				Plot(b,c,e)
			Next x
		Next y
		
		StopDrawing()
		
		Result = GrabImage(tempImg,#PB_Any,s-h+1,0,h,w) ; right
		
		FreeImage(tempImg)
		ProcedureReturn Result
	EndProcedure
	
	Global CornerUL = CatchImage(#PB_Any, ?Corner)
	Global CornerUR = ROTATE_90(CornerUL)
	;}
	
	Global Timeline_Height = 304, AssetContainer_Width = #Size_AssetContainer_MinimumWidth
	Global FileMenu, EditMenu, ProjectMenu, Renderer, AssetContainertID
	Global MediaState.b
	Global AssetButtonScrollBar, ScrollBarWidth = GetSystemMetrics_(#SM_CXVSCROLL) + 3
	
	Structure AssetButtonList
		Gadget.i
		UUID.s
	EndStructure
	
	Global NewList AssetButtonList.AssetButtonList()
	
	;}
	
	;{ Private procedures declaration
	; Handler
	Declare HandlerShortcutWorkAround(hWnd, Msg, wParam, lParam)
	Declare HandlerScrollArea(hWnd, Msg, wParam, lParam)
	Declare HandlerWindow(hWnd, Msg, wParam, lParam)
	Declare HandlerCloseButton()
	Declare HandlerMaximizeButton()
	Declare HandlerMinimizeButton()
	Declare HandlerFileButton()
	Declare HandlerEditButton()
	Declare HandlerProjectButton()
	Declare HandlerCloseMenu()
	Declare HandlerAssetBarButton()
	Declare HandlerAssetDrop()
	Declare HandlerAssetScrollBar()
	Declare HandlerDrop(TargetHandle, State, Format, Action, x, y)
	Declare HandlerDrag(Action)
	Declare HandlerTimeLineDrop()
	Declare HandlerTimeLineChildrenDrop()
	Declare HandlerTimeLine()
	Declare HandlerPropertieWindowsToggle()
	Declare Hook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	
	; Misc
	Declare Refit()
	Declare RefitAssets(ContainerWidth, ContainerHeight)
	;}
	
	;{ Public procedures	
	Procedure Open()
		Protected WindowID, *MediaButton.MediaButton, Image

		; Appearence
		WindowID = OpenWindow(#Window, 0, 0, 1920 - #Size_Window_Border * 2, 1041, General::#Name + " " + General::#Version , #WS_OVERLAPPEDWINDOW&~#WS_SYSMENU|#PB_Window_ScreenCentered|#PB_Window_Invisible)
		EnableWindowDrop(#Window, #PB_Drop_Text, #PB_Drag_Copy)
		
		CallFunction(0, "DwmExtendFrameIntoClientArea", WindowID, General::@WindowMargin)
		CallFunction(0, "DwmIsCompositionEnabled", @DWMEnabled)
		
		If DWMEnabled = 0
			SetWindowTheme_(WindowID, "", "")
		EndIf
		
		SetClassLongPtr_(WindowID, #GCL_HBRBACKGROUND, General::WindowBrush)
		SetProp_(WindowID, "oldproc", SetWindowLongPtr_(WindowID, #GWL_WNDPROC, @HandlerWindow()))
		
		; Title bar
		CanvasButton::Gadget(#FileButton, 36, #Size_TitleBar_TopMargin, 40, #Size_TitleBar_ButtonHeight, "File", -1, CanvasButton::#DarkTheme | CanvasButton::#Toggle)
		SetMenuButtonAppearence(FileButton)
		
		CanvasButton::Gadget(#EditButton, 76, #Size_TitleBar_TopMargin, 40, #Size_TitleBar_ButtonHeight, "Edit", -1, CanvasButton::#DarkTheme | CanvasButton::#Toggle)
		SetMenuButtonAppearence(EditButton)
		
		CanvasButton::Gadget(#ProjectButton, 116, #Size_TitleBar_TopMargin, 56, #Size_TitleBar_ButtonHeight, "Project", -1, CanvasButton::#DarkTheme | CanvasButton::#Toggle)
		SetMenuButtonAppearence(ProjectButton)
		
		CanvasButton::Gadget(#CloseButton, 1920 - #Size_TitleBar_ButtonWidth, #Size_TitleBar_TopMargin, #Size_TitleBar_ButtonWidth, #Size_TitleBar_ButtonHeight, "󰅖", -1, CanvasButton::#DarkTheme)
		SetWindowButtonApparence(CloseButton)
		SetGadgetColor(#CloseButton, CanvasButton::#BackColor_Warm, General::FixColor($E00000))
		SetGadgetColor(#CloseButton, CanvasButton::#BackColor_Hot, General::FixColor($E00000))
		SetGadgetColor(#CloseButton, CanvasButton::#FrontColor_Warm, General::FixColor($FFFFFF))
		SetGadgetColor(#CloseButton, CanvasButton::#FrontColor_Hot, General::FixColor($FFFFFF))
		
		CanvasButton::Gadget(#MaximizeButton, 1920 - #Size_TitleBar_ButtonWidth * 2, #Size_TitleBar_TopMargin, #Size_TitleBar_ButtonWidth, #Size_TitleBar_ButtonHeight, "󰖯", -1, CanvasButton::#DarkTheme)
		SetWindowButtonApparence(MaximizeButton)
		
		CanvasButton::Gadget(#MinimizeButton, 1920 - #Size_TitleBar_ButtonWidth * 3, #Size_TitleBar_TopMargin, #Size_TitleBar_ButtonWidth, #Size_TitleBar_ButtonHeight, "󰖰", -1, CanvasButton::#DarkTheme)
		SetWindowButtonApparence(MinimizeButton)
		
		ImageGadget(#PB_Any, 5, 5, 0 ,0 , ImageID(CatchImage(#PB_Any, ?Logo)))
		
		; Menus
		FileMenu = FlatMenu::Create(#Window)
		FlatMenu::AddItem(FileMenu, 1, -1, "New")
		FlatMenu::AddItem(FileMenu, 2, -1, "Open...")
		FlatMenu::AddItem(FileMenu, 3, -1, "Save")
		FlatMenu::AddItem(FileMenu, 4, -1, "Save As...")
		FlatMenu::AddItem(FileMenu, 5, -1, "Archive project...")
		FlatMenu::AddItem(FileMenu, 6, -1, "Exit")
		SetMenuAppearance(File)
		
		EditMenu =  FlatMenu::Create(#Window)
		FlatMenu::AddItem(EditMenu, 16, -1, "Preferences...")
		FlatMenu::AddItem(EditMenu, 22, -1, "Properties window", FlatMenu::#Toggle)
		FlatMenu::AddItem(EditMenu, 17, -1, "Undo")
		FlatMenu::AddItem(EditMenu, 18, -1, "Redo")
		FlatMenu::AddItem(EditMenu, 19, -1, "Cut")
		FlatMenu::AddItem(EditMenu, 20, -1, "Copy")
		FlatMenu::AddItem(EditMenu, 21, -1, "Paste")
		SetMenuAppearance(Edit)
		
		ProjectMenu =  FlatMenu::Create(#Window)
		FlatMenu::AddItem(ProjectMenu, 26, -1, "Settings...")
		FlatMenu::AddItem(ProjectMenu, 27, -1, "Export...")
		SetMenuAppearance(Project)
		
		UseGadgetList(WindowID)
		
		; Tools
		CanvasGadget(#Asset_VideoButton, 20, #Size_TitleBar_ButtonHeight + 2, #Size_Media_Icon, #Size_Media_Icon)
		*MediaButton = AllocateStructure(MediaButton)
		*MediaButton\Color = General::FixColor(#Color_Asset_Media)
		*MediaButton\Icon = ""
		*MediaButton\Text = "Media"
		*MediaButton\Pos = #Asset_Media
		SetAssetBarButtonAppearance(#Asset_VideoButton)
		
		CanvasGadget(#Asset_AudioButton, 20 + #Size_Media_Icon, #Size_TitleBar_ButtonHeight + 2, #Size_Media_Icon, #Size_Media_Icon)
		*MediaButton = AllocateStructure(MediaButton)
		*MediaButton\Color = General::FixColor(#Color_Asset_Audio)
		*MediaButton\Icon = ""
		*MediaButton\Text = "Audio"
		*MediaButton\Pos = #Asset_Sound
		SetAssetBarButtonAppearance(#Asset_AudioButton)
		
		CanvasGadget(#Asset_ModelButton, 20 + #Size_Media_Icon * 2, #Size_TitleBar_ButtonHeight + 2, #Size_Media_Icon, #Size_Media_Icon)
		*MediaButton = AllocateStructure(MediaButton)
		*MediaButton\Color = General::FixColor(#Color_Asset_Model)
		*MediaButton\Icon = ""
		*MediaButton\Text = "3D"
		*MediaButton\Pos = #Asset_Model
		SetAssetBarButtonAppearance(#Asset_ModelButton)
		
		CanvasGadget(#Asset_UIButton, 20 + #Size_Media_Icon * 3, #Size_TitleBar_ButtonHeight + 2, #Size_Media_Icon, #Size_Media_Icon)
		*MediaButton = AllocateStructure(MediaButton)
		*MediaButton\Color = General::FixColor(#Color_Asset_Overlay)
		*MediaButton\Icon = ""
		*MediaButton\Text = "Overlay"
		*MediaButton\Pos = #Asset_Overlay
		SetAssetBarButtonAppearance(#Asset_UIButton)
		
		CanvasGadget(#Asset_ElementButton, 20 + #Size_Media_Icon * 4, #Size_TitleBar_ButtonHeight + 2, #Size_Media_Icon, #Size_Media_Icon)
		*MediaButton = AllocateStructure(MediaButton)
		*MediaButton\Color = General::FixColor(#Color_Asset_Element)
		*MediaButton\Icon = ""
		*MediaButton\Text = "Elements"
		*MediaButton\Pos = #Asset_Element
		SetAssetBarButtonAppearance(#Asset_ElementButton)
		
		MediaState = 1
		PostEvent(#PB_Event_Gadget, #Window, #Asset_VideoButton, #PB_EventType_LeftButtonDown)
		
		AssetContainertID = ContainerGadget(#Asset_Container, 10, #Size_Media_Icon + #Size_TitleBar_ButtonHeight + 2, AssetContainer_Width, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon, #PB_Container_BorderLess)
		SetProp_(AssetContainertID, "oldproc", SetWindowLongPtr_(AssetContainertID, #GWL_WNDPROC, @HandlerShortcutWorkAround()))
		BindEvent(#PB_Event_GadgetDrop, @HandlerAssetDrop(), #Window, #Asset_Container)
		
		EnableGadgetDrop(#Asset_Container, #PB_Drop_Files, #PB_Drag_Copy | #PB_Drag_Link | #PB_Drag_Move)
		SetGadgetColor(#Asset_Container, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		
		Protected CornerDR = ROTATE_90(CornerUR)
		Protected CornerDL = ROTATE_90(CornerDR)
		
		Image = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner, 24, General::FixColor( General::#Color_Content_Back_Cold))
		StartDrawing(ImageOutput(Image))
		DrawAlphaImage(ImageID(CornerUL), 0, 0)
		StopDrawing()
		MediaContainerBorder(0) = GadgetID(ImageGadget(#PB_Any, 0, 0, 0, 0 , ImageID(Image)))
		
		Image = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner, 24, General::FixColor( General::#Color_Content_Back_Cold))
		StartDrawing(ImageOutput(Image))
		DrawAlphaImage(ImageID(CornerUR), 0, 0)
		StopDrawing()
		MediaContainerBorder(1) = GadgetID(ImageGadget(#PB_Any, AssetContainer_Width - #Size_RoundedCorner, 0, 0, 0 , ImageID(Image)))
		
		Image = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner, 24, General::FixColor( General::#Color_Content_Back_Cold))
		StartDrawing(ImageOutput(Image))
		DrawAlphaImage(ImageID(CornerDR), 0, 0)
		StopDrawing()
		MediaContainerBorder(2) = GadgetID(ImageGadget(#PB_Any, AssetContainer_Width - #Size_RoundedCorner, 1080 - #Size_TitleBar_ButtonHeight - 25 - Timeline_Height - #Size_Media_Icon, 0, 0 , ImageID(Image)))
		
		Image = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner, 24, General::FixColor( General::#Color_Content_Back_Cold))
		StartDrawing(ImageOutput(Image))
		DrawAlphaImage(ImageID(CornerDL), 0, 0)
		StopDrawing()
		MediaContainerBorder(3) = GadgetID(ImageGadget(#PB_Any, 0, 1080 - #Size_TitleBar_ButtonHeight - 25 - Timeline_Height - #Size_Media_Icon, 0, 0 , ImageID(Image)))
		
		ScrollAreaGadget(#Asset_ScrollArea, 0, 0, AssetContainer_Width - 46, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon, AssetContainer_Width - 6, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon, 45, #PB_ScrollArea_BorderLess)
		SetProp_(GadgetID(#Asset_ScrollArea), "oldproc", SetWindowLongPtr_(GadgetID(#Asset_ScrollArea), #GWL_WNDPROC, @HandlerScrollArea()))
		
 		SetGadgetColor(#Asset_ScrollArea, #PB_Gadget_BackColor, General::FixColor(General::#Color_Content_Back_Cold))
		CloseGadgetList()
		CloseGadgetList()
		ScrollBar::Gadget(#Asset_ScrollBar, 0, #Size_Media_Icon + #Size_TitleBar_ButtonHeight + 2, 12, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon, 0, 100, 10, ScrollBar::#Vertical)
		BindGadgetEvent(#Asset_ScrollBar, @HandlerAssetScrollBar(), #PB_EventType_Change)
		SetGadgetColor(#Asset_ScrollBar, #PB_Gadget_BackColor, General::SetAlpha($FF, General::FixColor(General::#Color_Content_Back_Cold)))
		SetGadgetColor(#Asset_ScrollBar, #PB_Gadget_LineColor, General::SetAlpha($FF, General::FixColor(General::#Color_Window_Back_Cold)))
		
		SetGadgetColor(#Asset_ScrollBar, #PB_Gadget_FrontColor, 		General::SetAlpha($FF, General::FixColor(General::#Color_Scrollbar_FrontCold)))
		SetGadgetColor(#Asset_ScrollBar, ScrollBar::#Color_FrontWarm,	General::SetAlpha($FF, General::FixColor(General::#Color_Scrollbar_FrontWarm)))
		SetGadgetColor(#Asset_ScrollBar, ScrollBar::#Color_FrontHot,	General::SetAlpha($FF, General::FixColor(General::#Color_Scrollbar_FrontHot)))
		
		; Timeline
		PureTL::Gadget(#TimeLine, 10, 1080 - Timeline_Height - 10, 1900, Timeline_Height)
		SetProp_(GadgetID(#TimeLine), "oldproc", SetWindowLongPtr_(GadgetID(#TimeLine), #GWL_WNDPROC, @HandlerShortcutWorkAround()))
		
		BindEvent(#PB_Event_GadgetDrop, @HandlerTimeLineDrop(), #Window, #TimeLine)
		BindEvent(PureTL::#Event_ParentDrop, @HandlerTimeLineChildrenDrop(), #Window, #TimeLine)
		BindGadgetEvent(#TimeLine,@HandlerTimeLine())
		
		; Misc
		BindEvent(#PB_Event_Menu, Project::@Undo(), #Window, 17)
		BindEvent(#PB_Event_Menu, Project::@Redo(), #Window, 18)
		BindEvent(#PB_Event_Menu, @HandlerPropertieWindowsToggle(), #Window, 22)
		
		SetGadgetFont(#PB_Default, Font)
		
		SetWindowPos_(WindowID, 0, 0, 0, 0, 0, #SWP_NOSIZE|#SWP_NOMOVE|#SWP_FRAMECHANGED|#SWP_SHOWWINDOW)
		
		SetDropCallback(@HandlerDrop())
		SetDragCallback(@HandlerDrag())
		
		DragPreview = OpenWindow(#PB_Any, 0, 0, 160, 90, "", #PB_Window_BorderLess | #PB_Window_Invisible, WindowID)
		SetWindowLongPtr_(WindowID(DragPreview),#GWL_EXSTYLE,#WS_EX_LAYERED)
		SetLayeredWindowAttributes_(WindowID(DragPreview),0,140,#LWA_ALPHA)
		ImagePreview = ImageGadget(#PB_Any, 0, 0, 0, 0, 0)
		
		
		#WH_KEYBOARD_LL = 13
		SetWindowsHookEx_(#WH_KEYBOARD_LL,@Hook(),GetModuleHandle_(0),0)
		
		; Renderer
		CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
			Renderer = FindWindow_(#Null, General::WindowName)
			While Renderer = 0
				Delay(10)
				Renderer=FindWindow_(#Null, General::WindowName)
			Wend
			
			SetWindowLong_(Renderer, #GWL_STYLE, GetWindowLong_(Renderer, #GWL_STYLE)| #WS_CHILD  !#WS_POPUP)
			SetWindowLong_(Renderer, #GWL_EXSTYLE, GetWindowLong_(Renderer, #GWL_EXSTYLE) ! #WS_EX_APPWINDOW)
			SetParent_(Renderer, WindowID)
		CompilerElse
			UseGadgetList(WindowID)
			Renderer = ContainerGadget(#PB_Any, AssetContainer_Width + 20, #Size_TitleBar_ButtonHeight + 2, 1920 - AssetContainer_Width - 30, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height, #PB_Container_BorderLess)
			
			SetGadgetColor(Renderer, #PB_Gadget_BackColor, 0)
			Renderer = GadgetID(Renderer)
			CloseGadgetList()

		CompilerEndIf
		Refit()
		HideWindow(#Window, #False)
		
		PropertiesWindow::Open()
		
		CloseLibrary(0)
	EndProcedure
	
	Procedure AddAssetButton(AssetType, Image, Text.s, UUID.s)
		Select MediaState
			Case #Asset_Media
				If Not ( AssetType = Project::#Asset_Type_Image Or AssetType = Project::#Asset_Type_Video)
					ProcedureReturn
				EndIf
			Case #Asset_Sound
				If Not ( AssetType = Project::#Asset_Type_Sound Or AssetType = Project::#Asset_Type_Music Or AssetType = Project::#Asset_Type_Voice)
					ProcedureReturn
				EndIf
			Case #Asset_Model
				
			Case #Asset_Overlay
				
			Case #Asset_Element
				If Not ( AssetType = Project::#Asset_Type_2DEffect)
					ProcedureReturn
				EndIf
		EndSelect
		
		LastElement(AssetButtonList())
		AddElement(AssetButtonList())
		
		OpenGadgetList(#Asset_ScrollArea)
		AssetButtonList()\Gadget = AssetButton::Gadget(#PB_Any, 20, 20, 160, 110, Image, AssetType, Text, UUID)
		AssetButtonList()\UUID = UUID
		Refit()
		CloseGadgetList()
	EndProcedure
	
	Procedure DeleteAssetButton(UUID.s)
		ForEach AssetButtonList()
			If AssetButtonList()\UUID = UUID
				AssetButton::Delete(AssetButtonList()\Gadget)
				DeleteElement(AssetButtonList())
				Refit()
				Break
			EndIf
		Next
	EndProcedure
	;}
	
	;{ Private procedures
	; Handler	
	Procedure HandlerShortcutWorkAround(hWnd, Msg, wParam, lParam)
		Protected oldproc = GetProp_(hWnd, "oldproc")
		If msg = #WM_KEYDOWN
			Select wParam 
				Case 89 ; Y
					If GetAsyncKeyState_(#VK_CONTROL)
						Project::Redo()
					EndIf
				Case 90 ; Z
					If GetAsyncKeyState_(#VK_CONTROL)
						Project::Undo()
					EndIf
			EndSelect
		EndIf
		
		ProcedureReturn CallWindowProc_(oldproc, hWnd, Msg, wParam, lParam)
	EndProcedure
		
	Procedure HandlerScrollArea(hWnd, Msg, wParam, lParam)
		Protected oldproc = GetProp_(hWnd, "oldproc")
		
		If msg = #WM_KEYDOWN
			Select wParam 
				Case 89 ; Y
					If GetAsyncKeyState_(#VK_CONTROL)
						Project::Redo()
					EndIf
				Case 90 ; Z
					If GetAsyncKeyState_(#VK_CONTROL)
						Project::Undo()
					EndIf
			EndSelect
		ElseIf Msg = #WM_VSCROLL
			SetGadgetState(#Asset_ScrollBar, (wParam >> 16) & $FFFF)
		EndIf
		
		ProcedureReturn CallWindowProc_(oldproc, hWnd, Msg, wParam, lParam)
	EndProcedure
	
	Procedure HandlerWindow(hWnd, Msg, wParam, lParam)
		Protected oldproc = GetProp_(hWnd, "oldproc")
		Protected Width, PosX, PosY, Height, p.POINT, cursor.POINT
		
		Select Msg
			Case #WM_GETMINMAXINFO ;{
				Protected *mmi.MINMAXINFO = lParam
				Protected hMon = MonitorFromWindow_(hWnd, #MONITOR_DEFAULTTONEAREST)
				Protected mie.MONITORINFOEX\cbSize = SizeOf(mie)
				GetMonitorInfo_(hMon, mie)
				*mmi\ptMaxPosition\x = Abs(mie\rcWork\left - mie\rcMonitor\left)
				*mmi\ptMaxPosition\y = Abs(mie\rcWork\top - mie\rcMonitor\top)
				*mmi\ptMaxSize\x = Abs(mie\rcWork\right - mie\rcWork\left)
				*mmi\ptMaxSize\y = Abs(mie\rcWork\bottom - mie\rcWork\top) - 1
				*mmi\ptMinTrackSize\x = 1280
				*mmi\ptMinTrackSize\Y = 720
				ProcedureReturn 0
				;}
			Case #WM_NCCALCSIZE ;{
				ProcedureReturn 0
				;}
			Case #WM_CTLCOLORSTATIC, #WM_CTLCOLORBTN ;{
				SetBkMode_(wParam, #TRANSPARENT)
				ProcedureReturn General::WindowBrush
				;}
			Case #WM_SIZE ;{
				Refit()
				;}
			Case #WM_NCACTIVATE ;{
				If DWMEnabled=0
					ProcedureReturn 1
				EndIf
				;}
			Case #WM_MOUSEMOVE ;{
				posX = lParam & $FFFF
				posY = (lParam >> 16) & $FFFF
				width = WindowWidth(#Window)
				height = WindowHeight(#Window)
				
				If EditSplitter = 0
				
					CursorSize = 0
					SplitterCursor = 0
					
					If IsZoomed_(hWnd) = 0
						If posX <= #Size_Window_Border And posY <= #Size_Window_Border
							SetCursor_(LoadCursor_(0, #IDC_SIZENWSE))
							CursorSize = #HTTOPLEFT
						ElseIf posX > #Size_Window_Border And posX <= width - #Size_Window_Border And posY <= #Size_Window_Border
							SetCursor_(LoadCursor_(0, #IDC_SIZENS))
							CursorSize = #HTTOP
						ElseIf posX > width - #Size_Window_Border And posY <= #Size_Window_Border
							SetCursor_(LoadCursor_(0, #IDC_SIZENESW))
							CursorSize = #HTTOPRIGHT
						ElseIf posX > width - #Size_Window_Border And posY > #Size_Window_Border And posY <= height - #Size_Window_Border
							SetCursor_(LoadCursor_(0, #IDC_SIZEWE))
							CursorSize = #HTRIGHT
						ElseIf posX > width - #Size_Window_Border And posY > height - #Size_Window_Border
							SetCursor_(LoadCursor_(0, #IDC_SIZENWSE))
							CursorSize = #HTBOTTOMRIGHT
						ElseIf posX > #Size_Window_Border And posX <= width - #Size_Window_Border And posY > height - #Size_Window_Border
							SetCursor_(LoadCursor_(0, #IDC_SIZENS))
							CursorSize = #HTBOTTOM
						ElseIf posX <= #Size_Window_Border And posY > height - #Size_Window_Border
							SetCursor_(LoadCursor_(0, #IDC_SIZENESW))
							CursorSize = #HTBOTTOMLEFT
						ElseIf posX <= #Size_Window_Border And posY > #Size_Window_Border And posY <= height - #Size_Window_Border
							SetCursor_(LoadCursor_(0, #IDC_SIZEWE))
							CursorSize = #HTLEFT
						EndIf
					EndIf
					
					If PosY > #Size_TitleBar_ButtonHeight + 2
						If PosY < Height - Timeline_Height - 20
							If posX >= AssetContainer_Width + 10 And posX <= AssetContainer_Width + 20
								SetCursor_(LoadCursor_(0, #IDC_SIZEWE))
								SplitterCursor = #HTLEFT
							EndIf
						ElseIf PosY < Height - Timeline_Height - 10
							If posX > 10 And PosX < Width - 10
								SetCursor_(LoadCursor_(0, #IDC_SIZENS))
								SplitterCursor = #HTBOTTOM
							EndIf
						EndIf
					EndIf
					
					If SplitterCursor = 0
						If wParam = 0 And CursorSize = 0
							SetCursor_(LoadCursor_(0, #IDC_ARROW))
						ElseIf wParam = #MK_LBUTTON
							SendMessage_(hWnd, #WM_NCLBUTTONDOWN, CursorSize, 0)
						EndIf
					Else
						CursorSize = SplitterCursor
					EndIf
				ElseIf EditSplitter = 1
					PosX = General::Min(General::Max(SplitterOrigin + PosX - MouseOrigin, #Size_AssetContainer_MinimumWidth), width - 600)
					If AssetContainer_Width <> PosX
						AssetContainer_Width = PosX
						Refit()
						SendMessage_(Renderer, #WM_SIZE, 0, 0)
					EndIf
				Else
					PosY = General::Min(General::Max(SplitterOrigin - PosY + MouseOrigin, #Size_Timeline_MinimumHeight), Height - 360)
					If Timeline_Height <> PosY
						
						Timeline_Height = PosY
						PosY = Height - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon
						AssetContainer_Width = General::Min(AssetContainer_Width, width - 600)
						RendererWidth = Width - AssetContainer_Width - 30
						RendererHeight = PosY + #Size_Media_Icon
						
						Refit()
						SendMessage_(Renderer, #WM_SIZE, 0, 0)
					EndIf
				EndIf
				;}
			Case #WM_LBUTTONDOWN, #WM_LBUTTONDBLCLK ;{
				GetCursorPos_(cursor.POINT)
				MapWindowPoints_(0, hWnd, cursor, 1)
				If cursor\y <= 28+#Size_Window_Border And CursorSize = 0
					If Msg = #WM_LBUTTONDBLCLK
						If IsZoomed_(hWnd)
							ShowWindow_(hWnd, #SW_RESTORE)
						Else
							ShowWindow_(hWnd, #SW_MAXIMIZE)
						EndIf
					Else
						SendMessage_(hWnd, #WM_NCLBUTTONDOWN, #HTCAPTION, 0)
					EndIf
				EndIf
				Select CursorSize
					Case #HTTOPLEFT, #HTBOTTOMRIGHT
						SetCursor_(LoadCursor_(0, #IDC_SIZENWSE))
					Case #HTTOP, #HTBOTTOM
						SetCursor_(LoadCursor_(0, #IDC_SIZENS))
					Case #HTTOPRIGHT, #HTBOTTOMLEFT
						SetCursor_(LoadCursor_(0, #IDC_SIZENESW))
					Case #HTLEFT, #HTRIGHT
						SetCursor_(LoadCursor_(0, #IDC_SIZEWE))
				EndSelect
				If Msg = #WM_LBUTTONDBLCLK
					If CursorSize = #HTTOP
						SendMessage_(hWnd, #WM_NCLBUTTONDBLCLK, #HTTOP, 0)
					ElseIf CursorSize = #HTBOTTOM
						SendMessage_(hWnd, #WM_NCLBUTTONDBLCLK, #HTBOTTOM, 0)
					EndIf
				EndIf
				
				If SplitterCursor = #HTLEFT
					EditSplitter = 1
					MouseOrigin = lParam & $FFFF
					SplitterOrigin = AssetContainer_Width
					SetCapture_(hWnd)
				ElseIf SplitterCursor = #HTBOTTOM
					EditSplitter = 2
					MouseOrigin = (lParam >> 16) & $FFFF
					SplitterOrigin = Timeline_Height
					SetCapture_(hWnd)
				EndIf
				;}
			Case #WM_LBUTTONUP ;{
				Select CursorSize
					Case #HTTOPLEFT, #HTBOTTOMRIGHT
						SetCursor_(LoadCursor_(0, #IDC_SIZENWSE))
					Case #HTTOP, #HTBOTTOM
						SetCursor_(LoadCursor_(0, #IDC_SIZENS))
					Case #HTTOPRIGHT, #HTBOTTOMLEFT
						SetCursor_(LoadCursor_(0, #IDC_SIZENESW))
					Case #HTLEFT, #HTRIGHT
						SetCursor_(LoadCursor_(0, #IDC_SIZEWE))
				EndSelect
				
				If EditSplitter
					CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
						AddElement(General::EventList())
						General::EventList()\EventType = General::#Event_Resize
					CompilerEndIf
					
					EditSplitter = 0
					ReleaseCapture_()
				EndIf
				;}
			Case #WM_SYSMENU ;{
				SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd, #GWL_STYLE)|#WS_SYSMENU)
				DefWindowProc_(hWnd, Msg, wParam, lParam)
				SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd, #GWL_STYLE)&~#WS_SYSMENU)
				ProcedureReturn 0
				;}
			Case #WM_NCDESTROY ;{
				SetWindowLongPtr_(WindowID(#Window), #GWL_WNDPROC, oldproc)
				ProcedureReturn 0
				;}
			Case #WM_SETCURSOR ;{
				If DragPreviewVisible
					HideWindow(DragPreview, #True)
					DragPreviewVisible = #False
				EndIf
				;}
		EndSelect
		ProcedureReturn CallWindowProc_(oldproc, hWnd, Msg, wParam, lParam)
	EndProcedure
	
	Procedure HandlerCloseButton()
		CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
			AddElement(General::EventList())
			General::EventList()\EventType = General::#Event_End
		CompilerElse
			End
		CompilerEndIf
	EndProcedure
	
	Procedure HandlerMaximizeButton()
		If IsZoomed_(WindowID(#Window))
			ShowWindow_(WindowID(#Window), #SW_RESTORE)
		Else
			ShowWindow_(WindowID(#Window), #SW_MAXIMIZE)
		EndIf
	EndProcedure
	
	Procedure HandlerMinimizeButton()
		ShowWindow_(WindowID(#Window), #SW_MINIMIZE)
	EndProcedure
	
	Procedure HandlerFileButton()
		FlatMenu::Show(FileMenu, GadgetX(#FileButton, #PB_Gadget_ScreenCoordinate), GadgetY(#FileButton, #PB_Gadget_ScreenCoordinate) + #Size_TitleBar_ButtonHeight)
	EndProcedure
	
	Procedure HandlerEditButton()
		FlatMenu::Show(EditMenu, GadgetX(#EditButton, #PB_Gadget_ScreenCoordinate), GadgetY(#EditButton, #PB_Gadget_ScreenCoordinate) + #Size_TitleBar_ButtonHeight)
	EndProcedure
	
	Procedure HandlerProjectButton()
		FlatMenu::Show(ProjectMenu, GadgetX(#ProjectButton, #PB_Gadget_ScreenCoordinate), GadgetY(#ProjectButton, #PB_Gadget_ScreenCoordinate) + #Size_TitleBar_ButtonHeight)
	EndProcedure
	
	Procedure HandlerCloseMenu()
		SetGadgetState(GetProp_(WindowID(EventWindow()), "gadget"), #False)
	EndProcedure
	
	Procedure HandlerAssetBarButton()
		Protected Gadget = EventGadget(), *MediaButton.MediaButton = GetGadgetData(Gadget)
		
		Select EventType()
			Case #PB_EventType_MouseEnter ;{
				If *MediaButton\State = 0
					StartDrawing(CanvasOutput(Gadget))
					Box(0, 0, #Size_Media_Icon, #Size_Media_Icon, General::FixColor(General::#Color_Window_Back_Cold))
					FrontColor($FFFFFF)
					BackColor(General::FixColor(General::#Color_Window_Back_Cold))
					
					DrawingFont(IconLight)
					DrawText(*MediaButton\IconX, 12, *MediaButton\Icon)
					
					DrawingFont(Font)
					DrawText(*MediaButton\Textx, 45, *MediaButton\Text)
					
					StopDrawing()
				EndIf ;}
			Case #PB_EventType_MouseLeave ;{
				If *MediaButton\State = 0
					StartDrawing(CanvasOutput(Gadget))
					Box(0, 0, #Size_Media_Icon, #Size_Media_Icon, General::FixColor(General::#Color_Window_Back_Cold))
					FrontColor($A0A0A0)
					BackColor(General::FixColor(General::#Color_Window_Back_Cold))
					
					DrawingFont(IconLight)
					DrawText(*MediaButton\IconX, 12, *MediaButton\Icon)
					
					DrawingFont(Font)
					DrawText(*MediaButton\Textx, 45, *MediaButton\Text)
					
					StopDrawing()
				EndIf ;}
			Case #PB_EventType_LeftButtonDown ;{
				If *MediaButton\State = 0
					*MediaButton\State = #True
					StartDrawing(CanvasOutput(Gadget))
					Box(0, 0, #Size_Media_Icon, #Size_Media_Icon, General::FixColor(General::#Color_Content_Back_Cold))
					FrontColor($FFFFFF)
					BackColor(General::FixColor(General::#Color_Content_Back_Cold))
					
					DrawingFont(IconLight)
					DrawText(*MediaButton\IconX, 12, *MediaButton\Icon)
					
					DrawingFont(Font)
					DrawText(*MediaButton\Textx, 45, *MediaButton\Text)
					
					Box(0, 0, #Size_Media_Icon, 3, *MediaButton\Color)
					DrawAlphaImage(ImageID(CornerUL),0, 0)
					DrawAlphaImage(ImageID(CornerUR), #Size_Media_Icon - 3, 0)
					
					StopDrawing()
					
					Gadget = #Asset_VideoButton + MediaState
					MediaState = *MediaButton\Pos
					*MediaButton.MediaButton = GetGadgetData(Gadget)
					*MediaButton\State = #False
					
					PostEvent(#PB_Event_Gadget, #Window, Gadget, #PB_EventType_MouseLeave)
					
					ForEach AssetButtonList()
						AssetButton::Delete(AssetButtonList()\Gadget)
					Next
					
					ClearList(AssetButtonList())
					
					Select MediaState
						Case #Asset_Media ;{
							AssetButton::PlusImage = AssetButton::AssetButtonMedia
							AssetButton::Color = General::FixColor(#Color_Asset_Media)
							Project::RePopulateMediaLibrary()
							;}
						Case #Asset_Sound ;{
							
							;}
						Case #Asset_Model ;{
							
							;}
						Case #Asset_Overlay ;{
							AssetButton::PlusImage = AssetButton::AssetButtonOverlay
							AssetButton::Color = General::FixColor(#Color_Asset_Overlay)
							Project::RePopulateOverlayLibrary()
							;}
						Case #Asset_Element ;{
							AssetButton::PlusImage = AssetButton::AssetButtonElement
							AssetButton::Color = General::FixColor(#Color_Asset_Element)
							Project::RePopulateElementLibrary()
							;}
					EndSelect
				EndIf
				 ;}
		EndSelect
		
	EndProcedure
	
	Procedure HandlerAssetDrop()
		Project::AddAsset(EventDropFiles())
	EndProcedure
	
	Procedure HandlerDrag(Action)
		ResizeWindow(DragPreview, DesktopMouseX() + 10, DesktopMouseY() + 10, #PB_Ignore, #PB_Ignore)
		ProcedureReturn #True
	EndProcedure
	
	Procedure HandlerDrop(TargetHandle, State, Format, Action, x, y)
		Protected Result
		
		If TargetHandle <> AssetContainertID
			If Format = #PB_Drop_Private Or State = #PB_Drag_Leave
				Result = PureTL::AssessDrop(#TimeLine, State, AssetButton::DragType, x, y)
			EndIf
		Else
			Result = #True
		EndIf
		
		If State = #PB_Drag_Finish
			HideWindow(DragPreview, #True)
			DragPreviewVisible = #False
		EndIf
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure HandlerAssetScrollBar()
		SetGadgetAttribute(#Asset_ScrollArea, #PB_ScrollArea_Y, GetGadgetState(#Asset_ScrollBar))
	EndProcedure
	
	Procedure HandlerTimeLineDrop()
		Protected Color, Icon.s
		
		Select AssetButton::DragType
			Case Project::#Asset_Type_Image
				Icon = ""
			Case Project::#Asset_Type_Video
			Case Project::#Asset_Type_Sound
			Case Project::#Asset_Type_Music
			Case Project::#Asset_Type_Voice
			Case Project::#Asset_Type_Character
			Case Project::#Asset_Type_Model
			Case Project::#Asset_Type_Text
				Icon = ""
			Case Project::#Asset_Type_Overlay
				Icon = ""
			Case Project::#Asset_Type_2DEffect
				Icon = ""
		EndSelect
		
		Color = AssetButton::Color
  		PureTL::AddMediaBlock(#TimeLine, EventType(), EventData(), 60, AssetButton::DragType, Icon, Project::GetAssetName(AssetButton::DragUUID), Color, AssetButton::DragUUID, Project::GetAssetDefaultState(AssetButton::DragUUID))
  	EndProcedure
  	
  	Procedure HandlerTimeLineChildrenDrop()
		Protected Color, Icon.s
		
		Select AssetButton::DragType
			Case Project::#Asset_Type_Image
				Icon = ""
			Case Project::#Asset_Type_Video
			Case Project::#Asset_Type_Sound
			Case Project::#Asset_Type_Music
			Case Project::#Asset_Type_Voice
			Case Project::#Asset_Type_Character
			Case Project::#Asset_Type_Model
			Case Project::#Asset_Type_2DEffect
				Icon = ""
		EndSelect
		
		Color = AssetButton::Color
  		PureTL::AddMediaBlock(#TimeLine, 0, EventData(), 30, AssetButton::DragType, Icon, Project::GetAssetName(AssetButton::DragUUID), Color, AssetButton::DragUUID, Project::GetAssetDefaultState(AssetButton::DragUUID), EventType())
  	EndProcedure
	
	Procedure HandlerTimeLine()
		Select EventType()
			Case PureTL::#EventType_AssetUnUse
				Project::AssetUnUse(PeekS(EventData()))
			Case PureTL::#EventType_AssetUse
				Project::AssetUse(PeekS(EventData()))
			Case PureTL::#EventType_ForceUpdate
				AddElement(General::EventList())
				General::EventList()\EventType = General::#Event_ReRender
				PureTL::UpdateCurrentAssetList(#TimeLine)
			Case PureTL::#EventType_PlayerMove
				AddElement(General::EventList())
				General::EventList()\EventType = General::#Event_ReRender
				PureTL::UpdateCurrentAssetList(#TimeLine)
				If PropertiesWindow::MediaBlockUUID <> ""
					PropertiesWindow::Update(PureTL::GetMediaBlockState(0, PropertiesWindow::MediaBlockUUID))
				EndIf
			Case PureTL::#EventType_Change
				
			Case PureTL::#EventType_Edit
				AddElement(General::EventList())
				General::EventList()\UUID = PeekS(EventData(), -1)
				General::EventList()\EventType = General::#Event_Edit
				
				PropertiesWindow::SetUp(General::EventList()\UUID)
			Case PureTL::#EventType_AddLayer
				AddElement(General::EventList())
				General::EventList()\EventType = General::#Event_AddLayer
			Case PureTL::#EventType_RemoveLayer
				AddElement(General::EventList())
				General::EventList()\EventType = General::#Event_RemoveLayer
		EndSelect
	EndProcedure
	
	Procedure HandlerPropertieWindowsToggle()
		If EventData()
			Debug "ok"
			HideWindow(PropertiesWindow::#Window, #False)
		Else
			Debug "disparait!"
			HideWindow(PropertiesWindow::#Window, #True)
		EndIf
	EndProcedure
	
	Procedure Hook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		If nCode = #HC_ACTION
			If wParam = #WM_KEYDOWN
				Select *p\vkCode
					Case #VK_LSHIFT, #VK_RSHIFT
						ModifierShift = #True
					Case #VK_LCONTROL, #VK_RCONTROL
						ModifierControl = #True
					Case 'Y'
						If ModifierControl
							Project::Redo()
						EndIf
					Case 'Z'
						If ModifierControl
							Project::Undo()
						EndIf
				EndSelect
			ElseIf wParam = #WM_KEYUP
				Select *p\vkCode
					Case #VK_LSHIFT, #VK_RSHIFT
						ModifierShift = #False
					Case #VK_LCONTROL, #VK_RCONTROL
						ModifierControl = #False
				EndSelect
			EndIf
		EndIf
		ProcedureReturn CallNextHookEx_(#NUL, nCode, wParam, *p)
	EndProcedure
	
	; Misc
	Procedure Refit()
		Protected Height = WindowHeight(#Window), Width = WindowWidth(#Window), AssetContainerHeight
		If Height >= 720 ; DOn't resize when the window is smaller than its bound (ie when it's minimized)
			Timeline_Height = General::Min(Timeline_Height, Height - 360)
			
			If Width > WindowWidth
				SetWindowPos_(GadgetID(#CloseButton), 0, Width - #Size_TitleBar_ButtonWidth, #Size_TitleBar_TopMargin, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER)
				SetWindowPos_(GadgetID(#MaximizeButton), 0, Width - #Size_TitleBar_ButtonWidth * 2, #Size_TitleBar_TopMargin, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER)
				SetWindowPos_(GadgetID(#MinimizeButton), 0, Width - #Size_TitleBar_ButtonWidth * 3, #Size_TitleBar_TopMargin, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER)
			Else
				SetWindowPos_(GadgetID(#MinimizeButton), 0, Width - #Size_TitleBar_ButtonWidth * 3, #Size_TitleBar_TopMargin, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER)
				SetWindowPos_(GadgetID(#MaximizeButton), 0, Width - #Size_TitleBar_ButtonWidth * 2, #Size_TitleBar_TopMargin, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER)
				SetWindowPos_(GadgetID(#CloseButton), 0, Width - #Size_TitleBar_ButtonWidth, #Size_TitleBar_TopMargin, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER)
			EndIf
			
			WindowWidth = Width
			
			PureTL::ResizeEX(#TimeLine, 10, Height - Timeline_Height - 10, WindowWidth - 20, Timeline_Height)
			
			AssetContainerHeight = Height - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon
			AssetContainer_Width = General::Min(AssetContainer_Width, WindowWidth - 600)
			AssetButtonScrollBar = RefitAssets(AssetContainer_Width, AssetContainerHeight)
			RendererWidth = WindowWidth - AssetContainer_Width - 30
			RendererHeight = AssetContainerHeight + #Size_Media_Icon
			
			SetWindowPos_(Renderer, 0, AssetContainer_Width + 20, #Size_TitleBar_ButtonHeight + 2, RendererWidth, AssetContainerHeight + #Size_Media_Icon, #SWP_NOZORDER)
			SetWindowPos_(MediaContainerBorder(1), 0, AssetContainer_Width - #Size_RoundedCorner, 0, 0, 0, #SWP_NOSIZE | #SWP_NOZORDER | #SWP_NOREDRAW)
			SetWindowPos_(MediaContainerBorder(2), 0, AssetContainer_Width - #Size_RoundedCorner, AssetContainerHeight - #Size_RoundedCorner, 0, 0, #SWP_NOSIZE | #SWP_NOZORDER | #SWP_NOREDRAW)
			SetWindowPos_(MediaContainerBorder(3), 0, 0, AssetContainerHeight - #Size_RoundedCorner, 0, 0, #SWP_NOSIZE | #SWP_NOZORDER | #SWP_NOREDRAW)
			
			AssetContainer_Width = AssetContainer_Width - AssetButtonScrollBar * 12
			
			ResizeGadget(#Asset_ScrollArea, #Size_RoundedCorner, 0, AssetContainer_Width + AssetButtonScrollBar * ScrollBarWidth - 7, AssetContainerHeight + ScrollBarWidth)
			SetGadgetAttribute(#Asset_ScrollArea, #PB_ScrollArea3D_InnerWidth, AssetContainer_Width - 6)
			
			CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
				AddElement(General::EventList())
				General::EventList()\EventType = General::#Event_Resize
			CompilerEndIf
			
			If AssetButtonScrollBar
				ResizeGadget(#Asset_ScrollBar, AssetContainer_Width + 10, #Size_Media_Icon + #Size_TitleBar_ButtonHeight + 2, 12, AssetContainerHeight)
			EndIf
			HideGadget(#Asset_ScrollBar, 1 - AssetButtonScrollBar)
			
			SetWindowPos_(AssetContainertID, 0, 0, 0, AssetContainer_Width, AssetContainerHeight, #SWP_NOMOVE | #SWP_NOZORDER)
			
			AssetContainer_Width = AssetContainer_Width + AssetButtonScrollBar * 12
			
			WindowHeight = Height
		EndIf
	EndProcedure
	
	Procedure RefitAssets(ContainerWidth, ContainerHeight)
		Protected Y = 20, ItemPerLine = (ContainerWidth - 30) / 170, Margin = ((ContainerWidth - 30) % 170) / (ItemPerLine - 1) + 170, Count
		
		ForEach AssetButtonList()
			SetWindowPos_(GadgetID(AssetButtonList()\Gadget), 0, 17 + Count * Margin, Y, 0, 0, #SWP_NOREDRAW | #SWP_NOSIZE | #SWP_NOZORDER)
			Count + 1
			If Count = ItemPerLine
				Count = 0
				Y + 132
			EndIf
		Next
		
		If Count
			Y + 132
		EndIf
		
		Y + ScrollBarWidth
		
		SetGadgetAttribute(#Asset_ScrollArea, #PB_ScrollArea3D_InnerHeight, Y)
		SetGadgetAttribute(#Asset_ScrollBar, #PB_ScrollBar_Maximum, Y)
		SetGadgetAttribute(#Asset_ScrollBar, #PB_ScrollBar_PageLength, ContainerHeight + ScrollBarWidth)
		
		If Y > ContainerHeight
			ProcedureReturn #True
		Else
			ProcedureReturn #False
		EndIf
	EndProcedure
	;}
	
	DataSection
		Logo:
		Data.q $0A1A0A0D474E5089,$524448490D000000,$1A0000001A000000,$DB28260000000208,$414449CA00000099
		Data.q $40554AF863017854,$C7F77A3B8D46E355,$6FBBD9E8213FEBCE,$F33C2DBE6F479140,$37BFC3EEEFFF69AB
		Data.q $05C62923F6F9FD5F,$1D043FF330CBF9AE,$B3029FC5D563F3BE,$DEF7F55EF2046C81,$0FFDB79718E46FCB
		Data.q $6690FF9B6944C490,$8D3277E9ED74411C,$0F1FEDE0F7F0DE8B,$AAEC7082D8CB7F5E,$DFE57DCE31C93F0B
		Data.q $77C9F97521A01F37,$271B24DFE1EF78B8,$BD4F08E7CDFFF73B,$0FEDB3952E0DF0FE,$E5F3D142ED95C6C9
		Data.q $979DD041906057CB,$60DC38D0395D87A4,$BFA3C4DC6A371B44,$7EE7A5A081FD774B,$570038D478D2CD0D
		Data.q $004A1B11DA4F12EF,$AE444E4549000000
		Data.b $42,$60,$82
		
		Corner:
		Data.q $0A1A0A0D474E5089,$524448490D000000,$0400000004000000,$9EF1A90000000608,$4144491F0000007E
		Data.q $FAB6529063017854,$D02612D88047C50F,$00640619200300C2,$340940C100048656,$00000000FE90996A
		Data.q $826042AE444E4549
		
	EndDataSection
EndModule











; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 932
; FirstLine = 417
; Folding = -4nAAQA-DF0
; EnableXP