// Open editable text and unregistered file types in Neovide.
item(mode="single" type="file"
	where=path.exists(neovide_exe) && (
		str.equals(str.lower(sel.file.ext), code_ext)
		|| str.lower(sel.file.ext)==".ahk"
		|| sel.file.ext==""
		|| !reg.exists('HKCR\@sel.file.ext')
	)
	pos=0 title="通过 Neovide 打开"
	image=neovide_exe
	cmd=neovide_exe
	args='"@sel.path"')

item(mode="single" type="dir"
	where=path.exists(neovide_exe)
	pos=0 title="通过 Neovide 打开"
	image=neovide_exe
	cmd=neovide_exe
	args='"@sel.path"')

item(mode="none" type="back"
	where=path.exists(neovide_exe)
	pos=0 title="通过 Neovide 打开"
	image=neovide_exe
	cmd=neovide_exe
	args='"@sel.workdir"')
