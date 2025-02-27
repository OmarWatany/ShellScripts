#!/usr/bin/bash
VERSION="0.1.0"

for profile in ./*; do for i in "$profile""/device.SM-T585"/*.json; do
	base_name=$(basename "$i")
	dst="$profile""/device.23129RAA4G/""$base_name"
	if [[ -f "$dst" ]] && [[ $(diff "$dst" "$i") ]]; then
		src_stat=$(stat -c %Y "$i")
		dst_stat=$(stat -c %Y "$dst")
		if [[ "$src_stat" -gt "$dst_stat" ]]; then
			echo "$i > $dst"
			cat "$i" >"$dst"
		elif [[ "$src_stat" -lt "$dst_stat" ]]; then
			echo "$dst > $i"
			cat "$dst" >"$i"
		fi
	fi
done; done
