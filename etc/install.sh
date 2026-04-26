#!/bin/bash

set -euo pipefail

echo "Linking systemd service overrides..."
for unit in $(find systemd -mindepth 1 -type d)
do
	service=$(basename $unit)
	ln -vsT $(pwd)/systemd/$service /etc/systemd/system/$service
done
