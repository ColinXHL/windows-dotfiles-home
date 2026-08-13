settings
{
	priority=1
	exclude.where = !process.is_explorer
	showdelay = 120
	modify.remove.duplicate=1
	tip.enabled=true
}

// User-editable paths and shared file-type groups must load first.
import 'imports/config.nss'
import 'imports/theme.nss'
import 'imports/images.nss'
import 'imports/customize.nss'
import 'imports/background.nss'
import 'imports/nvim.nss'
import 'imports/code.nss'
import 'imports/peazip.nss'
import 'imports/taskbar.nss'
