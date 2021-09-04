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
		Transparency.d
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
	Declare AddMediaBlock(Gadget, LineID, Position, Duration, Type, Icon.s, Text.s, Color, AssetUUID.s, DefaultState.s)
	Declare DeleteMediaBlock(Gadget, MediaBlockID)
	Declare MoveMediaBlock(Gadget, *MediaBlock, *NewLine, NewPosition, ParentXMLNode = 0)
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
	
	Macro SetMenuAppearance(MenuName)
		FlatMenu::SetFont(*GadgetData\Comp_Menu_#MenuName, Font)
		FlatMenu::SetAttribute(*GadgetData\Comp_Menu_#MenuName, FlatMenu::#Attribute_BorderSize, 1)
		FlatMenu::SetColor(*GadgetData\Comp_Menu_#MenuName, FlatMenu::#ColorType_LineColor, FixColor($202020))
		FlatMenu::SetColor(*GadgetData\Comp_Menu_#MenuName, FlatMenu::#colorType_BackCold, FixColor(#Color_MediaBlock_Back_Warm))
		FlatMenu::SetColor(*GadgetData\Comp_Menu_#MenuName, FlatMenu::#colorType_BackHot, FixColor(#Color_MediaBlock_Back_Hot))
		FlatMenu::SetColor(*GadgetData\Comp_Menu_#MenuName, FlatMenu::#colorType_FrontCold, FixColor(#Color_MediaBlock_Front_Cold))
		FlatMenu::SetColor(*GadgetData\Comp_Menu_#MenuName, FlatMenu::#colorType_FrontHot, FixColor(#Color_MediaBlock_Front_Hot))
		FlatMenu::SetColor(*GadgetData\Comp_Menu_#MenuName, FlatMenu::#colorType_FrontDisabled, FixColor($909090))
		SetProp_(WindowID(*GadgetData\Comp_Menu_#MenuName), "gadget", *GadgetData\Comp_Body)
	EndMacro
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
		
		#Action_Drop
		
		#Action_Player_Drag
	EndEnumeration
	
	Enumeration
		#Asset_Type_Image = 1
		#Asset_Type_Video
		#Asset_Type_Sound
		#Asset_Type_Music
		#Asset_Type_Voice
		#Asset_Type_Character
		#Asset_Type_Model
		
		#__Asset_Type_Count
	EndEnumeration
	
	Enumeration ;Properties
		#Properties_Sub
		#Properties_X
		#Properties_Y
		#Properties_Z
		#Properties_Width
		#Properties_Height
		#Properties_Depth
		#Properties_Transparency
		#Properties_Count
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
		Color.i
		Icon.s
		Duration.i
		BlockStart.i
		BlockEnd.i
		State.b
		Drag.b
		Text.s
		*Line.Line
		*ListAdress
		Animated.i
		Container.b
		
		Array DataPoints.DataPoint(1)
		Array DataPointState.DataPoint(1)
		UsedData.DataPoint							; for the line to know which sub data to display.
	EndStructure
	
	Structure Line
		Type.i	; MUST STAY IN FIRST POSITION!
		Name.s
		UUID.s
		State.b
		FoldButtonState.b
		Fold.b
		SubLineCount.b
		HorizontalOffset.i
		
		*Parent.Line
		
		List *Childrens.Line()
		
		*DisplayListAdress
		*ParentListAdress
		
		List *MediaBlock.MediaBlock()
		
		Array UsedDataPoints.l(#Properties_Count)
	EndStructure
	
	Structure SubArray
		Array Column.i(1)
	EndStructure
	
	Structure LineIndex
		*Line.Line
		Sub.b
		Position.l
	EndStructure
	
	Structure MBAdress				; Dirty workaround for the structured list sorting procedures
		*Object.MediaBlock
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
		Comp_Menu_Image.i
		Comp_Menu_Audio.i
		
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
		State_TaskList.i
		State_Action.i
		
		State_Drag_X.i
		State_Drag_Y.i
		State_Drag_HOffset.i
		State_Drag_VOffset.i
		State_Drag_Line.i
		State_Drag_Folded.b
		
		*State_SelectedLine.Line
		*State_WarmLine.Line
		*State_WarmButton.Line
		*State_WarmMediaBlock.MediaBlock
		
		Array State_Collision_Line.SubArray(1)
		List State_LineIndex.LineIndex()
		
		*State_AssetDropLine
		*State_AssetDropMediaBlock.MediaBlock
		State_AssetDropPosition.i
		
		
		List *State_Selected_MediaBlocks.MediaBlock()
		
		; Content
		List *Cont_Displayed_List.Line()
		Cont_Displayed_List_Size.i
		Cont_Duration.i
		
		Map Cont_Lines.Line(2048)
		Map Cont_MediaBlocks.MediaBlock(2048)
	EndStructure
	
	Structure Task
		XML.s
	EndStructure
	
	Structure Property
		Text.s
		Size.w
	EndStructure
	
	Global DragWindow, DragList, DragBody
	
	;{ Default Setting
	#Default_Duration = 300
	#Size_DragInit_Distance = 10
	;}
	
	;{ Style
	
	; Size
	#Size_TL_DefaultLineHeight = 58
	#Size_TL_DefaultColumnWidth = 6
	#Size_TL_MaxColumnWidth = 15
	#Size_TL_MinColumnWidth = 1
	
	#Size_List_MinimumWidth = 230
	#Size_List_Text_VerticalOffset = (#Size_TL_DefaultLineHeight - 16) * 0.48
	#Size_List_Text_HorizontalOffset = 30
	#Size_List_Icon_VerticalMargin = (#Size_TL_DefaultLineHeight - 20) / 2
	#Size_List_FoldIcon_Offset = 30
	
	#Size_Header_Height = 60
	#Size_Header_ButtonSize = 40
	#Size_Header_VerticalMargin = (#Size_Header_Height - #Size_Header_ButtonSize) / 2
	
	#Size_Line_Thick = 2
	#Size_Line_Thin = 1
	
	#Size_Scrollbar_Thickness = 12
	
	#Size_MediaBlock_Height = 46
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
	
	; backup
	#Color_MediaBlock_Back_Cold = $3B445B
	#Color_MediaBlock_Back_Warm = $454E63
	#Color_MediaBlock_Back_Hot = $4F576B
	
	#Color_MediaBlock_Front_Cold = $91A0BC
	#Color_MediaBlock_Front_Warm = $91A0BC
	#Color_MediaBlock_Front_Hot = $C4D8FF
	
	#Colors_General_Line = $1A233A
	
	#Color_Window_Back_Cold = $1A233A
	#Color_Window_Back_Warm = $293658
	#Color_Window_Back_Hot = $5A8DEE
	
	#Color_Window_Front_Cold = $D0D0D0
	#Color_Window_Front_Warm = $FFFFFF
	
	#Color_Content_Back_Cold = $272E48
	
	#Color_Scrollbar_FrontCold = $787B86
	#Color_Scrollbar_FrontWarm = $656873
	#Color_Scrollbar_FrontHot = $434651
	
	; Fonts
	Global FontBold = FontID(LoadFont(#PB_Any, "Rubik Medium", 12, #PB_Font_HighQuality))
	Global Font = FontID(LoadFont(#PB_Any, "Rubik", 12, #PB_Font_HighQuality))

	Global IconSolid = FontID(LoadFont(#PB_Any, "Font Awesome 5 Pro Solid", 16, #PB_Font_HighQuality))
	Global Icon = FontID(LoadFont(#PB_Any, "Font Awesome 5 Pro Regular", 16, #PB_Font_HighQuality))
	Global MaterialIcon = FontID(LoadFont(#PB_Any, "Material Design Icons Desktop", 16, #PB_Font_HighQuality))
	
	; FontAwesome shortcut
	#FontAwesome_Chevron_Right = ""
	#FontAwesome_Chevron_Down = ""
	
	; Misc
	Global Dim Properties.Property(#Properties_Count)
	Properties(#Properties_Sub)\Text = "Sub-media"
	Properties(#Properties_X)\Text = "X"
	Properties(#Properties_Y)\Text = "Y"
	Properties(#Properties_Z)\Text = "Z"
	Properties(#Properties_Width)\Text = "Width"
	Properties(#Properties_Height)\Text = "Height"
	Properties(#Properties_Depth)\Text = "Depth"
	Properties(#Properties_Transparency)\Text = "Opacity"
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
	Declare _RenameLine(*GadgetData.GadgetData, *Line.Line, Name.s)
	Declare _MoveLine(*GadgetData.GadgetData, *Line.Line, Position)
	Declare _Display_InsertLine(*GadgetData.GadgetData, *Line.Line, Position, *Parent.Line)
	Declare _Display_RemoveLine(*GadgetData.GadgetData, *Line.line)
	Declare _Display_GetLinePosition(*GadgetData.GadgetData, *Line.Line)
	Declare _HoverLine(*GadgetData.GadgetData, Y)
	
	; Mediablock stuff
	Declare _AddMediaBlock(*GadgetData.GadgetData, XMLNode)
	Declare _MoveMediaBlock(*GadgetData.GadgetData, *Mediablock.Mediablock, *Line.Line, Position)
	Declare ToggleAnimatedMediaBlock()
	
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
	Declare Handler_RenameString(hWnd, uMsg, wParam, lParam)
	
	; Redraw
	Declare Redraw(*GadgetData.GadgetData, UpdateCollisionData = #False)
	Declare Redraw_MediaBlock(*GadgetData.GadgetData, yPos, *Block.MediaBlock, CollisionDataLine)
	Declare Redraw_Line(*GadgetData.GadgetData, YPos, OddLine, CollisionDataLine, UpdateCollisionData = #False)
	
	; Misc
	Declare Refit(Gadget, GadgetWidth, GadgetHeight)
	Declare ToggleFold(Gadget)
	Declare VerticalFocus(*GadgetData.GadgetData)
	Declare HorizontalFocus(*GadgetData.GadgetData)
	Declare _UpdateCurrentAssetList(*GadgetData.GadgetData, *Line.Line)
	Declare.s SerializeDataPoint(*DataPoint.DataPoint)
	Declare UnserializeDataPoint(*DataPoint.DataPoint, JsonString.s)
	Declare CompareAscending(*a.MBAdress, *b.MBAdress)
	
	Prototype Proto_SortMediaBlocks(List LinkedList.MediaBlock(), *Compare, First=0, Last=-1)
	Global SortMediaBlocks.Proto_SortMediaBlocks = SortLinkedList::@_SortLinkedList_()
	;}
	
	;{ Public procedures
	;{ Misc
	Procedure Gadget(Gadget, X, Y, Width, Height, Flags = #Default)
		Protected Result = ContainerGadget(Gadget, X, Y, Width, Height, #PB_Container_BorderLess), *GadgetData.GadgetData, Loop
		Protected CanvasList = CanvasGadget(#PB_Any, 0, #Size_Header_Height, #Size_List_MinimumWidth, Height - #Size_Header_Height, #PB_Canvas_Container | #PB_Canvas_Keyboard)
		CloseGadgetList()
		Protected CanvasBody = CanvasGadget(#PB_Any, #Size_List_MinimumWidth - 1, 0, Width - #Size_List_MinimumWidth, Height, #PB_Canvas_Container | #PB_Canvas_Keyboard)
		Protected Margin, ImageGadget
		
		If Result
			If Gadget = #PB_Any
				Gadget = Result
			EndIf
			
			*GadgetData = AllocateStructure(GadgetData)
			With *GadgetData
				EnableGadgetDrop(CanvasBody, #PB_Drop_Private, #PB_Drag_Link, 1)
				
				\Cont_Duration = #Default_Duration
				\State_Drag_Line = -1
				
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
				
				SetGadgetData(\Comp_Body, *GadgetData)
				BindGadgetEvent(\Comp_Body, @Handler_Body())
				
				DragWindow = OpenWindow(#PB_Any, 0, 0, \Meas_List_Width, \Meas_TL_LineHeight, "", #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(0))
				SetWindowColor(DragWindow, FixColor(#Colors_List_Back_Hot))
				DragList = CanvasGadget(#PB_Any, 0, 0, \Meas_List_Width, \Meas_TL_LineHeight)
				StartDrawing(CanvasOutput(DragList))
				Box(0, 0, OutputWidth(), OutputHeight(), #Colors_List_Back_Hot)
				; Let's use the existing drawing context to get the text width for the animation properties :
				DrawingFont(FontBold)
				For Loop = 0 To ArraySize(Properties())
					Properties(Loop)\Size = TextWidth(Properties(Loop)\Text) + 8
				Next
				StopDrawing()
				
				DragBody = CanvasGadget(#PB_Any,\Meas_List_Width, 0, \Meas_Body_Width, \Meas_TL_LineHeight)
				StartDrawing(CanvasOutput(DragBody))
				Box(0, 0, OutputWidth(), OutputHeight(), #Colors_List_Back_Hot)
				StopDrawing()
				
				SetWindowLongPtr_(WindowID(DragWindow),#GWL_EXSTYLE,#WS_EX_LAYERED)
				SetLayeredWindowAttributes_(WindowID(DragWindow),0,140,#LWA_ALPHA)
				
				\Comp_Menu_Image= FlatMenu::Create(0)
				FlatMenu::AddItem(\Comp_Menu_Image, 51, -1, "Animated", FlatMenu::#Toggle)
				FlatMenu::AddItem(\Comp_Menu_Image, 52, -1, "Container", FlatMenu::#Toggle)
				FlatMenu::AddItem(\Comp_Menu_Image, 41, -1, "Cut")
				FlatMenu::AddItem(\Comp_Menu_Image, 42, -1, "Copy")
				FlatMenu::AddItem(\Comp_Menu_Image, 43, -1, "Delete")
				
				BindEvent(#PB_Event_Menu, @ToggleAnimatedMediaBlock(), 0, 51)
				
				SetMenuAppearance(Image)
				
				UseGadgetList(WindowID(0))
				
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
			
			Redraw(*GadgetData, #True)
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
			
			Redraw(*GadgetData, #True)
			SetWindowPos_(GadgetID(Gadget), 0, X, Y, Width, Height, #SWP_NOZORDER)
			SendMessage_(GadgetID(\Comp_List), #WM_SETREDRAW, #True, 0)
			SendMessage_(GadgetID(\Comp_Body), #WM_SETREDRAW, #True, 0)
			
			RedrawWindow_(GadgetID(\Comp_List), 0, 0, #RDW_INVALIDATE | #RDW_UPDATENOW | #RDW_ERASE)
			RedrawWindow_(GadgetID(\Comp_Body), 0, 0, #RDW_INVALIDATE | #RDW_UPDATENOW | #RDW_ERASE)
		EndWith
		
	EndProcedure
	
	Procedure AssessDrop(Gadget, State, ObjectType, X, Y)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget), *Line
		
		With *GadgetData
			Select State
				Case #PB_Drag_Update
					If Y > #Size_Header_Height
						*Line =_HoverLine(*GadgetData, Y - #Size_Header_Height)
						
						If *Line 
							If \State_LineIndex()\Sub = -1
								\State_AssetDropLine = *Line
								\State_AssetDropPosition = X / \Meas_TL_ColumnWidth + \Meas_HPosition
								Redraw(*GadgetData)
								ProcedureReturn #True
							ElseIf \State_LineIndex()\Sub = #Properties_Sub
								
							EndIf
						EndIf
					EndIf
				Case #PB_Drag_Finish
					PostEvent(#PB_Event_GadgetDrop, 0, Gadget, \State_AssetDropLine, \State_AssetDropPosition)
					\State_AssetDropLine = 0
					\State_Action = #Action_Hover
				Case #PB_Drag_Enter
					\State_Action = #Action_Drop
				Case #PB_Drag_Leave
					\State_Action = #Action_Hover
			EndSelect
			
			If \State_AssetDropLine
				\State_AssetDropLine = 0
				Redraw(*GadgetData)
			EndIf
		EndWith
		
		ProcedureReturn #False
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
		
		With *GadgetData
			If \State_SelectedLine <> *Line
				If \State_SelectedLine
					\State_SelectedLine\State = #Cold
				EndIf
				
				\State_SelectedLine = *Line.Line
				\State_SelectedLine\State = #Hot
				Redraw(*GadgetData)
			EndIf
		EndWith
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
	
	Procedure RenameLine(Gadget, *Line.Line, XML = -1)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget),Y
		Protected XMLNode
		
		With *GadgetData
			
			If XML = -1
				XML = CreateXML(#PB_Any)
				XMLNode = CreateXMLNode(RootXMLNode(XML), "Task")
				SetXMLAttribute(XMLNode, "Gadget", Str(Gadget))
			EndIf
			
 			SetActiveLine(Gadget, *Line)
 			Y = (_Display_GetLinePosition(*GadgetData, *Line) - \Meas_VPosition) * \Meas_TL_LineHeight
			
			OpenGadgetList(*GadgetData\Comp_List)
			*GadgetData\Comp_Rename = StringGadget(#PB_Any, *Line\HorizontalOffset - 4, Y + *GadgetData\Meas_TL_TextVericalOffset - 2, *GadgetData\Meas_List_Width - *Line\HorizontalOffset - 15, 25, *Line\Name)
			SendMessage_(GadgetID(*GadgetData\Comp_Rename), #EM_SETSEL, 0, Len(*Line\Name))
			SetGadgetFont(*GadgetData\Comp_Rename, FontBold)
			SetGadgetColor(*GadgetData\Comp_Rename, #PB_Gadget_BackColor, *GadgetData\Color_List_Back[#Hot])
			SetGadgetColor(*GadgetData\Comp_Rename, #PB_Gadget_FrontColor, *GadgetData\Color_List_Front[#Hot])
			SetGadgetData(*GadgetData\Comp_Rename, *GadgetData)
 			SetActiveGadget(*GadgetData\Comp_Rename)
 			SetProp_(GadgetID(*GadgetData\Comp_Rename), "oldproc", SetWindowLongPtr_(GadgetID(*GadgetData\Comp_Rename), #GWL_WNDPROC, @Handler_RenameString()))
 			SetProp_(GadgetID(*GadgetData\Comp_Rename), "gadget", *GadgetData\Comp_Rename)
 			SetProp_(GadgetID(*GadgetData\Comp_Rename), "XML", XML)
 			*GadgetData\State_Action = #Action_List_Rename
			
		EndWith
		
	EndProcedure
	
	Procedure AddLine(Gadget, Position, Text.s, *Parent.Line = 0, Flags = #Line_Asset)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget), UUID.s
		Protected *Task.Task, XML = CreateXML(#PB_Any)
		Protected XMLNode = CreateXMLNode(RootXMLNode(XML), "Task")
		SetXMLAttribute(XMLNode, "Gadget", Str(Gadget))
		XMLNode = CreateXMLNode(XMLNode, #CreateLine)
		
		With *GadgetData
			UUID = UUID()
			
			While FindMapElement(\Cont_Lines(), UUID) ; Is this really needed? I don't know how random is PB RNG, but even if its reaaaaaally bad I think it would be safe without it. On the other hand, it's so small that I've left it just to be sure...
				UUID = UUID()
			Wend
			
			SetXMLAttribute(XMLNode, "Position", Str(Position))
			SetXMLAttribute(XMLNode, "UUID", UUID)
			
			If *Parent
				SetXMLAttribute(XMLNode, "Parent", *Parent\UUID)
			Else
				SetXMLAttribute(XMLNode, "Parent", "0")
			EndIf
			
			If Text = ""
				SetXMLAttribute(XMLNode, "Text", "Line "+\Cont_Displayed_List_Size)
				
				RenameLine(Gadget, _AddLine(*GadgetData, XMLNode), XML)
			Else
				SetXMLAttribute(XMLNode, "Text", Text)
				_AddLine(*GadgetData, XMLNode)
				*Task = AllocateStructure(Task)
				*Task\XML = ComposeXML(XML, #PB_XML_NoDeclaration)
				FreeXML(XML)
				TaskList::NewTask(*GadgetData\State_TaskList, *Task, @Handler_UndoRedo())
			EndIf
			
		EndWith
			
	EndProcedure
	
	Procedure MoveLine(Gadget, *Line.Line, Position)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
		Protected *Task.Task = AllocateStructure(Task), XML = CreateXML(#PB_Any)
		Protected XMLNode = CreateXMLNode(RootXMLNode(XML), "Task")
		SetXMLAttribute(XMLNode, "Gadget", Str(Gadget))
		XMLNode = CreateXMLNode(XMLNode, #MoveLine)
		
 		With *GadgetData
 			ChangeCurrentElement(\Cont_Displayed_List(), *Line\DisplayListAdress)
 			SetXMLAttribute(XMLNode, "UUID", *Line\UUID)
			SetXMLAttribute(XMLNode, "NewPosition", Str(Position))
			SetXMLAttribute(XMLNode, "OldPosition", Str(ListIndex(\Cont_Displayed_List())))
			
			_MoveLine(*GadgetData, *Line.Line, Position)
			
			*Task\XML = ComposeXML(XML, #PB_XML_NoDeclaration)
			FreeXML(XML)
			TaskList::NewTask(*GadgetData\State_TaskList, *Task, @Handler_UndoRedo())

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
	Procedure AddMediaBlock(Gadget, *Line.Line, Position, Duration, Type, Icon.s, Text.s, Color, AssetUUID.s, DefaultState.s)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget), *Task.Task
		Protected UUID.s, XML = CreateXML(#PB_Any)
		Protected XMLNode = CreateXMLNode(RootXMLNode(XML), "Task")
		SetXMLAttribute(XMLNode, "Gadget", Str(Gadget))
		XMLNode = CreateXMLNode(XMLNode, #CreateMediaBlock)
		Duration - 1
		
		With *GadgetData
			UUID = UUID()
			
			While FindMapElement(\Cont_MediaBlocks(), UUID)
				UUID = UUID()
			Wend
			
			SetXMLAttribute(XMLNode, "Line", *Line\UUID)
			SetXMLAttribute(XMLNode, "UUID", UUID)
			SetXMLAttribute(XMLNode, "Duration", Str(Duration))
			SetXMLAttribute(XMLNode, "Position", Str(Position))
 			SetXMLAttribute(XMLNode, "Type", Str(Type))
 			SetXMLAttribute(XMLNode, "Icon", Icon)
 			SetXMLAttribute(XMLNode, "Text", Text)
 			SetXMLAttribute(XMLNode, "Color", Str(Color))
			SetXMLAttribute(XMLNode, "AssetUUID", AssetUUID)
			SetXMLAttribute(XMLNode, "DefaultState", DefaultState)
			
			_AddMediaBlock(*GadgetData.GadgetData, XMLNode)
			
			*Task = AllocateStructure(Task)
			*Task\XML = ComposeXML(XML, #PB_XML_NoDeclaration)
			FreeXML(XML)
			TaskList::NewTask(*GadgetData\State_TaskList, *Task, @Handler_UndoRedo())
		EndWith
	EndProcedure
	
	Procedure DeleteMediaBlock(Gadget, *MediaBlock.Mediablock)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure MoveMediaBlock(Gadget, *MediaBlock.Mediablock, *NewLine.Line, NewPosition, ParentXMLNode = 0)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget), *Task.Task, XMLNode, XML
		
		If ParentXMLNode = 0
			XML = CreateXML(#PB_Any)
			XMLNode = CreateXMLNode(RootXMLNode(XML), "Task")
			SetXMLAttribute(XMLNode, "Gadget", Str(Gadget))
			XMLNode = CreateXMLNode(XMLNode, #MoveMediaBlock)
		Else
			XMLNode = CreateXMLNode(ParentXMLNode, #MoveMediaBlock)
		EndIf
		
		SetXMLAttribute(XMLNode, "UUID", *MediaBlock\UUID)
		SetXMLAttribute(XMLNode, "NewPosition", Str(NewPosition))
		SetXMLAttribute(XMLNode, "OldPosition", Str(*MediaBlock\BlockStart))
		SetXMLAttribute(XMLNode, "NewLine", *NewLine\UUID)
		SetXMLAttribute(XMLNode, "OldLine", *MediaBlock\Line\UUID)
		
 		_MoveMediaBlock(*GadgetData, *MediaBlock, *NewLine, NewPosition)
		
		If ParentXMLNode = 0
			*Task = AllocateStructure(Task)
			*Task\XML = ComposeXML(XML, #PB_XML_NoDeclaration)
			FreeXML(XML)
			TaskList::NewTask(*GadgetData\State_TaskList, *Task, @Handler_UndoRedo())
			Redraw(*GadgetData)
		EndIf
	EndProcedure
	
	Procedure ResizeMediaBlock(Gadget, *MediaBlock.Mediablock, NewStart, NewEnd)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget)
	EndProcedure
	
	Procedure UpdateMediaBlockState(Gadget, Line, Json.s)
		Protected Loop, *MediaBlock.Mediablock
	EndProcedure
	
	Procedure.s DeleteMediaBlockByAsset(Gadget, AssetUUID.s)
		Debug "?"
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
		*NewLine\HorizontalOffset = *GadgetData\Meas_TL_TextHorizontaOffset
		
		_Display_InsertLine(*GadgetData, *NewLine, Val(GetXMLAttribute(XMLNode, "Position")), *NewLine\Parent)
		
		ProcedureReturn *NewLine
	EndProcedure
	
	Procedure _RemoveLine(*GadgetData.GadgetData, XMLNode)
		Protected *Line.Line = FindMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(XMLNode, "UUID"))
		
		; Clean up what's inside.
		
		_Display_RemoveLine(*GadgetData, *Line)
		DeleteMapElement(*GadgetData\Cont_Lines())
	EndProcedure
	
	Procedure _RenameLine(*GadgetData.GadgetData, *Line.Line, Name.s)
		*Line\Name = Name
		Redraw(*GadgetData)
	EndProcedure
	
	Procedure _MoveLine(*GadgetData.GadgetData, *Line.Line, Position)
		Protected *Element
		With *GadgetData
			If Position = \Cont_Displayed_List_Size - 1
				ChangeCurrentElement(\Cont_Displayed_List(), *Line\DisplayListAdress)
				MoveElement(\Cont_Displayed_List(), #PB_List_Last)
			Else
				If Position > _Display_GetLinePosition(*GadgetData, *Line)
					Position + 1
				EndIf
				*Element = SelectElement(\Cont_Displayed_List(), Position)
				ChangeCurrentElement(\Cont_Displayed_List(), *Line\DisplayListAdress)
				MoveElement(\Cont_Displayed_List(), #PB_List_Before, *Element)
			EndIf
			
			Redraw(*GadgetData, #True)
		EndWith
	EndProcedure
	
	Procedure _Display_InsertLine(*GadgetData.GadgetData, *Line.Line, Position, *Parent.Line)
		
		If *Parent
			
		Else
			If Position = -1 Or Position >= *GadgetData\Cont_Displayed_List_Size
				LastElement(*GadgetData\Cont_Displayed_List())
				AddElement(*GadgetData\Cont_Displayed_List())
			Else
				SelectElement(*GadgetData\Cont_Displayed_List(), Position)
				InsertElement(*GadgetData\Cont_Displayed_List())
			EndIf
			
			*GadgetData\Cont_Displayed_List_Size + 1
			*GadgetData\Cont_Displayed_List() = *Line
			*Line\DisplayListAdress = @*GadgetData\Cont_Displayed_List()
			
			Redraw(*GadgetData, #True)
		EndIf
		
	EndProcedure
	
	Procedure _Display_RemoveLine(*GadgetData.GadgetData, *Line.line)
		*GadgetData\Cont_Displayed_List_Size - 1
		
		ChangeCurrentElement(*GadgetData\Cont_Displayed_List(), *Line\DisplayListAdress)
		
		DeleteElement(*GadgetData\Cont_Displayed_List(), #True)
		
		If *Line = *GadgetData\State_SelectedLine
			If *GadgetData\Cont_Displayed_List_Size
				*GadgetData\State_SelectedLine = *GadgetData\Cont_Displayed_List()
				*GadgetData\State_SelectedLine\State = #Hot
			Else
				*GadgetData\State_SelectedLine = 0
			EndIf
		EndIf
		
		Redraw(*GadgetData, #True)
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
	
	Procedure AddUsedDataPoint(*GadgetData.GadgetData, *Line.Line, *UsedGadgetData.DataPoint)
		; At some point, you'll add a new property and forget about this place... Ain't there a better solution to make this a bit more robust?
		With *Line
			\UsedDataPoints(#Properties_X) 				+ *UsedGadgetData\X 		
			\UsedDataPoints(#Properties_Y) 				+ *UsedGadgetData\Y 		
			\UsedDataPoints(#Properties_Z) 				+ *UsedGadgetData\Z 		
			\UsedDataPoints(#Properties_width) 			+ *UsedGadgetData\width 
			\UsedDataPoints(#Properties_height)			+ *UsedGadgetData\height
			\UsedDataPoints(#Properties_depth) 			+ *UsedGadgetData\depth
			\UsedDataPoints(#Properties_Transparency) 	+ *UsedGadgetData\Transparency
			
			\SubLineCount = Bool(\UsedDataPoints(#Properties_X)) + Bool(\UsedDataPoints(#Properties_Y)) + Bool(\UsedDataPoints(#Properties_Z)) + Bool(\UsedDataPoints(#Properties_width)) + Bool(\UsedDataPoints(#Properties_height)) + Bool(\UsedDataPoints(#Properties_depth)) + Bool(\UsedDataPoints(#Properties_Transparency))
			
			If \SubLineCount > 0 And \Fold = #NoFold
				\Fold = #Folded
				\HorizontalOffset + #Size_List_FoldIcon_Offset
			EndIf
			
			Redraw(*GadgetData)
			
		EndWith
	EndProcedure
	
	Procedure RemoveUsedDataPoint(*GadgetData.GadgetData, *Line.Line, *UsedGadgetData.DataPoint)
		With *Line
			\UsedDataPoints(#Properties_X) 				- *UsedGadgetData\X 		
			\UsedDataPoints(#Properties_Y) 				- *UsedGadgetData\Y 		
			\UsedDataPoints(#Properties_Z) 				- *UsedGadgetData\Z 		
			\UsedDataPoints(#Properties_width) 			- *UsedGadgetData\width 
			\UsedDataPoints(#Properties_height)			- *UsedGadgetData\height
			\UsedDataPoints(#Properties_depth) 			- *UsedGadgetData\depth
			\UsedDataPoints(#Properties_Transparency) 	- *UsedGadgetData\Transparency
			
			\SubLineCount = Bool(\UsedDataPoints(#Properties_X)) + Bool(\UsedDataPoints(#Properties_Y)) + Bool(\UsedDataPoints(#Properties_Z)) + Bool(\UsedDataPoints(#Properties_width)) + Bool(\UsedDataPoints(#Properties_height)) + Bool(\UsedDataPoints(#Properties_depth)) + Bool(\UsedDataPoints(#Properties_Transparency))
			
			If \SubLineCount = 0 And \Fold
				\Fold = #NoFold
				\HorizontalOffset - #Size_List_FoldIcon_Offset
			EndIf
			
			Redraw(*GadgetData)
			
		EndWith
	EndProcedure
	
	; Media block stuff
	Procedure _AddMediaBlock(*GadgetData.GadgetData, XMLNode)
		Protected *NewMediaBlock.MediaBlock, Loop, Json, *Adress, BlockEnd
		
		With *GadgetData
			*NewMediaBlock.MediaBlock = AddMapElement(\Cont_MediaBlocks(), GetXMLAttribute(XMLNode, "UUID"))
			*NewMediaBlock\Line = FindMapElement(\Cont_Lines(), GetXMLAttribute(XMLNode, "Line"))
			*NewMediaBlock\UUID = GetXMLAttribute(XMLNode, "UUID")
			*NewMediaBlock\Type = Val(GetXMLAttribute(XMLNode, "Type"))
			*NewMediaBlock\Color = Val(GetXMLAttribute(XMLNode, "Color"))
			*NewMediaBlock\Icon = GetXMLAttribute(XMLNode, "Icon")
			*NewMediaBlock\Duration = Val(GetXMLAttribute(XMLNode, "Duration"))
			*NewMediaBlock\BlockStart = Val(GetXMLAttribute(XMLNode, "Position"))
			*NewMediaBlock\BlockEnd = *NewMediaBlock\BlockStart + *NewMediaBlock\Duration
			*NewMediaBlock\Text = GetXMLAttribute(XMLNode, "Text")
			
			Json = ParseJSON(#PB_Any, GetXMLAttribute(XMLNode, "DefaultState"))
			
			ReDim *NewMediaBlock\DataPoints(*NewMediaBlock\Duration)
			ReDim *NewMediaBlock\DataPointState(*NewMediaBlock\Duration)
			
			For Loop = 0 To *NewMediaBlock\Duration
				ExtractJSONStructure(JSONValue(json), *NewMediaBlock\DataPoints(Loop), DataPoint)
			Next
			
			*NewMediaBlock\DataPointState(0)\x = #True
			*NewMediaBlock\DataPointState(0)\y = #True
			*NewMediaBlock\DataPointState(0)\z = #True
			*NewMediaBlock\DataPointState(0)\width = #True
			*NewMediaBlock\DataPointState(0)\height = #True
			*NewMediaBlock\DataPointState(0)\depth = #True
			
			FreeJSON(Json)
			
			LastElement(*NewMediaBlock\Line\MediaBlock())
			AddElement(*NewMediaBlock\Line\MediaBlock())
			*NewMediaBlock\Line\MediaBlock() = *NewMediaBlock
			*NewMediaBlock\ListAdress = @*NewMediaBlock\Line\MediaBlock()
			SortMediaBlocks(*NewMediaBlock\Line\MediaBlock(), @CompareAscending())
			
			Select *NewMediaBlock\Type
				Case #Asset_Type_Image ;{
					*NewMediaBlock\UsedData\Depth = #False
					*NewMediaBlock\UsedData\Height = #True
					*NewMediaBlock\UsedData\Width = #True
					*NewMediaBlock\UsedData\X = #True
					*NewMediaBlock\UsedData\Y = #True
					*NewMediaBlock\UsedData\Z = #False
					*NewMediaBlock\UsedData\Transparency = #True
					;}
			EndSelect
			
			Redraw(*GadgetData, #True)
			
		EndWith
	EndProcedure
	
	Procedure _DeleteMediaBlock(*GadgetData.GadgetData, XMLNode)
		Protected *Mediablock.Mediablock
		With *GadgetData
			*Mediablock = FindMapElement(\Cont_MediaBlocks(), GetXMLAttribute(XMLNode, "UUID"))
			
			If *Mediablock\Animated
				RemoveUsedDataPoint(*GadgetData, *Mediablock\Line, *Mediablock\UsedData)
			EndIf
			
			ChangeCurrentElement(*Mediablock\Line\MediaBlock(), *Mediablock\ListAdress)
			DeleteElement(*Mediablock\Line\MediaBlock())
			DeleteMapElement(\Cont_MediaBlocks())
		EndWith
	EndProcedure
	
	Procedure _HoverLine(*GadgetData.GadgetData, Y)
		Protected *Result
		With *GadgetData
			ForEach \State_LineIndex()
				If \State_LineIndex()\Position > Y
					*Result = \State_LineIndex()\Line
					Break
				EndIf
			Next
		EndWith
		ProcedureReturn *Result
	EndProcedure
	
	Procedure _HoverMediaBlock(*GadgetData.GadgetData, X, Y)
		With *GadgetData
			Protected Line
			If _HoverLine(*GadgetData, Y)
				Line = ListIndex(\State_LineIndex()) + \Meas_VPosition
				
				If Line > -1
					ProcedureReturn \State_Collision_Line(Line)\Column(Int(Round(X / \Meas_TL_ColumnWidth, #PB_Round_Down)) + \Meas_HPosition)
				EndIf
			EndIf
		EndWith
	EndProcedure
	
	Procedure _FindMediaBlock(*GadgetData.GadgetData, *Mediablock.Mediablock)
		Protected Result = #False
		ForEach *GadgetData\State_Selected_MediaBlocks()
			If *GadgetData\State_Selected_MediaBlocks() = *Mediablock
				Result =  #True
				Break
			EndIf
		Next
		
		ProcedureReturn Result
	EndProcedure
	
	Procedure _MoveMediaBlock(*GadgetData.GadgetData, *Mediablock.Mediablock, *Line.Line, Position)
		With *GadgetData
			ChangeCurrentElement(*Mediablock\Line\MediaBlock(), *Mediablock\ListAdress)
			DeleteElement(*Mediablock\Line\MediaBlock())
			If *Mediablock\Animated And *Line <> *Mediablock\Line
				RemoveUsedDataPoint(*GadgetData, *Mediablock\Line, *Mediablock\UsedData)
				AddUsedDataPoint(*GadgetData, *Line, *Mediablock\UsedData)
			EndIf
			
			*Mediablock\BlockEnd = Position + *Mediablock\BlockEnd - *Mediablock\BlockStart
			*Mediablock\BlockStart = Position
			
			LastElement(*Line\MediaBlock())
			AddElement(*Line\MediaBlock())
			*Mediablock\Line = *Line
			*Mediablock\Line\MediaBlock() = *Mediablock
			*Mediablock\ListAdress = @*Mediablock\Line\MediaBlock()
			
			SortMediaBlocks(*Mediablock\Line\MediaBlock(), @CompareAscending())
		EndWith
	EndProcedure
	
	Procedure ToggleAnimatedMediaBlock()
		Protected *GadgetData.GadgetData = GetGadgetData(0), Loop; Yep. Hard coded gadget id... Yep, we've hit refactor time two weeks ago...
		
		With *GadgetData
			ForEach \State_Selected_MediaBlocks()
				If EventData()
					AddUsedDataPoint(*GadgetData, \State_Selected_MediaBlocks()\Line, @\State_Selected_MediaBlocks()\UsedData)
					\State_Selected_MediaBlocks()\Animated = #True
				Else
					RemoveUsedDataPoint(*GadgetData, \State_Selected_MediaBlocks()\Line, @\State_Selected_MediaBlocks()\UsedData)
					For Loop = 1 To \State_Selected_MediaBlocks()\Duration
						CopyStructure(@\State_Selected_MediaBlocks()\DataPoints(0), @\State_Selected_MediaBlocks()\DataPoints(Loop), Datapoint)
					Next
					
						\State_Selected_MediaBlocks()\DataPointState(0)\x = #True
						\State_Selected_MediaBlocks()\DataPointState(0)\y = #True
						\State_Selected_MediaBlocks()\DataPointState(0)\z = #True
						\State_Selected_MediaBlocks()\DataPointState(0)\width = #True
						\State_Selected_MediaBlocks()\DataPointState(0)\height = #True
						\State_Selected_MediaBlocks()\DataPointState(0)\depth = #True
						\State_Selected_MediaBlocks()\DataPointState(0)\Transparency = #True
					
					\State_Selected_MediaBlocks()\Animated = #False
				EndIf
			Next
			
			Redraw(*GadgetData, #True)
		EndWith
	EndProcedure
	
	Procedure ToggleContainerMediaBlock()
		Protected *GadgetData.GadgetData = GetGadgetData(0)
		
		With *GadgetData
			ForEach \State_Selected_MediaBlocks()
				If EventData()
					\State_Selected_MediaBlocks()\Container = #True
				Else
					\State_Selected_MediaBlocks()\Container = #False
				EndIf
			Next
			Redraw(*GadgetData, #True)
		EndWith
	EndProcedure
	
	; Handler
	Procedure Handler_Body()
		Protected Gadget = EventGadget(), *GadgetData.GadgetData = GetGadgetData(Gadget), Y = GetGadgetAttribute(*GadgetData\Comp_Body, #PB_Canvas_MouseY) - #Size_Header_Height, X = GetGadgetAttribute(*GadgetData\Comp_Body, #PB_Canvas_MouseX)
		Protected *Mediablock.MediaBlock, Redraw, VOffset, HOffset, *Line, *Adress
		Protected *Task.Task, XMLNode, XML
		
		With *GadgetData
			Select EventType()
				Case #PB_EventType_MouseMove ;{
					Select \State_Action
						Case #Action_Body_Drag ;{
							HOffset = Round(X / \Meas_TL_ColumnWidth, #PB_Round_Down) + \Meas_HPosition
							
							If \State_Drag_HOffset <> (HOffset - \State_Drag_X)
								\State_Drag_HOffset = (HOffset - \State_Drag_X)
								Redraw = #True
							EndIf
							
							If ListSize(\State_Selected_MediaBlocks()) > 1
								VOffset = Round(Y / \Meas_TL_LineHeight, #PB_Round_Down) + \Meas_VPosition
								
								If \State_Drag_VOffset <> (VOffset - \State_Drag_Y)
									If \State_Drag_Folded = #False
										\State_Drag_Folded = #True
										ForEach \Cont_Displayed_List()
											If \Cont_Displayed_List()\Fold = #Unfolded
												\Cont_Displayed_List()\Fold = #Folded
											EndIf
										Next
									EndIf
									\State_Drag_VOffset = (VOffset - \State_Drag_Y)
									Redraw = #True
								EndIf
							Else
								_HoverLine(*GadgetData.GadgetData, Y)
								*Line = \State_LineIndex()\Line
								If *Line And *Line <> \State_AssetDropLine
									\State_AssetDropLine = *Line
									Redraw = #True
								EndIf
								
							EndIf
							;}
						Case #Action_Body_InitDrag ;{
							If Abs(\State_Drag_X - GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)) + Abs(\State_Drag_Y - Y) > #Size_DragInit_Distance
								\State_Action = #Action_Body_Drag
								\State_Action = #Action_Body_Drag
								\State_Drag_HOffset = 0
								
								
								\State_Drag_Y = Round(\State_Drag_Y / \Meas_TL_LineHeight, #PB_Round_Down) + \Meas_VPosition
								\State_Drag_X = Round(\State_Drag_X / \Meas_TL_ColumnWidth, #PB_Round_Down) + \Meas_HPosition
								
								\State_Drag_Folded = #False
								
								ForEach \State_Selected_MediaBlocks()
									\State_Selected_MediaBlocks()\Drag = #True
								Next
								
								If ListSize(\State_Selected_MediaBlocks()) > 1
									\State_AssetDropLine = \State_Selected_MediaBlocks()\Line
								EndIf
								Redraw = #True
							EndIf
							;}	
						Default ;{
							*Mediablock = _HoverMediaBlock(*GadgetData, X, Y)
							
							If \State_WarmMediaBlock <> *Mediablock
								If \State_WarmMediaBlock And \State_WarmMediaBlock\State = #Warm
									\State_WarmMediaBlock\State = #Cold
								EndIf
								
								\State_WarmMediaBlock = *Mediablock
								
								If \State_WarmMediaBlock And \State_WarmMediaBlock\State = #Cold
									\State_WarmMediaBlock\State = #Warm
								EndIf
								
								Redraw = #True
							EndIf
							;}
					EndSelect
					
					If Redraw
						Redraw(*GadgetData)
					EndIf
					;}
				Case #PB_EventType_MouseLeave ;{
					If \State_WarmMediaBlock And \State_WarmMediaBlock\State = #Warm
						\State_WarmMediaBlock\State = #Cold
						\State_WarmMediaBlock = 0
						Redraw(*GadgetData)
					EndIf
					;}
				Case #PB_EventType_LeftButtonDown ;{
					If \State_WarmMediaBlock
						If GetGadgetAttribute(\Comp_Body, #PB_Canvas_Modifiers) & #PB_Canvas_Control
							If \State_WarmMediaBlock\State = #Warm
								AddElement(\State_Selected_MediaBlocks())
								\State_Selected_MediaBlocks() = \State_WarmMediaBlock
								\State_WarmMediaBlock\State = #Hot
								\State_WarmMediaBlock = 0
								
								Redraw = #True
							EndIf
						Else
							If \State_WarmMediaBlock\State = #Warm
								ForEach \State_Selected_MediaBlocks()
									\State_Selected_MediaBlocks()\State = #Cold
								Next
								ClearList(\State_Selected_MediaBlocks())
								
								AddElement(\State_Selected_MediaBlocks())
								\State_Selected_MediaBlocks() = \State_WarmMediaBlock
								\State_WarmMediaBlock\State = #Hot
								
								Redraw = #True
							EndIf
						EndIf
						\State_Drag_X = X
						\State_Drag_Y = Y
						\State_Action = #Action_Body_InitDrag
						
						If Redraw
							Redraw(*GadgetData)
						EndIf
					EndIf
					;}
				Case #PB_EventType_LeftButtonUp ;{
					If \State_Action = #Action_Body_InitDrag ;{
						If GetGadgetAttribute(\Comp_Body, #PB_Canvas_Modifiers) & #PB_Canvas_Control
							If \State_WarmMediaBlock
								\State_WarmMediaBlock\State = #Cold
								ForEach \State_Selected_MediaBlocks()
									If \State_Selected_MediaBlocks() = \State_WarmMediaBlock
										Break
									EndIf
								Next
								DeleteElement(\State_Selected_MediaBlocks())
								\State_WarmMediaBlock = _HoverMediaBlock(*GadgetData, X, Y)
								If \State_WarmMediaBlock And \State_WarmMediaBlock\State = #Cold
									\State_WarmMediaBlock\State = #Warm
								EndIf
								
								Redraw = #True
							EndIf
						Else
							If \State_WarmMediaBlock
								ForEach \State_Selected_MediaBlocks()
									\State_Selected_MediaBlocks()\State = #Cold
									DeleteElement(\State_Selected_MediaBlocks())
								Next
								
								AddElement(\State_Selected_MediaBlocks())
								\State_Selected_MediaBlocks() = \State_WarmMediaBlock
								\State_WarmMediaBlock\State = #Hot
								
								\State_WarmMediaBlock = _HoverMediaBlock(*GadgetData, X, Y)
								If \State_WarmMediaBlock And \State_WarmMediaBlock\State = #Cold
									\State_WarmMediaBlock\State = #Warm
								EndIf
								
								Redraw = #True
							EndIf
						EndIf
						\State_Action = #Action_Hover
						;}
					ElseIf \State_Action = #Action_Body_Drag ;{
						XML = CreateXML(#PB_Any)
						XMLNode = CreateXMLNode(RootXMLNode(XML), "Task")
						SetXMLAttribute(XMLNode, "Gadget", Str(Gadget))
						
						If ListSize(\State_Selected_MediaBlocks()) = 1
							\State_Selected_MediaBlocks()\Drag = #False
							MoveMediaBlock(Gadget, \State_Selected_MediaBlocks(), \State_AssetDropLine, Max(\State_Selected_MediaBlocks()\BlockStart + \State_Drag_HOffset, 0), XMLNode)
						Else
							ForEach \State_Selected_MediaBlocks()
								\State_Selected_MediaBlocks()\Drag = #False
								ChangeCurrentElement(\Cont_Displayed_List(), \State_Selected_MediaBlocks()\Line\DisplayListAdress)
								SelectElement(\Cont_Displayed_List(), Min(max(ListIndex(\Cont_Displayed_List()) + \State_Drag_VOffset, 0), \Cont_Displayed_List_Size - 1))
								*Adress = @\State_Selected_MediaBlocks() ;< In some rare cases, ForEach (Or While NextElement()) doesn't go through the whole list and I can't figure out why. This fixes the problem until further inspection
								MoveMediaBlock(Gadget, \State_Selected_MediaBlocks(), \Cont_Displayed_List(), Max(\State_Selected_MediaBlocks()\BlockStart + \State_Drag_HOffset, 0), XMLNode)
								ChangeCurrentElement(\State_Selected_MediaBlocks(), *Adress)
							Next
						EndIf
						
						Redraw(*GadgetData)
						
						\State_Drag_HOffset = 0
						\State_Drag_VOffset = 0
						\State_Action = #Action_Hover
						
						*Task = AllocateStructure(Task)
						*Task\XML = ComposeXML(XML, #PB_XML_NoDeclaration)
						FreeXML(XML)
						TaskList::NewTask(*GadgetData\State_TaskList, *Task, @Handler_UndoRedo())
						
						Redraw = #True
					EndIf ;}
					
					\State_AssetDropLine = 0
					
					If Redraw
						Redraw(*GadgetData, #True)
					EndIf
					;}
				Case #PB_EventType_RightClick ;{
					Select \State_Action
						Case #Action_Body_Drag ;{
							ForEach \State_Selected_MediaBlocks()
								\State_Selected_MediaBlocks()\Drag = #False
							Next
							
							\State_Drag_HOffset = 0
							\State_Drag_VOffset = 0
							\State_Action = #Action_Hover
							\State_Action = #Action_Hover
							
							Redraw(*GadgetData)
							
							;}
						Default ;{
							
							If \State_WarmMediaBlock
								If \State_WarmMediaBlock\State = #Hot And ListSize(\State_Selected_MediaBlocks()) > 1
									
								Else
									If \State_WarmMediaBlock\State = #Warm
										ForEach \State_Selected_MediaBlocks()
											\State_Selected_MediaBlocks()\State = #Cold
										Next
										ClearList(\State_Selected_MediaBlocks())
										
										AddElement(\State_Selected_MediaBlocks())
										\State_Selected_MediaBlocks() = \State_WarmMediaBlock
										\State_WarmMediaBlock\State = #Hot
										Redraw(*GadgetData)
									EndIf
									
									Select \State_WarmMediaBlock\Type
										Case #Asset_Type_Image
											FlatMenu::SetItemState(\Comp_Menu_Image, 0, \State_Selected_MediaBlocks()\Animated)
											FlatMenu::SetItemState(\Comp_Menu_Image, 1, \State_Selected_MediaBlocks()\Container)
											FlatMenu::Show(\Comp_Menu_Image)
										Case #Asset_Type_Video
											
										Case #Asset_Type_Sound
											
										Case #Asset_Type_Music
											
										Case #Asset_Type_Voice
											
										Case #Asset_Type_Character
											
										Case #Asset_Type_Model
											
									EndSelect
								EndIf
							Else
								
								
							EndIf
					EndSelect;
							;}
					;}
				Case #PB_EventType_KeyDown ;{
					Select GetGadgetAttribute(Gadget, #PB_Canvas_Key)
						Case #PB_Shortcut_Z ;{ Undo
							If GetGadgetAttribute(Gadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
								TaskList::Undo(\State_TaskList)
							EndIf
							;}
						Case #PB_Shortcut_Y ;{ Redo
							If GetGadgetAttribute(Gadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
								TaskList::Redo(\State_TaskList)
							EndIf
							;}
						Case #PB_Shortcut_Escape ;{ Cancel the current action
							Select \State_Action
								Case #Action_Body_Drag ;{
									ForEach \State_Selected_MediaBlocks()
										\State_Selected_MediaBlocks()\Drag = #False
									Next
									
									\State_Drag_HOffset = 0
									\State_Drag_VOffset = 0
									\State_Action = #Action_Hover
									\State_Action = #Action_Hover
									
									Redraw(*GadgetData)
									
									;}
							EndSelect
							;}
					EndSelect
					;}
			EndSelect
		EndWith	
		
	EndProcedure
	
	Procedure Handler_List()
		Protected Gadget = EventGadget(), *GadgetData.GadgetData = GetGadgetData(Gadget), Y = GetGadgetAttribute(*GadgetData\Comp_List, #PB_Canvas_MouseY), Item, X, *FoldButton, Redraw, *Line.Line
		
		With *GadgetData
			Select EventType()
				Case #PB_EventType_MouseMove ;{
					Select \State_Action
						Case #Action_List_Drag ;{
							SetWindowPos_(WindowID(DragWindow), 0, GadgetX(\Comp_List, #PB_Gadget_ScreenCoordinate),
							              Min(Max(GadgetY(\Comp_List, #PB_Gadget_ScreenCoordinate),DesktopMouseY() - \State_Drag_Y), GadgetY(\Comp_List, #PB_Gadget_ScreenCoordinate) + \Meas_List_Height - \Meas_TL_LineHeight),
							              0, 0, #SWP_NOSIZE|#SWP_NOZORDER)
							
							Item = Min(Round(Max(y- \State_Drag_Y, 0) / \Meas_TL_LineHeight + 0.49, #PB_Round_Down), \Cont_Displayed_List_Size - 1)
							If \State_Drag_Line <> Item
								\State_Drag_Line = Item
								Redraw(*GadgetData)
							EndIf
							;}
						Case #Action_List_InitDrag ;{
							If Abs(\State_Drag_X - GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)) + Abs(\State_Drag_Y - Y) > #Size_DragInit_Distance
								\State_Drag_Y = (\State_Drag_Y % \Meas_TL_LineHeight) + (Y - \State_Drag_Y)
								ResizeWindow(DragWindow, GadgetX(\Comp_List, #PB_Gadget_ScreenCoordinate), DesktopMouseY() - \State_Drag_Y, \Meas_Width, \Meas_TL_LineHeight)
								
								SetWindowPos_(GadgetID(DragList), 0, 0, 0, \Meas_List_Width, \Meas_TL_LineHeight, #SWP_NOMOVE | #SWP_NOZORDER | #SWP_NOREDRAW)
								SetWindowPos_(GadgetID(DragBody), \Meas_List_Width, 0, 0, \Meas_Body_Width, \Meas_TL_LineHeight, #SWP_NOZORDER | #SWP_NOREDRAW)
								
								StartDrawing(CanvasOutput(DragList))
								Box(0, 0,  \Meas_List_Width, \Meas_TL_LineHeight, \Color_List_Back[#Hot])
								DrawingFont(FontBold)
								DrawingMode(#PB_2DDrawing_Transparent)
								FrontColor(\Color_List_Front[#Cold])
								DrawText(\State_SelectedLine\HorizontalOffset, \Meas_TL_TextVericalOffset,  \State_SelectedLine\Name)
								Box(\Meas_List_Width - 1, 0, #Size_Line_Thin, \Meas_List_Height, \Color_General_Line)
								StopDrawing()
								
								StartVectorDrawing(CanvasVectorOutput(DragBody))
								ChangeCurrentElement(\Cont_Displayed_List(), \State_SelectedLine\DisplayListAdress)
								Redraw_Line(*GadgetData, 0, #True, 0)
								FillPath()
								StopVectorDrawing()
								
								\State_SelectedLine\State = #Draged
								\State_Action = #Action_List_Drag
								\State_Action = #Action_List_Drag
								
								Redraw(*GadgetData)
								HideWindow(DragWindow, #False)
							EndIf
							;}
						Default ;{
							*Line = _HoverLine(*GadgetData, Y)
							
							If *Line
								If *Line\Fold
									X = GetGadgetAttribute(*GadgetData\Comp_List, #PB_Canvas_MouseX)
									If (X >= \Meas_TL_TextHorizontaOffset - 6) And (X <= *Line\HorizontalOffset - 6) 
										Y - ( \State_LineIndex()\Position - \Meas_TL_LineHeight)
										If (Y >= 15) And (Y <= 43)
											*FoldButton = *Line
											*Line = 0
										EndIf
									EndIf
								EndIf
							EndIf
							
							If *Line <> \State_WarmLine
								If \State_WarmLine And \State_WarmLine\State = #Warm
									\State_WarmLine\State = #Cold
								EndIf
								
								\State_WarmLine = *Line
								
								If \State_WarmLine And \State_WarmLine\State = #Cold
									\State_WarmLine\State = #Warm
								EndIf
								Redraw = #True
							EndIf
							
							If *FoldButton <> \State_WarmButton
								If \State_WarmButton And \State_WarmButton\FoldButtonState = #Warm
									\State_WarmButton\FoldButtonState = #Cold
								EndIf
								
								\State_WarmButton = *FoldButton
								
								If \State_WarmButton And \State_WarmButton\FoldButtonState = #Cold
									\State_WarmButton\FoldButtonState = #Warm
								EndIf
								Redraw = #True
							EndIf
							
							If Redraw
								Redraw(*GadgetData)
							EndIf
							;}
					EndSelect
					;}
				Case #PB_EventType_MouseLeave ;{
					If \State_Action = #Action_Hover
						If \State_WarmLine 
							If \State_WarmLine\State = #Warm
								\State_WarmLine\State = #Cold
							EndIf
							\State_WarmLine = 0
							Redraw(*GadgetData)
						EndIf
					EndIf
					;}
				Case #PB_EventType_LeftButtonDown ;{
					If \State_Action = #Action_Hover
						If \State_WarmLine
							SetActiveLine(Gadget, \State_WarmLine)
							\State_Action = #Action_List_InitDrag
							\State_Drag_X = GetGadgetAttribute(Gadget, #PB_Canvas_MouseX)
							\State_Drag_Y = Y
						ElseIf \State_WarmButton
							If \State_WarmButton\Fold = #Folded
								\State_WarmButton\Fold = #Unfolded
							Else
								\State_WarmButton\Fold = #Folded
							EndIf
							Redraw(*GadgetData, #True)
						EndIf
					ElseIf \State_Action = #Action_List_HoverFold
						
					EndIf
					;}
				Case #PB_EventType_LeftButtonUp ;{
					If \State_Action = #Action_List_InitDrag
						\State_Action = #Action_Hover
					ElseIf \State_Action = #Action_List_Drag
						HideWindow(DragWindow, #True)
						
						\State_Action = #Action_Hover
						\State_Action = #Action_Hover
						\State_SelectedLine\State = #Hot
						
						MoveLine(Gadget, \State_SelectedLine, \State_Drag_Line)
					EndIf
					;}
				Case #PB_EventType_LeftClick ;{
					;}
				Case #PB_EventType_LeftDoubleClick ;{
					;}
				Case #PB_EventType_KeyDown ;{
					Select GetGadgetAttribute(Gadget, #PB_Canvas_Key)
						Case #PB_Shortcut_Z ;{ Undo
							If GetGadgetAttribute(Gadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
								TaskList::Undo(\State_TaskList)
							EndIf
							;}
						Case #PB_Shortcut_Y ;{ Redo
							If GetGadgetAttribute(Gadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
								TaskList::Redo(\State_TaskList)
							EndIf
							;}
						Case #PB_Shortcut_F2 ;{ Rename the current line
							If *GadgetData\State_SelectedLine And *GadgetData\State_Action = #Action_Hover
								RenameLine(*GadgetData\Comp_Container, *GadgetData\State_SelectedLine)
							EndIf
							;}
					EndSelect
					;}
			EndSelect
		EndWith
	EndProcedure
	
	Procedure Handler_Button_AddFolder()
	EndProcedure
	
	Procedure Handler_Button_AddLine()
		Protected Gadget = EventGadget(), *GadgetData.GadgetData = GetGadgetData(Gadget)
		
		If *GadgetData\State_Action = #Action_List_Rename
			Handler_RenameString(GadgetID(*GadgetData\Comp_Rename), #WM_KILLFOCUS, 0, 0)
		EndIf
		
		If *GadgetData\State_SelectedLine
			AddLine(Gadget, _Display_GetLinePosition(*GadgetData, *GadgetData\State_SelectedLine) + 1, "")
		Else
			AddLine(Gadget, -1, "")
		EndIf
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
	
	Procedure Handler_RenameString(hWnd, uMsg, wParam, lParam)
		Protected oldproc = GetProp_(hWnd, "oldproc"), Gadget, *GadgetData.GadgetData, XML, Item, NewName.s, *Task.Task, XMLNode, MainNode
		
		Select uMsg
			Case #WM_NCDESTROY
				RemoveProp_(hWnd, "oldproc")
				RemoveProp_(hWnd, "gadget")
				RemoveProp_(hWnd, "Task")
			Case #WM_KEYDOWN
				Gadget = GetProp_(hWnd, "gadget")
				If wParam = #VK_RETURN And GetGadgetText(Gadget) <> ""
					*GadgetData = GetGadgetData(GetProp_(hWnd, "gadget"))
					SetActiveGadget(*GadgetData\Comp_List)
				EndIf
				ProcedureReturn #False
			Case #WM_KILLFOCUS
				Gadget = GetProp_(hWnd, "gadget")
				*GadgetData = GetGadgetData(Gadget)
				
				If *GadgetData\State_Action = #Action_List_Rename
					XML = GetProp_(hWnd, "XML")
					NewName = GetGadgetText(Gadget)
					
					If NewName = "" Or NewName = *GadgetData\State_SelectedLine\Name
						If XML
							*Task = AllocateStructure(Task)
							*Task\XML = ComposeXML(XML, #PB_XML_NoDeclaration)
							FreeXML(XML)
							TaskList::NewTask(*GadgetData\State_TaskList, *Task, @Handler_UndoRedo())
						EndIf
					Else
						If XML = 0
							XML = CreateXML(#PB_Any)
							MainNode = CreateXMLNode(RootXMLNode(XML), "Task")
						Else
							MainNode = ChildXMLNode(RootXMLNode(XML))
						EndIf
						
						XMLNode = CreateXMLNode(MainNode, #RenameLine)
						
						SetXMLAttribute(XMLNode, "UUID", *GadgetData\State_SelectedLine\UUID)
						SetXMLAttribute(XMLNode, "OldName", *GadgetData\State_SelectedLine\Name)
						SetXMLAttribute(XMLNode, "NewName", NewName)
						
						*Task = AllocateStructure(Task)
						*Task\XML = ComposeXML(XML, #PB_XML_NoDeclaration)
						FreeXML(XML)
						TaskList::NewTask(*GadgetData\State_TaskList, *Task, @Handler_UndoRedo())
						
						_RenameLine(*GadgetData, *GadgetData\State_SelectedLine, NewName)
					EndIf
					
					*GadgetData\State_Action = #Action_Hover
					
					FreeGadget(Gadget)
				EndIf
				ProcedureReturn #False
		EndSelect
		
		ProcedureReturn CallWindowProc_(oldproc, hWnd, uMsg, wParam, lParam)
	EndProcedure
	
	Procedure Handler_UndoRedo(*Task.Task, Redo)
		Protected *GadgetData.GadgetData, XML = ParseXML(#PB_Any, *Task\XML), Loop, TaskCount, MainNode = ChildXMLNode(RootXMLNode(XML)), Task, *Line.Line, *MediaBlock.MediaBlock, Redraw
		
		*GadgetData = GetGadgetData(Val(GetXMLAttribute(MainNode, "Gadget")))
		
		If *GadgetData\State_Action <> #Action_Hover
			ProcedureReturn #False
		EndIf
		
		TaskCount = XMLChildCount(MainNode)
		
		If Redo ;{ Redo
			For Loop = 1 To TaskCount
				Task = ChildXMLNode(MainNode, Loop)
				
				Select GetXMLNodeName(Task)
					Case #CreateLine
						_AddLine(*GadgetData, Task)
					Case #RenameLine
						_RenameLine( *GadgetData, FindMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(Task, "UUID")), GetXMLAttribute(Task, "NewName"))
					Case #MoveLine
						_MoveLine( *GadgetData, FindMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(Task, "UUID")), Val(GetXMLAttribute(Task, "NewPosition")))
					Case #MoveMediaBlock
						_MoveMediaBlock(*GadgetData, FindMapElement(*GadgetData\Cont_MediaBlocks(), GetXMLAttribute(Task, "UUID")), FindMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(Task, "NewLine")), Val(GetXMLAttribute(Task, "NewPosition")))
						Redraw = #True
					Case #CreateMediaBlock
						_AddMediaBlock(*GadgetData, Task)
				EndSelect
			Next
			;}
		Else ;{ Undo
			For Loop = TaskCount To 1 Step -1
				Task = ChildXMLNode(MainNode, Loop)
				
				Select GetXMLNodeName(Task)
					Case #CreateLine
						_RemoveLine(*GadgetData, Task)
					Case #RenameLine
						_RenameLine(*GadgetData, FindMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(Task, "UUID")), GetXMLAttribute(Task, "OldName"))
					Case #MoveLine
						_MoveLine(*GadgetData, FindMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(Task, "UUID")), Val(GetXMLAttribute(Task, "OldPosition")))
					Case #MoveMediaBlock
						_MoveMediaBlock(*GadgetData, FindMapElement(*GadgetData\Cont_MediaBlocks(), GetXMLAttribute(Task, "UUID")), FindMapElement(*GadgetData\Cont_Lines(), GetXMLAttribute(Task, "OldLine")), Val(GetXMLAttribute(Task, "OldPosition")))
						Redraw = #True
					Case #CreateMediaBlock
						_DeleteMediaBlock(*GadgetData, Task)
						Redraw = #True
				EndSelect
			Next
		EndIf
		;}
		
		If Redraw
			Redraw(*GadgetData)
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	
	; Redraw
	Procedure Redraw(*GadgetData.GadgetData, UpdateCollisionData = #False)
		Protected Loop, LoopEnd, BodyYPos, YPos, OddLine, ListIndex, StepCount, LineHeight, DataPropertiesLoop, DataCount
		
		With *GadgetData
			StartDrawing(CanvasOutput(\Comp_List))
			StartVectorDrawing(CanvasVectorOutput(\Comp_Body))
			
			;{ Empty current collision data if needed
			If UpdateCollisionData
				For Loop = 0 To \Meas_Displayed_Line_Count 
					FreeArray(\State_Collision_Line(Loop)\Column()) 
					Dim \State_Collision_Line(Loop)\Column(\Meas_Displayed_Column_Count)
				Next
				
				ClearList(\State_LineIndex())
			EndIf
			;}
			
			;{ Background color
			Box(0, 0, \Meas_List_Width, \Meas_List_Height, \Color_List_Back[#cold])
			DrawingFont(FontBold)
			DrawingMode(#PB_2DDrawing_Transparent)
			FrontColor(\Color_List_Front[#Cold])
			
			AddPathBox(0, 0, \Meas_Body_Width, VectorOutputHeight())
			VectorSourceColor(SetAlpha($FF, \Color_List_Back[#cold]))
			FillPath()
			;}
						
			;{ Content
			If \Cont_Displayed_List_Size
				SelectElement(\Cont_Displayed_List(), \Meas_VPosition)
				LoopEnd = \Meas_VPosition + \Meas_Displayed_Line_Count
				OddLine = \Meas_VPosition % 2
				BodyYPos = #Size_Header_Height
				
				For Loop = \Meas_VPosition To LoopEnd
					If \Cont_Displayed_List()\State = #Draged
						Loop - 1
					Else
						;{ Line reordering effect
						If \State_Action = #Action_List_Drag And Loop = \State_Drag_Line
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
						;}
						
						StepCount = Redraw_Line(*GadgetData, BodyYPos, OddLine, Loop, UpdateCollisionData)
						
						;{ List
						If UpdateCollisionData
							AddElement(\State_LineIndex())
							\State_LineIndex()\Line = \Cont_Displayed_List()
							\State_LineIndex()\Position = YPos + \Meas_TL_LineHeight 
							\State_LineIndex()\Sub = -1
						EndIf
						
						If \Cont_Displayed_List()\State
							Box(0, YPos, \Meas_List_Width, \Meas_TL_LineHeight + #Size_MediaBlock_Height * (StepCount), \Color_List_Back[\Cont_Displayed_List()\State])
						EndIf
						
						If \Cont_Displayed_List()\Fold
							If \Cont_Displayed_List()\FoldButtonState
								RoundBox(\Meas_TL_TextHorizontaOffset - 6, YPos + 15, #Size_List_FoldIcon_Offset, 28, 3, 3, \Color_List_Back[Bool(Not \Cont_Displayed_List()\State) * 2])
							EndIf
							
							DrawingFont(IconSolid)
							If \Cont_Displayed_List()\Fold = #Folded
								DrawText(\Meas_TL_TextHorizontaOffset + 3, YPos + 18, #FontAwesome_Chevron_Right)
								DrawingFont(FontBold)
							ElseIf \Cont_Displayed_List()\Fold = #Unfolded
								DrawText(\Meas_TL_TextHorizontaOffset, YPos + 18, #FontAwesome_Chevron_Down)
								DrawingFont(FontBold)
								DataCount = 0
								For DataPropertiesLoop = 0 To #Properties_Count
									If \Cont_Displayed_List()\UsedDataPoints(DataPropertiesLoop)
										DataCount + 1
										If UpdateCollisionData
											AddElement(\State_LineIndex())
											\State_LineIndex()\Line = \Cont_Displayed_List()
											\State_LineIndex()\Position = YPos + DataCount * #Size_MediaBlock_Height + #Size_MediaBlock_Height + #Size_MediaBlock_VerticalMargin
											\State_LineIndex()\Sub = DataPropertiesLoop
										EndIf
										DrawText(\Meas_List_Width - Properties(DataPropertiesLoop)\Size, YPos + DataCount * #Size_MediaBlock_Height + \Meas_TL_TextVericalOffset - 2, Properties(DataPropertiesLoop)\Text)
									EndIf
								Next
								If UpdateCollisionData
									\State_LineIndex()\Position + #Size_MediaBlock_VerticalMargin
								EndIf
							EndIf
						EndIf
						
						DrawText(\Cont_Displayed_List()\HorizontalOffset, YPos + \Meas_TL_TextVericalOffset,  \Cont_Displayed_List()\Name)
						;}
						
						;{ Markers
						If \State_AssetDropLine = \Cont_Displayed_List()
							If \State_Action = #Action_Drop ; Draw the drop marker
								AddPathBox((\State_AssetDropPosition  - \Meas_HPosition) * \Meas_TL_ColumnWidth, BodyYPos, 2, \Meas_TL_LineHeight)
								VectorSourceColor(SetAlpha($FF, $E0E0E0))
								FillPath()
							ElseIf ListSize(\State_Selected_MediaBlocks()) = 1 ;draw drag marker For a single mediablock
								LineHeight = #Size_MediaBlock_Height
								If \Cont_Displayed_List()\Fold = #Unfolded And (\State_Selected_MediaBlocks()\Animated Or \State_Selected_MediaBlocks()\Container)
									LineHeight + \State_Selected_MediaBlocks()\Line\SubLineCount * #Size_MediaBlock_Height
								EndIf
								MaterialVector::AddPathRoundedBox((Max(\State_Selected_MediaBlocks()\BlockStart + \State_Drag_HOffset, 0) - \Meas_HPosition) * \Meas_TL_ColumnWidth + 0.5,
								                                  BodyYPos + #Size_MediaBlock_VerticalMargin + 0.5,
								                                  \State_Selected_MediaBlocks()\Duration * \Meas_TL_ColumnWidth + \Meas_TL_ColumnWidth, LineHeight, 2)
								VectorSourceColor($FFFFFFFF)
								StrokePath(1)
							EndIf
						EndIf
						;}
						
						Loop + StepCount
						YPos + \Meas_TL_LineHeight + #Size_MediaBlock_Height * StepCount
						BodyYPos + \Meas_TL_LineHeight + #Size_MediaBlock_Height * StepCount
						OddLine = Bool(Not OddLine)
					EndIf
					
					If Not NextElement(\Cont_Displayed_List()) ; Check if there is more to draw before starting to draw the next line.
						;{ Draw the alternate color in the edgecase where a line is dragged to the very end of the line
						If \State_Action = #Action_List_Drag And (Loop + 1) = \State_Drag_Line 
							If Not OddLine
								AddPathBox(0, BodyYPos, \Meas_Body_Width, \Meas_TL_LineHeight)
								VectorSourceColor(SetAlpha($FF, \Color_List_Back_Alternate[#Cold]))
								FillPath()
							EndIf
						EndIf
						;}
						Break
					EndIf
				Next
				
				;{ Draw drag marker for ultiple mediablocks moved at once
				If \State_Action = #Action_Body_Drag And ListSize(\State_Selected_MediaBlocks()) > 1
					LoopEnd = \Meas_VPosition + LoopEnd
					ForEach \State_Selected_MediaBlocks()
						ChangeCurrentElement(\Cont_Displayed_List(), \State_Selected_MediaBlocks()\Line\DisplayListAdress)
						ListIndex = Min(max(ListIndex(\Cont_Displayed_List()) + \State_Drag_VOffset, 0), \Cont_Displayed_List_Size - 1)
						
						If ListIndex >= \Meas_VPosition And ListIndex <= LoopEnd
							LineHeight = #Size_MediaBlock_Height
							If \State_Selected_MediaBlocks()\Line\Fold = #Unfolded And (\State_Selected_MediaBlocks()\Animated Or \State_Selected_MediaBlocks()\Container)
								LineHeight + \State_Selected_MediaBlocks()\Line\SubLineCount * #Size_MediaBlock_Height
							EndIf
							MaterialVector::AddPathRoundedBox((Max(\State_Selected_MediaBlocks()\BlockStart + \State_Drag_HOffset, 0) - \Meas_HPosition) * \Meas_TL_ColumnWidth + 0.5,
							                                  #Size_Header_Height + ListIndex * \Meas_TL_LineHeight + #Size_MediaBlock_VerticalMargin + 0.5,
							                                  \State_Selected_MediaBlocks()\Duration * \Meas_TL_ColumnWidth + \Meas_TL_ColumnWidth, LineHeight, 2)
						EndIf
					Next
					VectorSourceColor($FFFFFFFF)
					StrokePath(1)
				EndIf
				;}
				
			EndIf
			;}
			
			;{ Header 
			MovePathCursor(0, #Size_Header_Height - 0.5)
			AddPathLine(\Meas_Body_Width, 0, #PB_Path_Relative)
			VectorSourceColor(SetAlpha($FF, \Color_General_Line))
			StrokePath(#Size_Line_Thin)
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
	
	Procedure Redraw_MediaBlock(*GadgetData.GadgetData, YPos, *Block.MediaBlock, CollisionDataLine)
		Protected XPos, Duration, BlockStart, Height, Width, Alpha = $FF, Unfolded = Bool(*GadgetData\Cont_Displayed_List()\Fold = #Unfolded And (*Block\Animated Or *Block\Container)), Loop, LoopEnd
		With *GadgetData
			If *Block\Drag
				Alpha = 80
			EndIf
			
			BlockStart = Max(*Block\BlockStart, \Meas_HPosition - 3) ; minus 3 to have the right corners correctly rounded even at the lowest zoom level.
			Duration = *Block\BlockEnd - BlockStart + 1
			
			BlockStart - \Meas_HPosition
			XPos = BlockStart * \Meas_TL_ColumnWidth
			SaveVectorState()
			
			MovePathCursor(XPos + 3.5, YPos + 4)
			AddPathLine(Duration * \Meas_TL_ColumnWidth - 7, 0, #PB_Path_Relative)
			VectorSourceColor(SetAlpha(Alpha, *Block\Color))
			StrokePath(6, #PB_Path_RoundEnd)
			
			Height = #Size_MediaBlock_Height - 3
			If Unfolded
				Height + (\Cont_Displayed_List()\SubLineCount * #Size_MediaBlock_Height)
			EndIf
			Width = Duration * \Meas_TL_ColumnWidth
			
			MovePathCursor(XPos, YPos + 5)
			
			AddPathArc(0, Height - 3, Width, Height - 3, 3, #PB_Path_Relative)
			AddPathArc(Width - 3, 0, Width - 3, - Height, 3, #PB_Path_Relative)
			AddPathLine(0, 2 * 3 - Height, #PB_Path_Relative)
			ClosePath()
			VectorSourceColor(SetAlpha(Alpha, $FF202020))
			FillPath()
			
			Height = Height - 1
			Width = Width - 2
			
			MovePathCursor(XPos + 1, YPos + 5)
			
			AddPathArc(0, Height - 3, Width, Height - 3, 3, #PB_Path_Relative)
			AddPathArc(Width - 3, 0, Width - 3, - Height, 3, #PB_Path_Relative)
			AddPathLine(0, 2 * 3 - Height, #PB_Path_Relative)
			ClosePath()
			
			VectorSourceColor(SetAlpha(Alpha,\Color_MediaBlock_Back[*Block\State]))
			FillPath(#PB_Path_Preserve)
			
			ClipPath()
			
 			If *Block\Duration * \Meas_TL_ColumnWidth >= 37 ; Calculate the width of the text to see if we should display it
				XPos = Min(Max(XPos, -3), (*Block\BlockEnd - \Meas_HPosition) * \Meas_TL_ColumnWidth - 37)
				
				VectorSourceColor(SetAlpha(Alpha, \Color_MediaBlock_Front[*Block\State]))
				MovePathCursor( XPos + 8, YPos + 11)
				VectorFont(Icon, 28)
				DrawVectorText(*Block\Icon)
				
				VectorFont(Font, 14)
				MovePathCursor(XPos + 47.5, YPos + 17)
				DrawVectorText(*Block\Text)
			EndIf
			
			; If unfolded, draw the alterning color lines.
			If Unfolded
				LoopEnd = min(ArraySize(\State_Collision_Line()) - CollisionDataLine, \Cont_Displayed_List()\SubLineCount) -1
				YPos + \Meas_TL_LineHeight - 14
				VectorSourceColor(SetAlpha($35,0))
				For Loop = 0 To LoopEnd Step 2
					AddPathBox(XPos + 1, YPos + Loop * #Size_MediaBlock_Height, Width, #Size_MediaBlock_Height)
				Next
				
				FillPath()
			EndIf
			RestoreVectorState()
			
		EndWith
		ProcedureReturn *Block\BlockEnd
	EndProcedure
	
	Procedure Redraw_Line(*GadgetData.GadgetData, YPos, OddLine, CollisionDataLine, UpdateCollisionData = #False)
		Protected Loop, LoopEnd, LineHeight, StepCount, DataLineLoop, DataLineLoopEnd
		
		With *GadgetData
			Protected ColumnLoop, ColumnLoopEnd = \Meas_HPosition + \Meas_Displayed_Column_Count
			
			If \Cont_Displayed_List()\Fold = #Unfolded
				StepCount + \Cont_Displayed_List()\SubLineCount
			EndIf
			
			LineHeight =  \Meas_TL_LineHeight + StepCount * #Size_MediaBlock_Height
			
			If Not OddLine
				AddPathBox(0, YPos, \Meas_Body_Width, LineHeight)
				VectorSourceColor(SetAlpha($FF, \Color_List_Back_Alternate[\Cont_Displayed_List()\State]))
				FillPath()
			ElseIf \Cont_Displayed_List()\State
				AddPathBox(0, YPos, \Meas_Body_Width, LineHeight)
				VectorSourceColor(SetAlpha($FF, \Color_List_Back[\Cont_Displayed_List()\State]))
				FillPath()
			EndIf
			
			ForEach \Cont_Displayed_List()\MediaBlock()
				If \Cont_Displayed_List()\MediaBlock()\BlockStart > ColumnLoopEnd
					Break
				ElseIf \Cont_Displayed_List()\MediaBlock()\BlockEnd > \Meas_HPosition
					
					If UpdateCollisionData
						LoopEnd = Min(\Cont_Displayed_List()\MediaBlock()\BlockEnd, \Meas_HPosition + \Meas_Displayed_Column_Count)
						
						If \Cont_Displayed_List()\Fold = #Unfolded And (\Cont_Displayed_List()\MediaBlock()\Animated Or \Cont_Displayed_List()\MediaBlock()\Container)
							DataLineLoopEnd = min(ArraySize(\State_Collision_Line()), CollisionDataLine + StepCount)
							For Loop = Max(\Cont_Displayed_List()\MediaBlock()\BlockStart, \Meas_HPosition) To LoopEnd
								For DataLineLoop = CollisionDataLine To DataLineLoopEnd
									\State_Collision_Line(DataLineLoop)\Column(Loop) = \Cont_Displayed_List()\MediaBlock()
								Next
							Next
						Else
							For Loop = Max(\Cont_Displayed_List()\MediaBlock()\BlockStart, \Meas_HPosition) To LoopEnd
								\State_Collision_Line(CollisionDataLine)\Column(Loop) = \Cont_Displayed_List()\MediaBlock()
							Next
						EndIf
					EndIf
					
					Redraw_MediaBlock(*GadgetData, YPos + #Size_MediaBlock_VerticalMargin, \Cont_Displayed_List()\MediaBlock(), CollisionDataLine)
				EndIf
			Next
			
			ProcedureReturn StepCount
		EndWith
	EndProcedure
	
	; Misc
	Procedure Refit(Gadget, GadgetWidth, GadgetHeight)
		Protected *GadgetData.GadgetData = GetGadgetData(Gadget), Loop
		
		With *GadgetData
			GadgetHeight - #Size_Header_Height
			
			\Meas_List_Height = GadgetHeight
			
			\Meas_Body_Width = GadgetWidth - \Meas_List_Width
			
			\Meas_Displayed_Line_Count = Round(\Meas_List_Height / #Size_MediaBlock_Height, #PB_Round_Up)
			\Meas_Displayed_Column_Count = Round(\Meas_Body_Width / \Meas_TL_ColumnWidth, #PB_Round_Up)
			
			ReDim \State_Collision_Line(\Meas_Displayed_Line_Count)
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
	
	Procedure CompareAscending(*a.MBAdress, *b.MBAdress)
		ProcedureReturn *a\Object\BlockStart - *b\Object\BlockStart
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
; CursorPosition = 2306
; FirstLine = 413
; Folding = AAKABDAAAkIAAA5IAAAAAABBA9
; EnableXP