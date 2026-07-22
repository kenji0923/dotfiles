IsVimWindow() {
	activeTitle := WinGetTitle("A")
	return RegExMatch(activeTitle, "i)(?:^| - )(?:VIM|NVIM|NEOVIM)$")
}

#HotIf IsVimWindow()
	sc07B::+F1
	sc079::+F2
#HotIf
