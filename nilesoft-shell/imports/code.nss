// Replace VS Code's broad registry item with context-aware commands.
item(mode="single" type="file"
	where=path.exists(code_exe) && str.equals(str.lower(sel.file.ext), code_ext)
	pos=0 title="通过 Code 打开"
	image=code_exe
	cmd=code_exe
	args='"@sel.path"')

item(mode="single" type="dir" where=path.exists(code_exe)
	pos=0 title="通过 Code 打开"
	image=code_exe
	cmd=code_exe
	args='"@sel.path"')

item(mode="none" type="back" where=!wnd.is_desktop && path.exists(code_exe) pos=0
	title="通过 Code 打开"
	image=code_exe
	cmd=code_exe
	args='"@sel.workdir"')

item(mode="none" type="back" where=wnd.is_desktop && path.exists(code_exe) pos=0
	title="通过 Code 打开"
	image=code_exe
	cmd=code_exe
	args='"@sel.workdir"')
