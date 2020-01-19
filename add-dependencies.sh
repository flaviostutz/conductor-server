#!/usr/bin/python

s = open("/conductor/server/build.gradle").read()

a = "compile project(':conductor-core')"
b = "compile \"io.micrometer:micrometer-registry-prometheus:1.1.2\"\n    compile project(':conductor-core')\n"
s = s.replace(a, b)

f = open("/conductor/server/build.gradle", 'w')
f.write(s)

f.close()
