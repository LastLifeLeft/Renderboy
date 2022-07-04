Module Project
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
	
	Procedure New()
		; Clear everything
		ClearList(Project\Assets[#Media]\list())
		ClearList(Project\Assets[#Audio]\list())
		ClearList(Project\Assets[#_3D]\list())
		ClearList(Project\Assets[#Overlay]\list())
		ClearList(Project\Assets[#Modifiers]\list())
		
		; Load the built in assets
		
		; Load icons if they aren't loaded
		If AssetIcon(#Asset_Image) = 0
			AssetIcon(#Asset_Image) = ImageID(CatchImage(#PB_Any, ?LibraryImage))
			
		EndIf
	EndProcedure
	
	Procedure AddAsset(Assets.s)
		Protected Loop, Count, File.s, Extension.s, ExistingFile
		Protected Image, FinalImage, OriginalWidth, OriginalHeight, ImageWidth, ImageHeight
		
		Count = CountString(Assets, #LF$) + 1
		UITK::Freeze(MainWindow::Library, #True)
		For Loop = 1 To Count
			File = StringField(Assets, Loop, #LF$)
			Extension = LCase(GetExtensionPart(File))
			
			Select Extension
				Case "jpg", "jpeg", "png", "bmp" ;{
					ExistingFile = #False
					ForEach Project\Assets[#Media]\list()
						If Project\Assets[#Media]\list()\Path = File
							ExistingFile = #True
							Break
						EndIf
					Next
					
					If ExistingFile
						Continue
					EndIf
					
					Image = LoadImage(#PB_Any, File)
					
					If Image
						OriginalWidth = ImageWidth(Image)
						OriginalHeight = ImageHeight(Image)
						FinalImage = CreateImage(#PB_Any, 160, 90, 24, #Black)
						
						If OriginalWidth <= 160 And OriginalHeight <= 90
							ImageWidth = OriginalWidth
							ImageHeight = OriginalHeight
						Else
							If Round(OriginalWidth / 160, #PB_Round_Nearest) < Round(OriginalHeight / 90, #PB_Round_Nearest)
								ImageWidth = General::Max(1, Round(90 / OriginalHeight * OriginalWidth, #PB_Round_Nearest))
								ImageHeight = General::Min(90, OriginalHeight)
							Else
								ImageWidth = General::Min(160, OriginalWidth)
								ImageHeight = General::Max(1, Round(160 / OriginalWidth * OriginalHeight, #PB_Round_Nearest))
							EndIf
							ResizeImage(Image, ImageWidth, ImageHeight, #PB_Image_Smooth)
						EndIf
						
						StartVectorDrawing(ImageVectorOutput(FinalImage))
						MovePathCursor((160 - ImageWidth) * 0.5, (90 - ImageHeight) * 0.5)
						DrawVectorImage(ImageID(Image))
						AddPathBox(0, 0, 160, 90)
						UITK::AddPathRoundedBox(0, 0, 160, 90, 5)
						VectorSourceColor(SetAlpha(FixColor(MainWindow::#Color_Gadget_BackCold), 255))
						FillPath()
						StopVectorDrawing()
						FreeImage(Image)
						
						AddElement(Project\Assets[#Media]\list())
						Project\Assets[#Media]\list()\Name = GetFilePart(File, #PB_FileSystem_NoExtension)
						Project\Assets[#Media]\list()\PreviewImage = FinalImage
						Project\Assets[#Media]\list()\Type = #Asset_Image
						Project\Assets[#Media]\list()\Path = File
						
						If GetGadgetState(MainWindow::Tab) = 0
							SetGadgetItemData(MainWindow::Library, AddGadgetItem(MainWindow::Library, -1, Project\Assets[#Media]\list()\Name, ImageID(Project\Assets[#Media]\list()\PreviewImage), 1), @Project\Assets[#Media]\list())
						EndIf
					EndIf
					;}
			EndSelect
			
			
		Next
		UITK::Freeze(MainWindow::Library, #False)
	EndProcedure
	
	DataSection
		LibraryImage:
		IncludeBinary "../Media/Library-Image.png"
	EndDataSection
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 44
; Folding = 0v
; EnableXP
; DPIAware