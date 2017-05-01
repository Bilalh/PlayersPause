#!/usr/bin/env osascript
# Allow controls videos in safari on various sites, and other players such as iTunes.
on run argv
	
	# html5 video
	set seekjs to "var video =document.getElementsByTagName('video')[0]; video.currentTime+="
	set togglejs to "var video =document.getElementsByTagName('video')[0]; if(video.paused === false){video.pause();}else{video.play();} "
	
	# Amazon
	set amazon_foward to "document.getElementsByClassName('fastSeekForward')[0].click()"
	set amazon_backward to "document.getElementsByClassName('fastSeekBack')[0].click()"
	set amazon_toogle to "[].concat.apply([], ['playIcon', 'animatedPlayIcon', 'pausedIcon', 'animatedPausedIcon'].map(x => [].slice.call(document.getElementsByClassName(x)) ))[0].click()"
	
	# Netflix
	set netflix_toggle to "document.getElementsByClassName('player-play-pause')[0].click();"
	
	# mpv-player
	set mpv_fwd to "echo 'no-osd seek 10'"
	set mpv_back to "echo 'no-osd seek -10'"
	set mpv_toogle to "echo 'cycle pause' "
	
	set forward to {common:seekjs & "15", mpv:mpv_fwd, amazon:amazon_foward, netflix:""}
	set backward to {common:seekjs & "-15", mpv:mpv_back, amazon:amazon_backward, netflix:""}
	set toggle to {common:togglejs & "-15", mpv:mpv_toogle, amazon:amazon_toogle, netflix:netflix_toggle}
	
	set theData to toggle
	set theKind to "toggle"
	
	set mapping to {{"toggle", toggle}, {"forward", forward}, {"backward", backward}}
	if (count of argv) ³ 1 then
		set theKey to item 1 of argv
		repeat with i from 1 to length of mapping
			set ele to item i of mapping
			if item 1 of ele is equal to theKey then
				set theData to item 2 of ele
				set theKind to theKey
			end if
		end repeat
	end if
	
	set do_mpv to onSafari(theData)
	
	tell application "System Events"
		if do_mpv and (exists process "mpv") then
			tell process "mpv"
				do shell script mpv of theData & " >>  ~/.mplayer/pipe"
				return
			end tell
		end if
	end tell
	
	# Always Opens VLC even if it is not already running
	(*
	tell application "VLC"
		if it is running then
			
			if theKind is equal to "toggle" then
				play
				return
			else if theKind is equal to "forward" then
				step forward
				return
			else if theKind is equal to "backward" then
				step backward
				return
			end if
		end if
	end tell
	
*)
	
	tell application "iTunes"
		if it is running then
			if theKind is equal to "toggle" then
				playpause
				return
			else if theKind is equal to "forward" then
				play (next track)
				return
			else if theKind is equal to "backward" then
				play (previous track)
				return
			end if
		end if
	end tell
	
	
end run

on onSafari(theData)
	tell application "Safari"
		if it is running and (count of windows) > 0 then
			repeat with winId from 1 to (count of windows)
				repeat with tabId from 1 to (count of tabs of window winId)
					set theTab to tab tabId of window winId
					set theUrl to the URL of theTab
					
					if theUrl starts with "https://www.netflix.com/watch/" then
						set js to netflix of the theData
						do JavaScript js in theTab
						return false
					end if
					
					if theUrl starts with "https://www.amazon.co.uk/gp/video/" then
						set js to amazon of the theData
						do JavaScript js in theTab
						return false
					end if
					
					# We can not return the video tag so we convert it to a boolean 
					set hasVideo to do JavaScript "!!document.getElementsByTagName('video')[0];" in theTab
					if hasVideo then
						set js to common of the theData
						do JavaScript js in theTab
						return false
					end if
					
					
				end repeat
			end repeat
		end if
	end tell
	return true
end onSafari


