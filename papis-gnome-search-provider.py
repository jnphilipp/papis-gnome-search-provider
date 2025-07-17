#!/usr/bin/env python3
# Copyright (C) 2025 J. Nathanael Philipp (jnphilipp) <nathanael@philipp.land>
#
# This file is part of papis-gnome-search-provider.
#
# papis-gnome-search-provider is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# papis-gnome-search-provider is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with papis-gnome-search-provider. If not, see <http://www.gnu.org/licenses/>.
"""Papis GNOME search provider."""

import dbus
import dbus.service
import os

from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
from papis.api import get_all_documents_in_lib, get_documents_in_lib
from papis.document import Document


__app_name__ = "papis-gnome-search-provider"
__author__ = "J. Nathanael Philipp"
__email__ = "nathanael@philipp.land"
__copyright__ = "Copyright 2025 J. Nathanael Philipp (jnphilipp)"
__license__ = "GPLv3"
__version_info__ = (0, 1, 0)
__version__ = ".".join(str(e) for e in __version_info__)
__github__ = "https://github.com/jnphilipp/papis-gnome-search-provider"


search_bus_name = "org.gnome.Shell.SearchProvider2"
sbn = dict(dbus_interface=search_bus_name)


class PapisSearchService(dbus.service.Object):
    """Papis GNOME search provider."""

    bus_name = "org.gnome.papis.SearchProvider"
    _object_path = "/" + bus_name.replace(".", "/")

    def __init__(self):
        """Init."""
        self.session_bus = dbus.SessionBus()
        bus_name = dbus.service.BusName(self.bus_name, bus=self.session_bus)
        dbus.service.Object.__init__(self, bus_name, self._object_path)

    @dbus.service.method(
        in_signature="sasu", identifier="s", terms="as", timestamp="u", **sbn
    )
    def ActivateResult(  # noqa: N802
        self,
        identifier: str,
        terms: list[str],
        timestamp: int,
    ) -> None:
        """Activate result item."""
        doc = self._get_document(identifier)
        if doc is not None:
            if len(doc.get_files()) > 0:
                os.system(f'xdg-open "{doc.get_files()[0]}"')

    @dbus.service.method(in_signature="as", terms="as", out_signature="as", **sbn)
    def GetInitialResultSet(self, terms: list[str]) -> list[str]:  # noqa: N802
        """Get initial result set."""
        return self._get_result_set(terms)

    @dbus.service.method(
        in_signature="as", identifiers="as", out_signature="aa{sv}", **sbn
    )
    def GetResultMetas(self, identifiers: list[str]) -> list[dict]:  # noqa: N802
        """Get result metas."""
        metas: list[dict] = []
        for identifier in identifiers:
            obj = self._get_document(identifier)
            if obj is None:
                metas.append({"id": identifier})
            else:
                metas.append(
                    {
                        "id": identifier,
                        "name": obj["title"],
                    }
                )
                if "abstract" in obj and obj["abstract"]:
                    metas[-1]["description"] = obj["abstract"]
        return metas

    @dbus.service.method(
        in_signature="asas",
        previous_results="as",
        terms="as",
        out_signature="as",
        **sbn,
    )
    def GetSubsearchResultSet(  # noqa: N802
        self, previous_results: list[str], new_terms: list[str]
    ) -> list[str]:
        """Get subsearch result set."""
        return self._get_result_set(new_terms)

    @dbus.service.method(in_signature="asu", terms="as", timestamp="u", **sbn)
    def LaunchSearch(self, terms: list[str], timestamp: int) -> None:  # noqa: N802
        """Launch search."""
        pass

    def _get_document(self, papis_id: str) -> Document | None:
        results = get_documents_in_lib(search={"papis_id": papis_id})
        return results[0] if len(results) == 1 else None

    def _get_result_set(self, terms: list[str]) -> list[str]:
        return [
            doc["papis_id"]
            for doc in (
                get_all_documents_in_lib()
                if len(terms) == 0
                else get_documents_in_lib(search=" ".join(terms))
            )
        ]

    def notify(self, message, body="", error=False):
        """Send notification."""
        try:
            self.session_bus.get_object(
                "org.freedesktop.Notifications", "/org/freedesktop/Notifications"
            ).Notify(
                "papis",
                0,
                "papis",
                message,
                body,
                "",
                {"transient": False if error else True},
                0 if error else 3000,
                dbus_interface="org.freedesktop.Notifications",
            )
        except dbus.DBusException as e:
            print(f"Got error {e} while trying to display message {message}.")


if __name__ == "__main__":
    DBusGMainLoop(set_as_default=True)
    PapisSearchService()
    loop = GLib.MainLoop()
    loop.run()
