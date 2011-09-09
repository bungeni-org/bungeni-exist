xquery version "1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";


(:~
Controller XQuery for the lexsearch application.
Intercepts incoming named resource requests and forwards appropriately.
This script allows separation of view from control logic.

- default redirector to the home page (index.xql)

- searchbytitle 
  * titlesarch.xql - searchs for an actid and retrieves an xml snapshot
  * translate-titlesearch.xql - accepts the xml snapshot, transforms to html and returns it back
     in a html response to the caller
     
- viewfullact - used to retrieve a full act document as html. accepts 2 parameters, the actidentifier and 
   the id prefix. THe id prefix is passed in and is prefixed on identifiers in the transformed html page. 
   This is because there are instances when 2 acts are retrieved on the same page - and they could have 
   clashing identifiers.
   * uses the same pattern as searchbytitle - the first script in the chain returns xml, the second script,
     transforms the xml to html.
     
:)

(: Root path: redirect to index.xql :)
if ($exist:path eq '/') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		<redirect url="index.xql"/>
	</dispatch>
(: Execute a query :)
else if ($exist:resource eq 'searchbytitle') then
    let $actid := xs:string(request:get-parameter("actid", ""))
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		     <forward url="titlesearch.xql">
                <add-parameter name="actid" value="{$actid}" />
            </forward>
            <view>
                <forward url="translate-titlesearch.xql" />
			</view>
        </dispatch>
else if ($exist:resource eq 'viewfullact') then
    let $actid := xs:string(request:get-parameter("actid", ""))
    let $pref := xs:string(xmldb:decode(request:get-parameter("pref","")))
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		     <forward url="viewacthtml.xql">
                <add-parameter name="actid" value="{$actid}" />
                <add-parameter name="pref" value="{$pref}" />
            </forward>
             <view>
                <forward url="translate-fullact.xql" >
                    <add-parameter name="pref" value="{$pref}" />
                </forward>
             </view>
        </dispatch>
else if ($exist:resource eq 'viewacttoc') then
    let $actid := xs:string(request:get-parameter("actid", ""))
    let $pref := xs:string(xmldb:decode(request:get-parameter("pref","")))
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		     <forward url="viewacttoc.xql">
                <add-parameter name="actid" value="{$actid}" />
                <add-parameter name="pref" value="{$pref}" />
            </forward>
             <view>
                <forward url="translate-toc.xql" >
                    <add-parameter name="actid" value="{$actid}" />
                    <add-parameter name="pref" value="{$pref}" />
                </forward>
             </view>            
        </dispatch>        
else if ($exist:resource eq 'searchbycap') then
    let $actid := xs:string(xmldb:decode(request:get-parameter("actid", "")))
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		     <forward url="capsearch.xql">
                <add-parameter name="actid" value="{$actid}" />
            </forward>
            <view>
                <forward url="translate-capsearch.xql" />
			</view>
        </dispatch>
else if ($exist:resource eq 'adsearch') then
    let $q := xs:string(xmldb:decode(request:get-parameter("q", "")))
    let $searchfor := xs:string(request:get-parameter("searchfor",""))
    let $searchin := xs:string(request:get-parameter("searchin",""))
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		     <forward url="adsearch.xql">
                <add-parameter name="searchfor" value="{$searchfor}" />
                <add-parameter name="searchin" value="{$searchin}" />
                <add-parameter name="q" value="{$q}" />
            </forward>
            <view>
                <forward url="translate-adsearch.xql">
                    <add-parameter name="searchfor" value="{$searchfor}" />
                    <add-parameter name="searchin" value="{$searchin}" />
                    <add-parameter name="q" value="{$q}" />s
                </forward>
			</view>
        </dispatch>
else if ($exist:resource eq 'ftsearch') then
    let $q := xs:string(xmldb:decode(request:get-parameter("q", "")))
    let $searchfor := xs:string(request:get-parameter("searchfor",""))
    let $searchin := xs:string(request:get-parameter("searchin",""))
    let $searchmm := xs:string(request:get-parameter("restrictmm", ""))
    let $searchyy := xs:string(request:get-parameter("restrictyy", ""))
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
		     <forward url="ftsearch.xql">
                <add-parameter name="searchfor" value="{$searchfor}" />
                <add-parameter name="searchin" value="{$searchin}" />
                <add-parameter name="q" value="{$q}" />
                <add-parameter name="restrictyy" value="{$searchyy}" />
                <add-parameter name="restrictmm" value="{$searchmm}" />
            </forward>
            <view>
                <forward url="translate-adsearch.xql">
                    <add-parameter name="searchfor" value="{$searchfor}" />
                    <add-parameter name="searchin" value="{$searchin}" />
                    <add-parameter name="q" value="{$q}" />
                </forward>
			</view>
        </dispatch>         
else
    (: everything else is passed through :)
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </ignore>

