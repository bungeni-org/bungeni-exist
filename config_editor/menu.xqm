module namespace menu = "http://exist.bungeni.org/adm";

import module namespace cfg = "http://bungeni.org/xquery/config" at "config.xqm";

declare namespace xhtml="http://www.w3.org/1999/xhtml" ;

(:~
:  Renders the types main menu
: @param active
:   The current section
:
: @return
:   a HTML node()
:)
declare function menu:get-types($active as xs:string) {
    <xhtml:div dojoType="dijit.PopupMenuItem"> 
        <xhtml:span>
            Types            
        </xhtml:span>
        <xhtml:div dojoType="dijit.Menu" id="submenu">
            <xhtml:div dojoType="dijit.MenuItem" onClick="alert('new!');">add new</xhtml:div>
            <xhtml:div dojoType="dijit.MenuSeparator"/>
            {
                for $docu in doc(concat($cfg:CONFIGS-COLLECTION,'/types.xml'))/types/*
                return    
                    <xhtml:div dojoType="dijit.PopupMenuItem">
                        <xhtml:span>{data($docu/@name)}</xhtml:span>
                        <xhtml:div dojoType="dijit.Menu" id="formsMenu{data($docu/@name)}">
                            <xhtml:div dojoType="dijit.MenuItem" onclick="javascript:dojo.publish('/form/view',['{data($docu/@name)}','details']);">forms</xhtml:div>
                            <xhtml:div dojoType="dijit.MenuItem">workflows</xhtml:div>
                            <xhtml:div dojoType="dijit.MenuItem">workspace</xhtml:div>
                        </xhtml:div>
                    </xhtml:div>
            }
        </xhtml:div>
    </xhtml:div>             
};


(:~
:  Renders the list of language catalogues available
:
: @return
:   document with ISO codes of all availbale catalogues
:)
declare function menu:catalogues() {
    <catalogues>
    {
        for $lang in data(collection('/db/framework/i18n')/catalogue/@xml:lang)
        return 
            <lang label="{$lang}">{$lang}</lang>
    }
    </catalogues>            
};