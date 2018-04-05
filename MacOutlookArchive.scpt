set myName to "Mac Outlook Archive"
set mailName to "Microsoft Outlook"
set inboxName to "Inbox"
set archiveName to "Archive"
set debug to true

tell application "Microsoft Outlook"
	set frontWin to front window
	set winName to name of frontWin

	set frontWinView to null
	try
		set frontWinView to view of frontWin
	on error errorMessage number errorNumber
		if debug then
			display notification ("Window \"" & winName & "\" is not a Main Window") with title "No messages selected"
		end if
		return 0
	end try
	if frontWinView is not "mail view" then
		if debug then
			display notification ("Window \"" & winName & "\" does not have email open") with title "No messages selected"
		end if
		return 0
	end if

	set currMsgs to current messages
	if currMsgs = {} then
		if debug then
			display notification ("No selected messages in window: " & winName) with title "No messages selected"
		end if
		return 0
	end if
	set firstMsg to item 1 of currMsgs
	set currAccount to account of firstMsg
	set allFolders to mail folder of currAccount

	set destFolder to null
	repeat with theFolder in allFolders
		if name of theFolder is archiveName then
			set destFolder to theFolder
		end if
	end repeat

	if destFolder is null then
		set theInbox to null
		repeat with theFolder in allFolders
			if name of theFolder is inboxName then
				set theInbox to theFolder
			end if
		end repeat
		if theInbox is null then
			display alert myName message ("Neither \"" & inboxName & "\" nor \"" & archiveName & "\" was found") as critical
			return 0
		end if
		try
			set destFolder to folder archiveName of theInbox
		on error errorMessage number errorNumber
			display alert ("Archive folder not found: " & archiveName) message (errorMessage & "
Error number: " & errorNumber) as critical
			return 0
		end try
	end if

	try
		repeat with theMessage in currMsgs
			set (is read) of theMessage to true
			move theMessage to destFolder
		end repeat
	on error errorMessage number errorNumber
		display alert "Archiving failed" message (errorMessage & "
Error number: " & errorNumber) as critical
		return 0
	end try

	if debug then
		set msgCount to (count items in currMsgs)
		if msgCount = 1 then
			set msg to item 1 of currMsgs
			set subj to subject of msg
			display notification with title myName subtitle ("Archived: " & subj)
		else
			display notification with title myName subtitle ("Archived " & msgCount & " messages")
		end if
	end if
end tell
