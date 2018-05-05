#!/bin/sh
set -ex

nmap -sV 127.0.0.1 -p 25565 | grep Minecraft
