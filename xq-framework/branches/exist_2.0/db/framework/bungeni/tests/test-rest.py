""" 
    Python script to test RESTXQ API
"""

import httplib

def printText(txt):
    lines = txt.split('\n')
    for line in lines:
        print line.strip()

httpServ = httplib.HTTPConnection("192.168.0.75", 8088)
httpServ.connect()
"""
httpServ.request('GET', "/exist/restxq/ontology")
response = httpServ.getresponse()
if response.status == httplib.OK:
    print "=== OUTPUT FROM TEST 1 ==="
    printText (response.read())
"""
httpServ.request('POST', '/exist/restxq/ontology?type=*&offset=1&limit=1')
response = httpServ.getresponse()
if response.status == httplib.OK:
    print "=== OUTPUT FROM TEST 2 ==="
    printText (response.read())
"""
httpServ.request('GET', '/exist/restxq/ontology?type=*&offset=1&limit=5&search=text')
response = httpServ.getresponse()
if response.status == httplib.OK:
    print "=== OUTPUT FROM TEST 3 ==="
    printText (response.read())
"""
httpServ.close()
