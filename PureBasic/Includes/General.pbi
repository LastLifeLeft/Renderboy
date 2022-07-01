DeclareModule General
	; Public variables, constants and structures
	#AppName = "Renderboy"
	
	; Public procedure declarations
	Declare Init()
	Declare Min(A, B)
	Declare Max(A, B)
EndDeclareModule

DeclareModule MainWindow
	; Public procedure declarations
	;{ Colors
	#Color_Window_Border = $27293D
	#Color_Gadget_BackCold = $1E1E2F
	
	#Color_Ressources_Media = $4ABF10
	#Color_Ressources_Audio = $FF0F84
	#Color_Ressources_3D = $8E0FEF
	#Color_Ressources_Overlay = $FFAC65
	#Color_Ressources_Modifiers = $0FCAEF
	;}
	Global Library, Tab
	
	
	; Public procedure declarations
	Declare Open()
EndDeclareModule

DeclareModule Project
	Enumeration 1 ; Asset types
		#Asset_Image
		#Asset_Video
		
		
		#__Asset_Type_Count
	EndEnumeration
	
	Enumeration AssetGenre
		#Media
		#Audio
		#_3D
		#Overlay
		#Modifiers
	EndEnumeration
	
	Global Dim AssetIcon(#__Asset_Type_Count - 1)
	
	Structure Asset
		Type.i
		Name.s
		PreviewImage.i
	EndStructure
	
	Structure AssetArray
		List List.Asset()
	EndStructure
	
	Structure Project
		Assets.AssetArray[5]
; 		List Library_Media.Asset()
; 		List Library_Audio.Asset()
; 		List Library_3D.Asset()
; 		List Library_Overlay.Asset()
; 		List Library_Elements.Asset()
	EndStructure
	
	Global Project.Project
	
	Declare New()
	Declare AddAsset(Assets.s)
EndDeclareModule

Module General
	EnableExplicit
	UsePNGImageDecoder()
	
	
	; Public procedures
	Procedure Init()
		UsePNGImageDecoder()
		UseJPEGImageDecoder()
		UseJPEG2000ImageDecoder()
		
		MainWindow::Open()
	EndProcedure
	
	Procedure Min(A, B)
		If A > B
			ProcedureReturn B
		EndIf
		ProcedureReturn A
	EndProcedure
	
	Procedure Max(A, B)
		If A < B
			ProcedureReturn B
		EndIf
		ProcedureReturn A
	EndProcedure
	
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 56
; FirstLine = 20
; Folding = --
; EnableXP
; DPIAware