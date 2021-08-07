CompilerIf Not Defined(MaterialVector, #PB_Module)
	IncludeFile "MaterialVector\MaterialVector.pbi"
CompilerEndIf

CompilerIf Not Defined(CanvasButton, #PB_Module)
	IncludeFile "CanvasButton\CanvasButton.pbi"
CompilerEndIf

CompilerIf Not Defined(TextBox, #PB_Module)
	IncludeFile "Textbox\Textbox.pbi"
CompilerEndIf

CompilerIf Not Defined(ScrollBar, #PB_Module)
	IncludeFile "MaterialScrollBar\ScrollBar.pbi"
CompilerEndIf

CompilerIf Not Defined(SortLinkedList, #PB_Module) ; Couldn't figure how to sort the selected lists with the built in structured list sort, so I'll use this one : https://www.purebasic.fr/english/viewtopic.php?f=12&t=72352 
	DeclareModule SortLinkedList
		
		; v 1.10  March 2, 2019
		
		; Procedure Compare(*p1, *p2)
		; <0 The element pointed to by *p1 goes before the element pointed to by *p2
		;  0 The element pointed to by *p1 is equivalent to the element pointed to by *p2
		; >0 The element pointed to by *p1 goes after the element pointed to by *p2
		
		Declare _SortLinkedList_ (*LinkedList, *Compare, First=0, Last=-1)
		
		Declare SortLinkedListD (List LinkedList.d(), *Compare, First=0, Last=-1)
		Declare SortLinkedListI (List LinkedList.i(), *Compare, First=0, Last=-1)
		Declare SortLinkedListS (List LinkedList.s(), *Compare, First=0, Last=-1)
		
	EndDeclareModule
	
	Module SortLinkedList
		DisableDebugger
		EnableExplicit
		
		;- >> Structures <<
		
		Structure PB_ListHeader
			*Next.PB_ListHeader
			*Previous.PB_ListHeader
			Element.i[0]
		EndStructure
		
		Structure PB_List
			*First.PB_ListHeader
			*Last.PB_ListHeader
			*Current.PB_ListHeader
			*PtrCurrentVariable.Integer
			NBElements.i
			Index.i
			*StructureMap
			*Allocator
			*PositionStack
			*Object
			ElementSize.i
			ElementType.l
			IsIndexInvalid.b
			IsDynamic.b
			IsDynamicObject.b
		EndStructure
		
		;- >> Prototypes <<   
		
		Prototype.i ProtoCompare (*p1, *p2)
		Prototype Proto_SortLinkedListD (List LinkedList.d(), *Compare, First=0, Last=-1)
		Prototype Proto_SortLinkedListI (List LinkedList.i(), *Compare, First=0, Last=-1)
		Prototype Proto_SortLinkedListS (List LinkedList.s(), *Compare, First=0, Last=-1)
		
		;- >> Procedures << 
		
		Procedure _SortLinkedList_ (*LinkedList.PB_List, *Compare.ProtoCompare, First=0, Last=-1)
			Protected Dim *ListHead(31)
			Protected Dim *ListTail(31)
			Protected.PB_ListHeader *EqualItems, *List, *List1, *List2, *Next, *P, *Stop, *Tail, *Tail1, *Tail2
			Protected.i Count, Direction, Fractional, FractionalCount, i, ListSize0, NumItems, NumLists
			
			; Check parameters and return if there is nothing to sort
			If *LinkedList And *Compare And *LinkedList\NBElements
				If First < 0 : First = 0 : EndIf
				If Last < 0 Or Last >= *LinkedList\NBElements
					Last = *LinkedList\NBElements - 1
				EndIf
				NumItems = Last - First + 1
				If NumItems <= 1
					ProcedureReturn
				EndIf     
			Else
				ProcedureReturn
			EndIf
			
			; Invalidate the current index value
			*LinkedList\IsIndexInvalid = #True
			
			; Seek the first element to sort
			If First << 1 < *LinkedList\NBElements
				; Seek element starting from beginning
				i = First
				*List = *LinkedList\First
				While i
					*List = *List\Next
					i - 1
				Wend 
			Else
				; Seek element starting from end
				i = *LinkedList\NBElements - 1 - First
				*List = *LinkedList\Last
				While i
					*List = *List\Previous
					i - 1
				Wend
			EndIf
			
			; Store pointer to previous element
			*P = *List\Previous
			
			; Calculate the initial list size so that
			; the number of lists is a power of two
			ListSize0 = NumItems >> 3
			For i = 0 To 5
				ListSize0 | ListSize0 >> (1 << i)
			Next
			NumLists = ListSize0 + 1
			ListSize0 = NumItems / NumLists
			Fractional = NumItems - NumLists * ListSize0
			
			;- >> Sort <<
			While NumItems
				
				;- >> Build list using insertion sort <<
				*Next = *List\Next
				*Tail = *List
				*List\Next = #Null
				*List\Previous = #Null
				*List1 = *List
				*EqualItems = #Null
				Direction = 0
				
				Count = ListSize0
				FractionalCount + Fractional
				If FractionalCount >= NumLists
					FractionalCount - NumLists
					Count + 1
				EndIf
				NumItems - Count
				
				While Count > 1
					*List2 = *Next
					*Next = *List2\Next
					
					; Compare against previous insertion point
					i = *Compare(@*List1\Element, @*List2\Element)
					If i = 0
						; No search; insert directly after previous insertion point
						If *EqualItems = #Null
							*EqualItems = *List1
						EndIf   
						*Stop = *List1
					Else
						If i > 0
							; Search back from previous insertion point
							If *EqualItems
								*List1 = *EqualItems
							EndIf
							*Stop = #Null
							*List1 = *List1\Previous
							If Direction And Direction <> -1
								Direction = -2
							Else
								Direction = -1
							EndIf           
						Else
							; Search back from tail
							*Stop = *List1
							*List1 = *Tail
							If Direction And Direction <> 1
								Direction = -2
							Else
								Direction = 1
							EndIf
						EndIf
						*EqualItems = #Null
					EndIf
					; Backward search
					While *List1 <> *Stop And *Compare(@*List1\Element, @*List2\Element) > 0
						*List1 = *List1\Previous
					Wend
					; Insert
					If *List1
						; Insert *List2 after *List1
						*List2\Next = *List1\Next
						*List2\Previous = *List1
						If *List2\Next
							*List2\Next\Previous = *List2
						Else
							*Tail = *List2
						EndIf
						*List1\Next = *List2             
					Else
						; Insert *List2 before *List
						*List2\Next = *List
						*List2\Previous = #Null
						*List\Previous = *List2
						*List = *List2
					EndIf
					*List1 = *List2
					
					Count - 1
				Wend
				
				; Merge with other list(s)
				For i = 0 To 31
					If *ListHead(i)
						If *List
							*List1 = *ListHead(i)
							*Tail1 = *ListTail(i)
							*List2 = *List
							*Tail2 = *Tail
							
							;- >> Merge List1 and List2 <<
							
							If Direction = -1 And *Compare(@*List1\Element, @*Tail2\Element) > 0
								; Entire List1 goes after List2
								*Tail2\Next = *List1
								*List1\Previous = *Tail2
								*List = *List2
								*Tail = *Tail1
							ElseIf Direction >= 0 And *Compare(@*Tail1\Element, @*List2\Element) <= 0
								; Entire List2 goes after List1
								*Tail1\Next = *List2
								*List2\Previous = *Tail1
								*List = *List1
								*Tail = *Tail2
							Else
								Direction = -2
								; Merge List1 and List2 element by element
								
								If *Compare(@*List1\Element, @*List2\Element) <= 0
									*List = *List1
									*List1 = *List1\Next
								Else
									*List = *List2
									*List2 = *List2\Next
								EndIf
								*Tail = *List
								
								While *List1 And *List2
									If *Compare(@*List1\Element, @*List2\Element) <= 0
										*Tail\Next = *List1
										*List1\Previous = *Tail
										*Tail = *List1
										*List1 = *List1\Next
									Else
										*Tail\Next = *List2
										*List2\Previous = *Tail
										*Tail = *List2
										*List2 = *List2\Next
									EndIf
								Wend
								
								If *List1
									*Tail\Next = *List1
									*List1\Previous = *Tail
									*Tail = *Tail1
								ElseIf *List2
									*Tail\Next = *List2
									*List2\Previous = *Tail
									*Tail = *Tail2
								EndIf
								
							EndIf
							
							;- >> End of merge <<
							
						Else
							*List = *ListHead(i)
							*Tail = *ListTail(i)
						EndIf
						*ListHead(i) = #Null
					ElseIf NumItems
						Break
					EndIf
				Next
				
				If NumItems
					If i > 31 : i = 31 : EndIf
					*ListHead(i) = *List
					*ListTail(i) = *Tail
					*List = *Next
				EndIf
				
			Wend
			
			; Update *First and *Last when needed
			If First = 0
				*LinkedList\First = *List
			Else
				*P\Next = *List
				*List\Previous = *P
			EndIf
			If Last = *LinkedList\NBElements - 1
				*LinkedList\Last = *Tail
			Else
				*Tail\Next = *Next
				*Next\Previous = *Tail
			EndIf
			
		EndProcedure 
		
		Procedure SortLinkedListD (List LinkedList.d(), *Compare, First=0, Last=-1)
			Protected SortLinkedList.Proto_SortLinkedListD = @_SortLinkedList_()
			SortLinkedList(LinkedList(), *Compare, First, Last)
		EndProcedure
		
		Procedure SortLinkedListI (List LinkedList.i(), *Compare, First=0, Last=-1)
			Protected SortLinkedList.Proto_SortLinkedListI = @_SortLinkedList_()
			SortLinkedList(LinkedList(), *Compare, First, Last)
		EndProcedure
		
		Procedure SortLinkedListS (List LinkedList.s(), *Compare, First=0, Last=-1)
			Protected SortLinkedList.Proto_SortLinkedListS = @_SortLinkedList_()
			SortLinkedList(LinkedList(), *Compare, First, Last)
		EndProcedure
		
	EndModule
CompilerEndIf

CompilerIf Not Defined(GadgetTimer, #PB_Module)
	IncludeFile "GadgetTimer\GadgetTimer.pbi"
CompilerEndIf

CompilerIf Not Defined(TaskList, #PB_Module)
	IncludeFile "TaskList\TaskList.pbi"
CompilerEndIf

DeclareModule PureTL
	; Public variables, structures, constants...
	EnumerationBinary ;Gadget Flags
		#Default = 0
	EndEnumeration
	
	Enumeration ; Line Flags
		#Line_Asset = 0
		#Line_Folder
		#Line_Data
	EndEnumeration
	
	Enumeration ; Media block flags
		#MB_Default = 0
		#MB_FixedSize
		#MB_FreeSize
	EndEnumeration
	
	Enumeration #PB_EventType_FirstCustomValue
		#EventType_AssetUse
		#EventType_AssetUnUse
		#EventType_PlayerMove
		#EventType_Change
		#EventType_Edit
	EndEnumeration
	
	Structure DataPoint
		X.d
		Y.d
		Z.d
		Width.d
		Height.d
		Depth.d
		
		*Data0
		*Data1
		*Data2
		*Data3
		*Data4
	EndStructure
	
	; Public procedures declaration
	Declare Gadget(Gadget, X, Y, Width, Height, Flags = #Default)
	Declare Free(Gadget)
	Declare Resize(Gadget, X, Y, Width, Height)
	Declare ResizeEX(Gadget, X, Y, Width, Height)
	Declare AssessDrop(Gadget, State, ObjectType, X, Y)
	Declare UpdateCurrentAssetList(Gadget) ; create a list of all the assets used at the current frame ordered by depth, it's the simplest solution I found given the limited commuication with the renderer
	
	; State
	Declare GetActiveLine(Gadget)
	Declare SetActiveLine(Gadget, LineID)
	Declare Freeze(Gadget, State)
	Declare SetTaskList(Gadget, TaskList)
	Declare GetPlayerPosition(Gadget)
	Declare.s GetAsset(Gadget, Line)
	Declare GetEditedLine(Gadget)
	Declare.s GetMediaBlockState(Gadget, Line)
	
	; Line stuff
	Declare AddLine(Gadget, Position, Text.s, Parent = 0, Flags = #Line_Asset)
	Declare RemoveLine(Gadget, *Line)
	
	Declare GetLineID(Gadget, Position, Parent = 0)
	Declare GetLineText(Gadget, LineID)
	
	Declare SetLineText(Gadget, LineID, Text.s)
	Declare CountLine(Gadget)
	
	; Media block
	Declare AddMediaBlock(Gadget, LineID, Position, Duration, Icon.s, Text.s, Color, AssetUUID.s, DefaultState.s)
	Declare DeleteMediaBlock(Gadget, MediaBlockID)
	Declare MoveMediaBlock(Gadget, MediaBlockID, Offset)
	Declare.s DeleteMediaBlockByAsset(Gadget, AssetUUID.s)
	Declare ResizeMediaBlock(Gadget, *MediaBlock, NewStart, NewEnd)
	Declare UpdateMediaBlockState(Gadget, Line, Json.s)
	
	; Data point
	
	
	; Misc
	Declare Handler_UndoRedo(*Task, Redo)
	
	; Macro
	Macro PassKeyboardInput(gadget)
		If EventType() = #PB_EventType_KeyDown
			Select GetGadgetAttribute(gadget, #PB_Canvas_Key)
				Case #PB_Shortcut_Z
					If GetGadgetAttribute(gadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
						SendMessage_(WindowID(0), #WM_KEYDOWN, 90, 0)
					EndIf
				Case #PB_Shortcut_Y
					If GetGadgetAttribute(gadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
						SendMessage_(WindowID(0), #WM_KEYDOWN, 89, 0)
					EndIf
			EndSelect
		EndIf
	EndMacro
	
EndDeclareModule

Module PureTL
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
		Macro SetAlpha(Alpha, Color)
			Alpha << 24 + Color
		EndMacro
	CompilerElse
		Macro SetAlpha(Alpha, Color) ; You might want to check that...
			Color << 8 + Alpha
		EndMacro
	CompilerEndIf
	;}
	
	;{ Private variables, structures, constants...
	Enumeration ; State
		#Cold
		#Warm
		#Hot
		
		#Draged
	EndEnumeration
	
	Enumeration ;Fold
		#NoFold
		#Folded
		#Unfolded
	EndEnumeration
	
	Enumeration ;User Action
		#Action_Hover = 0
		#Action_List_InitDrag
		#Action_List_Drag
		#Action_List_Rename
		#Action_List_HoverFold
		
		#Action_Body_InitDrag
		#Action_Body_Drag
		#Action_Body_Resize
		
		#Action_Player_Drag
	EndEnumeration
	
	;Tasks
	#CreateLine = "CreateLine"
	#DeleteLine = "DeleteLine"
	#MoveLine = "MoveLine"
	#RenameLine = "RenameLine"
	#CreateMediaBlock = "CreateMediaBlock"
	#DeleteMediaBlock = "DeleteMediaBlock"
	#MoveMediaBlock = "MoveMediaBlock"
	#ResizeMediaBlock = "ResizeMediaBlock"
	
	Structure MediaBlock
		Type.i
		UUID.s
		
		Array *DataPoints.DataPoint(1)
	EndStructure
	
	Structure Line
		Type.i	; MUST STAY IN FIRST POSITION!
		Name.s
		UUID.s
		State.b
		
		HorizontalOffset.i
		
		*Parent.Line
		
		List *Childrens.Line()
		
		*DisplayListAdress
		*ParentListAdress
		
		Array *MediaBlocks.MediaBlock(1)
	EndStructure
	
	Structure GadgetData
		; Components
		Comp_Container.i
		Comp_Body.i
		Comp_List.i
		Comp_VScrollBar.i
		Comp_HScrollBar.i
		Comp_Rename.i
		
		Comp_Button_AddFolder.i
		Comp_Button_AddLine.i
		Comp_Button_Remove.i
		Comp_Button_Up.i
		Comp_Button_Down.i
		
		; Measurement
		Meas_List_Height.i
		Meas_List_Width.i
		
		Meas_Body_Width.i
		
		Meas_Displayed_Line_Count.i
		Meas_Displayed_Column_Count.i
		
		Meas_TL_ColumnWidth.i
		Meas_TL_LineHeight.i
		Meas_TL_TextVericalOffset.i
		Meas_TL_TextHorizontaOffset.i
		
		Meas_VPosition.i
		Meas_HPosition.i
		
		Meas_Height.i
		Meas_Width.i
		
		; Colors
		Color_List_Back_Alternate.l[3]
		Color_List_Back.l[3]
		Color_List_Front.l[3]
		Color_General_Line.l
		
		Color_Primary_Back.l[3]
		Color_Primary_Front.l[3]
		
		Color_Danger_Back.l[3]
		Color_Danger_Front.l[3]
		
		Color_MediaBlock_Back.l[3]
		Color_MediaBlock_Front.l[3]
		
		; State
		*State_SelectedLine.Line
		State_TaskList.i
		
		State_Drag_X.i
		State_Drag_Y.i
		
		State_List.i
		State_List_Item.i
		
		State_Action.i
		
		; Content
		List *Cont_Line_List.Line()
		List *Cont_Displayed_List.Line()
		Cont_Displayed_List_Size.i
		
		Map Cont_Lines.Line(2048)
		Map Cont_MediaBlocks.MediaBlock(2048)
	EndStructure
	
	Structure Task
		XML.s
	EndStructure
	
	Global DragWindow
	
	;{ Default Setting
	#Default_Duration = 300
	#Size_DragInit_Distance = 15
	;}
	
	;{ Style
	
	; Size
	#Size_TL_DefaultLineHeight = 58
	#Size_TL_DefaultColumnWidth = 6
	#Size_TL_MaxColumnWidth = 15
	#Size_TL_MinColumnWidth = 1
	
	#Size_List_MinimumWidth = 230
	#Size_List_Text_VerticalOffset = (#Size_TL_DefaultLineHeight - 16) / 2
	#Size_List_Text_HorizontalOffset = 30
	#Size_List_Icon_VerticalMargin = (#Size_TL_DefaultLineHeight - 20) / 2
	#Size_List_Icon_Offset = 34
	#Size_SubItemOffset = 11 + #Size_List_Icon_Offset
	
	#Size_Header_Height = 60
	#Size_Header_ButtonSize = 40
	#Size_Header_VerticalMargin = (#Size_Header_Height - #Size_Header_ButtonSize) / 2
	
	#Size_Line_Thick = 2
	#Size_Line_Thin = 1
	
	#Size_Scrollbar_Thickness = 12
	
	#Size_MediaBlock_Height = 44
	#Size_MediaBlock_VerticalMargin = (#Size_TL_DefaultLineHeight - #Size_MediaBlock_Height) / 2
	
	#Size_Player_Width = 1
	#Size_Player_TopHeight = 24
	#Size_Player_TopWidth = 18
	#Size_Player_TopOffset = (#Size_Player_TopWidth - #Size_Player_Width) / 2
	#Size_Player_TopSquare = #Size_Player_TopHeight - #Size_Player_TopOffset - 1
	
	#Size_RoundedCorner = 4
	
	; Colors
	#Colors_List_Back_Alternate_Cold = $232941
	#Colors_List_Back_Alternate_Warm = $2D3A5E
	#Colors_List_Back_Alternate_Hot = $334571
	
	#Colors_List_Back_Cold = $272E48     
	#Colors_List_Back_Warm = $2D3A5E
	#Colors_List_Back_Hot = $334571
	
	#Colors_List_Front_Cold = $8A99B5
	#Colors_List_Front_Warm = $8A99B5
	#Colors_List_Front_Hot = $8A99B5
	
	#Color_Primary_Back_Cold = $272E48
	#Color_Primary_Back_Warm = $719DF0
	#Color_Primary_Back_Hot  = $437DEC
	
	#Color_Primary_Front_Cold = $5A8DEE
	#Color_Primary_Front_Warm = $FFFFFF
	#Color_Primary_Front_Hot  = $FFFFFF
	
	#Color_Danger_Back_Cold = $272E48
	#Color_Danger_Back_Warm = $FF7575
	#Color_Danger_Back_Hot  = $FF4243
	
	#Color_Danger_Front_Cold = $FF5B5C
	#Color_Danger_Front_Warm = $FFFFFF
	#Color_Danger_Front_Hot  = $FFFFFF
	
	#Color_Scrollbar_Back = $212639
	#Color_Scrollbar_FrontCold = $787B86
	#Color_Scrollbar_FrontWarm = $656873
	#Color_Scrollbar_FrontHot = $434651
	
	#Color_MediaBlock_Back_Cold = $353D52
	#Color_MediaBlock_Back_Warm = $3F475B
	#Color_MediaBlock_Back_Hot = $495063
	
	#Color_MediaBlock_Front_Cold = $8A99B5
	#Color_MediaBlock_Front_Warm = $8A99B5
	#Color_MediaBlock_Front_Hot = $BDD1F8
	
	#Colors_General_Line = $1A233A
	
	; Fonts
	Global FontBold = FontID(LoadFont(#PB_Any, "Rubik Medium", 12, #PB_Font_HighQuality))
	Global Font = FontID(LoadFont(#PB_Any, "Rubik", 12, #PB_Font_HighQuality))
	Global FontTest = FontID(LoadFont(#PB_Any, "Karla", 11, #PB_Font_HighQuality))
	
	Global IconSolid = FontID(LoadFont(#PB_Any, "Font Awesome 5 Pro Solid", 16, #PB_Font_HighQuality))
	Global Icon = FontID(LoadFont(#PB_Any, "Font Awesome 5 Pro Regular", 16, #PB_Font_HighQuality))
	Global MaterialIcon = FontID(LoadFont(#PB_Any, "Material Design Icons Desktop", 16, #PB_Font_HighQuality))
	
	; FontAwesome shortcut
	#FontAwesome_Folder_Open = ""
	#FontAwesome_Folder = ""
	#FontAwesome_Chevron_Right = ""
	#FontAwesome_Chevron_Down = ""
	
	; Misc
	
	;}
	
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
	Global CornerDR = ROTATE_90(CornerUR)
	Global CornerDL = CreateImage(#PB_Any, #Size_RoundedCorner, #Size_RoundedCorner)
	StartDrawing(ImageOutput(CornerDL))
	Box(0, 0, #Size_RoundedCorner, #Size_RoundedCorner, SetAlpha($FF, FixColor(#Colors_List_Back_Cold)))
	DrawAlphaImage(ImageID(CornerUL), 0, 0)
	StopDrawing()
	FreeImage(CornerUL) 
	CornerUL = CornerDL
	CornerDL = ROTATE_90(CornerDR)
	
	CornerUR = ImageID(CornerUR)
	CornerDR = ImageID(CornerDR)
	CornerDL = ImageID(CornerDL)
	;}
	;}
	
	;{ Private procedures declaration
	; Non specific
	Declare Min(a, b)
	Declare Max(a, b)
	Declare.s UUID()
	
	; Line stuff
	Declare _AddLine(*GadgetData.GadgetData, XMLNode)
	Declare _RemoveLine(*GadgetData.GadgetData, XMLNode)
	Declare _Display_InsertLine(*GadgetData.GadgetData, *Line.Line, Position, *Parent.Line)
	Declare _Display_RemoveLine(*GadgetData.GadgetData, *Line.line)
	Declare _Display_GetLinePosition(*GadgetData.GadgetData, *Line.Line)
	
	; Handler
	Declare Handler_Body()
	Declare Handler_List()
	Declare Handler_Button_AddFolder()
	Declare Handler_Button_AddLine()
	Declare Handler_Button_RemoveLine()
	Declare Handler_Button_Up()
	Declare Handler_Button_Down()
	Declare Handler_HScrollBar()
	Declare Handler_VScrollBar()
	Declare Handler_UndoRedo(*Task.Task, Redo)
	
	; Redraw
	Declare Redraw(*GadgetData.GadgetData)
	Declare Redraw_MediaBlock(*GadgetData.GadgetData, yPos, *Block.MediaBlock)
	
	; Misc
	Declare Refit(Gadget, GadgetWidth, GadgetHeight)
	Declare ToggleFold(Gadget)
	Declare VerticalFocus(*GadgetData.GadgetData)
	Declare HorizontalFocus(*GadgetData.GadgetData)
	Declare _UpdateCurrentAssetList(*GadgetData.GadgetData, *Line.Line)
	Declare.s SerializeDataPoint(*DataPoint.DataPoint)
	Declare UnserializeDataPoint(*DataPoint.DataPoint, JsonString.s)
	;}
	
	;{ Public procedures
	;{ Misc
	Procedure Gadget(Gadget, X, Y, Width, Height, Flags = #Default)
		Protected Result = ContainerGadget(Gadget, X, Y, Width, Height, #PB_Container_BorderLess), *GadgetData.GadgetData
		Protected CanvasList = CanvasGadget(#PB_Any, 0, #Size_Header_Height, #Size_List_MinimumWidth, Height - #Size_Header_Height, #PB_Canvas_Keyboard)
		Protected CanvasBody = CanvasGadget(#PB_Any, #Size_List_MinimumWidth - 1, 0, Width - #Size_List_MinimumWidth, Height, #PB_Canvas_Container | #PB_Canvas_Keyboard)
		Protected Margin, ImageGadget
		
		If Result
			If Gadget = #PB_Any
				Gadget = Result
			EndIf
			
			*GadgetData = AllocateStructure(GadgetData)
			With *GadgetData
				EnableGadgetDrop(CanvasBody, #PB_Drop_Private, #PB_Drag_Link, 1)
				
				;Measurement
				\Meas_List_Width = #Size_List_MinimumWidth - 1
				\Meas_TL_ColumnWidth = #Size_TL_DefaultColumnWidth
				\Meas_TL_LineHeight = #Size_TL_DefaultLineHeight
				\Meas_Width = Width
				\Meas_Height = Height
				\Meas_TL_TextVericalOffset = #Size_List_Text_VerticalOffset
				\Meas_TL_TextHorizontaOffset = #Size_List_Text_HorizontalOffset
				
				;Colors
				\Color_List_Back_Alternate[#Cold] = FixColor(#Colors_List_Back_Alternate_Cold)
				\Color_List_Back_Alternate[#Warm] = FixColor(#Colors_List_Back_Alternate_Warm)
				\Color_List_Back_Alternate[#Hot] = FixColor(#Colors_List_Back_Alternate_Hot)
				 
				\Color_List_Back[#Cold] = FixColor(#Colors_List_Back_Cold)
				\Color_List_Back[#Warm] = FixColor(#Colors_List_Back_Warm)
				\Color_List_Back[#Hot] = FixColor(#Colors_List_Back_Hot)
				
				\Color_List_Front[#Cold] = FixColor(#Colors_List_Front_Cold)
				\Color_List_Front[#Warm] = FixColor(#Colors_List_Front_Warm)
				\Color_List_Front[#Hot] =  FixColor(#Colors_List_Front_Hot)
				
				\Color_General_Line = FixColor(#Colors_General_Line)
				
				\Color_Primary_Back[#Cold] = FixColor(#Color_Primary_Back_Cold)
				\Color_Primary_Back[#Warm] = FixColor(#Color_Primary_Back_Warm)
				\Color_Primary_Back[#Hot] =  FixColor(#Color_Primary_Back_Hot)
				
				\Color_Primary_Front[#Cold] = FixColor(#Color_Primary_Front_Cold)
				\Color_Primary_Front[#Warm] = FixColor(#Color_Primary_Front_Warm)
				\Color_Primary_Front[#Hot] =  FixColor(#Color_Primary_Front_Hot)
				
				\Color_Danger_Back[#Cold] = FixColor(#Color_Danger_Back_Cold)
				\Color_Danger_Back[#Warm] = FixColor(#Color_Danger_Back_Warm)
				\Color_Danger_Back[#Hot] =  FixColor(#Color_Danger_Back_Hot)
				
				\Color_Danger_Front[#Cold] = FixColor(#Color_Danger_Front_Cold)
				\Color_Danger_Front[#Warm] = FixColor(#Color_Danger_Front_Warm)
				\Color_Danger_Front[#Hot] =  FixColor(#Color_Danger_Front_Hot)
				
				\Color_MediaBlock_Back[#Cold] =  FixColor(#Color_MediaBlock_Back_Cold)
				\Color_MediaBlock_Back[#Warm] =  FixColor(#Color_MediaBlock_Back_Warm)
				\Color_MediaBlock_Back[#Hot] =   FixColor(#Color_MediaBlock_Back_Hot)
				                                       
				\Color_MediaBlock_Front[#Cold] = FixColor(#Color_MediaBlock_Front_Cold)
				\Color_MediaBlock_Front[#Warm] = FixColor(#Color_MediaBlock_Front_Warm)
				\Color_MediaBlock_Front[#Hot] =  FixColor(#Color_MediaBlock_Front_Hot)
				
				;Components
				SetGadgetColor(\Comp_Container, #PB_Gadget_BackColor, \Color_Primary_Back[#Cold])
				
				\Comp_Body = CanvasBody
				\Comp_List = CanvasList
				CloseGadgetList()
				
				ImageGadget = ImageGadget(#PB_Any, 0, 0, 4, 4, ImageID(CornerUL))
				
				Margin = ((\Meas_List_Width - 5 * #Size_Header_ButtonSize + 4)) / 2
				
				\Comp_Button_AddFolder = CanvasButton::Gadget(#PB_Any, Margin, #Size_Header_VerticalMargin, #Size_Header_ButtonSize, #Size_Header_ButtonSize, "", MaterialVector::#Folder, CanvasButton::#MaterialVector | MaterialVector::#Style_Outline | CanvasButton::#Rounded_Left | CanvasButton::#Outline)
				SetGadgetColor(\Comp_Button_AddFolder, CanvasButton::#BackColor_Cold, SetAlpha($FF ,\Color_Primary_Back[#Cold]))
				SetGadgetColor(\Comp_Button_AddFolder, CanvasButton::#BackColor_Warm, SetAlpha($FF ,\Color_Primary_Back[#Warm]))
				SetGadgetColor(\Comp_Button_AddFolder, CanvasButton::#BackColor_Hot, SetAlpha($FF ,\Color_Primary_Back[#Hot]))
				
				SetGadgetColor(\Comp_Button_AddFolder, CanvasButton::#FrontColor_Cold, SetAlpha($FF ,\Color_Primary_Front[#Cold]))
				SetGadgetColor(\Comp_Button_AddFolder, CanvasButton::#FrontColor_Warm, SetAlpha($FF ,\Color_Primary_Front[#Warm]))
				SetGadgetColor(\Comp_Button_AddFolder, CanvasButton::#FrontColor_Hot, SetAlpha($FF , \Color_Primary_Front[#Hot]))
				
				SetGadgetData(\Comp_Button_AddFolder, *GadgetData)
				BindGadgetEvent(\Comp_Button_AddFolder, @Handler_Button_AddFolder(), #PB_EventType_Change)
				
				\Comp_Button_AddLine = CanvasButton::Gadget(#PB_Any, Margin + #Size_Header_ButtonSize - 1, #Size_Header_VerticalMargin, #Size_Header_ButtonSize, #Size_Header_ButtonSize, "", MaterialVector::#Plus, CanvasButton::#MaterialVector | CanvasButton::#Outline)
				SetGadgetColor(\Comp_Button_AddLine, CanvasButton::#BackColor_Cold, SetAlpha($FF ,\Color_Primary_Back[#Cold]))
				SetGadgetColor(\Comp_Button_AddLine, CanvasButton::#BackColor_Warm, SetAlpha($FF ,\Color_Primary_Back[#Warm]))
				SetGadgetColor(\Comp_Button_AddLine, CanvasButton::#BackColor_Hot, SetAlpha($FF ,\Color_Primary_Back[#Hot]))
				
				SetGadgetColor(\Comp_Button_AddLine, CanvasButton::#FrontColor_Cold, SetAlpha($FF ,\Color_Primary_Front[#Cold]))
				SetGadgetColor(\Comp_Button_AddLine, CanvasButton::#FrontColor_Warm, SetAlpha($FF ,\Color_Primary_Front[#Warm]))
				SetGadgetColor(\Comp_Button_AddLine, CanvasButton::#FrontColor_Hot, SetAlpha($FF , \Color_Primary_Front[#Hot]))
				
				SetGadgetData(\Comp_Button_AddLine, *GadgetData)
				BindGadgetEvent(\Comp_Button_AddLine, @Handler_Button_AddLine(), #PB_EventType_Change)
				
				\Comp_Button_Remove = CanvasButton::Gadget(#PB_Any, Margin + #Size_Header_ButtonSize * 2 - 2, #Size_Header_VerticalMargin, #Size_Header_ButtonSize, #Size_Header_ButtonSize, "", MaterialVector::#Minus, CanvasButton::#MaterialVector | CanvasButton::#Outline)
				SetGadgetColor(\Comp_Button_Remove, CanvasButton::#BackColor_Cold, SetAlpha($FF ,\Color_Primary_Back[#Cold]))
				SetGadgetColor(\Comp_Button_Remove, CanvasButton::#BackColor_Warm, SetAlpha($FF ,\Color_Danger_Back[#Warm]))
				SetGadgetColor(\Comp_Button_Remove, CanvasButton::#BackColor_Hot, SetAlpha($FF ,\Color_Danger_Back[#Hot]))
				
				SetGadgetColor(\Comp_Button_Remove, CanvasButton::#FrontColor_Cold, SetAlpha($FF ,\Color_Primary_Front[#Cold]))
				SetGadgetColor(\Comp_Button_Remove, CanvasButton::#FrontColor_Warm, SetAlpha($FF ,\Color_Danger_Front[#Warm]))
				SetGadgetColor(\Comp_Button_Remove, CanvasButton::#FrontColor_Hot, SetAlpha($FF , \Color_Danger_Front[#Hot]))
				
				SetGadgetData(\Comp_Button_Remove, *GadgetData)
				BindGadgetEvent(\Comp_Button_Remove, @Handler_Button_RemoveLine(), #PB_EventType_Change)
				
				\Comp_Button_Up = CanvasButton::Gadget(#PB_Any, Margin + #Size_Header_ButtonSize * 3 - 3, #Size_Header_VerticalMargin, #Size_Header_ButtonSize, #Size_Header_ButtonSize, "", MaterialVector::#Chevron, CanvasButton::#MaterialVector | CanvasButton::#Outline)
				SetGadgetColor(\Comp_Button_Up, CanvasButton::#BackColor_Cold, SetAlpha($FF ,\Color_Primary_Back[#Cold]))
				SetGadgetColor(\Comp_Button_Up, CanvasButton::#BackColor_Warm, SetAlpha($FF ,\Color_Primary_Back[#Warm]))
				SetGadgetColor(\Comp_Button_Up, CanvasButton::#BackColor_Hot, SetAlpha($FF ,\Color_Primary_Back[#Hot]))
				
				SetGadgetColor(\Comp_Button_Up, CanvasButton::#FrontColor_Cold, SetAlpha($FF ,\Color_Primary_Front[#Cold]))
				SetGadgetColor(\Comp_Button_Up, CanvasButton::#FrontColor_Warm, SetAlpha($FF ,\Color_Primary_Front[#Warm]))
				SetGadgetColor(\Comp_Button_Up, CanvasButton::#FrontColor_Hot, SetAlpha($FF , \Color_Primary_Front[#Hot]))
				
				SetGadgetData(\Comp_Button_Up, *GadgetData)
				BindGadgetEvent(\Comp_Button_Up, @Handler_Button_Up(), #PB_EventType_Change)
				
				\Comp_Button_Down = CanvasButton::Gadget(#PB_Any, Margin + #Size_Header_ButtonSize * 4 - 4, #Size_Header_VerticalMargin, #Size_Header_ButtonSize, #Size_Header_ButtonSize, "", MaterialVector::#Chevron, CanvasButton::#MaterialVector| MaterialVector::#Style_rotate_180 | CanvasButton::#Rounded_Right | CanvasButton::#Outline)
				SetGadgetColor(\Comp_Button_Down, CanvasButton::#BackColor_Cold, SetAlpha($FF ,\Color_Primary_Back[#Cold]))
				SetGadgetColor(\Comp_Button_Down, CanvasButton::#BackColor_Warm, SetAlpha($FF ,\Color_Primary_Back[#Warm]))
				SetGadgetColor(\Comp_Button_Down, CanvasButton::#BackColor_Hot, SetAlpha($FF ,\Color_Primary_Back[#Hot]))
				
				SetGadgetColor(\Comp_Button_Down, CanvasButton::#FrontColor_Cold, SetAlpha($FF ,\Color_Primary_Front[#Cold]))
				SetGadgetColor(\Comp_Button_Down, CanvasButton::#FrontColor_Warm, SetAlpha($FF ,\Color_Primary_Front[#Warm]))
				SetGadgetColor(\Comp_Button_Down, CanvasButton::#FrontColor_Hot, SetAlpha($FF , \Color_Primary_Front[#Hot]))
				
				
				SetGadgetData(\Comp_Button_Down, *GadgetData)
				BindGadgetEvent(\Comp_Button_Down, @Handler_Button_Down(), #PB_EventType_Change)
				
				CloseGadgetList()
				
				SetGadgetData(Gadget, *GadgetData)
				
				Refit(*GadgetData\Comp_Container, Width, Height)
				Redraw(*GadgetData)
				
				SetGadgetData(\Comp_List, *GadgetData)
				BindGadgetEvent(\Comp_List, @Handler_List())
				
				DragWindow = OpenWindow(#PB_Any, 0, 0, \Meas_List_Width, \Meas_TL_LineHeight, "", #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(0))
				SetWindowData(DragWindow, CanvasGadget(#PB_Any, 0, 0, \Meas_List_Width, \Meas_TL_LineHeight))
				SetWindowLongPtr_(WindowID(DragWindow),#GWL_EXSTYLE,#WS_EX_LAYERED)
				SetLayeredWindowAttributes_(WindowID(DragWindow),0,140,#LWA_ALPHA)
			EndWith
		EndIf
		ProcedureReturn Result
	EndProcedure
	
	Procedure Free(Gadget)
	EndProcedure
	
	Procedure Resize(Gadget, X, Y, Width, Height)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		
		Refit(Gadget, Width, Height)
		
		With *GadgetData
			\Meas_Width = Width
			\Meas_Height = Height
			SetWindowPos_(GadgetID(\Comp_Container), 0, X, Y, Width, Height, #SWP_NOZORDER)
			
			SetWindowPos_(GadgetID(\Comp_List), 0, 0, 0, \Meas_List_Width, \Meas_List_Height, #SWP_NOMOVE | #SWP_NOZORDER | #SWP_NOREDRAW)
			SetWindowPos_(GadgetID(\Comp_Body), 0, 0, 0, \Meas_Body_Width, Height, #SWP_NOMOVE | #SWP_NOZORDER | #SWP_NOREDRAW)
			
			Redraw(*GadgetData)
		EndWith
		
	EndProcedure
	
	Procedure ResizeEX(Gadget, X, Y, Width, Height)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		
		With *GadgetData
			\Meas_Width = Width
			\Meas_Height = Height
			SendMessage_(GadgetID(\Comp_List), #WM_SETREDRAW, #False, 0)
			SendMessage_(GadgetID(\Comp_Body), #WM_SETREDRAW, #False, 0)
			Refit(Gadget, Width, Height)
			
			SetWindowPos_(GadgetID(\Comp_List), 0, 0, 0, \Meas_List_Width, \Meas_List_Height, #SWP_NOMOVE | #SWP_NOZORDER | #SWP_NOREDRAW)
			SetWindowPos_(GadgetID(\Comp_Body), 0, 0, 0, \Meas_Body_Width, Height, #SWP_NOMOVE | #SWP_NOZORDER | #SWP_NOREDRAW)
			
			Redraw(*GadgetData)
			SetWindowPos_(GadgetID(Gadget), 0, X, Y, Width, Height, #SWP_NOZORDER)
			SendMessage_(GadgetID(\Comp_List), #WM_SETREDRAW, #True, 0)
			SendMessage_(GadgetID(\Comp_Body), #WM_SETREDRAW, #True, 0)
			
			RedrawWindow_(GadgetID(\Comp_List), 0, 0, #RDW_INVALIDATE | #RDW_UPDATENOW | #RDW_ERASE)
			RedrawWindow_(GadgetID(\Comp_Body), 0, 0, #RDW_INVALIDATE | #RDW_UPDATENOW | #RDW_ERASE)
		EndWith
		
	EndProcedure
	
	Procedure AssessDrop(Gadget, State, ObjectType, X, Y)
	EndProcedure
	
	Procedure UpdateCurrentAssetList(Gadget)
	EndProcedure
	;}
	
	;{ State
	Procedure GetActiveLine(Gadget)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure SetActiveLine(Gadget, *Line.Line)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure Freeze(Gadget, State)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure SetTaskList(Gadget, TaskList)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		*GadgetData\State_TaskList = TaskList
	EndProcedure
	
	Procedure GetPlayerPosition(Gadget)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure.s GetAsset(Gadget, Line)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure.s GetMediaBlockState(Gadget, Line)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		
	EndProcedure
	
	Procedure GetEditedLine(Gadget)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	;}
	
	;{ Line stuff
	Procedure RemoveLine(Gadget, *Line.Line)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure AddLine(Gadget, Position, Text.s, *Parent.Line = 0, Flags = #Line_Asset)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget), UUID.s
		Protected *Task.Task = AllocateStructure(Task), XML = CreateXML(#PB_Any)
 		Protected MainNode = CreateXMLNode(RootXMLNode(XML), "Tasks") 
 		Protected XMLNode = CreateXMLNode(MainNode, #CreateLine)
		
		With *GadgetData
			UUID = UUID()
			
			While FindMapElement(\Cont_Lines(), UUID) ; Is this really needed? I don't know how random is PB RNG, but even if its reaaaaaally bad I think it would be safe without it. On the other hand, it's so small that I've left it just to be sure...
				UUID = UUID()
			Wend
			
			SetXMLAttribute(XMLNode, "Gadget", Str(Gadget))
			SetXMLAttribute(XMLNode, "Position", Str(Position))
			SetXMLAttribute(XMLNode, "UUID", UUID)
			
			If *Parent
				SetXMLAttribute(XMLNode, "Parent", *Parent\UUID)
			Else
				SetXMLAttribute(XMLNode, "Parent", "0")
			EndIf
			
			If Text = ""
				SetXMLAttribute(XMLNode, "Text", "New Line")
				_AddLine(*GadgetData, XMLNode)
				
			Else
				SetXMLAttribute(XMLNode, "Text", Text)
				_AddLine(*GadgetData, XMLNode)
				
				*Task\XML = ComposeXML(XML, #PB_XML_NoDeclaration)
				FreeXML(XML)
				TaskList::NewTask(*GadgetData\State_TaskList, *Task, @Handler_UndoRedo())
			EndIf
			
		EndWith
			
	EndProcedure
	
	Procedure MoveLine(Gadget, *Line.Line, Position)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget), *Element
		
		With *GadgetData
			If Position = \Cont_Displayed_List_Size - 1
				ChangeCurrentElement(\Cont_Displayed_List(), *Line\DisplayListAdress)
				MoveElement(\Cont_Displayed_List(), #PB_List_Last)
			Else
				If Position > _Display_GetLinePosition(*GadgetData, \State_SelectedLine)
					Position + 1
				EndIf
				*Element = SelectElement(\Cont_Displayed_List(), Position)
				ChangeCurrentElement(\Cont_Displayed_List(), *Line\DisplayListAdress)
				MoveElement(\Cont_Displayed_List(), #PB_List_Before, *Element)
			EndIf
		EndWith
	EndProcedure
	
	Procedure GetLineID(Gadget, Position, *Parent.Line = 0)
		Protected *GadgetData.GadgetData
	EndProcedure
	
	Procedure GetLineText(Gadget, *Line.Line)
	EndProcedure
	
	Procedure SetLineText(Gadget, *Line.Line, Text.s)
	EndProcedure
	
	Procedure CountLine(Gadget)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	;}
	
	;{ Media block
	Procedure AddMediaBlock(Gadget, *Line.Line, Position, Duration, Icon.s, Text.s, Color, AssetUUID.s, DefaultState.s)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure DeleteMediaBlock(Gadget, *MediaBlock.Mediablock)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure MoveMediaBlock(Gadget, *MediaBlock.Mediablock, Offset)
	EndProcedure
	
	Procedure ResizeMediaBlock(Gadget, *MediaBlock.Mediablock, NewStart, NewEnd)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure.s DeleteMediaBlockByAsset(Gadget, AssetUUID.s)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure UpdateMediaBlockState(Gadget, Line, Json.s)
		Protected Loop, *MediaBlock.Mediablock
	EndProcedure
	;}
	
	;}
	
	;{ Private procedures
	; Non specific
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
	
	; Line Stuff
	Procedure _AddLine(*GadgetData.GadgetData, XMLNode)
		Protected *NewLine.Line = AddMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(XMLNode, "UUID"))
		
		*NewLine\Parent = FindMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(XMLNode, "Parent"))
		*NewLine\Name = GetXMLAttribute(XMLNode, "Text")
		*NewLine\UUID = GetXMLAttribute(XMLNode, "UUID")
		*NewLine\Type = #Line_Asset
		
		_Display_InsertLine(*GadgetData, *NewLine, Val(GetXMLAttribute(XMLNode, "Position")), *NewLine\Parent)
		
	EndProcedure
	
	Procedure _RemoveLine(*GadgetData.GadgetData, XMLNode)
	EndProcedure
	
	Procedure _Display_InsertLine(*GadgetData.GadgetData, *Line.Line, Position, *Parent.Line)
		
		If *Parent
			
		Else
			If Position = -1 Or Position > *GadgetData\Cont_Displayed_List_Size
				LastElement(*GadgetData\Cont_Displayed_List())
				AddElement(*GadgetData\Cont_Displayed_List())
			Else
				SelectElement(*GadgetData\Cont_Displayed_List(), Position)
				InsertElement(*GadgetData\Cont_Displayed_List())
			EndIf
			
			*GadgetData\Cont_Displayed_List_Size + 1
			*GadgetData\Cont_Displayed_List() = *Line
			*Line\DisplayListAdress = @*GadgetData\Cont_Displayed_List()
			*Line\HorizontalOffset = *GadgetData\Meas_TL_TextHorizontaOffset
			Redraw(*GadgetData)
		EndIf
		
	EndProcedure
	
	Procedure _Display_RemoveLine(*GadgetData.GadgetData, *Line.line)
	EndProcedure
	 
	Procedure _Display_GetLinePosition(*GadgetData.GadgetData, *Line.Line) ; Returns the position of the line
		Protected Result = -1
		
		With *GadgetData
			If *Line
				ChangeCurrentElement(\Cont_Displayed_List(), *Line\DisplayListAdress)
				Result = ListIndex(\Cont_Displayed_List())
			EndIf
		EndWith
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure EditLine(*GadgetData.GadgetData, *Line.line, XML = 0)
		
	EndProcedure
	
	; Handler
	Procedure Handler_Body()
	EndProcedure
	
	Procedure Handler_List()
		Protected Gadget = EventGadget(), *GadgetData.GadgetData = GetGadgetData(Gadget), Y = GetGadgetAttribute(Gadget, #PB_Canvas_MouseY), Item
		
		With *GadgetData
			Select EventType()
				Case #PB_EventType_MouseMove ;{
					Select \State_List
						Case #Action_List_Drag
							
							ResizeWindow(DragWindow, GadgetX(\Comp_List, #PB_Gadget_ScreenCoordinate),Min(Max(GadgetY(\Comp_List, #PB_Gadget_ScreenCoordinate), DesktopMouseY() - \State_Drag_Y), GadgetY(\Comp_List, #PB_Gadget_ScreenCoordinate) + \Meas_List_Height - \Meas_TL_LineHeight), #PB_Ignore, #PB_Ignore)
							
							Item = Min(Round(Max(y- \State_Drag_Y, 0) / \Meas_TL_LineHeight + 0.49, #PB_Round_Down), \Cont_Displayed_List_Size - 1)
							If \State_List_Item <> Item
								\State_List_Item = Item
								Redraw(*GadgetData)
							EndIf
							
						Case #Action_List_InitDrag
							If Abs(\State_Drag_X - GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)) + Abs(\State_Drag_Y - Y) > #Size_DragInit_Distance
								\State_List = #Action_List_Drag
								\State_Action = #Action_List_Drag
								\State_SelectedLine\State = #Draged
								
								\State_Drag_X = GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)
								\State_Drag_Y = y % \Meas_TL_LineHeight
								
								ResizeWindow(DragWindow, GadgetX(\Comp_List, #PB_Gadget_ScreenCoordinate), DesktopMouseY() - \State_Drag_Y, \Meas_List_Width, \Meas_TL_LineHeight)
								ResizeGadget(GetWindowData(DragWindow), 0, 0, \Meas_List_Width, \Meas_TL_LineHeight)
								
								StartDrawing(CanvasOutput(GetWindowData(DragWindow)))
								Box(0, 0,  \Meas_List_Width, \Meas_TL_LineHeight, \Color_List_Back[#Hot])
								DrawingFont(FontBold)
								DrawingMode(#PB_2DDrawing_Transparent)
								FrontColor(\Color_List_Front[#Cold])
								DrawText(\State_SelectedLine\HorizontalOffset, \Meas_TL_TextVericalOffset,  \State_SelectedLine\Name)
								
								StopDrawing()
								Redraw(*GadgetData)
								HideWindow(DragWindow, #False)
							EndIf
						Default
							Item = Round(y / \Meas_TL_LineHeight, #PB_Round_Down)
							
							If Item + \Meas_VPosition >= \Cont_Displayed_List_Size
								\State_List_Item = -1
							Else
								\State_List_Item = Item
								
								; Check if it's hovering over a fold button (we need a fold button first...)
								
							EndIf
					EndSelect
					;}
				Case #PB_EventType_MouseLeave ;{
					Select \State_List
						Case #Action_List_HoverFold
							
						Case #Action_Hover
							\State_List_Item = -1
					EndSelect
					;}
				Case #PB_EventType_LeftButtonDown ;{
					If \State_List = #Action_Hover
						If \State_List_Item > -1
							If SelectElement(\Cont_Displayed_List(), \State_List_Item) And \State_SelectedLine <> \Cont_Displayed_List()
								If \State_SelectedLine 
									\State_SelectedLine\State = #Cold
								EndIf
								
								\State_SelectedLine = \Cont_Displayed_List()
								\State_SelectedLine\State = #Hot
								Redraw(*GadgetData)
							EndIf
							
							\state_list = #Action_List_InitDrag
							\State_Drag_X = GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)
							\State_Drag_Y = Y
							
						EndIf
					ElseIf \State_List = #Action_List_HoverFold
						
					EndIf
					;}
				Case #PB_EventType_LeftButtonUp ;{
					If \State_List = #Action_List_InitDrag
						\State_List = #Action_Hover
					ElseIf \State_List = #Action_List_Drag
						HideWindow(DragWindow, #True)
						
						MoveLine(Gadget, \State_SelectedLine, \State_List_Item)
						
						\State_List = #Action_Hover
						\State_Action = #Action_Hover
						\State_SelectedLine\State = #Hot
						
						Redraw(*GadgetData)
					EndIf
					;}
				Case #PB_EventType_LeftClick ;{
					;}
				Case #PB_EventType_LeftDoubleClick ;{
					;}
			EndSelect
		EndWith
	EndProcedure
	
	Procedure Handler_Button_AddFolder()
	EndProcedure
	
	Procedure Handler_Button_AddLine()
		Protected Gadget = EventGadget(), *GadgetData.GadgetData = GetGadgetData(Gadget)
		AddLine(Gadget, _Display_GetLinePosition(*GadgetData, *GadgetData\State_SelectedLine) + 1, "")
	EndProcedure
	
	Procedure Handler_Button_RemoveLine()
	EndProcedure
	
	Procedure Handler_Button_Up()
	EndProcedure
	
	Procedure Handler_Button_Down()
	EndProcedure
	
	Procedure Handler_VScrollBar()
	EndProcedure
	
	Procedure Handler_HScrollBar()
	EndProcedure
	
	Procedure HandlerRenameString(hWnd, uMsg, wParam, lParam)
	EndProcedure
	
	Procedure Handler_UndoRedo(*Task.Task, Redo)
	EndProcedure
	
	; Redraw
	Procedure Redraw(*GadgetData.GadgetData)
		Protected Loop, LoopEnd, BodyYPos, YPos, OddLine
		
		With *GadgetData
			StartDrawing(CanvasOutput(\Comp_List))
			StartVectorDrawing(CanvasVectorOutput(\Comp_Body))
			
			;{ Background color
			Box(0, 0, \Meas_List_Width, \Meas_List_Height, \Color_List_Back[#cold])
			DrawingFont(FontBold)
			DrawingMode(#PB_2DDrawing_Transparent)
			FrontColor(\Color_List_Front[#Cold])
			
			AddPathBox(0, 0, \Meas_Body_Width, VectorOutputHeight())
			VectorSourceColor(SetAlpha($FF, \Color_List_Back[#cold]))
			FillPath()
			;}
			
			;{ Header
			MovePathCursor(0, #Size_Header_Height - 0.5)
			AddPathLine(\Meas_Body_Width, 0, #PB_Path_Relative)
			VectorSourceColor(SetAlpha($FF, \Color_General_Line))
			StrokePath(#Size_Line_Thin)
			;}
			
			;{ Content
			If \Cont_Displayed_List_Size
				SelectElement(\Cont_Displayed_List(), \Meas_VPosition)
				LoopEnd = \Meas_VPosition + \Meas_Displayed_Line_Count
				OddLine = \Meas_VPosition % 2
				BodyYPos = #Size_Header_Height
				
				For Loop = \Meas_VPosition To \Meas_Displayed_Line_Count
					If \Cont_Displayed_List()\State = #Draged
						Loop - 1
					Else
						
						If \State_Action = #Action_List_Drag And Loop = \State_List_Item
							If Not OddLine
								AddPathBox(0, BodyYPos, \Meas_Body_Width, \Meas_TL_LineHeight)
								VectorSourceColor(SetAlpha($FF, \Color_List_Back_Alternate[\Cont_Displayed_List()\State]))
								FillPath()
							EndIf
							Loop + 1
							YPos + \Meas_TL_LineHeight
							BodyYPos + \Meas_TL_LineHeight
							OddLine = Bool(Not OddLine)
						EndIf
						
						; List
						If \Cont_Displayed_List()\State
							Box(0, YPos, \Meas_List_Width, \Meas_TL_LineHeight, \Color_List_Back[\Cont_Displayed_List()\State])
						EndIf
						DrawText(\Cont_Displayed_List()\HorizontalOffset, YPos + \Meas_TL_TextVericalOffset,  \Cont_Displayed_List()\Name)
						
						; Body
						If Not OddLine
							AddPathBox(0, BodyYPos, \Meas_Body_Width, \Meas_TL_LineHeight)
							VectorSourceColor(SetAlpha($FF, \Color_List_Back_Alternate[\Cont_Displayed_List()\State]))
							FillPath()
						ElseIf \Cont_Displayed_List()\State
							AddPathBox(0, BodyYPos, \Meas_Body_Width, \Meas_TL_LineHeight)
							VectorSourceColor(SetAlpha($FF, \Color_List_Back[\Cont_Displayed_List()\State]))
							FillPath()
						EndIf
						
						YPos + \Meas_TL_LineHeight
						BodyYPos + \Meas_TL_LineHeight
						OddLine = Bool(Not OddLine)
					EndIf
					
					If Not NextElement(\Cont_Displayed_List())
						If \State_Action = #Action_List_Drag And (Loop + 1) = \State_List_Item ; Draw the alternate color in the edgecase were a line is dragged to the very end of the line
							If Not OddLine
								AddPathBox(0, BodyYPos, \Meas_Body_Width, \Meas_TL_LineHeight)
								VectorSourceColor(SetAlpha($FF, \Color_List_Back_Alternate[#Cold]))
								FillPath()
							EndIf
						EndIf
						
						Break
					EndIf
					
				Next
				
				
				
			EndIf
			;}
			
			;{ Corner and finish
			Box(\Meas_List_Width - 1, 0, #Size_Line_Thin, \Meas_List_Height, \Color_General_Line)
			MovePathCursor(\Meas_Body_Width - #Size_RoundedCorner, 0)
			DrawVectorImage(CornerUR)
			MovePathCursor(\Meas_Body_Width - #Size_RoundedCorner, VectorOutputHeight() - #Size_RoundedCorner)
			DrawVectorImage(CornerDR)
			DrawAlphaImage(CornerDL, 0, \Meas_List_Height - #Size_RoundedCorner)
			StopDrawing()
			StopVectorDrawing()
			;}
		EndWith		
	EndProcedure
	
	Procedure Redraw_MediaBlock(*GadgetData.GadgetData, YPos, *Block.MediaBlock)
	EndProcedure
	
	; Misc
	Procedure Refit(Gadget, GadgetWidth, GadgetHeight)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		
		With *GadgetData
			GadgetHeight - #Size_Header_Height
			
			\Meas_List_Height = GadgetHeight
			
			\Meas_Body_Width = GadgetWidth - \Meas_List_Width
			
			\Meas_Displayed_Line_Count = Round(\Meas_List_Height / \Meas_TL_LineHeight, #PB_Round_Up) - 1
			
		EndWith
		
	EndProcedure
	
	Procedure RecurciveFold(*GadgetData.GadgetData, *Line.Line)
	EndProcedure
	
	Procedure RecurciveUnfold(*GadgetData.GadgetData, *Line.Line)
	EndProcedure
	
	Procedure ToggleFold(Gadget)
	EndProcedure
	
	Procedure VerticalFocus(*GadgetData.GadgetData)
	EndProcedure
	
	Procedure HorizontalFocus(*GadgetData.GadgetData)
	EndProcedure
	
	Procedure _UpdateCurrentAssetList(*GadgetData.GadgetData, *Line.Line)
	EndProcedure
	
	Procedure.s SerializeDataPoint(*DataPoint.DataPoint)
	EndProcedure
	
	Procedure UnserializeDataPoint(*DataPoint.DataPoint, JsonString.s)
	EndProcedure
	;}
	
	DataSection
		Corner:
		Data.q $0A1A0A0D474E5089,$524448490D000000,$0400000004000000,$9EF1A90000000608,$4144491F0000007E
		Data.q $FAB6529063017854,$D02612D88047C50F,$00640619200300C2,$340940C100048656,$00000000FE90996A
		Data.q $826042AE444E4549
	EndDataSection
	
EndModule













































; IDE Options = PureBasic 6.00 Alpha 3 (Windows - x64)
; CursorPosition = 1239
; FirstLine = 317
; Folding = AAqmhhSQCKCYAAAIA+
; EnableXP