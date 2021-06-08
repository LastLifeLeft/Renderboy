DeclareModule Ease
	Declare.f linear(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InQuad(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f OutQuad(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InOutQuad(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InCubic(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f OutCubic(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InOutCubic(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InQuart(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f OutQuart(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InOutQuart(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InQuint(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f OutQuint(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InOutQuint(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InSine(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f OutSine(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InOutSine(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InExpo(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f) 
	Declare.f OutExpo(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InOutExpo(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InCirc(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f OutCirc(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
	Declare.f InOutCirc(CurrentTime.f, InitialValue.f, TargetValue.f, Duration.f)
EndDeclareModule

Module Ease
	Procedure.f linear(t.f, b.f, c.f, d.f)
		ProcedureReturn c*t/d + b
	EndProcedure
	
	Procedure.f InQuad(t.f, b.f, c.f, d.f)
		t / d
		ProcedureReturn c*t*t + b
	EndProcedure
	
	Procedure.f OutQuad(t.f, b.f, c.f, d.f)
		t / d
		ProcedureReturn -c * t*(t-2) + b
	EndProcedure
	
	Procedure.f InOutQuad(t.f, b.f, c.f, d.f)
		t = t/(d/2)
		If (t < 1)
			ProcedureReturn c/2*t*t + b
		EndIf
		t - 1
		ProcedureReturn -c/2 * (t*(t-2) - 1) + b
		
	EndProcedure
	
	Procedure.f InCubic(t.f, b.f, c.f, d.f)
		t / d
		ProcedureReturn c*t*t*t + b
	EndProcedure
	
	Procedure.f OutCubic(t.f, b.f, c.f, d.f)
		t / d
		t - 1		
		ProcedureReturn c*(t*t*t + 1) + b
	EndProcedure
	
	Procedure.f InOutCubic(t.f, b.f, c.f, d.f)
		t = t / (d/2)
		If (t < 1)
			ProcedureReturn c/2*t*t*t + b
		EndIf
		t - 2																
		ProcedureReturn c/2*(t*t*t + 2) + b		
		
	EndProcedure
	
	Procedure.f InQuart(t.f, b.f, c.f, d.f)
		t / d
		ProcedureReturn c*t*t*t*t + b
	EndProcedure
	
	Procedure.f OutQuart(t.f, b.f, c.f, d.f)
		t / d
		t- 1		
		ProcedureReturn -c * (t*t*t*t - 1) + b
	EndProcedure
	
	Procedure.f InOutQuart(t.f, b.f, c.f, d.f)
		t = t / (d/2)
		If (t < 1)
			ProcedureReturn c/2*t*t*t*t + b
		EndIf
		t - 2																	
		ProcedureReturn -c/2 * (t*t*t*t - 2) + b
		
	EndProcedure
	
	Procedure.f InQuint(t.f, b.f, c.f, d.f)
		t / d
		ProcedureReturn c*t*t*t*t*t + b
	EndProcedure
	
	Procedure.f OutQuint(t.f, b.f, c.f, d.f)
		t / d
		t - 1		
		ProcedureReturn c*(t*t*t*t*t + 1) + b
	EndProcedure
	
	Procedure.f InOutQuint(t.f, b.f, c.f, d.f)
		t = t / (d/2)
		If (t < 1)
			ProcedureReturn c/2*t*t*t*t*t + b
		EndIf
		t - 2																		
		ProcedureReturn c/2*(t*t*t*t*t + 2) + b		
		
	EndProcedure
	
	Procedure.f InSine(t.f, b.f, c.f, d.f)
		ProcedureReturn -c * Cos(t/d * (#PI/2)) + c + b
	EndProcedure
	
	Procedure.f OutSine(t.f, b.f, c.f, d.f)
		ProcedureReturn c * Sin(t/d * (#PI/2)) + b
	EndProcedure
	
	Procedure.f InOutSine(t.f, b.f, c.f, d.f)
		ProcedureReturn -c/2 * (Cos(#PI*t/d) - 1) + b
	EndProcedure
	
	Procedure.f InExpo(t.f, b.f, c.f, d.f) 
		ProcedureReturn c * Pow( 2, 10 * (t/d - 1) ) + b
	EndProcedure
	
	Procedure.f OutExpo(t.f, b.f, c.f, d.f)
		ProcedureReturn c * ( -Pow( 2, -10 * t/d ) + 1 ) + b
	EndProcedure
	
	Procedure.f InOutExpo(t.f, b.f, c.f, d.f)
		t =t / (d/2)
		If (t < 1)
			ProcedureReturn c/2 * Pow( 2, 10 * (t - 1) ) + b
		EndIf
		t-1																													
		ProcedureReturn c/2 * ( -Pow( 2, -10 * t) + 2 ) + b			
		
	EndProcedure
	
	Procedure.f InCirc(t.f, b.f, c.f, d.f)
		t / d
		ProcedureReturn -c * (Sqr(1 - t*t) - 1) + b
	EndProcedure
	
	Procedure.f OutCirc(t.f, b.f, c.f, d.f)
		t / d
		t-1
		ProcedureReturn c * Sqr(1 - t*t) + b
	EndProcedure
	
	Procedure.f InOutCirc(t.f, b.f, c.f, d.f)
		t = t /(d/2)
		If (t < 1)
			ProcedureReturn -c/2 * (Sqr(1 - t*t) - 1) + b
		EndIf
		t - 2																											
		ProcedureReturn c/2 * (Sqr(1 - t*t) + 1) + b					
		
	EndProcedure
	
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; Folding = AAAA-
; EnableXP