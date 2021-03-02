tell application "TimingHelper"
	set usageData to get time summary between (current date) and (current date)
	set score to (round (productivity score of usageData) * 100) as string
	set total to overall total of usageData
	delete usageData -- this is required to avoid accumulating old summaries (and thus leaking memory)
	set timeString to my FormatSeconds(total)
	return timeString & " (" & score & "%)"
end tell


on FormatSeconds(totalSeconds)
	set theHours to (totalSeconds div hours)
	set theRemainderSeconds to (totalSeconds mod hours)
	set theMinutes to (theRemainderSeconds div minutes)
	set theRemainderSeconds to (theRemainderSeconds mod minutes)
	
	if length of (theMinutes as text) = 1 then
		set theMinutes to "0" & (theMinutes as text)
	end if
	
	set theTimeString to theHours & ":" & theMinutes as text
	
	return theTimeString
end FormatSeconds