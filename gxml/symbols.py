#!/usr/bin/python3
# You must specify the file to parse as command line argument
import fileinput
import re, os
p = re.compile ('gxml_')
f = open ("gxml.symbols", 'w')
d = {'':''}
blacklist = ("error_quark", "gxml_last_error;", "gxml_warning")
for line in fileinput.input():
  bl = False
  for b in blacklist:
    if b in line:
      bl = True
      print ("found blacklist" + line)
  if ('gxml_' in line and not ('(gxml_' in line) and not bl):
    sp = line.split (" ")
    for s in sp:
      if ('gxml_' in s):
        print("FOUND:" + s)
        d[s] = s
ds = sorted (d)
for t in ds:
  if t == '':
    continue
  print ("ADDING: " + t)
  f.write (str(t)+'\n')
