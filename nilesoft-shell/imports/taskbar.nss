// Practical taskbar background menu based on Shell's bundled example.
menu(where=@(this.count == 0) type="taskbar" expanded=true)
{
	item(title="任务管理器" image=icon.task_manager cmd="taskmgr.exe")
	item(title="显示桌面" image=icon.desktop cmd=command.toggle_desktop)

	menu(title="窗口排列" sep="before" image=\uE1FB)
	{
		item(title="层叠窗口" cmd=command.cascade_windows)
		item(title="堆叠显示窗口" cmd=command.show_windows_stacked)
		item(title="并排显示窗口" cmd=command.show_windows_side_by_side)
		sep
		item(title="最小化所有窗口" cmd=command.minimize_all_windows)
		item(title="还原所有窗口" cmd=command.restore_all_windows)
	}

	item(title="任务栏设置" sep="before" image=icon.taskbar_settings
		cmd="ms-settings:taskbar")
	item(title="系统设置" image=icon.settings cmd="ms-settings:")
	item(vis=key.shift() title="重新启动资源管理器" sep="before"
		image=\uE1F4 cmd=command.restart_explorer)
}
