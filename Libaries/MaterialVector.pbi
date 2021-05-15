DeclareModule MaterialVector
	EnumerationBinary
		#Style_Regular = 0
		#Style_Outline = 65536						; The first 16 bits shall stay unused, it'll help MaterialVector to be integrated in other libraries
		#Style_Circle
		#Style_Box
		
		#style_rotate_90
		#style_rotate_180
		#style_rotate_270
		
	EndEnumeration
	
	Enumeration
		#Accessibility
		#AllOut
		#Arrow
		#Bento
		#Camera
		#Chevron
		#Cube
		#Folder
		#FolderOpen
		#Image
		#Minus
		#Music
		#Pause
		#Person
		#Pen
		#Play
		#Plus
		#Skip
		#Video
		#_LISTSIZE
	EndEnumeration
	
	Declare AddPathRoundedBox(x.d, y.d, Width, Height, Radius, Flag = #PB_Path_Default)
	Declare Draw(icon, x, y, Size, FrontColor, BackColor, Style = #Style_Regular)
EndDeclareModule

Module MaterialVector
	EnableExplicit
	
	;{ Private variables, structures, constants...
	Global Dim Function(#_LISTSIZE)
	
	#Style_NoPath = 16384
	
	;}
	
	;{ Private Procedure Declarations
	Declare Rotation(Style, Size)
	
	Declare Accessibility(x, y, Size, FrontColor, BackColor, Style)
	Declare AllOut(x, y, Size, FrontColor, BackColor, Style)
	Declare Arrow(x, y, Size, FrontColor, BackColor, Style)
	Declare Bento(x, y, Size, FrontColor, BackColor, Style)
	Declare Camera(x, y, Size, FrontColor, BackColor, Style)
	Declare Chevron(x, y, Size, FrontColor, BackColor, Style)
	Declare Cube(x, y, Size, FrontColor, BackColor, Style)
	Declare Folder(x, y, Size, FrontColor, BackColor, Style)
	Declare FolderOpen(x, y, Size, FrontColor, BackColor, Style)
	Declare Minus(x, y, Size, FrontColor, BackColor, Style)
	Declare Music(x, y, Size, FrontColor, BackColor, Style)
	Declare Person(x, y, Size, FrontColor, BackColor, Style)
	Declare Pen(x, y, Size, FrontColor, BackColor, Style)
	Declare Plus(x, y, Size, FrontColor, BackColor, Style)
	Declare Pause(x, y, Size, FrontColor, BackColor, Style)
	Declare Play(x, y, Size, FrontColor, BackColor, Style)
	Declare Skip(x, y, Size, FrontColor, BackColor, Style)
	Declare Video(x, y, Size, FrontColor, BackColor, Style)
	;}
	
	; Public Procedures
	Procedure Draw(icon, x, y, Size, FrontColor, BackColor, Style = #Style_Regular)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5, Half.i = Size/2, Path.i
		
		MovePathCursor(x, y)
		
		If Style & #Style_Circle
			If Style & #Style_Outline
				AddPathCircle(Half, Half, Half - Margin, 0, 360, #PB_Path_Relative)
				VectorSourceColor(BackColor)
				FillPath(#PB_Path_Preserve)
				VectorSourceColor(FrontColor)
				StrokePath(PathWidth, #PB_Path_Default)
				MovePathCursor(x, y)
				Path = CallFunctionFast(Function(icon),  x + PathWidth * 2, y + PathWidth * 2, Size - PathWidth * 4, FrontColor, BackColor, Style!#Style_Outline|#Style_NoPath)
			Else
				AddPathCircle(Half, Half, Half, 0, 360, #PB_Path_Relative)
				VectorSourceColor(FrontColor)
				FillPath()
				MovePathCursor(x, y)
				Path = CallFunctionFast(Function(icon),  x + PathWidth * 2, y + PathWidth * 2, Size - PathWidth * 4, BackColor, FrontColor, Style|#Style_NoPath)
			EndIf
			StrokePath(PathWidth, Path)
		ElseIf Style & #Style_Box
			If Style & #Style_Outline
				AddPathRoundedBox(Margin, Margin, Size - Margin * 2, Size - Margin * 2, Margin, #PB_Path_Relative)
				VectorSourceColor(BackColor)
				FillPath(#PB_Path_Preserve)
				VectorSourceColor(FrontColor)
				StrokePath(PathWidth, #PB_Path_Default)
				MovePathCursor(x, y)
				Path = CallFunctionFast(Function(icon), x + PathWidth * 2, y + PathWidth * 2, Size - PathWidth * 4, FrontColor, BackColor, Style!#Style_Outline|#Style_NoPath)
			Else
				AddPathRoundedBox(0, 0, Size, Size, PathWidth, #PB_Path_Relative)
				VectorSourceColor(FrontColor)
				FillPath()
				MovePathCursor(x, y)
				Path = CallFunctionFast(Function(icon),  x + PathWidth * 2, y + PathWidth * 2, Size - PathWidth * 4, BackColor, FrontColor, Style|#Style_NoPath)
			EndIf
			StrokePath(PathWidth, Path)
		Else
			CallFunctionFast(Function(icon), x, y, Size, FrontColor, BackColor, Style)
		EndIf
		
	EndProcedure
	
	Procedure AddPathRoundedBox(x.d, y.d, Width, Height, Radius, Flag = #PB_Path_Default)
		MovePathCursor(x, y + Radius, Flag)
		
		AddPathArc(0, Height - radius, Width, Height - radius, Radius, #PB_Path_Relative)
		AddPathArc(Width - Radius, 0, Width - Radius, - Height, Radius, #PB_Path_Relative)
		AddPathArc(0, Radius - Height, -Width, Radius - Height, Radius, #PB_Path_Relative)
		AddPathArc(Radius - Width, 0, Radius - Width, Height, Radius, #PB_Path_Relative)
		ClosePath()
		
		MovePathCursor(-x,-y-Radius, Flag)
	EndProcedure
	
	; Private procedures
	;Tools
	Procedure Rotation(Style, Size) ; There has to be a better solution, but I can't figure it out with trigonometry... This is most likely a brainfart, come back to it later
		Protected Rotation, RotationOffsetX, RotationOffsetY
		If Style & #style_rotate_90
			Rotation = 90
			RotationOffsetY = -Size
		ElseIf Style & #style_rotate_180
			Rotation = 180
			RotationOffsetX = -Size
			RotationOffsetY = -Size
		ElseIf Style & #style_rotate_270
			Rotation = 270
			RotationOffsetX = -Size
		EndIf
		RotateCoordinates(0, 0, Rotation)
		MovePathCursor(RotationOffsetX,RotationOffsetY, #PB_Path_Relative)
		ProcedureReturn Rotation
	EndProcedure
	
	;Icons
	Procedure Accessibility(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5, Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		MovePathCursor(PathWidth, PathWidth * 3, #PB_Path_Relative)
		AddPathLine(7 * PathWidth, 0, #PB_Path_Relative)
		AddPathLine(0, PathWidth, #PB_Path_Relative)
		AddPathLine(-2 * PathWidth, 0, #PB_Path_Relative)
		AddPathLine(0, Half + PathWidth, #PB_Path_Relative)
		AddPathLine(- PathWidth, 0, #PB_Path_Relative)
		AddPathLine(0, -2.5 * PathWidth, #PB_Path_Relative)
		AddPathLine(- PathWidth, 0, #PB_Path_Relative)
		AddPathLine(0, 2.5 * PathWidth, #PB_Path_Relative)
		AddPathLine(- PathWidth, 0, #PB_Path_Relative)
		AddPathLine(0, - Half - PathWidth, #PB_Path_Relative)
		AddPathLine(-2 * PathWidth, 0, #PB_Path_Relative)
		
		AddPathCircle(PathWidth * 3.5 , PathWidth * - 2.5, PathWidth, 0, 360, #PB_Path_Relative)
		
		FillPath(#PB_Path_Winding)
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure
	
	Procedure AllOut(x, y, Size, FrontColor, BackColor, Style)
		Protected NewSize = Size * 0.8,  Offset = (Size - NewSize) * 0.5
		Size = NewSize
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up)
		
		MovePathCursor(x + Offset, y + Offset)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		AddPathLine(0, PathWidth, #PB_Path_Relative)
		AddPathLine(PathWidth, - PathWidth, #PB_Path_Relative)
		ClosePath()
		
		MovePathCursor(Size - PathWidth, 0, #PB_Path_Relative)
		AddPathLine(PathWidth, PathWidth, #PB_Path_Relative)
		AddPathLine(0, -PathWidth, #PB_Path_Relative)
		ClosePath()
		
		MovePathCursor(PathWidth, Size - PathWidth, #PB_Path_Relative)
		AddPathLine(-PathWidth, PathWidth, #PB_Path_Relative)
		AddPathLine(PathWidth, 0, #PB_Path_Relative)
		ClosePath()
		
		MovePathCursor(PathWidth - Size, PathWidth, #PB_Path_Relative)
		AddPathLine(-PathWidth, 0, #PB_Path_Relative)
		AddPathLine(0, -PathWidth, #PB_Path_Relative)
		ClosePath()
		
		AddPathCircle(Size * 0.5 - PathWidth, - Size * 0.5, Size * 0.38, 0, 360, #PB_Path_Relative)
		
		If Not  Style & #Style_Outline
			FillPath(#PB_Path_Preserve)
		EndIf
		
		StrokePath(PathWidth, #PB_Path_Default)
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure
	
	Procedure Arrow(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5, Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		
		Protected Rotation = Rotation(Style, Size)
			
		MovePathCursor( Half, PathWidth, #PB_Path_Relative)
		AddPathLine(0, Size - PathWidth, #PB_Path_Relative)
		MovePathCursor(Margin - Half, - Size + Half + Margin, #PB_Path_Relative)
		AddPathLine(Half - Margin, Margin - Half, #PB_Path_Relative)
		AddPathLine(Half - Margin,	Half - Margin, #PB_Path_Relative)
		VectorSourceColor(FrontColor)
		If Not Style & #Style_NoPath
			StrokePath(PathWidth, #PB_Path_Default)
		EndIf
			
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure
	
	Procedure Bento(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5, Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size) ;< call rotation for an automatic setup
		
		MovePathCursor((Size - PathWidth * 6 - Margin * 2) * 0.5, (Size - (PathWidth * 4 + Margin)) * 0.5 , #PB_Path_Relative)
		AddPathBox(0, 0, PathWidth * 2, PathWidth * 4 + Margin, #PB_Path_Relative)
		MovePathCursor(PathWidth * 2 + Margin, 0, #PB_Path_Relative)
		AddPathBox(0, 0, PathWidth * 4 + Margin, PathWidth * 2,  #PB_Path_Relative)
		MovePathCursor(0, PathWidth * 2 + Margin, #PB_Path_Relative)
		AddPathBox(0, 0, PathWidth * 2, PathWidth * 2,  #PB_Path_Relative)
		MovePathCursor(PathWidth * 2 + Margin, 0, #PB_Path_Relative)
		AddPathBox(0, 0, PathWidth * 2, PathWidth * 2,  #PB_Path_Relative)
		
		If Not Style & #Style_NoPath ;< if needed, draw your paths
			FillPath()
		EndIf
		
		If Rotation ;< return the output to it's original position
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default ; returns the correct path flaf for boxes/circled icons
	EndProcedure
	
	Procedure Camera(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5, Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		MovePathCursor(Size - Margin, PathWidth * 2 + Margin, #PB_Path_Relative)
		AddPathLine(0, PathWidth * 4, #PB_Path_Relative)
		AddPathLine(- PathWidth * 2 - Margin, - PathWidth * 2, #PB_Path_Relative)
		ClosePath()
		FillPath()
		
		If Rotation ; Couldn't figure a way out of this since fillpath reset the cursor position...
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		MovePathCursor(x, y)
		
		Rotation(Style, Size)
		
		If Style & #Style_Outline
			AddPathRoundedBox(Margin, PathWidth * 2 + Margin, Size - PathWidth * 3, PathWidth * 4, Margin * 0.33, #PB_Path_Relative)
			StrokePath(PathWidth, #PB_Path_Default)
		Else
			AddPathRoundedBox(0, PathWidth * 2, Size - PathWidth * 2, PathWidth * 5, Margin, #PB_Path_Relative)
			FillPath()
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure	
	
	Procedure Chevron(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5,  Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		
		Protected Rotation = Rotation(Style, Size)
		
		MovePathCursor(Margin, (Size - (Margin - Half)) / 2, #PB_Path_Relative)
		AddPathLine(Half - Margin, Margin - Half, #PB_Path_Relative)
		AddPathLine(Half - Margin,	Half - Margin, #PB_Path_Relative)
		VectorSourceColor(FrontColor)
		
		If Not Style & #Style_NoPath
			StrokePath(PathWidth, #PB_Path_RoundCorner|#PB_Path_RoundEnd)
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_RoundCorner|#PB_Path_RoundEnd
	EndProcedure
	
	Procedure Cube(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5,  Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size) ;< call rotation for an automatic setup
		
		MovePathCursor(Half, PathWidth, #PB_Path_Relative)
		AddPathLine(PathWidth * 3, PathWidth * 1.5, #PB_Path_Relative)
		AddPathLine(-PathWidth * 3, PathWidth * 1.5, #PB_Path_Relative)
		AddPathLine(-PathWidth * 3, -PathWidth * 1.5, #PB_Path_Relative)
		ClosePath()
		MovePathCursor(0, PathWidth * 3, #PB_Path_Relative)
		
		AddPathLine(0					, PathWidth * 4, #PB_Path_Relative)
		AddPathLine(-PathWidth * 3		, -PathWidth * 1.5, #PB_Path_Relative)
		AddPathLine(0					, -PathWidth * 4, #PB_Path_Relative)
		MovePathCursor(PathWidth * 3	, PathWidth * 5.5, #PB_Path_Relative)
		AddPathLine(PathWidth * 3		, -PathWidth * 1.5, #PB_Path_Relative)
		AddPathLine(0					, -PathWidth * 4, #PB_Path_Relative)
		
		
		StrokePath(PathWidth, #PB_Path_RoundCorner)
		
		If Rotation ;< return the output to it's original position
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default ; returns the correct path flaf for boxes/circled icons
	EndProcedure
	
	Procedure Folder(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5,  Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		MovePathCursor(Margin * 2, Round(PathWidth * 1.4, #PB_Round_Nearest), #PB_Path_Relative)
		AddPathLine(- Round(Margin * 0.5, #PB_Round_Nearest), Round(Margin * 1.5, #PB_Round_Nearest), #PB_Path_Relative)
		AddPathLine(0, Round(Size * 0.6, #PB_Round_Nearest), #PB_Path_Relative)
		AddPathLine(Size - Margin * 2, 0, #PB_Path_Relative)
		AddPathLine(0, - Round(Size * 0.6, #PB_Round_Nearest), #PB_Path_Relative)
		AddPathLine(- Half, 0, #PB_Path_Relative)
		AddPathLine( - Round(Margin * 0.5, #PB_Round_Nearest), - Round(Margin * 1.5, #PB_Round_Nearest), #PB_Path_Relative)
		ClosePath()
		
		If Not Style & #Style_Outline
 			FillPath(#PB_Path_Preserve)
 		EndIf
 		
		If Not Style & #Style_NoPath ;< if needed, draw your paths
			StrokePath(PathWidth, #PB_Path_RoundCorner)
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_RoundCorner
	EndProcedure
	
	Procedure FolderOpen(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5,  Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		MovePathCursor(Margin * 2, Round(PathWidth * 1.4, #PB_Round_Nearest), #PB_Path_Relative)
		SaveVectorState()
		AddPathLine(- Round(Margin * 0.5, #PB_Round_Nearest), Round(Margin * 1.5, #PB_Round_Nearest), #PB_Path_Relative)
		AddPathLine( Size * 0.35, 0, #PB_Path_Relative)
		AddPathLine( - Round(Margin * 0.5, #PB_Round_Nearest), - Round(Margin * 1.5, #PB_Round_Nearest), #PB_Path_Relative)
		ClosePath()
		
		RestoreVectorState()
		AddPathLine(- Round(Margin * 0.5, #PB_Round_Nearest), Round(Margin * 1.5, #PB_Round_Nearest), #PB_Path_Relative)
		AddPathLine(0, Round(Size * 0.6, #PB_Round_Nearest), #PB_Path_Relative)
		AddPathLine(Size - Margin * 2, 0, #PB_Path_Relative)
		AddPathLine(0, - Round(Size * 0.6, #PB_Round_Nearest), #PB_Path_Relative)
		AddPathLine(- Half, 0, #PB_Path_Relative)
		AddPathLine( - Round(Margin * 0.5, #PB_Round_Nearest), - Round(Margin * 1.5, #PB_Round_Nearest), #PB_Path_Relative)
		ClosePath()
 		
		If Not Style & #Style_NoPath
			StrokePath(PathWidth, #PB_Path_RoundCorner)
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_RoundCorner
	EndProcedure
	
	Procedure Image(x, y, Size, FrontColor, BackColor, Style)
		Protected NewSize = Size * 0.9,  Offset.f = (Size - NewSize) * 0.5
		Size = NewSize
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin = PathWidth * 0.5, MountainWidth = (Size - PathWidth * 2 - Margin * 2) / 6
		
		MovePathCursor(x + Offset, y + Offset)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		If Not Style & #Style_Outline
			AddPathRoundedBox(0, 0, Size, Size, PathWidth, #PB_Path_Relative)
			
			MovePathCursor(PathWidth + Margin, Size - (PathWidth * 2), #PB_Path_Relative)
			AddPathLine(MountainWidth, - PathWidth, #PB_Path_Relative)
			AddPathLine(MountainWidth, PathWidth, #PB_Path_Relative)
			AddPathLine(MountainWidth * 2, - PathWidth * 2, #PB_Path_Relative)
			AddPathLine(MountainWidth * 2,  PathWidth * 2, #PB_Path_Relative)
			AddPathLine(-6  * MountainWidth,  0, #PB_Path_Relative)
			ClosePath()
			
			FillPath()
		Else
			AddPathRoundedBox(0, 0, Size, Size, PathWidth, #PB_Path_Relative)
			
			AddPathBox(PathWidth, PathWidth, Size - PathWidth * 2, Size - PathWidth * 2, #PB_Path_Relative)
			
			MovePathCursor(Margin, Size - (PathWidth * 3), #PB_Path_Relative)
			AddPathLine(MountainWidth, - PathWidth * 1.2, #PB_Path_Relative)
			AddPathLine(MountainWidth, PathWidth * 1.2, #PB_Path_Relative)
			AddPathLine(MountainWidth * 2, - PathWidth * 2.4, #PB_Path_Relative)
			AddPathLine(MountainWidth * 2,  PathWidth * 2.4, #PB_Path_Relative)
			AddPathLine(-6  * MountainWidth,  0, #PB_Path_Relative)
			ClosePath()
			
			FillPath()
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_RoundCorner
	EndProcedure
	
	Procedure Minus(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		If Style & #Style_Outline
			MovePathCursor(PathWidth, Half - PathWidth, #PB_Path_Relative)
			AddPathBox(0,0, Size - PathWidth * 2, PathWidth * 2,  #PB_Path_Relative)
			StrokePath(PathWidth, #PB_Path_Default)
		Else
			MovePathCursor(PathWidth, Half, #PB_Path_Relative)
			AddPathLine(Size - PathWidth * 2, 0, #PB_Path_Relative)

			If Not Style & #Style_NoPath
				StrokePath(PathWidth, #PB_Path_Default)
			EndIf
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure
	
	Procedure Music(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5, Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		If Style & #Style_Outline
			MovePathCursor(Half, PathWidth , #PB_Path_Relative)
 			AddPathLine(PathWidth * 3, 0, #PB_Path_Relative)
 			MovePathCursor(-PathWidth * 2.5 , 0, #PB_Path_Relative)
 			AddPathLine(0, PathWidth * 4.5, #PB_Path_Relative)
 			AddPathCircle(- PathWidth * 1.5, 0, PathWidth + Margin, 0 , 360,  #PB_Path_Relative)
 			StrokePath(PathWidth, #PB_Path_Default)
		Else
			AddPathBox(Half, PathWidth, PathWidth * 3 , PathWidth, #PB_Path_Relative)
	 		AddPathBox(0,0, PathWidth, PathWidth * 5, #PB_Path_Relative)
	 		AddPathCircle(- PathWidth, PathWidth * 5, PathWidth * 2, 0 , 360,  #PB_Path_Relative)
 			FillPath(#PB_Path_Winding)
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure
	
	Procedure Person(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5, Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		If Style & #Style_Outline
			MovePathCursor(PathWidth + Margin, Size - PathWidth * 3, #PB_Path_Relative)
			AddPathLine(0, PathWidth * 2, #PB_Path_Relative)
			AddPathLine(Size - PathWidth * 3, 0, #PB_Path_Relative)
			AddPathLine(0, - PathWidth * 2, #PB_Path_Relative)
			AddPathEllipse(- (Size - PathWidth * 3) * 0.5, Margin * 0.5, (Size - PathWidth * 3) * 0.5 , PathWidth, 180, 360, #PB_Path_Relative)
			
			AddPathCircle(- (Size - PathWidth * 3) * 0.5, - PathWidth * 3 - Margin, PathWidth, 0, 360, #PB_Path_Relative)
			
			StrokePath(PathWidth, #PB_Path_Default)
		Else
			MovePathCursor(PathWidth + Margin, Size - PathWidth * 3, #PB_Path_Relative)
			AddPathLine(0, PathWidth * 2, #PB_Path_Relative)
			AddPathLine(Size - PathWidth * 3, 0, #PB_Path_Relative)
			AddPathLine(0, - PathWidth * 2, #PB_Path_Relative)
			AddPathEllipse(- (Size - PathWidth * 3) * 0.5, 0, (Size - PathWidth * 3) * 0.5 , PathWidth, 180, 360, #PB_Path_Relative)
			
			AddPathCircle(- (Size - PathWidth * 3) * 0.5, - PathWidth * 3, PathWidth + Margin, 0, 360, #PB_Path_Relative)

			FillPath(#PB_Path_Winding)
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default ; returns the correct path flaf for boxes/circled icons
	EndProcedure
	
	Procedure Pen(x, y, Size, FrontColor, BackColor, Style) ; Really not material design complient as it is right now.
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Diagonal = Size - 2 * PathWidth
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size) ;< call rotation for an automatic setup
		
		; Eraser
		If Style & #Style_Outline
			MovePathCursor(Diagonal, 0, #PB_Relative)
			AddPathLine(PathWidth* 2, PathWidth* 2, #PB_Relative)
			AddPathLine(-PathWidth, PathWidth, #PB_Relative)
			AddPathLine(-PathWidth* 2, -PathWidth* 2, #PB_Relative)
			ClosePath()
			FillPath()
			
			If Rotation ; Couldn't figure a way out of this since fillpath reset the cursor position...
				RotateCoordinates(0, 0, -Rotation)
			EndIf
			
			MovePathCursor(x, y)
			Rotation(Style, Size)
			MovePathCursor(Diagonal, 0, #PB_Relative)
			AddPathLine(PathWidth* 2, PathWidth* 2, #PB_Relative)
			AddPathLine(-PathWidth, PathWidth, #PB_Relative)
			AddPathLine(-PathWidth* 2, -PathWidth* 2, #PB_Relative)
			ClosePath()
		Else
			MovePathCursor(Diagonal, 0, #PB_Relative)
			AddPathLine(PathWidth* 2, PathWidth* 2, #PB_Relative)
			AddPathLine(-PathWidth* 1.5, PathWidth* 1.5, #PB_Relative)
			AddPathLine(-PathWidth* 2, -PathWidth* 2, #PB_Relative)
			ClosePath()
		EndIf
		
		; Pen
		Diagonal = Size - 4.5 * PathWidth
		MovePathCursor( - 2 * PathWidth, PathWidth * 2, #PB_Relative)
		AddPathLine(- Diagonal, Diagonal, #PB_Relative)
		AddPathLine(0, PathWidth * 2, #PB_Relative)
		AddPathLine(PathWidth * 2, 0, #PB_Relative)
		AddPathLine(Diagonal, - Diagonal, #PB_Relative)
		AddPathLine(- PathWidth * 2, - PathWidth * 2, #PB_Relative)
		ClosePath()
		
		If Not Style & #Style_Outline
			FillPath()
		EndIf
		
		If Not Style & #Style_NoPath ;< if needed, draw your paths
			StrokePath(PathWidth, #PB_Path_RoundCorner)
		EndIf
		
		If Rotation ;< return the output to it's original position
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default ; returns the correct path flaf for boxes/circled icons
	EndProcedure
	
	Procedure Plus(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up),  Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		If Style & #Style_Outline
			MovePathCursor(Half - PathWidth, PathWidth, #PB_Path_Relative)
			AddPathLine(0, Half - PathWidth * 2, #PB_Path_Relative)
			AddPathLine(PathWidth * 2 - Half, 0, #PB_Path_Relative)
			AddPathLine(0, PathWidth * 2, #PB_Path_Relative)
			AddPathLine(Half - PathWidth * 2, 0, #PB_Path_Relative)
			AddPathLine(0, Half - PathWidth * 2, #PB_Path_Relative)
			AddPathLine(PathWidth * 2,0, #PB_Path_Relative)
			AddPathLine(0, PathWidth * 2 - Half , #PB_Path_Relative)
			AddPathLine(Half - PathWidth * 2, 0, #PB_Path_Relative)
			AddPathLine(0, - PathWidth * 2, #PB_Path_Relative)
			AddPathLine(PathWidth * 2 - Half, 0, #PB_Path_Relative)
			AddPathLine(0, PathWidth * 2 - Half, #PB_Path_Relative)
			ClosePath()
			
			StrokePath(PathWidth, #PB_Path_Default)
		Else
			MovePathCursor(Half, PathWidth, #PB_Path_Relative)
			AddPathLine(0, Size - PathWidth * 2, #PB_Path_Relative)
			
			MovePathCursor(PathWidth - Half, PathWidth - Half, #PB_Path_Relative)
			AddPathLine(Size - PathWidth * 2, 0, #PB_Path_Relative)
			
			If Not Style & #Style_NoPath
				StrokePath(PathWidth, #PB_Path_Default)
			EndIf
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure
	
	Procedure Pause(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		AddPathBox(Round((Size - PathWidth *6) * 0.5, #PB_Round_Nearest), 0, PathWidth * 2, Size, #PB_Path_Relative)
		AddPathBox(PathWidth * 4, 0, PathWidth * 2, Size, #PB_Path_Relative)
		
		VectorSourceColor(FrontColor)
		FillPath()
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure	
	
	Procedure Play(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		MovePathCursor(PathWidth * 2, 0, #PB_Path_Relative)
		AddPathLine(0, Size, #PB_Path_Relative)
		AddPathLine(PathWidth * 6, -Half, #PB_Path_Relative)
		ClosePath()
		
		VectorSourceColor(FrontColor)
		FillPath()
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure	
	
	Procedure Skip(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Half.i = Size * 0.5

		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		MovePathCursor(PathWidth, 0, #PB_Path_Relative)
		AddPathLine(0, Size, #PB_Path_Relative)
		AddPathLine(PathWidth * 5, -Half, #PB_Path_Relative)
		ClosePath()
		AddPathBox(PathWidth * 5, 0, PathWidth * 2, Size, #PB_Path_Relative)
		
		VectorSourceColor(FrontColor)
		FillPath(#PB_Path_Winding)
		
		If Not Style & #Style_NoPath
			StrokePath(PathWidth, #PB_Path_Default)
		EndIf
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure	
	
	Procedure Video(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up), Margin.i = PathWidth * 0.5, Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size)
		
		AddPathBox((Size - (Size - PathWidth)) * 0.5, (Size - PathWidth * 9) * 0.5, Size - PathWidth , PathWidth * 9, #PB_Path_Relative)
		AddPathBox(PathWidth, 0, PathWidth, PathWidth, #PB_Path_Relative)
		AddPathBox(0, PathWidth * 2, PathWidth, PathWidth, #PB_Path_Relative)
		AddPathBox(0, PathWidth * 2, PathWidth, PathWidth, #PB_Path_Relative)
		AddPathBox(0, PathWidth * 2, PathWidth, PathWidth, #PB_Path_Relative)
		AddPathBox(0, PathWidth * 2, PathWidth, PathWidth, #PB_Path_Relative)
		
		AddPathBox(Size - PathWidth * 4, 0, PathWidth, PathWidth, #PB_Path_Relative)
		AddPathBox(0, PathWidth * - 2, PathWidth, PathWidth, #PB_Path_Relative)
		AddPathBox(0, PathWidth * - 2, PathWidth, PathWidth, #PB_Path_Relative)
		AddPathBox(0, PathWidth * - 2, PathWidth, PathWidth, #PB_Path_Relative)
		AddPathBox(0, PathWidth * - 2, PathWidth, PathWidth, #PB_Path_Relative)
			
		If Style & #Style_Outline
			AddPathBox(- Size + PathWidth * 6, PathWidth, Size - PathWidth * 7, PathWidth * 7, #PB_Path_Relative)
		EndIf
		
		FillPath()
		
		If Rotation
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default
	EndProcedure
	
	Function(#Accessibility) = @Accessibility()
	Function(#AllOut) = @AllOut()
	Function(#Arrow) = @Arrow()
	Function(#Bento) = @Bento()
	Function(#Camera) = @Camera()
	Function(#Chevron) = @Chevron()
	Function(#Cube) = @Cube()
	Function(#Folder) = @Folder()
	Function(#FolderOpen) = @FolderOpen()
	Function(#Image) = @Image()
	Function(#Plus) = @Plus()
	Function(#Minus) = @Minus()
	Function(#Music) = @Music()
	Function(#Person) = @Person()
	Function(#Pen) = @Pen()
	Function(#Pause) = @Pause()
	Function(#Play) = @Play()
	Function(#Skip) = @Skip()
	Function(#Video) = @Video()
	
	CompilerIf #False
	;Build your own 
	Procedure NewIconExample(x, y, Size, FrontColor, BackColor, Style)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up) ;< seems to be the correct width to "feel" material design
		
		MovePathCursor(x, y)
		VectorSourceColor(FrontColor)
		
		Protected Rotation = Rotation(Style, Size) ;< call rotation for an automatic setup
		
		If Not Style & #Style_NoPath ;< if needed, draw your paths
			StrokePath(PathWidth, #PB_Path_Default)
		EndIf
		
		If Rotation ;< return the output to it's original position
			RotateCoordinates(0, 0, -Rotation)
		EndIf
		
		ProcedureReturn #PB_Path_Default ; returns the correct path flaf for boxes/circled icons
	EndProcedure
	CompilerEndIf
EndModule

CompilerIf #PB_Compiler_IsMainFile ;Gallery
	Global FrontColor = RGBA(16, 16, 20, 255), BackColor = RGBA(255, 255, 255, 255)
	
	Procedure Update()
		Protected Icon = GetGadgetState(1)
		StartVectorDrawing(CanvasVectorOutput(0))
		AddPathBox(0, 0, VectorOutputWidth(), VectorOutputHeight())
		VectorSourceColor(BackColor)
		FillPath()
		
		MaterialVector::Draw(Icon, 10, 10, 16, FrontColor, BackColor)
		MaterialVector::Draw(Icon, 30, 10, 16, FrontColor, BackColor, MaterialVector::#Style_Outline)
		MaterialVector::Draw(Icon, 50, 10, 16, FrontColor, BackColor, MaterialVector::#Style_Box|MaterialVector::#Style_Outline)
		MaterialVector::Draw(Icon, 70, 10, 16, FrontColor, BackColor, MaterialVector::#Style_Box)
		MaterialVector::Draw(Icon, 90, 10, 16, FrontColor, BackColor, MaterialVector::#Style_Circle|MaterialVector::#Style_Outline)
		MaterialVector::Draw(Icon, 110, 10, 16, FrontColor, BackColor, MaterialVector::#Style_Circle)
		
		MaterialVector::Draw(Icon, 10, 45, 32, FrontColor, BackColor, MaterialVector::#style_rotate_90)
		MaterialVector::Draw(Icon, 50, 45, 32, FrontColor, BackColor, MaterialVector::#style_rotate_90|MaterialVector::#Style_Outline)
		MaterialVector::Draw(Icon, 90, 45, 32, FrontColor, BackColor, MaterialVector::#Style_Box|MaterialVector::#Style_Outline|MaterialVector::#style_rotate_90)
		MaterialVector::Draw(Icon, 130, 45, 32, FrontColor, BackColor, MaterialVector::#Style_Box|MaterialVector::#style_rotate_90)
		MaterialVector::Draw(Icon, 170, 45, 32, FrontColor, BackColor, MaterialVector::#Style_Circle|MaterialVector::#Style_Outline|MaterialVector::#style_rotate_90)
		MaterialVector::Draw(Icon, 210, 45, 32, FrontColor, BackColor, MaterialVector::#Style_Circle|MaterialVector::#style_rotate_90)
		
		MaterialVector::Draw(Icon, 10, 100, 64, FrontColor, BackColor, MaterialVector::#style_rotate_180)
		MaterialVector::Draw(Icon, 80, 100, 64, FrontColor, BackColor, MaterialVector::#style_rotate_180|MaterialVector::#Style_Outline)
		MaterialVector::Draw(Icon, 150, 100, 64, FrontColor, BackColor, MaterialVector::#Style_Box|MaterialVector::#Style_Outline|MaterialVector::#style_rotate_180)
		MaterialVector::Draw(Icon, 220, 100, 64, FrontColor, BackColor, MaterialVector::#Style_Box|MaterialVector::#style_rotate_180)
		MaterialVector::Draw(Icon, 290, 100, 64, FrontColor, BackColor, MaterialVector::#Style_Circle|MaterialVector::#Style_Outline|MaterialVector::#style_rotate_180)
		MaterialVector::Draw(Icon, 360, 100, 64, FrontColor, BackColor, MaterialVector::#Style_Circle|MaterialVector::#style_rotate_180)
		
		MaterialVector::Draw(Icon, 10, 200, 96, FrontColor, BackColor, MaterialVector::#style_rotate_270)
		MaterialVector::Draw(Icon, 120, 200, 96, FrontColor, BackColor, MaterialVector::#style_rotate_270|MaterialVector::#Style_Outline)
		MaterialVector::Draw(Icon, 230, 200, 96, FrontColor, BackColor, MaterialVector::#Style_Box|MaterialVector::#Style_Outline|MaterialVector::#style_rotate_270)
		MaterialVector::Draw(Icon, 340, 200, 96, FrontColor, BackColor, MaterialVector::#Style_Box|MaterialVector::#style_rotate_270)
		MaterialVector::Draw(Icon, 450, 200, 96, FrontColor, BackColor, MaterialVector::#Style_Circle|MaterialVector::#Style_Outline|MaterialVector::#style_rotate_270)
		MaterialVector::Draw(Icon, 560, 200, 96, FrontColor, BackColor, MaterialVector::#Style_Circle|MaterialVector::#style_rotate_270)
		StopVectorDrawing()
	EndProcedure
	
	Procedure Close()
		End
	EndProcedure
	
	OpenWindow(0, 0, 0, 670, 360, "Material Vector Gallery", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
	SetWindowColor(0, #White)
	CanvasGadget(0, 0, 40, 670, 320)
	
	ComboBoxGadget(1, 10, 10, 120, 20)
	AddGadgetItem(1, -1, "Accessibility")
	AddGadgetItem(1, -1, "AllOut")
	AddGadgetItem(1, -1, "Arrow")
	AddGadgetItem(1, -1, "Bento")
	AddGadgetItem(1, -1, "Camera")
	AddGadgetItem(1, -1, "Chevron")
	AddGadgetItem(1, -1, "Cube")
	AddGadgetItem(1, -1, "Folder")
	AddGadgetItem(1, -1, "Folder Open")
	AddGadgetItem(1, -1, "Image")
	AddGadgetItem(1, -1, "Minus")
	AddGadgetItem(1, -1, "Music")
	AddGadgetItem(1, -1, "Pause")
	AddGadgetItem(1, -1, "Person")
	AddGadgetItem(1, -1, "Pen")
	AddGadgetItem(1, -1, "Play")
	AddGadgetItem(1, -1, "Plus")
	AddGadgetItem(1, -1, "Skip")
	AddGadgetItem(1, -1, "Video")
 	SetGadgetState(1, 9)
	
	Update()
	
	BindGadgetEvent(1,@Update(), #PB_EventType_Change)
	BindEvent(#PB_Event_CloseWindow, @Close())
	
	Repeat
		WaitWindowEvent()
	ForEver
CompilerEndIf


























; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 119
; FirstLine = 60
; Folding = rAAIY+
; EnableXP