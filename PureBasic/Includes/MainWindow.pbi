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
	
	
	;}
	
	;{ Private variables, constants and structures
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
	
	
	Global Window, Window_Width, Window_Height
	Global Render, TimeLine
	
	; Appearance
	#Appearance_Window_Width = 1200
	#Appearance_Window_Height = 700
	#Appearance_Window_Margin = 10
	#Appearance_TimeLine_MinHeight = 300
	#Appearance_Render_MinWidth = 600
	#Appearance_Render_MinHeight = 400
	#Appearance_LibraryButton_Height = 70
	;}
	
	; Private procedure declarations
	Declare Handler_Tab()
	Declare Library_RedrawItem(*Item.UITK::Library_Item, X, Y, Width, Height, State, *Theme.UITK::Theme)
	
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
		
		UITK::SetWindowIcon(Window, ImageID(CatchImage(#PB_Any, ?Icon)))
		Window_Width = WindowWidth(Window)
		Window_Height = WindowHeight(Window) - 30
		;}
		
		;{ Gadgets
		Tab = UITK::Tab(#PB_Any, #Appearance_Window_Margin * 2, 0, Window_Width - 3 * #Appearance_Window_Margin - #Appearance_Render_MinWidth - #Appearance_Window_Margin * 2, #Appearance_LibraryButton_Height)
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
		
		Library = UITK::Library(#PB_Any, #Appearance_Window_Margin, #Appearance_LibraryButton_Height, Window_Width - 3 * #Appearance_Window_Margin - #Appearance_Render_MinWidth, Window_Height - 2 * #Appearance_Window_Margin - #Appearance_TimeLine_MinHeight - #Appearance_LibraryButton_Height, UITK::#Drag, @Library_RedrawItem())
		SetGadgetAttribute(Library, UITK::#Attribute_CornerRadius, 5)
		EnableGadgetDrop(Library, #PB_Drop_Files, #PB_Drag_Copy | #PB_Drag_Move)
		
		Render = ContainerGadget(#PB_Any, GadgetX(Library) + GadgetWidth(Library) + #Appearance_Window_Margin, 0, Window_Width - 3 * #Appearance_Window_Margin - GadgetWidth(Library), Window_Height - 2 * #Appearance_Window_Margin - #Appearance_TimeLine_MinHeight, #PB_Container_BorderLess)
		SetGadgetColor(Render, #PB_Gadget_BackColor, $000000)
		CloseGadgetList()
		
		TimeLine = TimeLine::Gadget(#Appearance_Window_Margin, GadgetY(Library) + GadgetHeight(Library) + #Appearance_Window_Margin, Window_Width - 2 * #Appearance_Window_Margin, #Appearance_TimeLine_MinHeight) 
		
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
			Case 0 ; Media
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Media), 255))
				AddGadgetColumn(Library, 0, "Video", 0)
				AddGadgetColumn(Library, 1, "Images", 0)
				
				ForEach Project::Project\Assets[Project::#Media]\List()
					SetGadgetItemData(Library, AddGadgetItem(Library, -1, Project::Project\Assets[Project::#Media]\List()\Name, ImageID(Project::Project\Assets[Project::#Media]\List()\PreviewImage), Project::Project\Assets[Project::#Media]\List()\Type), Project::@Project\Assets[Project::#Media]\list())
				Next
				
			Case 1 ; Audio
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Audio), 255))
				AddGadgetColumn(Library, 0, "Music", 0)
				AddGadgetColumn(Library, 1, "Sound", 0)
				AddGadgetColumn(Library, 2, "Voice clip", 0)
			Case 2 ; 3D
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_3D), 255))
				AddGadgetColumn(Library, 0, "Models", 0)
				AddGadgetColumn(Library, 1, "Particles", 0)
			Case 3 ; Overlay
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Overlay), 255))
				AddGadgetColumn(Library, 0, "Text", 0)
				AddGadgetColumn(Library, 1, "Shape", 0)
				AddGadgetColumn(Library, 2, "???", 0)
			Case 4 ; Modifiers
				SetGadgetColor(Library, UITK::#Color_Special3_Cold, SetAlpha(FixColor(#Color_Ressources_Modifiers), 255))
				AddGadgetColumn(Library, 0, "Transitions", 0)
				AddGadgetColumn(Library, 1, "Post processing", 0)
				AddGadgetColumn(Library, 1, "Colors", 0)
				AddGadgetColumn(Library, 2, "Effects", 0)
		EndSelect
				
		UITK::Freeze(Library, #False)
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
			
		EndWith
	EndProcedure
	
	
	DataSection
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
	EndDataSection
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 136
; FirstLine = 25
; Folding = 0H7
; EnableXP
; DPIAware