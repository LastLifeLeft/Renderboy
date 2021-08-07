Module MainWindow
	EnableExplicit
	; Macro
	Macro SetMenuButtonAppearence(menu)
		SetGadgetColor(#menu, CanvasButton::#BackColor_Cold, General::FixColor(#Color_Window_Back_Cold))
		SetGadgetColor(#menu, CanvasButton::#BackColor_Warm, General::FixColor(#Color_Window_Back_Warm))
		SetGadgetColor(#menu, CanvasButton::#BackColor_Hot, General::FixColor(#Color_Window_Back_Warm))
		SetGadgetColor(#menu, CanvasButton::#FrontColor_Cold, General::FixColor(#Color_Window_Front_Cold))
		SetGadgetColor(#menu, CanvasButton::#FrontColor_Warm, General::FixColor(#Color_Window_Front_Warm))
		SetGadgetColor(#menu, CanvasButton::#FrontColor_Hot, General::FixColor(#Color_Window_Front_Warm))
		SetGadgetFont(#menu, Font)
		BindGadgetEvent(#menu, @Handler#menu#(), #PB_EventType_Change)
	EndMacro
	
	Macro SetWindowButtonApparence(Button)
		SetGadgetColor(#Button, CanvasButton::#BackColor_Cold, General::FixColor(#Color_Window_Back_Cold))
		SetGadgetColor(#Button, CanvasButton::#BackColor_Warm, General::FixColor(#Color_Window_Back_Warm))
		SetGadgetColor(#Button, CanvasButton::#BackColor_Hot, General::FixColor(#Color_Window_Back_Warm))
		SetGadgetColor(#Button, CanvasButton::#FrontColor_Cold, General::FixColor(#Color_Window_Front_Cold))
		SetGadgetColor(#Button, CanvasButton::#FrontColor_Warm, General::FixColor(#Color_Window_Front_Warm))
		SetGadgetColor(#Button, CanvasButton::#FrontColor_Hot, General::FixColor(#Color_Window_Front_Warm))
		SetGadgetFont(#Button, MaterialIcon)
		BindGadgetEvent(#Button, @Handler#Button#(), #PB_EventType_Change)
	EndMacro
	
	Macro SetMenuAppearance(MenuName)
		FlatMenu::SetFont(MenuName#Menu, Font)
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#ColorType_LineColor, General::FixColor(#Color_Window_Back_Cold))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_BackCold, General::FixColor(#Color_Window_Back_Warm))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_BackHot, General::FixColor(#Color_Window_Back_Hot))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_FrontCold, General::FixColor(#Color_Window_Front_Cold))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_FrontHot, General::FixColor(#Color_Window_Front_Warm))
		FlatMenu::SetColor(MenuName#Menu, FlatMenu::#colorType_FrontDisabled, General::FixColor($909090))
		BindEvent(#PB_Event_DeactivateWindow, @HandlerCloseMenu(), MenuName#Menu)
		SetProp_(WindowID(MenuName#Menu), "gadget", #MenuName#Button)
	EndMacro
	
	Macro SetAssetBarButtonAppearance(ButtonName)
		*MediaButton\State = #False
		StartDrawing(CanvasOutput(ButtonName))
		Box(0, 0, #Size_Media_Icon, #Size_Media_Icon, General::FixColor(#Color_Window_Back_Cold))
		FrontColor($A0A0A0)
		BackColor(General::FixColor(#Color_Window_Back_Cold))
		
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
	; Colors
	#Color_Window_Back_Cold = $1A233A
	#Color_Window_Back_Warm = $293658
	#Color_Window_Back_Hot = $5A8DEE
	
	#Color_Window_Front_Cold = $D0D0D0
	#Color_Window_Front_Warm = $FFFFFF
	
	#Color_Content_Back_Cold = $272E48
	
	#Color_Scrollbar_FrontCold = $787B86
	#Color_Scrollbar_FrontWarm = $656873
	#Color_Scrollbar_FrontHot = $434651
	
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
	
	CreateImage(0, 8, 8, 32, General::FixColor($1A233A))
	Global Margin.RECT, Brush = CreatePatternBrush_(ImageID(0)), CursorSize, DWMEnabled, SplitterCursor, WindowWidth = 1920, WindowHeight = 1080, EditSplitter = 0, SplitterOrigin, MouseOrigin
	FreeImage(0)
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
	Declare HandlerGMS2Window(hWnd, Msg, wParam, lParam)
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
	Declare HandlerTimeLine()
	
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
		SetRect_(@Margin, 0, 0, 1, 0)
		
		CallFunction(0, "DwmExtendFrameIntoClientArea", WindowID, @Margin)
		CallFunction(0, "DwmIsCompositionEnabled", @DWMEnabled)
		
		If DWMEnabled = 0
			SetWindowTheme_(WindowID, "", "")
		EndIf
		
		CloseLibrary(0)
		
		SetClassLongPtr_(WindowID, #GCL_HBRBACKGROUND, Brush)
		SetProp_(WindowID, "oldproc", SetWindowLongPtr_(WindowID, #GWL_WNDPROC, @HandlerWindow()))
		
		; Title bar
		CanvasButton::Gadget(#FileButton, 46, #Size_TitleBar_TopMargin, 40, #Size_TitleBar_ButtonHeight, "File", -1, CanvasButton::#DarkTheme | CanvasButton::#Toggle)
		SetMenuButtonAppearence(FileButton)
		
		CanvasButton::Gadget(#EditButton, 86, #Size_TitleBar_TopMargin, 40, #Size_TitleBar_ButtonHeight, "Edit", -1, CanvasButton::#DarkTheme | CanvasButton::#Toggle)
		SetMenuButtonAppearence(EditButton)
		
		CanvasButton::Gadget(#ProjectButton, 126, #Size_TitleBar_TopMargin, 56, #Size_TitleBar_ButtonHeight, "Project", -1, CanvasButton::#DarkTheme | CanvasButton::#Toggle)
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
		
		ImageGadget(#PB_Any, #Size_Window_Border, 3, 0 ,0 , ImageID(CatchImage(#PB_Any, ?Logo)))
		
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
		SetGadgetColor(#Asset_Container, #PB_Gadget_BackColor, General::FixColor(#Color_Content_Back_Cold))
		
		Protected CornerDR = ROTATE_90(CornerUR)
		Protected CornerDL = ROTATE_90(CornerDR)
		
		Image = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner, 24, General::FixColor( #Color_Content_Back_Cold))
		StartDrawing(ImageOutput(Image))
		DrawAlphaImage(ImageID(CornerUL), 0, 0)
		StopDrawing()
		MediaContainerBorder(0) = GadgetID(ImageGadget(#PB_Any, 0, 0, 0, 0 , ImageID(Image)))
		
		Image = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner, 24, General::FixColor( #Color_Content_Back_Cold))
		StartDrawing(ImageOutput(Image))
		DrawAlphaImage(ImageID(CornerUR), 0, 0)
		StopDrawing()
		MediaContainerBorder(1) = GadgetID(ImageGadget(#PB_Any, AssetContainer_Width - #Size_RoundedCorner, 0, 0, 0 , ImageID(Image)))
		
		Image = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner, 24, General::FixColor( #Color_Content_Back_Cold))
		StartDrawing(ImageOutput(Image))
		DrawAlphaImage(ImageID(CornerDR), 0, 0)
		StopDrawing()
		MediaContainerBorder(2) = GadgetID(ImageGadget(#PB_Any, AssetContainer_Width - #Size_RoundedCorner, 1080 - #Size_TitleBar_ButtonHeight - 25 - Timeline_Height - #Size_Media_Icon, 0, 0 , ImageID(Image)))
		
		Image = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner, 24, General::FixColor( #Color_Content_Back_Cold))
		StartDrawing(ImageOutput(Image))
		DrawAlphaImage(ImageID(CornerDL), 0, 0)
		StopDrawing()
		MediaContainerBorder(3) = GadgetID(ImageGadget(#PB_Any, 0, 1080 - #Size_TitleBar_ButtonHeight - 25 - Timeline_Height - #Size_Media_Icon, 0, 0 , ImageID(Image)))
		
		ScrollAreaGadget(#Asset_ScrollArea, 0, 0, AssetContainer_Width - 46, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon, AssetContainer_Width - 6, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon, 45, #PB_ScrollArea_BorderLess)
		SetProp_(GadgetID(#Asset_ScrollArea), "oldproc", SetWindowLongPtr_(GadgetID(#Asset_ScrollArea), #GWL_WNDPROC, @HandlerScrollArea()))
		
 		SetGadgetColor(#Asset_ScrollArea, #PB_Gadget_BackColor, General::FixColor(#Color_Content_Back_Cold))
		CloseGadgetList()
		CloseGadgetList()
		ScrollBar::Gadget(#Asset_ScrollBar, 0, #Size_Media_Icon + #Size_TitleBar_ButtonHeight + 2, 12, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height - #Size_Media_Icon, 0, 100, 10, ScrollBar::#Vertical)
		BindGadgetEvent(#Asset_ScrollBar, @HandlerAssetScrollBar(), #PB_EventType_Change)
		SetGadgetColor(#Asset_ScrollBar, #PB_Gadget_BackColor, General::SetAlpha($FF, General::FixColor(#Color_Content_Back_Cold)))
		SetGadgetColor(#Asset_ScrollBar, #PB_Gadget_LineColor, General::SetAlpha($FF, General::FixColor(#Color_Window_Back_Cold)))
		
		SetGadgetColor(#Asset_ScrollBar, #PB_Gadget_FrontColor, 		General::SetAlpha($FF, General::FixColor(#Color_Scrollbar_FrontCold)))
		SetGadgetColor(#Asset_ScrollBar, ScrollBar::#Color_FrontWarm,	General::SetAlpha($FF, General::FixColor(#Color_Scrollbar_FrontWarm)))
		SetGadgetColor(#Asset_ScrollBar, ScrollBar::#Color_FrontHot,	General::SetAlpha($FF, General::FixColor(#Color_Scrollbar_FrontHot)))
		
		; Timeline
		PureTL::Gadget(#TimeLine, 10, 1080 - Timeline_Height - 10, 1900, Timeline_Height)
		SetProp_(GadgetID(#TimeLine), "oldproc", SetWindowLongPtr_(GadgetID(#TimeLine), #GWL_WNDPROC, @HandlerShortcutWorkAround()))
		
		BindEvent(#PB_Event_GadgetDrop, @HandlerTimeLineDrop(), #Window, #TimeLine)
		BindGadgetEvent(#TimeLine,@HandlerTimeLine())
		
		; Misc
		BindEvent(#PB_Event_Menu, Project::@Undo(), #Window, 17)
		BindEvent(#PB_Event_Menu, Project::@Redo(), #Window, 18)
		
		SetGadgetFont(#PB_Default, Font)
		
		SetWindowPos_(WindowID, 0, 0, 0, 0, 0, #SWP_NOSIZE|#SWP_NOMOVE|#SWP_FRAMECHANGED|#SWP_SHOWWINDOW)
		
		SetDropCallback(@HandlerDrop())
		SetDragCallback(@HandlerDrag())
		
		DragPreview = OpenWindow(#PB_Any, 0, 0, 160, 90, "", #PB_Window_BorderLess | #PB_Window_Invisible, WindowID)
		SetWindowLongPtr_(WindowID(DragPreview),#GWL_EXSTYLE,#WS_EX_LAYERED)
		SetLayeredWindowAttributes_(WindowID(DragPreview),0,140,#LWA_ALPHA)
		ImagePreview = ImageGadget(#PB_Any, 0, 0, 0, 0, 0)
		
		; Renderer
		CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
			Renderer=FindWindow_(#Null, General::WindowName)
			While Renderer = 0
				Delay(10)
				Renderer=FindWindow_(#Null, General::WindowName)
			Wend
			
			SetWindowLong_(Renderer, #GWL_STYLE, GetWindowLong_(Renderer, #GWL_STYLE)| #WS_CHILD  !#WS_POPUP)
			SetWindowLong_(Renderer, #GWL_EXSTYLE, GetWindowLong_(Renderer, #GWL_EXSTYLE) ! #WS_EX_APPWINDOW)
			
			SetParent_(Renderer, WindowID)
 			SetProp_(Renderer, "oldproc", SetWindowLongPtr_(Renderer, #GWL_WNDPROC, @HandlerGMS2Window()))
			; 			SendMessage_(Renderer, #HKM_SETHOTKEY, #VK_DELETE, 0)
			
		CompilerElse
			UseGadgetList(WindowID)
			Renderer = ContainerGadget(#PB_Any, AssetContainer_Width + 20, #Size_TitleBar_ButtonHeight + 2, 1920 - AssetContainer_Width - 30, 1080 - #Size_TitleBar_ButtonHeight - 22 - Timeline_Height, #PB_Container_BorderLess)
			
			SetGadgetColor(Renderer, #PB_Gadget_BackColor, 0)
			Renderer = GadgetID(Renderer)
			CloseGadgetList()

		CompilerEndIf
		Refit()
		HideWindow(#Window, #False)
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
	Procedure HandlerGMS2Window(hWnd, Msg, wParam, lParam)
		
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
		
		ProcedureReturn CallWindowProc_(GetProp_(hWnd, "oldproc"), hWnd, Msg, wParam, lParam)
	EndProcedure
	
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
				ProcedureReturn brush
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
						General::EventList() = General::#Event_Resize
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
			Case #WM_KEYDOWN ;{
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
				;}
		EndSelect
		ProcedureReturn CallWindowProc_(oldproc, hWnd, Msg, wParam, lParam)
	EndProcedure
	
	Procedure HandlerCloseButton()
		CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
			AddElement(General::EventList())
			General::EventList() = General::#Event_End
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
			Case #PB_EventType_MouseEnter
				If *MediaButton\State = 0
					StartDrawing(CanvasOutput(Gadget))
					Box(0, 0, #Size_Media_Icon, #Size_Media_Icon, General::FixColor(#Color_Window_Back_Cold))
					FrontColor($FFFFFF)
					BackColor(General::FixColor(#Color_Window_Back_Cold))
					
					DrawingFont(IconLight)
					DrawText(*MediaButton\IconX, 12, *MediaButton\Icon)
					
					DrawingFont(Font)
					DrawText(*MediaButton\Textx, 45, *MediaButton\Text)
					
					StopDrawing()
				EndIf
			Case #PB_EventType_MouseLeave
				If *MediaButton\State = 0
					StartDrawing(CanvasOutput(Gadget))
					Box(0, 0, #Size_Media_Icon, #Size_Media_Icon, General::FixColor(#Color_Window_Back_Cold))
					FrontColor($A0A0A0)
					BackColor(General::FixColor(#Color_Window_Back_Cold))
					
					DrawingFont(IconLight)
					DrawText(*MediaButton\IconX, 12, *MediaButton\Icon)
					
					DrawingFont(Font)
					DrawText(*MediaButton\Textx, 45, *MediaButton\Text)
					
					StopDrawing()
				EndIf
			Case #PB_EventType_LeftButtonDown
				If *MediaButton\State = 0
					*MediaButton\State = #True
					StartDrawing(CanvasOutput(Gadget))
					Box(0, 0, #Size_Media_Icon, #Size_Media_Icon, General::FixColor(#Color_Content_Back_Cold))
					FrontColor($FFFFFF)
					BackColor(General::FixColor(#Color_Content_Back_Cold))
					
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
					
				EndIf
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
				Color = General::SetAlpha($FF, General::FixColor(#Color_Asset_Media))
				Icon = ""
			Case Project::#Asset_Type_Video
				Color = General::SetAlpha($FF, General::FixColor(#Color_Asset_Media))
			Case Project::#Asset_Type_Sound
				Color = General::SetAlpha($FF, General::FixColor(#Color_Asset_Audio))
			Case Project::#Asset_Type_Music
				Color = General::SetAlpha($FF, General::FixColor(#Color_Asset_Audio))
			Case Project::#Asset_Type_Voice
				Color = General::SetAlpha($FF, General::FixColor(#Color_Asset_Audio))
			Case Project::#Asset_Type_Character
				Color = General::SetAlpha($FF, General::FixColor(#Color_Asset_Model))
			Case Project::#Asset_Type_Model
				Color = General::SetAlpha($FF, General::FixColor(#Color_Asset_Model))
		EndSelect
		
  		PureTL::AddMediaBlock(#TimeLine, EventType(), EventData(), 30, Icon, Project::GetAssetName(AssetButton::DragUUID), Color, AssetButton::DragUUID, Project::GetAssetDefaultState(AssetButton::DragUUID))
	EndProcedure
	
	Procedure HandlerTimeLine()
		
		Select EventType()
			Case PureTL::#EventType_AssetUnUse
				Project::AssetUnUse(PeekS(EventData()))
			Case PureTL::#EventType_AssetUse
				Project::AssetUse(PeekS(EventData()))
			Case PureTL::#EventType_PlayerMove, PureTL::#EventType_Change
				CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
					AddElement(General::EventList())
					General::EventList() = General::#Event_ReRender
				CompilerEndIf
				PureTL::UpdateCurrentAssetList(#TimeLine)
			Case PureTL::#EventType_Edit
				CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
					AddElement(General::EventList())
					General::EventList() = General::#Event_Edit
				CompilerEndIf
				
		EndSelect
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
			
			ResizeGadget(#Asset_ScrollArea, #Size_RoundedCorner, 0, AssetContainer_Width + AssetButtonScrollBar * ScrollBarWidth - 8, AssetContainerHeight + ScrollBarWidth)
			SetGadgetAttribute(#Asset_ScrollArea, #PB_ScrollArea3D_InnerWidth, AssetContainer_Width - 6)
			
			CompilerIf #PB_Compiler_ExecutableFormat = #PB_Compiler_DLL
				AddElement(General::EventList())
				General::EventList() = General::#Event_Resize
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
		Data.q $0A1A0A0D474E5089,$524448490D000000,$1E0000001E000000,$AE303B0000000608,$41444959030000A2
		Data.q $00A3051862017854,$5144B6C8C03D5A40,$DB6DB6DB6DB5CE18,$6DB6DB6DB6DB6DB6,$9953A56FFCF8E6DB
		Data.q $A837C9DBCDCF65D4,$202A7FDD4A57B273,$FFA25D523E96B4BA,$57959C846531669F,$749DEB1A4BFA4DB2
		Data.q $5DD2CFAEC4FC47B2,$5E061351686BFF82,$9A6DFAEF7F3C7EDE,$38E35E4A929A977E,$F70B063EAC01F170
		Data.q $97799BE9F073F6C3,$F1F1BC529A12FFD9,$8606B61869D363F5,$37FA3E08765916AC,$9A8F2B1F9F9F84FD
		Data.q $4C2BC1E0EB9196E7,$B027D92068480E35,$782B7932CCD580F8,$FE330DE8EA82F978,$2E956BA78337E31B
		Data.q $BF278DC0A1382404,$C16E270BDBCDB236,$454C7D4F7F7F7588,$BB05D760445C1775,$C62C7A12B81BBFC1
		Data.q $3705DDF9531A78D9,$DEC7C9BFD270D814,$8341EFE2B81EF00B,$341E61D065DF4157,$86BE1C8927F50298
		Data.q $BF1C087382EE18A9,$EC3CC9FB7EF4DFE9,$5A08BEEAB3F7F538,$75EC0732BF41374C,$F8FAE878B838F640
		Data.q $868DD396356F5C07,$730E91F4197FD5E2,$4F9A2FFCD364E1A1,$653F7D8075F6F1C7,$0FD8064AB27E95C4
		Data.q $9C15E1A83D2C0A56,$BD707AA5EB9BD4AF,$F1C675DE61B76748,$DBC7ED969E30EAA1,$58DDEADAD5307BA5
		Data.q $C4C921E672AEC53C,$6676CCD3F06FC787,$A3923843CADBCBAC,$D7BE02B8C6B51E29,$BA5879834A9BC31C
		Data.q $569E54E2748AD737,$709BD94388DAC81C,$E38A1ED6EE1B5F2E,$7C15A8243700EDE5,$82B1EB3DBAAB5F89
		Data.q $779F5CCAEC1BF1CF,$C8575F6CA4F28795,$1731AD9838838AAB,$28BCEE894EE7B60B,$775BE047D5CF803F
		Data.q $CA0BAE9D769B3402,$FB291C01AC2EBB3A,$0ACB7205901732D3,$CF0B564410BF62CE,$DEA0CD155DE11CB6
		Data.q $2B2F4668CFACD744,$38744DEBA975FC0C,$3E498649B03A3D72,$FAB584BB25812409,$41DDFF07B2CC129F
		Data.q $260D0F3EEC7826DB,$340568F63F5CB4F3,$140AFA4C1B835FBB,$FCD9B2F091F45311,$E6763377D49AC7BF
		Data.q $27D7141C943CA74F,$B5F4CB8F2672D395,$8DD7A3C1F7F32D02,$8A6207EA59826381,$DFE66C6B1A67A6B9
		Data.q $C20BE82FD93858AE,$C0A68D81DB567D71,$4BCBAE69BA988BEE,$5AEAFD33048A6BB1,$5AD2C0EFDDDD4DE3
		Data.q $43676D0DBA9C08BE,$4BCEA631F57059AB,$890BF3F7D3F6E902,$21A8CB3D671AF560,$E1E2F812EF1A65F7
		Data.q $684A5600993FAF38,$22D8A628FD356219,$BEC3CC66038F4D81,$CC1F246CEAFD016A,$E608ECF320497ACC
		Data.q $3217856C9F2598D0,$F61B749FFF307CEF,$A91C58D3FF8FBD97,$5C9164C1FFCCA126,$D6FFFFDAD8121894
		Data.q $701D3435A186EF49,$7018000A30188C30,$000009353FFF36E9,$42AE444E45490000
		Data.b $60,$82
		
		Corner:
		Data.q $0A1A0A0D474E5089,$524448490D000000,$0400000004000000,$9EF1A90000000608,$4144491F0000007E
		Data.q $FAB6529063017854,$D02612D88047C50F,$00640619200300C2,$340940C100048656,$00000000FE90996A
		Data.q $826042AE444E4549
		
	EndDataSection
EndModule











; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 983
; FirstLine = 274
; Folding = hXHioGEAw-
; EnableXP