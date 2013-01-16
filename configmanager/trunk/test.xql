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
      <link rel="stylesheet" href="resources/css/fancydropdown.css"/>
   </head>
   <body>
<div id="menu">
<ul class="tabs">
	<li><h4><a href="#">In the blog</a></h4></li>
	<li class="hasmore"><a href="#"><span>Recent</span></a>
		<ul class="dropdown">
			<li><a href="#">Menu item 1</a></li>
			<li><a href="#">Menu item 2</a></li>
			<li><a href="#">Menu item 3</a></li>
			<li><a href="#">Menu item 4</a></li>
			<li><a href="#">Menu item 5</a></li>
			<li class="last"><a href="#">Menu item 6</a></li>
		</ul>
	</li>
	<li class="hasmore"><a href="#"><span>Topics</span></a>
		<ul class="dropdown">
			<li><a href="#">Topic 1</a></li>
			<li><a href="#">Topic 2</a></li>
			<li><a href="#">Topic 3</a></li>
			<li class="last"><a href="#">Topic 4</a></li>
		</ul>
	</li>
	<li><a href="#"><span><strong><img src="images/feed-icon-14x14.png" width="14" height="14" alt="RSS"/> Subscribe to RSS</strong></span></a></li>
	<li><h4><a href="#">Elsewhere</a></h4></li>
	<li><a href="#"><span>About</span></a></li>
	<li class="hasmore"><a href="/about/#networks"><span>Networks</span></a>
		<ul class="dropdown">
			<li><a href="#">Twitter</a></li>
			<li><a href="#">posterous</a></li>
			<li><a href="#">SpeakerSite</a></li>
			<li><a href="#">LinkedIn</a></li>
			<li class="last"><a href="#">See more</a></li>
		</ul>
	</li>
	<li><a href="#"><span>Bookmarks</span></a></li>
</ul>
</div>   
<xf:group>
    <xf:label>Switch / Case</xf:label>
    <div style="display:none;">
        <xf:trigger id="t-case1">
            <xf:label>Case 1</xf:label>
            <xf:toggle case="case1"></xf:toggle>
        </xf:trigger>
        <xf:trigger id="t-case2">
            <xf:label>Case 2</xf:label>
            <xf:toggle case="case2"></xf:toggle>
        </xf:trigger>
        <xf:trigger id="t-case3">
            <xf:label>Case 3</xf:label>
            <xf:toggle case="case3"></xf:toggle>
        </xf:trigger>
        <xf:trigger id="t-case4">
            <xf:label>Case 4</xf:label>
            <xf:toggle case="case4"></xf:toggle>
        </xf:trigger>
    </div>
    <xf:switch id="switch1" appearance="dijit:TabContainer">
        <xf:case id="case1" selected="true">
            <xf:label>Case 1</xf:label>
            <div class="caseContent" style="background:#bbbbff">
                <h2>CASE 1</h2>
                <p>This is some content for the first case</p>
            </div>
        </xf:case>
        <xf:case id="case2">
            <xf:label>Case 2</xf:label>
            <div class="caseContent" style="background:#ccccff">
                <h2>CASE 2</h2>
                <p>This is some content for the second case</p>
            </div>
        </xf:case>
        <xf:case id="case3">
            <xf:label>Case 3</xf:label>
            <div class="caseContent" style="background:#ddddff">
                <h2>CASE 3</h2>
                <p>This is some content for the third case</p>
            </div>
        </xf:case>
        <xf:case id="case4">
            <xf:label>Case 4</xf:label>
            <div class="caseContent" style="background:#eeeeff">
                <h2>CASE 4</h2>
                <p>This is some content for the fourth case</p>                
            </div>
        </xf:case>
    </xf:switch>
</xf:group>

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

        <script type="text/javascript" src="resources/js/jquery-1.8.1.min.js"></script>
        <script type="text/javascript" src="resources/js/fancydropdown.js"></script>
        <script type="text/javascript" defer="defer">
        <!--
        
        -->
        </script>    
   </body>
</html>

return $doc