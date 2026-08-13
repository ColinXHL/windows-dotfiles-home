// Global cleanup. These registrations stay installed but are not displayed.
modify(mode="none" find='"Open Git GUI here"|"Open Git Bash here"' vis=vis.remove)
modify(mode="none" find='Browse path with PeaZip' vis=vis.remove)
modify(mode="multiple" find='"Open Git GUI here"|"Open Git Bash here"' vis=vis.remove)
modify(mode="none" find='"Open with Neovide"' vis=vis.remove)
modify(mode="single" find='"Open with Neovide"' vis=vis.remove)
modify(mode="multiple" find='"Open with Neovide"' vis=vis.remove)
modify(mode="none" find='Code' vis=vis.remove)
modify(mode="multiple" find='Code' vis=vis.remove)
modify(mode="multiple"
	find='"上传钉钉并打开"|WPS|"加密菜单"|百度网盘|"自动备份该文件夹"|"手机打开"|"用手机打开"|"Word转PDF"|"同步至其它设备"|云打印'
	vis=vis.remove)
modify(mode="multiple" where=this.id==id.give_access_to vis=vis.remove)
modify(mode="multiple" find='"授予访问权限"' vis=vis.remove)
modify(mode="multiple" in=title.send_to find="PeaZip" vis=vis.remove)

// Commands that do not belong on a selected file.
modify(mode="multiple" type="file"
	where=str.equals(this.name, ["新建", "添加到收藏夹"])
	vis=vis.remove)
modify(mode="multiple" type="file"
	where=!str.equals(str.lower(sel.file.ext), code_ext) && this.id==id.edit
	vis=vis.remove)
modify(mode="multiple" type="file"
	where=!str.equals(str.lower(sel.file.ext), code_ext)
	find='"在记事本中编辑"'
	vis=vis.remove)
modify(mode="multiple" type="file"
	where=!str.equals(str.lower(sel.file.ext), printable_ext) && this.id==id.print
	vis=vis.remove)

// Opening actions occupy the first group; native Open with remains conditional.
modify(mode="multiple" type="file|dir" where=this.type==2 vis=vis.remove)
modify(mode="multiple" type="file|dir" where=this.id==id.open pos=0)
modify(mode="multiple" type="file"
	where=(this.id==id.open_with || str.contains(this.name, "打开方式"))
		&& str.equals(str.lower(sel.file.ext), code_ext)
	pos=4 sep="after" image=icon.open_with)
modify(mode="multiple" type="file"
	where=(this.id==id.open_with || str.contains(this.name, "打开方式"))
		&& !str.equals(str.lower(sel.file.ext), code_ext)
		&& !(str.equals(str.lower(sel.file.ext), executable_ext)
			|| (sel.file.ext==".lnk" && path.isexe(sel.lnk)))
	pos=1 sep="after" image=icon.open_with)
modify(mode="multiple" type="file"
	where=(this.id==id.open_with || str.contains(this.name, "打开方式"))
		&& (str.equals(str.lower(sel.file.ext), executable_ext)
			|| (sel.file.ext==".lnk" && path.isexe(sel.lnk)))
	pos=2 sep="after" image=icon.open_with)

modify(mode="multiple" type="file"
	where=str.equals(str.lower(sel.file.ext), executable_ext)
		&& this.id==id.run_as_administrator
	pos=1 image=icon.run_as_administrator)
modify(mode="multiple" type="file"
	where=str.equals(str.lower(sel.file.ext), code_ext)
	find='"在记事本中编辑"'
	pos=3)
modify(mode="multiple" type="file"
	where=str.equals(str.lower(sel.file.ext), printable_ext) && (
		this.id==id.print
		|| str.contains(this.name, "打印")
		|| str.contains(this.title, "打印")
	)
	pos=5 sep="before")

// MSI package actions are primary actions, not overflow commands.
modify(mode="single" type="file" where=sel.file.ext==".msi"
	find='安装' pos=0 image=icon.install)
modify(mode="single" type="file" where=sel.file.ext==".msi"
	find='修复' pos=1)
modify(mode="single" type="file" where=sel.file.ext==".msi"
	find='卸载' pos=2)

modify(mode="multiple" type="dir"
	where=path.exists(code_exe) && (
		this.id==id.open_powershell_window_here
		|| str.contains(this.name, "终端")
		|| str.contains(this.title, "终端")
	)
	pos=indexof("通过 Code 打开"))
modify(mode="multiple" type="dir"
	where=!path.exists(code_exe) && (
		this.id==id.open_powershell_window_here
		|| str.contains(this.name, "终端")
		|| str.contains(this.title, "终端")
	)
	pos=1)

// Keep folder editors together: Terminal, Code, then Neovide.
modify(mode="multiple" type="dir"
	where=path.exists(neovide_exe) && path.exists(code_exe)
	find='"通过 Neovide 打开"'
	pos=indexof("通过 Code 打开", 1))
modify(mode="multiple" type="dir"
	where=path.exists(neovide_exe) && !path.exists(code_exe)
	find='"通过 Neovide 打开"'
	pos=indexof("在终端中打开", 1))

// Keep only relevant actions at the top level; collect everything else.
menu(mode="multiple" type="file|dir" title="更多操作"
	pos="bottom" sep="before" image=icon.more_options)
{
	modify(mode="multiple" type="file|dir"
		where=this.type!=2
			&& !this.id(
				id.open,
				id.open_with,
				id.copy_as_path,
				id.cut,
				id.copy,
				id.delete,
				id.rename,
				id.properties
			)
			&& !str.contains(this.name, "打开方式")
			&& !(this.id==id.run_as_administrator
				&& (str.equals(str.lower(sel.file.ext), executable_ext)
					|| (sel.file.ext==".lnk" && path.isexe(sel.lnk))))
			&& !((this.id==id.print
				|| str.contains(this.name, "打印")
				|| str.contains(this.title, "打印"))
				&& str.equals(str.lower(sel.file.ext), printable_ext))
			&& !(sel.file.ext==".msi" && (
				str.contains(this.name, "安装")
				|| str.contains(this.name, "修复")
				|| str.contains(this.name, "卸载")
			))
			&& !(str.equals(this.name, ["在记事本中编辑"])
				&& str.equals(str.lower(sel.file.ext), code_ext))
			&& !((this.id==id.open_powershell_window_here
				|| str.contains(this.name, "终端")
				|| str.contains(this.title, "终端"))
				&& sel.directory.length>0)
			&& !(sel.directory.length>0 && (
				str.contains(this.name, "PeaZip")
				|| str.contains(this.title, "PeaZip")
			))
		menu="更多操作")

	// PeaZip's registry submenu is moved explicitly because it is a cascaded menu.
	modify(mode="multiple" type="file"
		find='"PeaZip"' menu="更多操作")
}

// Keep Explorer's location command in the primary opening-actions group.
modify(mode="multiple" type="file|dir"
	find='"打开文件所在位置"'
	menu="/" pos=indexof("打开", 1) image=icon.open_file_location)

// PeaZip is a primary folder tool and follows the last available editor.
modify(mode="multiple" type="dir"
	where=path.exists(peazip_exe) && path.exists(neovide_exe)
	find='"PeaZip"' menu="/" pos=indexof("通过 Neovide 打开", 1))
modify(mode="multiple" type="dir"
	where=path.exists(peazip_exe) && !path.exists(neovide_exe) && path.exists(code_exe)
	find='"PeaZip"' menu="/" pos=indexof("通过 Code 打开", 1))
modify(mode="multiple" type="dir"
	where=path.exists(peazip_exe) && !path.exists(neovide_exe) && !path.exists(code_exe)
	find='"PeaZip"' menu="/" pos=indexof("在终端中打开", 1))
modify(mode="multiple" type="dir"
	where=!path.exists(peazip_exe)
	find='"PeaZip"' vis=vis.remove)

// Non-executable files must not expose Run as administrator as a primary action.
modify(mode="multiple" type="file"
	where=(this.id==id.run_as_administrator
		|| str.contains(this.name, "以管理员身份运行")
		|| str.contains(this.title, "以管理员身份运行"))
		&& !str.equals(str.lower(sel.file.ext), executable_ext)
		&& !(sel.file.ext==".lnk" && path.isexe(sel.lnk))
	menu="更多操作")

// Keep Run as administrator at the top for shortcuts targeting executables.
modify(mode="single" type="file"
	where=this.id==id.run_as_administrator
		&& sel.file.ext==".lnk"
		&& path.isexe(sel.lnk)
	menu="/" pos=1 sep="after" image=icon.run_as_administrator)

// Keep native file-operation order and place Copy path directly after Copy.
modify(mode="multiple" type="file" where=this.id==id.cut
		&& str.equals(str.lower(sel.file.ext), code_ext)
	pos=5 sep="before" image=icon.cut)
modify(mode="multiple" type="file" where=this.id==id.cut
		&& !str.equals(str.lower(sel.file.ext), code_ext)
	sep="before" image=icon.cut)
modify(mode="multiple" type="dir" where=this.id==id.cut && path.exists(peazip_exe)
	pos=indexof("PeaZip", 1) sep="before" image=icon.cut)
modify(mode="multiple" type="dir" where=this.id==id.cut
		&& !path.exists(peazip_exe) && path.exists(neovide_exe)
	pos=indexof("通过 Neovide 打开", 1) sep="before" image=icon.cut)
modify(mode="multiple" type="dir" where=this.id==id.cut
		&& !path.exists(peazip_exe) && !path.exists(neovide_exe) && path.exists(code_exe)
	pos=indexof("通过 Code 打开", 1) sep="before" image=icon.cut)
modify(mode="multiple" type="dir" where=this.id==id.cut
		&& !path.exists(peazip_exe) && !path.exists(neovide_exe) && !path.exists(code_exe)
	pos=indexof("在终端中打开", 1) sep="before" image=icon.cut)
modify(mode="multiple" type="file|dir" where=this.id==id.copy
	image=icon.copy)
modify(mode="multiple" type="file|dir" where=this.id==id.rename
	image=icon.rename)
modify(mode="multiple" type="file|dir" where=this.id==id.delete
	image=icon.delete)
modify(mode="multiple" type="file|dir" where=this.id==id.copy_as_path
	pos=indexof("复制", 1) image=icon.copy_as_path)

// Organize the overflow menu into tools, sharing, and system actions.
modify(mode="multiple" in="更多操作"
	find='"编辑"|"在记事本中编辑"' pos=1)
modify(mode="multiple" in="更多操作" where=this.id==id.print pos=2 sep="after")
modify(mode="multiple" in="更多操作" find='火绒' pos=3)
modify(mode="multiple" in="更多操作" find='"PeaZip"' pos=4 sep="after")
modify(mode="multiple" in="更多操作" where=this.id==id.share pos=5)
modify(mode="multiple" in="更多操作" where=this.id==id.send_to pos=6 sep="after")
modify(mode="multiple" in="更多操作" where=this.id==id.create_shortcut pos=7)
modify(mode="multiple" in="更多操作"
	where=this.id==id.restore_previous_versions pos=8)

// Folder overflow: common locations, optional tools, then system management.
modify(mode="multiple" type="dir" in="更多操作"
	where=this.id(id.pin_current_folder_to_quick_access, id.pin_to_quick_access)
	pos=0)
modify(mode="multiple" type="dir" in="更多操作" find='Everything' pos=1)
modify(mode="multiple" type="dir" in="更多操作" find='火绒' pos=2 sep="after")
modify(mode="multiple" type="dir" in="更多操作"
	where=this.id==id.include_in_library pos=3)
modify(mode="multiple" type="dir" in="更多操作"
	where=this.id==id.pin_to_start pos=4)
modify(mode="multiple" type="dir" in="更多操作"
	where=this.id==id.restore_previous_versions pos=5 sep="before")
modify(mode="multiple" type="dir" in="更多操作"
	where=this.id==id.send_to pos=6)
modify(mode="multiple" type="dir" in="更多操作"
	where=this.id==id.create_shortcut pos=7)

// Properties is always the final top-level item.
modify(mode="multiple" type="file|dir" where=this.id==id.properties
	pos=indexof("更多操作", 1) sep="before" image=icon.properties)
