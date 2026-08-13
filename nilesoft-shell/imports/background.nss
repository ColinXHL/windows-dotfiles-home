// Rebuild separators for Explorer and desktop background menus.
modify(mode="none" type="back" where=this.type==2 vis=vis.remove)

// Explorer folder background: view and clipboard retain the native order.
modify(mode="none" type="back" where=!wnd.is_desktop && this.id==id.view pos=0)
modify(mode="none" type="back" where=!wnd.is_desktop && this.id==id.sort_by pos=1)
modify(mode="none" type="back" where=!wnd.is_desktop && this.id==id.group_by pos=2)
modify(mode="none" type="back" where=!wnd.is_desktop && this.id==id.refresh pos=3)
modify(mode="none" type="back" where=!wnd.is_desktop && this.id==id.paste
	pos=4 sep="before")
modify(mode="none" type="back"
	where=!wnd.is_desktop && (
		this.id==id.paste_shortcut
		|| str.contains(this.name, "粘贴快捷方式")
		|| str.contains(this.title, "粘贴快捷方式")
	)
	pos=indexof("新建"))
modify(mode="none" type="back"
	where=!wnd.is_desktop && (
		this.id==id.undo
		|| str.contains(this.name, "撤消")
		|| str.contains(this.name, "撤销")
		|| str.contains(this.name, "恢复")
		|| str.contains(this.title, "撤消")
		|| str.contains(this.title, "撤销")
		|| str.contains(this.title, "恢复")
	)
	pos=indexof("新建"))

// Build the creation and tools block around the dynamic Code item.
modify(mode="none" type="back"
	where=!wnd.is_desktop && (
		this.id(id.new, id.new_item)
		|| str.contains(this.title, "新建")
	)
	pos=indexof("终端"))
modify(mode="none" type="back"
	where=!wnd.is_desktop && path.exists(code_exe) && (
		this.id==id.open_powershell_window_here
		|| str.contains(this.name, "终端")
		|| str.contains(this.title, "终端")
	)
	pos=indexof("通过 Code 打开") sep="before")
modify(mode="none" type="back"
	where=!wnd.is_desktop && !path.exists(code_exe) && path.exists(everything_exe) && (
		this.id==id.open_powershell_window_here
		|| str.contains(this.name, "终端")
		|| str.contains(this.title, "终端")
	)
	pos=indexof("Everything") sep="before")
modify(mode="none" type="back"
	where=!wnd.is_desktop && !path.exists(code_exe) && !path.exists(everything_exe) && (
		this.id==id.open_powershell_window_here
		|| str.contains(this.name, "终端")
		|| str.contains(this.title, "终端")
	)
	pos=indexof("自定义文件夹") sep="before")
modify(mode="none" type="back"
	where=!wnd.is_desktop && str.contains(this.title, "Everything")
		&& path.exists(everything_exe) && path.exists(code_exe)
	pos=indexof("通过 Code 打开", 1))
modify(mode="none" type="back"
	where=!wnd.is_desktop && str.contains(this.title, "Everything")
		&& path.exists(everything_exe) && !path.exists(code_exe)
	pos=indexof("自定义文件夹"))
modify(mode="none" type="back"
	where=!wnd.is_desktop && str.contains(this.title, "Everything")
		&& !path.exists(everything_exe)
	vis=vis.remove)

// The final system block never depends on an optional application.
modify(mode="none" type="back" where=!wnd.is_desktop && this.id==id.properties
	pos="bottom")
modify(mode="none" type="back"
	where=!wnd.is_desktop && (
		this.id==id.customize_this_folder
		|| str.contains(this.title, "自定义文件夹")
	)
	pos=indexof("属性") sep="before")

// Desktop background uses the same relative chain without the folder-only items.
modify(mode="none" type="back" where=wnd.is_desktop && this.id==id.view pos=0)
modify(mode="none" type="back" where=wnd.is_desktop && this.id==id.sort_by pos=1)
modify(mode="none" type="back" where=wnd.is_desktop && this.id==id.refresh pos=2)
modify(mode="none" type="back" where=wnd.is_desktop && this.id==id.paste
	pos=3 sep="before")
modify(mode="none" type="back"
	where=wnd.is_desktop && (
		this.id==id.paste_shortcut
		|| str.contains(this.name, "粘贴快捷方式")
		|| str.contains(this.title, "粘贴快捷方式")
	)
	pos=indexof("新建"))
modify(mode="none" type="back"
	where=wnd.is_desktop && (
		this.id==id.undo
		|| str.contains(this.name, "撤消")
		|| str.contains(this.name, "撤销")
		|| str.contains(this.name, "恢复")
		|| str.contains(this.title, "撤消")
		|| str.contains(this.title, "撤销")
		|| str.contains(this.title, "恢复")
	)
	pos=indexof("新建"))
modify(mode="none" type="back"
	where=wnd.is_desktop && (
		this.id(id.new, id.new_item)
		|| str.contains(this.title, "新建")
	)
	pos=indexof("终端"))
modify(mode="none" type="back"
	where=wnd.is_desktop && path.exists(code_exe) && (
		this.id==id.open_powershell_window_here
		|| str.contains(this.name, "终端")
		|| str.contains(this.title, "终端")
	)
	pos=indexof("通过 Code 打开") sep="before")
modify(mode="none" type="back"
	where=wnd.is_desktop && !path.exists(code_exe) && path.exists(everything_exe) && (
		this.id==id.open_powershell_window_here
		|| str.contains(this.name, "终端")
		|| str.contains(this.title, "终端")
	)
	pos=indexof("Everything") sep="before")
modify(mode="none" type="back"
	where=wnd.is_desktop && !path.exists(code_exe) && !path.exists(everything_exe) && (
		this.id==id.open_powershell_window_here
		|| str.contains(this.name, "终端")
		|| str.contains(this.title, "终端")
	)
	pos=indexof("显示设置") sep="before")
// A later modify resets pos even when it only changes sep, so keep both here.
modify(mode="none" type="back"
	where=path.exists(code_exe) && (
		str.contains(this.name, "终端预览")
		|| str.contains(this.title, "终端预览")
	)
	pos=indexof("通过 Code 打开") sep="none")
modify(mode="none" type="back"
	where=!path.exists(code_exe) && path.exists(everything_exe) && (
		str.contains(this.name, "终端预览")
		|| str.contains(this.title, "终端预览")
	)
	pos=indexof("Everything") sep="none")
modify(mode="none" type="back"
	where=!wnd.is_desktop && !path.exists(code_exe) && !path.exists(everything_exe) && (
		str.contains(this.name, "终端预览")
		|| str.contains(this.title, "终端预览")
	)
	pos=indexof("自定义文件夹") sep="none")
modify(mode="none" type="back"
	where=wnd.is_desktop && !path.exists(code_exe) && !path.exists(everything_exe) && (
		str.contains(this.name, "终端预览")
		|| str.contains(this.title, "终端预览")
	)
	pos=indexof("显示设置") sep="none")
modify(mode="none" type="back"
	where=wnd.is_desktop && str.contains(this.title, "Everything")
		&& path.exists(everything_exe) && path.exists(code_exe)
	pos=indexof("通过 Code 打开", 1))
modify(mode="none" type="back"
	where=wnd.is_desktop && str.contains(this.title, "Everything")
		&& path.exists(everything_exe) && !path.exists(code_exe)
	pos=indexof("显示设置"))
modify(mode="none" type="back"
	where=wnd.is_desktop && str.contains(this.title, "Everything")
		&& !path.exists(everything_exe)
	vis=vis.remove)
modify(mode="none" type="back" where=wnd.is_desktop && this.id==id.personalize
	pos="bottom")
modify(mode="none" type="back"
	where=wnd.is_desktop && this.id==id.display_settings
	pos=indexof("个性化") sep="before")
