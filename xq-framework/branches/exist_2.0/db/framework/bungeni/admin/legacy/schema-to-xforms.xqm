module namespace s2f='http://code.google.com/p/xrx/s2f';

(: XQuery module for transforming an XML Schema to an XForms application :)


(: if you what to change the styling you can put in your own module here.  It must have the following functions:
   style:import-css(),
   style:breadcrumb(),
   style:header(),
   style:footer()
:)
import module namespace style='http://code.google.com/p/xrx/style' at '/db/framework/bungeni/admin/legacy/style.xqm';

(: Note that many of these functions have the entire XML Schema $schema as the first argument.  We need
this whenever we can not predict where in the XML Schema the information is coming from :)

declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace bu="http://portal.bungeni.org/1.0/";

(: functions that are used to transform and XML Schema to XForms :)
(: note that this assumes an intance has been generated in {$schemas}/gen-xforms/{myform}-instance.xml :)

(: to use this point the $schema to the target XML Schema like this:
   let $schema := doc($path-to-schema-dir/my-schema.xsd)/xs:schema 
   
Known issues
   No support for include files yet
   Does not handle all typed elements
   Does not handle read-only (CSS file)
   Does not handle repitition
   Data types not complete
   Does not use ISO names and Representation Terms to guess the form type
   No support for metadata registry label lookups
   :)

(: Stub for given a element name, look up a the screen label from the metadata registry :)
declare function s2f:get-label-for-element-name($element-name as xs:string) {
(: if (exists(xrx:get-label-from-registry($element-name)) :)
  $element-name
};

declare function s2f:get-element-for-name($schema as node(), $element-name as xs:string) {
(: if (exists(xrx:get-label-from-registry($element-name)) :)
   $schema//xs:element[@name=$element-name]
};

declare function s2f:element-name-to-xforms-control($schema as node(), $element-name as xs:string, $use-current as xs:boolean) as node() {
(: FIXME: put in a lookup into a metadata registry to get a nice-looking data element label :)
(: xrx:get-label-for-element({$element-name}) :)
let $name :=
   if ($use-current)  then ('.')
   else ($element-name)
return
    if (ends-with(lower-case($element-name), 'code')) then (
       let $element := s2f:get-element-for-name($schema, $element-name)
       return
          s2f:element-to-select1($element)
       )
    else if (ends-with(lower-case($element-name), 'text')
            or ends-with(lower-case($element-name), 'note')
            or ends-with(lower-case($element-name), 'description')) then 
             <xf:textarea ref="{$element-name}" class="{$element-name}">
                     <xf:label>{$element-name} : </xf:label>
             </xf:textarea>
    else
            <xf:input ref="{$element-name}" class="{$element-name}">
                <xf:label>{$element-name} : </xf:label>
            </xf:input>
};

(: just a test function for testing XPath expressions - not used in the actual tranformation :)
declare function s2f:get-all-simple-elements($schema as node()) as item()* {
for $element in $schema//xs:element[not(*)]
   let $element-name := string($element/@name)
   let $type := string($element/@type)
return
<xf:input ref="{$element-name}" class="{$type}">
         <xf:label>{s2f:get-label-for-element-name(string($element/@name))} : </xf:label>
</xf:input>
};

(: recursive test function to process all complex elements in an XML Schema :)
declare function s2f:process-complex-element($complex-element as node()) as node() {
   let $element-name := concat(string($complex-element/@name), string($complex-element/@ref))
   return
    element {$element-name}
       {
       if ($complex-element/xs:complexType)
          then
             for $sub-element in $complex-element/xs:complexType/*/xs:element
               return
                  s2f:process-complex-element($sub-element)
          else ()
        }
};

(: return true if an element is a complex element :)
declare function s2f:isComplex($schema as node(), $element as node()) as xs:boolean {
   let $element-name := if (string($element/xs:schema/name()) eq "xs:schema") then
                            concat(string($element/xs:schema/xs:element/@name), string($element/xs:schema/xs:element/@ref))
                        else
                            concat(string($element/@name), string($element/@ref))
   return
      if ($schema//xs:element[@name eq $element-name]/xs:complexType) then true()
      else false()
};

(: return true if we need to generate an XForms repeat for this elements :)
declare function s2f:generate-xforms-repeat($schema as node(), $element as node()) as xs:boolean {
   let $maxOccurs := string($element/@maxOccurs)        
   (: we want to generate repeats in the XForms if the maxOccurs is not missing (the default) or set to be 1  :)
   (: this should return true() if $maxOccurs is 2,3,4..etc or 'unbounded'. :)
   return
      if (not($maxOccurs = '' or $maxOccurs = '1')) then true()
      else false()
};

(: Recursive function to process all complex elements in an XML Schema :)
(: this uses the fact that any XForms must set the context of the instance :)
(: Schema must be passed to allow ref lookups :)
(: complex-element is the current place we are looking up :)
declare function s2f:xforms-body($schema as node(), $element as node(), $base as xs:string, $depth as xs:integer) as node() {
   (: ignore the xs:schema guy :)
   let $element-name := if (string($element/xs:schema/name()) eq "xs:schema") then
                            concat(string($element/xs:schema/xs:element/@name), string($element/xs:schema/xs:element/@ref))
                        else
                            concat(string($element/@name), string($element/@ref))
   return
       (: if there are any complex types under this complex type - recurse:)
       if ($schema//xs:element[@name=$element-name and not(string(@maxOccurs) = '' or string(@maxOccurs) = '1')]) then 
            (s2f:repeat($element, $element, $base, $depth + 1))
       else ((: else if we have a complex element :)
            if (s2f:isComplex($schema, $element)) then (
                     <xf:group ref="{concat($base, '/', $element-name)}" appearance="compact">
                        <xf:label class="group-label">{$element-name}</xf:label>
                        {for $sub-element in $element//xs:element/xs:complexType/*/xs:element
                            return
                                s2f:xforms-body($schema, $sub-element, concat($base, '/', $element-name), $depth + 1)
                        }
                   </xf:group>
                   )
              else (: we have a simple no-repeating element :)
                 (s2f:element-name-to-xforms-control($schema, $element-name, false()))
          )
};


declare function s2f:repeat($schema as node(), $element as node(), $base as xs:string, $depth as xs:integer) as node()* {

(: Generate a single XForms repeat structure for adding and deleting items from a sequence.
Should be called by the XForms driver every time it encounters an element with cardinality greater than one :)
(: repeat should be don when
   not($maxOccurs = '' or $maxOccurs = '1') :)
(: TODO - put in rules for when to conditionall bind the add based on maxOccurs bind="{$name}-add-trigger" :)

(: $schema is the XML Schema that we are transforming.
   $element is the current element that is a repeated element.
   $base is the full path from the base of the XML Schema :)
   
(: note that the div repeat must be there to style the repitition group AND the add button at the end :)
   
let $name := string($element/@name)
(: if we have the full base like /Root/element/sub-element we only want "sub-element" after
the instance('save-data')/ here so we trim the "/Root/" off :)
let $base-temp := substring-after($base, '/')
let $new-base := substring-after($base-temp, '/')
let $first-field-id := concat(string($schema//xs:element[@name=$name]/xs:complexType/*/xs:element[1]/@name), '-id')
return
   <div class="repeat">
       <xf:label class="repeat-label">{$name}</xf:label>
       <xf:repeat nodeset="instance('save-data')/{$new-base}/{$name}" id="{$name}-repeat">
          
           {
           (: if we have just a complex element :)
           if (exists($schema//xs:element[@name=$name]/xs:complexType/*/xs:element))
              then (
                   for $sub-element at $count in $schema//xs:element[@name=$name]/xs:complexType/*/xs:element
                     let $sub-element-name := string($sub-element/@name)
                     return
                     if ($sub-element/*)
                        then ( (: concat($name, '[', $name, '-repeat]/', $sub-element) :)
                        s2f:xforms-body($schema, $sub-element, $base, $depth + 1))
                        else (s2f:element-name-to-xforms-control($schema, $sub-element-name, false()))
                    )
              else ( (: else we have just a single element :)
                s2f:element-name-to-xforms-control($schema, $name, true())
            )
           }
           <xf:trigger bind="{$name}-delete-trigger">
               <xf:label>Delete</xf:label>
               <xf:delete nodeset="instance('save-data')/{$new-base}/{$name}[index('{$name}-repeat')]" ev:event="DOMActivate"/>
           </xf:trigger>
           
       </xf:repeat>
       

       <xf:trigger>
           <xf:label>Add {$name}</xf:label>
           <xf:action ev:event="DOMActivate">
              <xf:insert nodeset="instance('save-data')/{$new-base}/{$name}" at="last()" position="after"/>
              { (: this initializes the values of the copied last row to nulls.  Can also use an origin attribute. :)
              for $sub-element at $count in $schema//xs:element[@name=$name]/xs:complexType/*/xs:element
                 let $name := string($sub-element/@name)
                 return 
                    <xf:setvalue ref="instance('save-data')/{$new-base}/{$name}[index('{$name}-repeat')]/{$name}" value=""/>
              }
              <!-- this puts the cursor in the first field of the new row we just added -->
              <xf:setfocus control="{$first-field-id}"/>
           </xf:action>
       </xf:trigger>
    </div>
};

(: Create bind statements for all required fields :)
(: FIXME: Check for duplicates - never put in a bind if we already have it.
Get a list of required elements and run it through distinct-values. :)
declare function s2f:required-binds($schema as node()) as node()* {
if (exists($schema//xs:element[not(@minOccurs='0') and not(xs:complexType)]))
  then (
      <!-- required fields -->,
      (: binds for required fields: any element that does NOT have a minOccurs = 0 or HAS a minOccurs over 1 :)
      (: as an efficiency measure we can replace "//" with an absolute path to the element :)
      let $me := for $element in $schema//xs:element[not(@minOccurs='0') and not(xs:complexType)] return <unique>{string(if($element/@ref) then $element/@ref else $element/@name)}</unique>
      let $unique := distinct-values($me)      
      for $element in $unique
          return
            <xf:bind nodeset="//{string($element)}" required="true()"/>
     )
     else ()
};

(: If the element has a type="xs:date" or if the element name ends in "date" or "Date" or "DATE" then we bind
it to the date calendar selector. Note that dateTimes are never bound to a calendar selector.  :)
declare function s2f:date-binds($schema as node()) as node()*{
if (exists($schema//xs:element[@type="xs:date" or ends-with(lower-case(@name), 'date')]))
then (
   <!-- bindings for dates -->,
   for $element in $schema//xs:element[@type="xs:date" or ends-with(lower-case(@name), 'date')]
          return
             <xf:bind nodeset="//{string($element/@name)}" type="xs:date"/>
             )
   else ()
};

(: If the element has a type="xs:boolean" or if the element name ends in "indicator" or "Indicator" or "INDICATOR" then we bind
it to the input checkbox. Note that dateTimes are never bound to a calendar selector.  :)
declare function s2f:indicator-binds($schema as node()) as node()*{
if (exists($schema//xs:element[@type="xs:boolean" or ends-with(lower-case(@name), 'indicator')]))
then (
   <!-- bindings for booleans -->,
   for $element in $schema//xs:element[@type="xs:boolean" or ends-with(lower-case(@name), 'indicator')]
          return
            if ($element/@ref) then 
                <xf:bind nodeset="//{string($element/@ref)}" type="xs:boolean"/>
            else
                <xf:bind nodeset="//{string($element/@name)}" type="xs:boolean"/>          
             
    )
  else ()
};


(: Transform the element with enumerations to a select1 control :)
(: FIXME: lookup the value from the metadata registry to get a nice-looking label :)
declare function s2f:element-to-select1($element as node()) as node(){
   <xf:select1>
      <xf:label>{s2f:get-label-for-element-name(string($element/@name))}</xf:label>{
         for $enum in $element/xs:simpleType/xs:restriction/xs:enumeration
         return
            <xf:item>
               <xf:label>{string($enum/@value)}</xf:label>
               <xf:value>{string($enum/@value)}</xf:value>
            </xf:item>
   }</xf:select1>
};

(: Create a list of conditional views instance for binding add delete triggers :)
declare function s2f:conditional-views($schema as node()) as node()* {
if (exists($schema//xs:element[exists(@maxOccurs) and @maxOccurs != '1']))
  then (
        <!-- Instance to hold conditional view bindings. -->,
        <xf:instance id="views"  xmlns="" >
          <data>
           {(: Delete triggers we want to include if there are any @maxOccurs attributes and @maxOccurs != '1' :)
           for $element in $schema//xs:element[exists(@maxOccurs) and @maxOccurs != 'unbounded']
              return
                 element {concat(string($element/@name), '-delete-trigger')} {''}
           }
           
           {(: Add triggers we want to include if there are any @maxOccurs attributes @maxOccurs != 'unbounded' :)
           for $element in $schema//xs:element[exists(@maxOccurs) and @maxOccurs != 'unbounded']
              return
                 element {concat(string($element/@name), '-add-trigger')} {''}
           }
          </data>
        </xf:instance>
    )
    else ()
};

(: create a list of conditional views instance for binding delete triggers :)
declare function s2f:trigger-visability-bind-rules($schema as node()) as node()* {
if (exists($schema//xs:element[exists(@maxOccurs) and @maxOccurs != '1']))
then (
   (: conditionally put in some comment here :)
   <!-- binds for add/delete trigger visability -->,
   for $element in $schema//xs:element[exists(@maxOccurs) and @maxOccurs != '1']
      let $name := if ($element/@name) then string($element/@name) else string($element/@ref)
      let $min := string($element/@minOccurs)
      let $max := string($element/@maxOccurs)
      return
         <xf:bind 
            id="{concat($name, '-delete-trigger')}"
            nodeset="instance('views')/{$name}-delete-trigger"
            relevent="instance('save-data')//{$name}[{$min}]" />
    (:,
   for $element in $schema//xs:element[exists(@maxOccurs) and @maxOccurs != '1']
      let $name := string($element/@name)
      let $min := string($element/@minOccurs)
      let $max := string($element/@maxOccurs)
      return
         <xf:bind id="{concat('bind-', $element, '-add-trigger')}" 
         nodeset="instance('views')/{$name}-add-trigger" 
         relevent="count(instance('save-data')//{$name} &gt $max" />
         :)
  ) 
  else ()
};



(: generate an XForms application using XRX app-info conventions from an XML Schema :)
declare function s2f:schema-to-xforms($schema as node(), $schema-name as xs:string) as node(){
  let $my-form := substring-before($schema-name, '.xsd')
  (: Using NIEM conventions we look for a first-level representation term with a suffix "Document" :)
  let $form-name := $schema/xs:schema/xs:element[ends-with(@name, 'Document')]/xs:annotation/xs:documentation/text()
  (: newlines with to two or three tabs :)
  let $nl2ttt := '

            '
  let $nltt := '
        '
  let $nlttt := '
            '
return
<html
   xmlns="http://www.w3.org/1999/xhtml"
   xmlns:xhtml="http://www.w3.org/1999/xhtml"
   xmlns:xf="http://www.w3.org/2002/xforms"
   xmlns:bu="http://portal.bungeni.org/1.0/"
   xmlns:ev="http://www.w3.org/2001/xml-events"
   xmlns:bf="http://betterform.sourceforge.net/xforms"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" 
>
 <head>
    <title>Bungeni XForms application generated from constraint schema.</title>
    <!--{style:import-css()}-->
    <style language="text/css">
      <![CDATA[
        @namespace xf url("http://www.w3.org/2002/xforms");
        body {font-family: Arial, Helvetica; sans-serif;}
        
        /* This line ensures all the separate input controls appear on their own lines */
        xf|output, xf|input, xf|select, xf|select1, xf|textarea {display:block; margin:5px 0;}
    
        /* Makes the labels right aligned in a column that floats to the left of the input controls. */
        xf|output > xf|label,
        xf|input > xf|label,
        xf|secret > xf|label,
        xf|select > xf|label,
        xf|select1 > xf|label,
        xf|textarea > xf|label
        {text-align:right; padding-right:10px; width:160px; float:left;}
    
        /* the input values are left aligned */
        xf|value {
           text-align: left;
        }
    
       ]]>
    </style>    
    <xf:model schema="/exist/rest/db/framework/bungeni/admin/legacy/edit/bungeni-xml.xsd">
         {$nl2ttt}
         <!-- this instance holds the data we save -->
         <xf:instance xmlns="" id="save-data" src="/exist/rest/db/framework/bungeni/admin/legacy/edit/{$my-form}.xml"/>
         {$nl2ttt}
         {s2f:conditional-views($schema)}
         {$nl2ttt}
         {s2f:required-binds($schema)}
         {$nl2ttt}
         {s2f:date-binds($schema)}
         {$nl2ttt}
         {s2f:indicator-binds($schema)}
         {$nl2ttt}
         {s2f:trigger-visability-bind-rules($schema)}
         {$nlttt}
          
          <!-- <run xq="import-code-tables"/> -->
          <!-- put the server-side call to save your form data here using -->
         <xf:submission id="save" method="post" action="save-new.xq" instance="save-data"/>
      </xf:model>
 </head>
  <body>
     {style:header()}
     {style:breadcrumb()} &gt; <a href="/exist/rest/db/schema2xforms/schema-to-xforms-test.xq">List Schemas</a>
     <!-- start at the base and schema and generate all groups.  The second is the starting point. -->
     {s2f:xforms-body($schema, $schema, '', 1)}
   
      <xf:submit submission="save">
         <xf:label>Save</xf:label>
      </xf:submit>
      {style:footer()}
  </body>
</html>
 };