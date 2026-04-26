#!/bin/bash

set -u

echo "Configuring systemd components"
mkdir -p /etc/systemd/resolved.conf.d
cp -v resolved.conf.d/* /etc/systemd/resolved.conf.d/

echo "Linking systemd service overrides..."
for unit in $(find systemd -mindepth 1 -type d)
do
	service=$(basename $unit)
	mkdir -p /etc/systemd/system/$service
	cp -v systemd/$service/* /etc/systemd/system/$service/
done
