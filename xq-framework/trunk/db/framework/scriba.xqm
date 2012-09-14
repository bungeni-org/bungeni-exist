xquery version "3.0";

module namespace scriba = 'http://scribaebookmake.sourceforge.net/1.0/';
declare namespace transform = "http://exist-db.org/xquery/transform";
import module namespace cmn = "http://exist.bungeni.org/cmn" at "common.xqm";

(:~
    : Module for Generating ScribaEbookMaker main config file. The SCF
    
    : @author Anthony Oduor <aowino@googlemail.com>
:)

(:~
 : Add authors to metadata node
 :
 : @param $authors nodes with authors, editors
 :
 : @return <metaitem/> node(s)
:)
declare function scriba:add-authors($author as xs:string) {

    if ($author) then 
        <metaitem eletype="dc" elename="creator" role="aut">{$author}</metaitem>
    else
        <metaitem eletype="dc" elename="creator" role="aut">Bungeni Creator</metaitem>     
};

(:~
 : Add title of ebook to metadata node
 :
 : @param $title of document
 :
 : @return <metaitem/> node(s)
:)
declare function scriba:add-title($title as xs:string) {
    if (not(empty($title))) then 
        <metaitem eletype="dc" elename="title">{$title}</metaitem>
    else
        <metaitem eletype="dc" elename="title">Blank title of %pretty_date%</metaitem> 
};

(:~
 : Add main component - <metatdata/> node
 :
 : @param $title of document
 : @param $authors of document
 :
 : @return <metdadata/> node
:)
declare function scriba:generate-metadata($title as xs:string, $authors as xs:string) {

    <metadata>
        {scriba:add-title($title)}    
        {scriba:add-authors($authors)}
        <metaitem eletype="dc" elename="creator" role="edt">Bungeni Parliament</metaitem>
        <metaitem eletype="dc" elename="language">it</metaitem>
        <metaitem eletype="dc" elename="identifier" id="senabookid">testId</metaitem>
        <metaitem eletype="dc" elename="subject">Legislation</metaitem>
        <metaitem eletype="dc" elename="date">%date%</metaitem>
        <metaitem eletype="meta" elename="meta" name="copyright" content="Bungeni Parliament" destination="opf"/>
        <metaitem eletype="meta" elename="meta" name="dtb:uid" content="testId" destination="ncx"/>
        <metaitem eletype="meta" elename="meta" name="dtb:depth" content="1" destination="ncx"/>
        <metaitem eletype="meta" elename="meta" name="dtb:totalPageCount" content="2" destination="ncx"/>
        <metaitem eletype="meta" elename="meta" name="dtb:maxPageNumber" content="2" destination="ncx"/>
    </metadata>
};

(:~
 : Add main component - <contents/> node
 :
 : @param $title of document
 : @param $authors of document
 :
 : @return <contents/> node
:)
declare function scriba:generateContent($pages as node()) {

    <contents tocId="toc">{
        for $page at $pos in $pages/page
            return
                <content packageId="bungeni_{$pos}" 
                        packagePath="Bungeni{$pos}" 
                        packageFile="bungeni/bungeni_{$pos}.htm" 
                        contentMediaType="application/xhtml+xml" 
                        isInSpine="true" 
                        tocName="Bungeni {$pos}" 
                        isNeededTidy="true" 
                        isNeededXsl="false">
                    {scriba:escapee($page)}
                </content>
    }
    </contents>
};

(:~
 : Add main component - <contents/> node
 :
 : @param $title of document
 : @param $authors of document
 :
 : @return <contents/> node
:)
declare function scriba:create-book($title as xs:string, $authors as xs:string, $pages as node()) {
            
     <book version="1.0">
        <metadata>
            {scriba:add-title($title)}    
            {scriba:add-authors($authors)}
            <metaitem eletype="dc" elename="creator" role="edt">Bungeni Parliament</metaitem>
            <metaitem eletype="dc" elename="language">it</metaitem>
            <metaitem eletype="dc" elename="identifier" id="senabookid">testId</metaitem>
            <metaitem eletype="dc" elename="subject">Legislation</metaitem>
            <metaitem eletype="dc" elename="date">%date%</metaitem>
            <metaitem eletype="meta" elename="meta" name="copyright" content="Bungeni Parliament" destination="opf"/>
            <metaitem eletype="meta" elename="meta" name="dtb:uid" content="bungeniId" destination="ncx"/>
            <metaitem eletype="meta" elename="meta" name="dtb:depth" content="1" destination="ncx"/>
            <metaitem eletype="meta" elename="meta" name="dtb:totalPageCount" content="{count($pages/page)}" destination="ncx"/>
            <metaitem eletype="meta" elename="meta" name="dtb:maxPageNumber" content="{count($pages/page)}" destination="ncx"/>
        </metadata>     
        {
            scriba:generateContent($pages)
        }</book>
};

(:~
 : Add escapes the node given for scriba not to complain
 :
 : @param $noded item node
 :
 : @return node with escape content
:)
declare function scriba:escapee($noded as node()) {
    
    let $stylesheet := cmn:get-xslt("escape-xml.xsl")    
    let $doc := <div>
                    {transform:transform($noded,$stylesheet,())}
                </div>
    return 
        $doc

};