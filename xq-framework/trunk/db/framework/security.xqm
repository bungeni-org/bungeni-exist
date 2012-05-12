(:
This module manages security and admin user login
Adapted from the seewhatithink application
:)

(:
 Original copyright notice : 

 Copyright 2011 Adam Retter

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
:)

module namespace sec="http://exist.bungeni.org/sec";

import module namespace session = "http://exist-db.org/xquery/session";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace config = "http://bungeni.org/xquery/config" at "config.xqm";

(:
: User name of the current logged in user
:
: @return
:   user name of the logged in user, if user is anonymous it returns guest
:)
declare function sec:get-current-user() as xs:string {
    xmldb:get-current-user()
};

declare function sec:is-loggedin-user() as xs:boolean {
    xmldb:get-user-groups(security:get-username()) = $config:fw-group
};

