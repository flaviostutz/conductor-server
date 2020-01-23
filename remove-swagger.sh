#!/usr/bin/python

s = open("/conductor/server/src/main/java/com/netflix/conductor/bootstrap/ModulesProvider.java").read()

a = "modules.add(new SwaggerModule());"
b = ""
s = s.replace(a, b)

a = "import com.netflix.conductor.server.SwaggerModule;"
b = ""
s = s.replace(a, b)

f = open("/conductor/server/src/main/java/com/netflix/conductor/bootstrap/ModulesProvider.java", 'w')
f.write(s)
f.close()

