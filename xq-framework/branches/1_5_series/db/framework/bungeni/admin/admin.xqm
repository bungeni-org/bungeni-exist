module namespace adm = "http://exist.bungeni.org/adm";

(:~
:  Renders the admin's main menu
: @param active
:   The current section
:
: @return
:   a HTML node()
:)
declare function adm:main-menu($active as xs:string) {
    <ul id="adm-main-menu">
        <li><a href="admin-nav.xql" title="Navigation Preferences">Navigation</a></li>
        <li><a href="admin-route.xql" title="Route Configurations">Routes</a></li>
        <li><a href="admin-order.xql" title="Order Configurations">Order</a></li>
        <li><a href="admin-search.xql" title="Search Configurations">Search</a></li>
        <li><a href="admin-tabgroup.xql" title="Tab Groups Configurations">Tabgroups</a></li>
        <li><a href="admin-download.xql" title="Download-options Configurations">Downloads</a></li>
    </ul>              
};