module namespace adm = "http://exist.bungeni.org/adm";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;

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
        <xhtml:li><xhtml:a href="admin-order.xql" title="Order Configurations">Order</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-search.xql" title="Search Configurations">Search</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-tabgroup.xql" title="Tab Groups Configurations">Tabgroups</xhtml:a></xhtml:li>
        <xhtml:li><xhtml:a href="admin-download.xql" title="Download-options Configurations">Downloads</xhtml:a></xhtml:li>
    </xhtml:ul>              
};