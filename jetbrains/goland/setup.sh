#!/bin/sh

echo "start kill GoLand app"
ps -ef | grep /Applications/GoLand.app/Contents/MacOS/goland | grep -v grep | awk '{print $2}' | xargs kill
echo "kill GoLand app complete"

echo "start install plugins"
open -na "GoLand.app" --args installPlugins IdeaVIM IdeaVimExtension AceJump eu.theblob42.idea.whichkey
echo "install plugins complete"
