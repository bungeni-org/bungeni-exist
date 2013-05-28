xquery version "3.0";

declare namespace json="http://www.json.org";
declare namespace control="http://exist-db.org/apps/frameworkadmin/controller";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rest="http://exquery.org/ns/restxq";

import module namespace login-helper="http://exist-db.org/apps/frameworkadmin/login-helper" at "modules/login-helper.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $login := login-helper:get-login-method();

if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if (matches($exist:path, ".xql/?$")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        { $login("org.exist.login", (), true()) }
        <set-attribute name="$exist:path" value="{$exist:path}"/>
        <cache-control cache="yes"/>
    </dispatch>    
else if ($exist:resource = "login") then (
    util:declare-option("exist:serialize", "method=json media-type=application/json"),
    try {
        let $loggedIn := $login("org.exist.login", (), true())
        return
            if (xmldb:get-current-user() != "guest") then
                <response>
                    <user>{xmldb:get-current-user()}</user>
                    <isDba json:literal="true">true</isDba>
                </response>
            else (
                <response>
                    <fail>Wrong user or password</fail>
                </response>
            )
    } catch * {
        <response>
            <fail>{$err:description}</fail>
        </response>
    }

)     
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
