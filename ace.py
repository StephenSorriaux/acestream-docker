#!/usr/bin/env python

import argparse
import subprocess

parser = argparse.ArgumentParser(description='Launch torrent or acestream stream using acestreamplayer.')
parser.add_argument("-tu","--torrent-url", help="URL to torrent file")
parser.add_argument("-su","--subtitle-url", help="URL to subtitles file")
parser.add_argument("-au","--acestream-url", help="URL to acestream stream")

args = parser.parse_args()
parameters = ""

if args.torrent_url and args.acestream_url:
    print "can't define torrent-url and acestream-url, define only one"
    exit(1)

for key,value in vars(args).iteritems():
    if value is not None:
        parameters += " --%s '%s'" % (key.replace("_","-"),value)

p = subprocess.Popen("/usr/bin/docker run -u $(id -u):$(id -g) -v $HOME:$HOME -v /tmp/.X11-unix:/tmp/.X11-unix -v $XAUTHORITY:/tmp/xauth -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -e HOME -e PYTHON_EGG_CACHE=/tmp/.python-eggs -e DISPLAY=unix$DISPLAY -e XAUTHORITY=/tmp/xauth --device /dev/dri --device /dev/snd --group-add audio --group-add video --rm ssorriaux/acestreamplayer %s" % parameters,shell=True).wait()
exit(p)
