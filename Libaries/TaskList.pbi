DeclareModule TaskList
	Enumeration
		#Action_Undo = 0
		#Action_Redo
	EndEnumeration
	
	Declare Create(Maximum = -1)
	Declare Free(TaskList)
	Declare Clear(TaskList)
	Declare ReDo(TaskList)
	Declare Undo(TaskList)
	Declare NewTask(TaskList, *Data, *Callback)
EndDeclareModule

Module TaskList
	;{ Private variables, structures, constants...
	Prototype UndoRedoProcedure(*Data, Action)
	
	Structure Task
		Callback.UndoRedoProcedure
		*Data
	EndStructure
	
	Structure TaskList
		Maximum.i
		List Task.Task()
	EndStructure
	;}
	
	;{ Public procedures
	Procedure Create(Maximum = -1)
		Protected *Data.TaskList = AllocateStructure(TaskList)
		
		*Data\Maximum = Maximum
		
		ProcedureReturn *Data
	EndProcedure
	
	Procedure Free(*TaskList.TaskList)
		Clear(*TaskList.TaskList)
		FreeStructure(*TaskList)
	EndProcedure
	
	Procedure Clear(*TaskList.TaskList)
		ForEach *TaskList\Task()
			FreeStructure(*TaskList\Task()\Data)
		Next
	EndProcedure
	
	Procedure ReDo(*TaskList.TaskList)
		If NextElement(*TaskList\Task())
			If Not *TaskList\Task()\Callback(*TaskList\Task()\Data, #True)
				PreviousElement(*TaskList\Task())
			EndIf
		EndIf
	EndProcedure
	
	Procedure Undo(*TaskList.TaskList)
		If ListIndex(*TaskList\Task()) > -1
			If *TaskList\Task()\Callback(*TaskList\Task()\Data, #False)
				If Not PreviousElement(*TaskList\Task())
					ResetList(*TaskList\Task())
				EndIf
			EndIf
		EndIf
	EndProcedure
	
	Procedure NewTask(*TaskList.TaskList, *Data, *Callback)
		If ListIndex(*TaskList\Task()) < ListSize(*TaskList\Task()) - 1
			While NextElement(*TaskList\Task())
				FreeStructure(*TaskList\Task()\Data)
				DeleteElement(*TaskList\Task())
			Wend
		EndIf
		
		AddElement(*TaskList\Task())
		*TaskList\Task()\Data = *Data
		*TaskList\Task()\Callback = *Callback
	EndProcedure
	;}
EndModule

























































; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 63
; FirstLine = 12
; Folding = ---
; EnableXP