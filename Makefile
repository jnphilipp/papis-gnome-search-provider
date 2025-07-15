SHELL:=/bin/bash

BIN_DIR?=/usr/bin
DOC_DIR?=/usr/share/doc
SHARE_DIR?=/usr/share
SYSTEMD_DIR?=/usr/lib/systemd/user
DEST_DIR?=


ifdef VERBOSE
  Q :=
else
  Q := @
endif

print-%:
	@echo $*=$($*)


clean:
	$(Q)rm -rf ./build
	$(Q)find . -depth -name __pycache__ -type d -exec rm -rf {} \;


install: papis-gnome-search-provider.py build/changelog.Debian.gz build/copyright build/org.gnome.papis.SearchProvider.svg org.gnome.papis.SearchProvider.ini org.gnome.papis.SearchProvider.service.dbus org.gnome.papis.SearchProvider.service.systemd org.gnome.papis.SearchProvider.desktop
	$(Q)install -Dm 0755 papis-gnome-search-provider.py "${DEST_DIR}${BIN_DIR}"/papis-gnome-search-provider
	$(Q)install -Dm 0644 build/changelog.Debian.gz "${DEST_DIR}${DOC_DIR}"/papis-gnome-search-provider/changelog.Debian.gz
	$(Q)install -Dm 0644 build/copyright "${DEST_DIR}${DOC_DIR}"/papis-gnome-search-provider/copyright
	$(Q)install -Dm 0644 build/org.gnome.papis.SearchProvider.svg "${DEST_DIR}/${ICON_DIR}"/hicolor/scalable/apps/org.gnome.papis.SearchProvider.svg
	$(Q)install -Dm 0644 LICENSE "${DEST_DIR}${DOC_DIR}"/papis-gnome-search-provider/LICENSE
	$(Q)install -Dm 0644 org.gnome.papis.SearchProvider.ini "${DEST_DIR}${SHARE_DIR}"/gnome-shell/search-providers/org.gnome.papis.SearchProvider.ini
	$(Q)install -Dm 0644 org.gnome.papis.SearchProvider.desktop "${DEST_DIR}${SHARE_DIR}"/applications/org.gnome.papis.SearchProvider.desktop
	$(Q)install -Dm 0644 org.gnome.papis.SearchProvider.service.dbus "${DEST_DIR}${SHARE_DIR}"/dbus-1/services/org.gnome.papis.SearchProvider.service
	$(Q)install -Dm 0644 org.gnome.papis.SearchProvider.service.systemd "${DEST_DIR}${SYSTEMD_DIR}"/org.gnome.papis.SearchProvider.service
	@echo "papis-gnome-search-provider install completed."


uninstall:
	$(Q)rm -r "${DEST_DIR}${DOC_DIR}"/papis-gnome-search-provider
	$(Q)rm "${DEST_DIR}${BIN_DIR}"/papis-gnome-search-provider
	$(Q)rm "${DEST_DIR}${SHARE_DIR}"/applications/org.gnome.papis.SearchProvider.desktop
	$(Q)rm "${DEST_DIR}${SHARE_DIR}"/gnome-shell/search-providers/org.gnome.papis.SearchProvider.ini
	$(Q)rm "${DEST_DIR}${SHARE_DIR}"/dbus-1/services/org.gnome.papis.SearchProvider.service
	$(Q)rm "${DEST_DIR}${SYSTEMD_DIR}"/org.gnome.papis.SearchProvider.service
	$(Q)rm "${DEST_DIR}${ICON_DIR}"/hicolor/scalable/apps/org.gnome.papis.SearchProvider.svg
	@echo "papis-gnome-search-provider uninstall completed."


build:
	$(Q)mkdir -p build


build/copyright: build
	$(Q)echo "Upstream-Name: papis-gnome-search-provider" > build/copyright
	$(Q)echo "Source: https://github.com/jnphilipp/papis-gnome-search-provider" >> build/copyright
	$(Q)echo "" >> build/copyright
	$(Q)echo "Files: *" >> build/copyright
	$(Q)echo "Copyright: 2025 J. Nathanael Philipp (jnphilipp) <nathanael@philipp.land>" >> build/copyright
	$(Q)echo "License: GPL-3+" >> build/copyright
	$(Q)echo " This program is free software: you can redistribute it and/or modify" >> build/copyright
	$(Q)echo " it under the terms of the GNU General Public License as published by" >> build/copyright
	$(Q)echo " the Free Software Foundation, either version 3 of the License, or" >> build/copyright
	$(Q)echo " any later version." >> build/copyright
	$(Q)echo "" >> build/copyright
	$(Q)echo " This program is distributed in the hope that it will be useful," >> build/copyright
	$(Q)echo " but WITHOUT ANY WARRANTY; without even the implied warranty of" >> build/copyright
	$(Q)echo " MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the" >> build/copyright
	$(Q)echo " GNU General Public License for more details." >> build/copyright
	$(Q)echo "" >> build/copyright
	$(Q)echo " You should have received a copy of the GNU General Public License" >> build/copyright
	$(Q)echo " along with this program. If not, see <http://www.gnu.org/licenses/>." >> build/copyright
	$(Q)echo " On Debian systems, the full text of the GNU General Public" >> build/copyright
	$(Q)echo " License version 3 can be found in the file" >> build/copyright
	$(Q)echo " '/usr/share/common-licenses/GPL-3'." >> build/copyright



build/copyright.h2m: build
	$(Q)echo "[COPYRIGHT]" > build/copyright.h2m
	$(Q)echo "This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version." >> build/copyright.h2m
	$(Q)echo "" >> build/copyright.h2m
	$(Q)echo "This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details." >> build/copyright.h2m
	$(Q)echo "" >> build/copyright.h2m
	$(Q)echo "You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/." >> build/copyright.h2m


build/changelog.latest.md:
	$(Q)( \
		declare TAGS=(`git tag`); \
		for ((i=$${#TAGS[@]};i>=0;i--)); do \
			if [ $$i -eq 0 ]; then \
				echo -e "$${TAGS[$$i]}" >> build/changelog.latest.md; \
				git log $${TAGS[$$i]} --no-merges --format="  * %h %s"  >> build/changelog.latest.md; \
			elif [ $$i -eq $${#TAGS[@]} ] && [ $$(git log $${TAGS[$$i-1]}..HEAD --oneline | wc -l) -ne 0 ]; then \
				echo -e "$${TAGS[$$i-1]}-$$(git log -n 1 --format='%h')" >> build/changelog.latest.md; \
				git log $${TAGS[$$i-1]}..HEAD --no-merges --format="  * %h %s"  >> build/changelog.latest.md; \
			elif [ $$i -lt $${#TAGS[@]} ]; then \
				echo -e "$${TAGS[$$i]}" >> build/changelog.latest.md; \
				git log $${TAGS[$$i-1]}..$${TAGS[$$i]} --no-merges --format="  * %h %s"  >> build/changelog.latest.md; \
				break; \
			fi; \
		done \
	)


build/changelog.Debian.gz: build
	$(Q)( \
		declare TAGS=(`git tag`); \
		for ((i=$${#TAGS[@]};i>=0;i--)); do \
			if [ $$i -eq 0 ]; then \
				echo -e "papis-gnome-search-provider ($${TAGS[$$i]}) unstable; urgency=medium" >> build/changelog; \
				git log $${TAGS[$$i]} --no-merges --format="  * %h %s"  >> build/changelog; \
				git log $${TAGS[$$i]} -n 1 --format=" -- %an <%ae>  %aD" >> build/changelog; \
			elif [ $$i -eq $${#TAGS[@]} ] && [ $$(git log $${TAGS[$$i-1]}..HEAD --oneline | wc -l) -ne 0 ]; then \
				echo -e "papis-gnome-search-provider ($${TAGS[$$i-1]}-$$(git log -n 1 --format='%h')) unstable; urgency=medium" >> build/changelog; \
				git log $${TAGS[$$i-1]}..HEAD --no-merges --format="  * %h %s"  >> build/changelog; \
				git log HEAD -n 1 --format=" -- %an <%ae>  %aD" >> build/changelog; \
			elif [ $$i -lt $${#TAGS[@]} ]; then \
				echo -e "papis-gnome-search-provider ($${TAGS[$$i]}) unstable; urgency=medium" >> build/changelog; \
				git log $${TAGS[$$i-1]}..$${TAGS[$$i]} --no-merges --format="  * %h %s"  >> build/changelog; \
				git log $${TAGS[$$i]} -n 1 --format=" -- %an <%ae>  %aD" >> build/changelog; \
			fi; \
		done \
	)
	$(Q)cat build/changelog | gzip -n9 > build/changelog.Debian.gz


build/org.gnome.papis.SearchProvider.svg:
	$(Q)wget https://raw.githubusercontent.com/papis/papis/refs/heads/main/resources/logo.svg -O build/org.gnome.papis.SearchProvider.svg
