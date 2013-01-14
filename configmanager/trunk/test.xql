xquery version "3.0";
declare option exist:serialize "method=xhtml media-type=application/xhtml+html";

let $doc := 
<html
 xmlns="http://www.w3.org/1999/xhtml"
 xmlns:xf="http://www.w3.org/2002/xforms">
   <head>
      <title>XForms inputs with labels</title>
      <xf:model>
         <xf:instance xmlns="">
            <data>
               <PersonGivenName/>
               <PersonSurName/>
            </data>
         </xf:instance>
      </xf:model>
   </head>
   <body>

      <p>Enter your first name, and last name.</p>
         <xf:input ref="PersonGivenName" incremental="true">
            <xf:label>Input First-Name:</xf:label>
            <xf:hint>Also known as given name.</xf:hint>
         </xf:input>
         <br/>
         <xf:input ref="PersonSurName" incremental="true">
            <xf:label>Input Last Name:</xf:label>
            <xf:hint>Also known as sur name or family name.</xf:hint>
         </xf:input>
         <br/>
         <br/>
         Output First Name: <b><xf:output ref="PersonGivenName"/></b>
         <br/>
         Output Last Name: <b><xf:output ref="PersonSurName"/></b>
      <p>Note that as you type the model output will be updated.</p>
      
      <span id="progmenu">Right click me to get a menu</span>
      
      <script type="text/javascript" defer="defer">
      <!--
        require(["dojo/ready", "dijit/Menu", "dijit/MenuItem", "dijit/CheckedMenuItem", "dijit/MenuSeparator", "dijit/PopupMenuItem"], function(ready, Menu, MenuItem, CheckedMenuItem, MenuSeparator, PopupMenuItem){
            ready(function(){
                var pMenu;
                pMenu = new Menu({
                    targetNodeIds: ["progmenu"]
                });
                pMenu.addChild(new MenuItem({
                    label: "Simple menu item"
                }));
                pMenu.addChild(new MenuItem({
                    label: "Disabled menu item",
                    disabled: true
                }));
                pMenu.addChild(new MenuItem({
                    label: "Menu Item With an icon",
                    iconClass: "dijitEditorIcon dijitEditorIconCut",
                    onClick: function(){alert('i was clicked')}
                }));
                pMenu.addChild(new CheckedMenuItem({
                    label: "checkable menu item"
                }));
                pMenu.addChild(new MenuSeparator());
        
                var pSubMenu = new Menu();
                pSubMenu.addChild(new MenuItem({
                    label: "Submenu item"
                }));
                pSubMenu.addChild(new MenuItem({
                    label: "Submenu item"
                }));
                pMenu.addChild(new PopupMenuItem({
                    label: "Submenu",
                    popup: pSubMenu
                }));
        
                pMenu.startup();
            });
        });      
-->
</script>
   </body>
</html>

return $doc