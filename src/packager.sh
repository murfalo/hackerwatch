#!/usr/bin/env bash
set -xe

main () {
	local -r hwr_path="${HOME}/.steam/steam/steamapps/common/Heroes of Hammerwatch"
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${hwr_path}/";

	cd "${hwr_path}"
	"${HOME}/.local/share/Steam/ubuntu12_32/steam-runtime/run.sh" "./Packager" "${@}"
}

main "${@}"
