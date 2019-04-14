on run argv
	tell application "Terminal" to do script "cd " & quoted form of (item 1 of argv) & " ; ./start-wiremock.sh " & quoted form of (item 1 of argv) & ""
end run
