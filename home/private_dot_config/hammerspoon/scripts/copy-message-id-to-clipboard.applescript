tell application "Mail"
	
	set theSelection to selection
	set theMessage to first item of theSelection
	set theUrl to "message://<" & message id of theMessage & ">"
	set the clipboard to theUrl
	
end tell