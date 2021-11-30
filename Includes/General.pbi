DeclareModule General
	#Name = "RenderBoy"
	#Version = "0.02"
	
	#PB_Image_KeepAspectRatio = 2
	#PB_Image_LetterBox = 6
	
	Enumeration ;Events
		#Event_None
		#Event_End
		#Event_Resize
		#Event_ReRender
		#Event_Edit
		#Event_AddLayer
		#Event_RemoveLayer
	EndEnumeration
	
	Structure EventList
		EventType.i
		UUID.s
	EndStructure
	
	Global WindowName.s
	Global NewList EventList.EventList()
	
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
		Macro SetAlpha(Alpha, Color) ; Not tested...
			Color << 8 + Alpha
		EndMacro
	CompilerEndIf
	
	Declare Min(a, b)
	Declare Max(a, b)
	Declare.s UUID()
	Declare ResizeImageEx(Image.i, Width.i, Height.i, Mode.i = #PB_Image_Smooth)
	Declare CeilPow(Number)
	
EndDeclareModule

DeclareModule MainWindow
	Global MaterialIcon = FontID(LoadFont(#PB_Any, "Material Design Icons Desktop", 16, #PB_Font_HighQuality))
	Global MaterialIconBig = FontID(LoadFont(#PB_Any, "Material Design Icons Desktop", 20, #PB_Font_HighQuality))
	Global DragPreview, ImagePreview, DragPreviewVisible
	Global RendererWidth, RendererHeight
	Global ModifierControl, ModifierShift
	
	Declare Open()
	Declare AddAssetButton(AssetType, Image, Text.s, UUID.s)
	Declare DeleteAssetButton(UUID.s)
	
	Enumeration ;Gadgets
		#TimeLine
		
		#CloseButton
		#MinimizeButton
		#MaximizeButton
		
		#FileButton
		#EditButton
		#ProjectButton
		
		#Asset_Container
		
		#Asset_VideoButton
		#Asset_AudioButton
		#Asset_ModelButton
		#Asset_UIButton
		#Asset_ElementButton
		#Asset_ScrollArea
		#Asset_ScrollBar
	EndEnumeration
	
	Enumeration ;Window
		#Window = 0
	EndEnumeration
	
	#Color_Asset_Media = $39DA8A
	#Color_Asset_Audio = $FDAC41
	#Color_Asset_Model = $00CFDD
	#Color_Asset_Overlay = $9341FD
	#Color_Asset_Element = $DD00B2
EndDeclareModule

DeclareModule Project
	Enumeration
		#Asset_Type_Image = 1
		#Asset_Type_Video
		#Asset_Type_Sound
		#Asset_Type_Music
		#Asset_Type_Voice
		#Asset_Type_Character
		#Asset_Type_Model
		#Asset_Type_2DEffect
		
		#__Asset_Type_Count
	EndEnumeration
	
	Declare New()
	Declare Load(File.s)
	Declare Save()
	Declare Export()
	Declare Archive()
	Declare AddAsset(Asset.s)
	Declare DeleteAsset(UUID.s)
	Declare Undo()
	Declare Redo()
	Declare AssetUse(UUID.s)
	Declare AssetUnUse(UUID.s)
	
	; Library
	Declare RePopulateMediaLibrary()
	Declare RePopulateElementLibrary()
	
	; Get
	Declare.s GetAssetName(UUID.s)
	Declare GetAssetType(UUID.s)
	Declare.s GetAssetPath(UUID.s)
	Declare GetAssetWidth(UUID.s)
	Declare GetAssetHeight(UUID.s)
	Declare.s GetAssetDefaultState(UUID.s)
EndDeclareModule

DeclareModule AssetButton
	Global DragType.i, DragUUID.s, PlusImage, Color
	
	Global AssetButtonMedia, AssetButtonSound, AssetButtonModel, AssetButtonOverlay, AssetButtonElement
	
	Declare Gadget(Gadget, X, Y, Width, Height, Image, AssetType, Text.s, UUID.s)
	Declare Delete(Gadget)
EndDeclareModule

Module General
	
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
	
	Procedure.s UUID()
		Protected i, GUID.s
		
		For i = 0 To 15
			GUID + RSet(Hex(Random(255) & $FF), 2, "0")
		Next
		
		ProcedureReturn GUID
	EndProcedure
	
	Procedure ResizeImageEx(Image.i, Width.i, Height.i, Mode.i = #PB_Image_Smooth)
		Protected AspectRatio.f, NewImage
		If Mode & #PB_Image_KeepAspectRatio
			AspectRatio = ImageWidth(Image)/ImageHeight(Image)
			If Width/Height < AspectRatio
				ResizeImage(Image, Width, Width/AspectRatio, #PB_Image_Smooth)
			Else
				ResizeImage(Image, Height*AspectRatio, Height, #PB_Image_Smooth)
			EndIf
			
			If Mode & #PB_Image_LetterBox = #PB_Image_LetterBox
				NewImage = CopyImage(Image, #PB_Any)
				ResizeImage(Image, Width, Height, #PB_Image_Raw)
				StartDrawing(ImageOutput(Image))
				Box(0, 0, Image, Width, $FF000000)
				DrawAlphaImage(ImageID(NewImage), (Width - ImageWidth(NewImage)) * 0.5, (Height - ImageHeight(NewImage)) * 0.5)
				StopDrawing()
			EndIf
		Else
			ResizeImage(Image, Width, Height, Mode)
		EndIf
	EndProcedure
	
	Procedure CeilPow(Number)
		Number - 1
		Number = (Number | Number >> 1)
		Number = (Number | Number >> 2)
		Number = (Number | Number >> 4)
		Number = (Number | Number >> 8)
		Number = (Number | Number >> 16)
		
		CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
			Number = (Number | Number >> 32)
		CompilerEndIf
		
		ProcedureReturn Number + 1
	EndProcedure

EndModule


; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 42
; Folding = 0dw
; EnableXP