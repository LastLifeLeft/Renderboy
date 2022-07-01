DeclareModule TimeLine
	
	Declare Gadget(x, y, Width, Height)
	
EndDeclareModule

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
	Structure TLData
		Container.i
		LeftList.i
		Header.i
	EndStructure
	;}
	
	#Color_Gadget_BackCold = $1E1E2F
	
	Procedure Gadget(x, y, Width, Height)
		Protected Result
		Result = ContainerGadget(#PB_Any, x, y, Width, Height, #PB_Container_BorderLess)
		SetGadgetColor(Result, #PB_Gadget_BackColor, FixColor(#Color_Gadget_BackCold))
		
		CloseGadgetList()
		ProcedureReturn Result
	EndProcedure
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 37
; Folding = 8-
; EnableXP
; DPIAware