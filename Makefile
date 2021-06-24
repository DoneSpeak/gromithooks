
install-git-hooks: install-git-hooks.sh
	chmod +x ./$< && ./$<

install-git-hooks.sh:
	# 如果遇到 Failed to connect to raw.githubusercontent.com port 443: Connection refused
	# 为DNS污染问题，可在https://www.ipaddress.com/查询域名，然后写入hosts文件中
	# 见：https://github.com/hawtim/blog/issues/10
	wget https://raw.githubusercontent.com/DoneSpeak/gromithooks/v1.0.1/install-git-hooks.sh
