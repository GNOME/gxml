#!/usr/bin/python3
# (C) 2014 Daniel Espinosa Ortiz
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This programs parse an input file (like a header) to extract function names and 
# use them when create shared/static libraries in MinGW
#
# You must specify the file to parse as command line argument
import fileinput
import re, os
# Configuration parameters
# Change this according with your project's function's prefix
prefix = 'gxml_'
# Change this the output file name
filename = "gxml.symbols"
# Add any symbols, prefixes or simple texts you want to skip from parsing
blacklist = ("error_quark", "gxml_last_error;", "gxml_warning")

# Start parsing
p = re.compile (prefix)
f = open (filename, 'w')
d = {'':''}
for line in fileinput.input():
  bl = False
  for b in blacklist:
    if b in line:
      bl = True
      print ("found blacklist" + line)
  if (prefix in line and not ('('+prefix in line) and not bl):
    sp = line.split (" ")
    for s in sp:
      if (prefix in s):
        print("FOUND:" + s)
        d[s] = s
ds = sorted (d)
for t in ds:
  if t == '':
    continue
  print ("ADDING: " + t)
  f.write (str(t)+'\n')
