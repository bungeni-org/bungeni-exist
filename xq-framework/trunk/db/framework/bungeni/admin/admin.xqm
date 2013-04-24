xquery version "3.0";

module namespace adm = "http://exist.bungeni.org/adm";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;


declare variable $adm:CXT := request:get-context-path();
declare variable $adm:UI-CONFIG :=  $adm:CXT || "/rest/db/apps/framework/bungeni/ui-config.xml";

(:~
:  Renders the admin's main menu
: @param active
:   The current section
:
: @return
:   a HTML node()
:)
declare function adm:main-menu($active as xs:string) {
    <xhtml:ul id="adm-main-menu">
        <xhtml:li><xhtml:a href="admin-navigation.xql" title="Navigation Preferences">Navigation</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-pagination.xql" title="Pagination Preferences">Pagination</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-route.xql" title="Route Configurations">Routes</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-order.xql" title="Order By Configurations">Order By</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-search.xql" title="Search In Configurations">Search In</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-viewgroup.xql" title="View Groups Configurations">Viewgroups</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-download.xql" title="Download-options Configurations">Downloads</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-i18n.xql" title="Edit i18n message strings">i18n Catalogues</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="help.xql" title="Help notes on using admin panel">Help&#160;<xhtml:span class="help"/></xhtml:a></xhtml:li>
    </xhtml:ul>              
};


(:~
:  Renders the list of language catalogues available
:
: @return
:   document with ISO codes of all availbale catalogues
:)
declare function adm:catalogues() {
    <catalogues>
    {
        for $lang in data(collection('/db/apps/framework/i18n')/catalogue/@xml:lang)
        return 
            <lang label="{$lang}">{$lang}</lang>
    }
    </catalogues>            
};