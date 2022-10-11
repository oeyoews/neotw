include ./neotw.config.mk
include ./src/color.mk

info: $(PackageJson)
	@echo -e " Project: $(PROJECT)\n Version: $(version)\n Platform: $(PLATFORM)\n Commit: $(ShortCommitId)"

# @rm -rf $(TiddlyWiki-Git-File); cp $(TiddlyWiki-Git-TemplateFile) $(TiddlyWiki-Git-File)
# @sed -i "s#LongId#$(LongCommitId)#" $(TiddlyWiki-Git-File)
# @sed -i "s#ShortId#$(ShortCommitId)#" $(TiddlyWiki-Git-File)
update-git-commit:
	@sed -i "s#commit/[0-9a-z]*#commit/$(LongCommitId)#" $(TiddlyWiki-Git-File)
	@sed -i "s#>[0-9a-z]*<#>$(ShortCommitId)<#" $(TiddlyWiki-Git-File)
	@echo -e 🎉 update-git-commit $(Green)Finished ✔ $(Color_off)

bump: $(BumpFile)
	yarn zx bump.mjs

# startup tiddlywiki
run:
	@echo "ℹ️  Your current OS is $(PLATFORM) \
		🚀 startup $(PACKAGE)"
	# $(CMD) --listen port=$(PORT) anon-username=$(USER) 2>&1 &
	$(CMD) --build listen 2>&1 &

# startup to the world
run-to-the-world:
	@echo "👋 startup $(PACKAGE) to the world"
	$(CMD) --listen port=$(PORT) anon-username=$(USERNAME) host=$(HOST)

# generate index.html(support subwiki, but not build html no include subwiki)
# note: because use make, so can't read this `tiddlywiki` cmd from current project, recommend install tiddlywiki global, likw `yarn global add tiddlywiki`
# should before build
build: $(Lib)
	@make update-git-commit
	@echo -e  👷 $(Green)Building 🗘 $(Color_off)
	@sh ./lib
	@rm -rf $(dist) $(NEOTWTEMP); mkdir $(NEOTWTEMP)
	@cp -r tiddlers/ dev/ tiddlywiki.info $(NEOTWTEMP)
# if error how to exit
	@rm -rf $(NEOTWTEMP)/tiddlers/subwiki \
		$(NEOTWTEMP)/tiddlers/trashbin \
	 	$(NEOTWTEMP)/tiddlers/\$$__StoryLis*.tid
	$(CMD) $(NEOTWTEMP) --build index >> $(logfile) 2>&1  # build
# $(CMD) $(NEOTWTEMP) --build static >> $(logfile) 2>&1  # static giscus and commpand palette widget have a error
# $(CMD) public --build favicon >> /tmp/neotw.log 2>&1  # favicon
# $(CMD) public --output dist/ --build debug >> /tmp/neotw.log 2>&1  # build
	@mv library/ $(dist)
	@cp -r src/vercel.json $(dist); echo "📁 `ls  -sh $(dist)/index.html`" # patch
	@tree $(dist) -L 1
	@echo -e 🎉 $(Green)Finished ✔ $(Color_off)

build-lib: $(Lib)
	@sh ./lib

# view
view:
	@google-chrome-stable $(dist)/index.html

view-log:
	@nvim $(logfile)

# bpview
bpview:
	@make build; google-chrome-stable $(dist)/index.html

# check dir
install-subwiki:
	@git clone --depth 1 $(subwiki-address) tiddlers/subwiki

install-archrepo:
	@git clone --depth 1 $(archrepo) dev/archrepo

# install service
install-bin:
	@echo "tiddlywiki --listen" > $(NEOTWBIN)
	@chmod +x ~/.local/bin/$(PKGNAME)
	@echo "🎉 Installed neotw ✔"

# or yay tidgi directly
install-tidgi:
	@rm -rf $(tidgi_dir); mkdir $(tidgi_dir)/; cp src/tidgi-repo/PKGBUILD $(tidgi_dir)
	@cd $(tidgi_dir); makepkg; sudo pacman -U *.zst

edit-config:
	@nvim $(tiddlywiki_configfile)

# @cp $(SERVICETEMPLATEFILE) $(SERVICEFILE)
# @sed -i "s#NEOTWDIR#$(neotwdir-user)#" $(SERVICEFILE)
# echo $(neotwdir-user)

install-service:
	@cp $(SERVICETEMPLATEFILE) $(SERVICEFILE)
	@sed -i "s#\$NEOTWDIR#$(neotwdir-user)#" $(SERVICEFILE)
	@mv -i $(SERVICEFILE) $(SERVICETARGETFILE)
	@echo "🎉 $(SERVICETARGETFILE) file has installed"

# use highlight color
# maybe should start byhand firstly
reload-service:
	$(SERVICECMD) --user daemon-reload
enable:
	$(SERVICECMD) enable --user $(SERVICEFILE)
disable:
	$(SERVICECMD) disable --user $(SERVICEFILE)
status:
	$(SERVICECMD) status --user $(SERVICEFILE)
start:
	$(SERVICECMD) start --user $(SERVICEFILE)
	@echo "$(SERVICEFILE) has started, Click this address https://127.0.0.1:$(PORT) to open"
	@make status
restart:
	$(SERVICECMD) restart --user $(SERVICEFILE)
	@echo "$(SERVICEFILE) has restared, Click this address https://127.0.0.1:$(PORT) to open"
	@make status
stop:
	$(SERVICECMD) stop --user $(SERVICEFILE)
	@echo $(SERVICEFILE) has stopped
uninstall:
	rm -i $(NEOTWBIN)
	@echo "👋 $(NEOTWBIN) file has uninstalled"
	# uninstall service
uninstall-service:
	@rm -f -i $(SERVICETARGETFILE);
	@echo "👋 $(SERVICETARGETFILE) file has removed"

# clean
.PHONY: clean
clean:
	@rm -rf $(NEOTWTEMP) $(dist)
