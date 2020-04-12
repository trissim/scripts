#!/bin/python3
import sys
import subprocess as sh
size = int(sys.argv[1])
step = int(sys.argv[2])
separator = sys.argv[3]
string = sys.argv[4]
string = string+separator
repeats = int(int(size)/len(string))+1
string = string*repeats
string2 = ""
try:
    start = int(sh.check_output(["cat", "/tmp/marquee"]).decode("utf-8"))
except:
    start = 0
total_len = len(string)
if start > total_len:
    start = start-total_len
end = start + size
if end > total_len:
    string2 = string[:end-total_len]
    string1 = string[start:]
    to_print = string1+string2
else:
    to_print = string[start:end]+string2
tmp = open('/tmp/marquee', 'w')
tmp.write(str(start+step))
tmp.close()
print(to_print)

