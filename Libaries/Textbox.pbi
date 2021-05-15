; Module version of https://www.purebasic.fr/english/viewtopic.php?f=12&t=75341

DeclareModule TextBox
	EnumerationBinary
		#TEXT_Right
		#TEXT_HCenter
		#TEXT_VCenter
		#TEXT_Bottom
	EndEnumeration
	
	Declare DrawVectorTextBox(x, y, dx, dy, text.s, flags = 0)
	Declare DrawTextBox(x, y, dx, dy, text.s, flags = 0)
	Declare.s WrapText(Width, Text.s, LineLimit = -1, FontID = 0)
EndDeclareModule

Module TextBox
	EnableExplicit
	
	Procedure DrawVectorTextBox(x, y, dx, dy, text.s, flags = 0)
		Protected is_right, is_hcenter, is_vcenter, is_bottom
		Protected text_width.d, text_height.d, text_line.d
		Protected text_x.l, text_y.l, break_y.d
		Protected text2.s, rows, row, row_text.s, row_text1.s, out_text.s, start, count
		
		; Flags
		is_right = flags & #TEXT_Right
		is_hcenter = flags & #TEXT_HCenter
		is_vcenter = flags & #TEXT_VCenter
		is_bottom = flags & #TEXT_Bottom
		
		; Übersetze Zeilenumbrüche
		text = ReplaceString(text, #LFCR$, #LF$)
		text = ReplaceString(text, #CRLF$, #LF$)
		text = ReplaceString(text, #CR$, #LF$)
		
		; Erforderliche Zeilenumbrüche setzen
		rows = CountString(text, #LF$)
		For row = 1 To rows + 1
			text2 = StringField(text, row, #LF$)
			If text2 = ""
				out_text + #LF$
				Continue
			EndIf
			start = 1
			count = CountString(text2, " ") + 1
			Repeat
				row_text = StringField(text2, start, " ") + " "
				Repeat
					start + 1
					row_text1 = StringField(text2, start, " ")
					If VectorTextWidth(row_text + row_text1) < dx - 12
						row_text + row_text1 + " "
					Else
						Break
					EndIf
				Until start > count
				out_text + RTrim(row_text) + #LF$
			Until start > count
		Next
		
		; Berechne Y-Position
		text_height = VectorTextHeight("X") * 1.1
		text_line = text_height * 0.25
		rows = CountString(out_text, #LF$)
		If is_vcenter
			text_y = Round((dy * 0.5 - text_height * 0.5) - (text_height * 0.5 * (rows-1)), #PB_Round_Nearest)
		ElseIf is_bottom
			text_y = Round(dy - (text_height * rows) - text_line, #PB_Round_Nearest)
		Else
			text_y = Round(text_line, #PB_Round_Nearest)
		EndIf
		
		; Korrigiere Y-Position
		While text_y < text_line
			text_y = text_line
		Wend
		
		break_y = dy - text_height
		
		; Text ausgeben
		For row = 1 To rows
			row_text = StringField(out_text, row, #LF$)
			If is_hcenter
				text_x = Round(dx * 0.5 - VectorTextWidth(row_text) * 0.5, #PB_Round_Nearest)
			ElseIf is_right
				text_x = Round(dx - VectorTextWidth(row_text) - 4, #PB_Round_Nearest)
			Else
				text_x = 4
			EndIf
			MovePathCursor(x + text_x, y + text_y)
			DrawVectorText(row_text)
			text_y + text_height
			If text_y > break_y
				Break
			EndIf
		Next
		
		ProcedureReturn rows
		
	EndProcedure
	
	Procedure DrawTextBox(x, y, dx, dy, text.s, flags = 0)
		Protected is_right, is_hcenter, is_vcenter, is_bottom
		Protected text_width, text_height
		Protected text_x, text_y, break_y
		Protected text2.s, rows, row, row_text.s, row_text1.s, out_text.s, start, count
		
		; Flags
		is_right = flags & #TEXT_Right
		is_hcenter = flags & #TEXT_HCenter
		is_vcenter = flags & #TEXT_VCenter
		is_bottom = flags & #TEXT_Bottom
		
		; Übersetze Zeilenumbrüche
		text = ReplaceString(text, #LFCR$, #LF$)
		text = ReplaceString(text, #CRLF$, #LF$)
		text = ReplaceString(text, #CR$, #LF$)
		
		; Erforderliche Zeilenumbrüche setzen
		rows = CountString(text, #LF$)
		For row = 1 To rows + 1
			text2 = StringField(text, row, #LF$)
			If text2 = ""
				out_text + #LF$
				Continue
			EndIf
			start = 1
			count = CountString(text2, " ") + 1
			Repeat
				row_text = StringField(text2, start, " ") + " "
				Repeat
					start + 1
					row_text1 = StringField(text2, start, " ")
					If TextWidth(row_text + row_text1) < dx - 12
						row_text + row_text1 + " "
					Else
						Break
					EndIf
				Until start > count
				out_text + RTrim(row_text) + #LF$
			Until start > count
		Next
		
		; Berechne Y-Position
		text_height = TextHeight("X")
		rows = CountString(out_text, #LF$)
		If is_vcenter
			CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
				text_y = (dy * 0.5 - text_height * 0.5) - (text_height * 0.5 * (rows-1)) - 2
			CompilerElse
				text_y = (dy * 0.5 - text_height * 0.5) - (text_height * 0.5 * (rows-1))
			CompilerEndIf
		ElseIf is_bottom
			text_y = dy - (text_height * rows) - 2
		Else
			text_y = 2
		EndIf
		
		; Korrigiere Y-Position
		While text_y < 2
			text_y = 2;+ text_height
		Wend
		
		break_y = dy - text_height * 0.5
		
		; Text ausgeben
		For row = 1 To rows
			row_text = StringField(out_text, row, #LF$)
			If is_hcenter
				text_x = dx * 0.5 - TextWidth(row_text) * 0.5
			ElseIf is_right
				text_x = dx - TextWidth(row_text) - 4
			Else
				text_x = 4
			EndIf
			DrawText(x + text_x, y + text_y, row_text)
			text_y + text_height
			If text_y > break_y
				Break
			EndIf
		Next
		
		ProcedureReturn rows
		
	EndProcedure
	
	Procedure.s WrapText(Width, Text.s, LineLimit = -1, FontID = 0)
		Protected text2.s, rows, row, row_text.s, row_text1.s, out_text.s, start, count, Line
		Static image
		
		; Übersetze Zeilenumbrüche
		text = ReplaceString(text, #LFCR$, #LF$)
		text = ReplaceString(text, #CRLF$, #LF$)
		text = ReplaceString(text, #CR$, #LF$)
		
		If StartDrawing(ImageOutput(image))
			If FontID
				DrawingFont(FontID)
			EndIf
			
			If LineLimit < 1
				LineLimit = 65535
			EndIf
			
			rows = CountString(text, #LF$)
			For row = 1 To rows + 1
				text2 = StringField(text, row, #LF$)
				If text2 = ""
					out_text + #LF$
					Continue
				EndIf
				start = 1
				count = CountString(text2, " ") + 1
				Repeat
					row_text = StringField(text2, start, " ") + " "
					Repeat
						start + 1
						row_text1 = StringField(text2, start, " ")
						If TextWidth(row_text + row_text1) < Width - 12
							row_text + row_text1 + " "
						Else
							Break
						EndIf
					Until start > count
					
					Line + 1
					
					If Line = LineLimit
						out_text + "..."
						Break
					EndIf
					
					out_text + RTrim(row_text) + #LF$
					
				Until start > count
			Next
			out_text = RTrim(out_text, #LF$)
			StopDrawing()
		EndIf
		
		ProcedureReturn out_text
		
	EndProcedure
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 187
; FirstLine = 3
; Folding = j-
; EnableXP