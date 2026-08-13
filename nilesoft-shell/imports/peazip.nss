// Show smart extraction only for actual archive formats.
item(mode="multiple" type="file"
	where=path.exists(peazip_exe) find=archive_pattern
	pos=0 sep="after" title="智能解压到此处"
	tip="解压到此处，需要时自动新建文件夹"
	image=peazip_exe
	cmd=peazip_exe
	args='-ext2multismart @sel.path.quote' invoke="multiple")
