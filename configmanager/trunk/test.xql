xquery version "3.0";


declare option exist:serialize "method=html media-type=text/html";

let $doc := 
<html    xmlns:xf="http://www.w3.org/2002/xforms"
        xmlns:ev="http://www.w3.org/2001/xml-events" 
     >
<head>
<title>Hello World in XForms</title>
<xf:model id="model">
<xf:instance id="codes">
    <modes>
        <mode>add</mode>
        <mode>edit</mode>
        <mode>view</mode>
     </modes>
</xf:instance>

<xf:instance id="source">
    <modes />
</xf:instance>

<xf:submission>
</xf:submission>

<!-- Initial loading of the address list when form is ready -->
        <xf:action ev:event="xforms-ready">
            <xf:send submission="load"/>
        </xf:action>
 
</xf:model>
</head>
<body>
<p>Type your first name in the input box. <br/>
If you are running XForms, the output should be displayed in the output area.</p>   
<br />
<xf:select id="select"  appearance="full" incremental="true">
    <xf:label>a combobox select</xf:label>
    <xf:hint>a Hint for this control</xf:hint>
    <xf:help>help for select</xf:help>
    <xf:alert>invalid</xf:alert>
    <xf:itemset nodeset="instance('codes')/mode">
        <xf:label ref="."></xf:label>
        <xf:value ref="."></xf:value>
    </xf:itemset>
</xf:select>
    <script type="text/javascript" defer="defer">
        <![CDATA[
        dojo.addOnLoad(function(){
            dojo.subscribe("/xf/ready", function() {
                fluxProcessor.skipshutdown=true;
            });
        });
       ]]>
    </script>   
</body>
</html>

return $doc