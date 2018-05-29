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

p = subprocess.Popen("/usr/bin/docker run -v /dev/snd:/dev/snd --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -e uid=$(id -u) -e gid=$(id -g) -e DISPLAY=unix$DISPLAY --rm ssorriaux/acestreamplayer %s" % parameters,shell=True).wait()
exit(p)
