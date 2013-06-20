xquery version "3.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)

(: the target collection into which the app is deployed :)
declare variable $target external;

for $resource in xmldb:get-child-resources($target || "/modules")
where ends-with($resource,".xql")
return
    sm:chmod(xs:anyURI($target || "/modules/" || $resource), "rwxr-xr-x")