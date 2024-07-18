#!/usr/bin/sh 

DOCKERNAME=$1

GWIP=$(docker inspect "$DOCKERNAME" -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}')
#echo "$GWIP"

DOCKERIF=$(ifconfig | grep -B1 "$GWIP" | head -1 | cut -d ':' -f 1)
echo "$DOCKERIF"