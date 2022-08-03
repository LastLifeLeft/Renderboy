Module TimeLine
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
	
	;{ Variables, constants and structures
	#Appearance_ListWidth = 222
	#Appearance_HeaderHeight = 60
	
	Structure Line
		Name.s
		UUID.s
	EndStructure
	
	Structure TLData
		; Gadget parts
		Container.i
		Container_ID.i
		Container_Height.l
		Container_Width.l
		List.i
		List_ID.i
		List_Height.l
		List_Width.l
		Header.i
		Header_ID.i
		Header_Height.l
		Header_Width.l
		TimeLine.i
		TimeLine_ID.i
		TimeLine_Height.l
		TimeLine_Width.l
		
		;Timelines
		List LineList.Line()
	EndStructure
	
	Global CornerTL = CreateImage(#PB_Any, MainWindow::#Appearance_CornerSize, MainWindow::#Appearance_CornerSize, 24)
	StartVectorDrawing(ImageVectorOutput(CornerTL))
	AddPathBox(0, 0, MainWindow::#Appearance_CornerSize, MainWindow::#Appearance_CornerSize)
	VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Window_Border), 255))
	FillPath()
	UITK::AddPathRoundedBox(0, 0, 20, 20, MainWindow::#Appearance_CornerSize)
	VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Gadget_BackCold), 255))
	FillPath()
	StopVectorDrawing()
	CornerTL = ImageID(CornerTL)
	
	Global CornerDL = CreateImage(#PB_Any, MainWindow::#Appearance_CornerSize, MainWindow::#Appearance_CornerSize, 32, #PB_Image_Transparent)
	StartVectorDrawing(ImageVectorOutput(CornerDL))
	UITK::AddPathRoundedBox(0, -20 + MainWindow::#Appearance_CornerSize, 20, 20, MainWindow::#Appearance_CornerSize)
	AddPathBox(0, 0, VectorOutputWidth(), VectorOutputHeight())
	VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Window_Border), 255))
	FillPath()
	StopVectorDrawing()
	CornerDL = ImageID(CornerDL)
	;}
	
	;{ Private procedure declaration
	Declare Header_Event()
	Declare Header_Redraw(Gadget)
	Declare List_Event()
	Declare List_Redraw(Gadget)
	Declare Timeline_Event()
	Declare Timeline_Redraw(Gadget)
	;}
	
	; Public procedures
	Procedure Gadget(x, y, Width, Height)
		Protected *GadgetData.TLData = AllocateStructure(TLData)
		
		*GadgetData\Container_Height = Height
		*GadgetData\Container_Width = Width
		*GadgetData\Container = ContainerGadget(#PB_Any, x, y, *GadgetData\Container_Width, *GadgetData\Container_Height, #PB_Container_BorderLess)
		*GadgetData\Container_ID = GadgetID(*GadgetData\Container)
		ImageGadget(#PB_Any, 0, 0, MainWindow::#Appearance_CornerSize, MainWindow::#Appearance_CornerSize, CornerTL)
		SetGadgetColor(*GadgetData\Container, #PB_Gadget_BackColor, FixColor(MainWindow::#Color_Gadget_BackCold))
		SetGadgetData(*GadgetData\Container, *GadgetData)
		
		*GadgetData\List_Width = #Appearance_ListWidth
		*GadgetData\List_Height = *GadgetData\Container_Height - #Appearance_HeaderHeight
		*GadgetData\List = CanvasGadget(#PB_Any, 0, #Appearance_HeaderHeight, *GadgetData\List_Width, *GadgetData\List_Height)
		*GadgetData\List_ID = GadgetID(*GadgetData\List)
		SetGadgetData(*GadgetData\List, *GadgetData)
		List_Redraw(*GadgetData\List)
		
		*GadgetData\Header_Width = *GadgetData\Container_Width - #Appearance_ListWidth
		*GadgetData\Header_Height = #Appearance_HeaderHeight
		*GadgetData\Header = CanvasGadget(#PB_Any, #Appearance_ListWidth, 0, *GadgetData\Header_Width, *GadgetData\Header_Height)
		*GadgetData\Header_ID = GadgetID(*GadgetData\Header)
		SetGadgetData(*GadgetData\Header, *GadgetData)
		Header_Redraw(*GadgetData\Header)
		
		*GadgetData\TimeLine_Width = *GadgetData\Container_Width - #Appearance_ListWidth
		*GadgetData\TimeLine_Height = *GadgetData\Container_Height - #Appearance_HeaderHeight
		*GadgetData\TimeLine = CanvasGadget(#PB_Any, #Appearance_ListWidth, #Appearance_HeaderHeight, *GadgetData\TimeLine_Width, *GadgetData\TimeLine_Height)
		*GadgetData\TimeLine_ID = GadgetID(*GadgetData\TimeLine)
		SetGadgetData(*GadgetData\TimeLine, *GadgetData)
		Timeline_Redraw(*GadgetData\TimeLine)
		
		ProcedureReturn *GadgetData\Container
	EndProcedure
	
	Procedure Resize(Gadget, x, y, Width, Height)
		Protected *GadgetData.TLData = GetGadgetData(Gadget)
		
		*GadgetData\Container_Width = Width
		*GadgetData\Container_Height = Height
		
		*GadgetData\List_Height = *GadgetData\Container_Height - #Appearance_HeaderHeight
		*GadgetData\Header_Width = *GadgetData\Container_Width - #Appearance_ListWidth
		*GadgetData\TimeLine_Width = *GadgetData\Container_Width - #Appearance_ListWidth
		*GadgetData\TimeLine_Height = *GadgetData\Container_Height - #Appearance_HeaderHeight
		
		SendMessage_(*GadgetData\Container_ID, #WM_SETREDRAW, #False, 0)
		
		SetWindowPos_(*GadgetData\Header_ID, 0, 0, 0, *GadgetData\Header_Width, *GadgetData\Header_Height, #SWP_NOZORDER | #SWP_NOMOVE | #SWP_NOREDRAW)
		SetWindowPos_(*GadgetData\List_ID, 0, 0, 0, *GadgetData\List_Width, *GadgetData\List_Height, #SWP_NOZORDER | #SWP_NOMOVE | #SWP_NOREDRAW)
		SetWindowPos_(*GadgetData\TimeLine_ID, 0, 0, 0, *GadgetData\TimeLine_Width, *GadgetData\TimeLine_Height, #SWP_NOZORDER | #SWP_NOMOVE | #SWP_NOREDRAW)
		
		List_Redraw(*GadgetData\List)
		Header_Redraw(*GadgetData\Header)
		Timeline_Redraw(*GadgetData\TimeLine)
		
		SendMessage_(*GadgetData\Container_ID, #WM_SETREDRAW, #True, 0)
		
		ResizeGadget(*GadgetData\Container, x, y, *GadgetData\Container_Width, *GadgetData\Container_Height)
; 		SetWindowPos_(*GadgetData\Container_ID, 0, x, y, *GadgetData\Container_Width, *GadgetData\Container_Height, #SWP_NOZORDER | #SWP_NOREDRAW)
	EndProcedure
	
	Procedure AddLine(Gadget, Position, Name.s, UUID.s)
		Protected *GadgetData.TLData = GetGadgetData(Gadget)
		
		If Position > -1 And SelectElement(*GadgetData\LineList(), Position)
			InsertElement(*GadgetData\LineList())
		Else
			LastElement(*GadgetData\LineList())
			AddElement(*GadgetData\LineList())
		EndIf
		
		*GadgetData\LineList()\Name = Name
		*GadgetData\LineList()\UUID = UUID
		
		List_Redraw(Gadget)
		Timeline_Redraw(Gadget)
	EndProcedure
	
	Procedure RemoveLine(Gadget, Position)
		
	EndProcedure
	
	;{ Private procedures
	Procedure Header_Event()
		Protected Gadget = EventGadget()
		Protected *GadgetData.TLData = GetGadgetData(Gadget)
		
		
	EndProcedure
	
	Procedure Header_Redraw(Gadget)
		Protected *GadgetData.TLData = GetGadgetData(Gadget)
		
		StartVectorDrawing(CanvasVectorOutput(*GadgetData\Header))
		AddPathBox(0, 0, *GadgetData\Header_Width, *GadgetData\Header_Height)

		VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Gadget_BackCold), 255))
		FillPath()
		
		AddPathBox(*GadgetData\Header_Width - 10, 0, 10, 10)
		UITK::AddPathRoundedBox(*GadgetData\Header_Width - 10, 0, 10, 10, MainWindow::#Appearance_CornerSize, UITK::#Corner_TopRight)
		VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Window_Border), 255))
		FillPath()
		MovePathCursor(0, *GadgetData\Header_Height - 0.5)
		AddPathLine(*GadgetData\Header_Width, 0, #PB_Path_Relative)
		StrokePath(1)
		StopVectorDrawing()
	EndProcedure
	
	Procedure List_Event()
		Protected Gadget = EventGadget()
		Protected *GadgetData.TLData = GetGadgetData(Gadget)
		
		
	EndProcedure
	
	Procedure List_Redraw(Gadget)
		Protected *GadgetData.TLData = GetGadgetData(Gadget)
		StartDrawing(CanvasOutput(*GadgetData\List))
		Box(0,0, *GadgetData\List_Width, *GadgetData\List_Height, FixColor(MainWindow::#Color_Gadget_BackCold))
		
		
		
		
		
		
		Line(*GadgetData\List_Width - 1, 0, 1, *GadgetData\List_Height, FixColor(MainWindow::#Color_Window_Border))
		DrawAlphaImage(CornerDL, 0, *GadgetData\List_Height - MainWindow::#Appearance_CornerSize)
		StopDrawing()
		
; 		
; 		StartVectorDrawing(CanvasVectorOutput(*GadgetData\List))
; 		AddPathBox(0, 0, *GadgetData\List_Width, *GadgetData\List_Height)
; 
; 		VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Gadget_BackCold), 255))
; 		FillPath()
; 		
; 		
; 		
; 		;{ Corner and line
; 		AddPathBox(0, *GadgetData\List_Height - 10, 10, 10)
; 		UITK::AddPathRoundedBox(0, *GadgetData\List_Height - 10, 10, 10, MainWindow::#Appearance_CornerSize, UITK::#Corner_BottomLeft)
; 		VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Window_Border), 255))
; 		FillPath()
; 		MovePathCursor(*GadgetData\List_Width - 0.5, 0)
; 		AddPathLine(0, *GadgetData\List_Height, #PB_Path_Relative)
; 		StrokePath(1)
; 		StopVectorDrawing()
; 		;}
	EndProcedure
	
	Procedure Timeline_Event()
		Protected Gadget = EventGadget()
		Protected *GadgetData.TLData = GetGadgetData(Gadget)
		
		
	EndProcedure
	
	Procedure Timeline_Redraw(Gadget)
		Protected *GadgetData.TLData = GetGadgetData(Gadget)
		
		StartVectorDrawing(CanvasVectorOutput(*GadgetData\TimeLine))
		AddPathBox(0, 0, *GadgetData\TimeLine_Width, *GadgetData\TimeLine_Height)

		VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Gadget_BackCold), 255))
		FillPath()
		
		AddPathBox(*GadgetData\TimeLine_Width - 10, *GadgetData\TimeLine_Height - 10, 10, 10)
		UITK::AddPathRoundedBox(*GadgetData\TimeLine_Width - 10, *GadgetData\TimeLine_Height - 10, 10, 10, MainWindow::#Appearance_CornerSize, UITK::#Corner_BottomRight)
		VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Window_Border), 255))
		FillPath()
		StopVectorDrawing()
	EndProcedure
	;}
EndModule




















; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 208
; FirstLine = 27
; Folding = 0HG5
; EnableXP
; DPIAware