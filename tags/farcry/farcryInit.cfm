<cfsetting enablecfoutputonly="true" />
<!--- @@copyright: Daemon Internet 2002-2007, http://www.daemon.com.au --->
<!--- @@license: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: farcryInit --->
<!--- @@description: Application initialisation tag. --->

<cfif thistag.executionMode eq "End">
	<!--- DO NOTHING IN CLOSING TAG --->
	<cfexit method="exittag" />
</cfif>

<!--- USED TO DETERMINE OVERALL PAGE TICKCOUNT --->
<cfset request.farcryPageTimerStart = getTickCount() />

<!--- DEFAULT ATTRIBUTES THAT CAN BE PASSED IN TO FARCRYINIT TO SET SOME MAJOR APPLICATION SCOPE VARIABLES --->
<cfif not isDefined("attributes.name")>
	<cfabort showerror="attributes.name not passed.">
</cfif>
<cfif not isDefined("attributes.dbtype")>
	<cfabort showerror="attributes.dbtype not passed.">
</cfif>

<cfparam name="attributes.sessionmanagement" default="true"  />
<cfparam name="attributes.sessiontimeout" default="#createTimeSpan(0,0,20,0)#" />
<cfparam name="attributes.applicationtimeout" default="#createTimeSpan(2,0,0,0)#" />
<cfparam name="attributes.clientmanagement" default="false" />
<cfparam name="attributes.clientstorage" default="registry" />
<cfparam name="attributes.loginstorage" default="cookie" />
<cfparam name="attributes.scriptprotect" default="" />
<cfparam name="attributes.setclientcookies" default="true" />
<cfparam name="attributes.setdomaincookies" default="true" />

<cfparam name="attributes.dsn" default="#attributes.name#" />
<cfparam name="attributes.dbowner" default="" />

<cfparam name="attributes.projectDirectoryName" default="#attributes.name#"  />
<cfparam name="attributes.plugins" default="farcrycms"  />

<cfparam name="attributes.projectURL" default="" />


<cfparam name="attributes.bObjectBroker" default="true" />
<cfparam name="attributes.ObjectBrokerMaxObjectsDefault" default="100" />

<cfparam name="attributes.locales" default="en_AU" />

<!--- Option to archive --->
<cfparam name="attributes.bUseMediaArchive" default="false" />
	
<cfif attributes.dbtype EQ "mssql" AND NOT len(attributes.dbowner)>
	<cfset attributes.dbowner = "dbo." />
</cfif>



<!--- 
FARCRY INIT WAS A 4.0 CUSTOM TAG USED TO INITIALIZE THE APPLICATION.
5.0 is initialised via the application.cfc
This tag is now used to invoke the updater and can only be run from the local machine

 --->
<cfset lAllowHosts = "127.0.0.1" />
<cfif NOT listFind(lAllowHosts, cgi.remote_addr)>
	<cfthrow errorcode="upgrade_invalid_host" detail="Your IP address (#cgi.remote_addr#) is not permitted to access the 5.0 updater" extendedinfo="By default, the 5.0 updater is only permitted to the following hosts : 127.0.0.1  To give access to other hosts, then append the desired IP address to the variable lAllowHosts in /farcry/core/tags/farcry/farcryInit.cfm">
</cfif>

<cfif structKeyExists(url, "upgrade") and url.upgrade EQ 1>
	
	<cfset varibles.projectPath = expandpath('/farcry/projects/#attributes.projectDirectoryName#/www') />
	<cfset varibles.upgraderPath = expandpath('/farcry/core/admin/updates/b500') />
	
	<cfif directoryExists("#varibles.projectPath#/upgrader5.0.0")>
		<cfdirectory action="delete" directory="#varibles.projectPath#/upgrader5.0.0" recurse="true" mode="777" />
	</cfif>

	<cfdirectory action="create" directory="#varibles.projectPath#/upgrader5.0.0" />
	<cffile action="copy" source="#varibles.upgraderPath#/Application.cfm" destination="#varibles.projectPath#/upgrader5.0.0" mode="777" />
	<cffile action="copy" source="#varibles.upgraderPath#/index.cfm" destination="#varibles.projectPath#/upgrader5.0.0" mode="777" />
	<cffile action="copy" source="#varibles.upgraderPath#/readme.txt" destination="#varibles.projectPath#/upgrader5.0.0" mode="777" />
	<cffile action="copy" source="#varibles.upgraderPath#/Application.cf_" destination="#varibles.projectPath#/upgrader5.0.0" mode="777" />
	<cffile action="copy" source="#varibles.upgraderPath#/proxyApplication.cf_" destination="#varibles.projectPath#/upgrader5.0.0" mode="777" />
	<cffile action="copy" source="#varibles.upgraderPath#/farcryConstructor.cf_" destination="#varibles.projectPath#/upgrader5.0.0" mode="777" />
	
	
	<cffile action="read" file="#varibles.projectPath#/upgrader5.0.0/farcryConstructor.cf_" variable="sFarcryConstructor" />

	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@Name", "#attributes.name#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@sessionmanagement", "#attributes.sessionmanagement#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@sessiontimeout", "#attributes.sessiontimeout#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@applicationtimeout", "#attributes.applicationtimeout#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@clientmanagement", "#attributes.clientmanagement#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@clientstorage", "#attributes.clientstorage#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@loginstorage", "#attributes.loginstorage#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@scriptprotect", "#attributes.scriptprotect#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@setclientcookies", "#attributes.setclientcookies#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@setdomaincookies", "#attributes.setdomaincookies#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@locales", "#attributes.locales#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dsn", "#attributes.dsn#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dbType", "#attributes.dbType#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dbOwner", "#attributes.dbOwner#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@plugins", "#attributes.plugins#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@projectDirectoryName", "#attributes.projectDirectoryName#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@projectURL", "#attributes.projectURL#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dsn", "#attributes.dsn#") />
	<cfset sFarcryConstructor = replaceNoCase(sFarcryConstructor, "@@dsn", "#attributes.dsn#") />
	
	<cffile action="write" file="#varibles.projectPath#/upgrader5.0.0/farcryConstructor.cf_" output="#sFarcryConstructor#" addnewline="false" mode="777" />
			
	<cflocation url="#attributes.projectURL#/upgrader5.0.0?Name=#attributes.name#&dsn=#attributes.dsn#&dbtype=#attributes.dbtype#&dbOwner=#attributes.dbOwner#" addtoken="false" />
<cfelse>
	<cfoutput>
	<h1>You are trying to initialise a 4.0 application using a 5.0 core.</h1>
	<p>
		Would you like to setup and run the upgrader now now? <br />
		This can only be run from an IP in the list (#lAllowHosts#)
	</p>
	
	<a href="#cgi.SCRIPT_NAME#?upgrade=1">Continue to Upgrader</a>
	</cfoutput>

</cfif>


<cfabort>



<cfapplication name="#attributes.name#" 
	sessionmanagement="#attributes.sessionmanagement#" 
	sessiontimeout="#attributes.sessiontimeout#"
	applicationtimeout="#attributes.applicationtimeout#"  
	clientmanagement="#attributes.clientmanagement#" 
	clientstorage="#attributes.clientstorage#"
	loginstorage="#attributes.loginstorage#" 
	scriptprotect="#attributes.scriptprotect#" 
	setclientcookies="#attributes.setclientcookies#" 
	setdomaincookies="#attributes.setdomaincookies#">


<!---------------------------------------- 
BEGIN: Application Initialise 
----------------------------------------->
<cfif NOT structkeyExists(url, "updateapp")>
	<cfset url.updateapp=false />
</cfif>

<cftry>

<cfif (NOT structkeyexists(application, "bInit") OR NOT application.binit) OR url.updateapp>
	<cflock name="#application.applicationName#_init" type="exclusive" timeout="3" throwontimeout="true">
		<cfif (NOT structkeyexists(application, "bInit") OR NOT application.binit) OR url.updateapp>
			
			<!--- set binit to false to block users accessing on restart --->
			<cfset application.bInit =  false />
			
			<!--- Project directory name can be changed from the default which is the applicationname --->
			<cfset application.projectDirectoryName =  attributes.projectDirectoryName />
			
			<!--- Set available locales --->
			<cfset application.locales = attributes.locales />
			
			<!----------------------------------------
			 SET THE DATABASE SPECIFIC INFORMATION 
			---------------------------------------->
			<cfset application.dsn = attributes.dsn />
			<cfset application.dbtype = attributes.dbtype />
			<cfset application.dbowner = attributes.dbowner />
			
			<cfif application.dbtype EQ "mssql" AND NOT len(application.dbowner)>
				<cfset application.dbowner = "dbo." />
			</cfif>
			
			<!----------------------------------------
			 SET THE MAIN PHYSICAL PATH INFORMATION
			 ---------------------------------------->
			<cfset application.path.project = expandpath("/farcry/projects/#application.projectDirectoryName#") />
			<cfset application.path.core = expandpath("/farcry/core") />
			<cfset application.path.plugins = expandpath("/farcry/plugins") />
			
			<cfset application.path.defaultFilePath = "#application.path.project#/www/files">
			<cfset application.path.secureFilePath = "#application.path.project#/securefiles">		
			
			<cfset application.path.imageRoot = "#application.path.project#/www">
			
			<cfset application.path.mediaArchive = "#application.path.project#/mediaArchive">
			
			
			<!----------------------------------------
			 WEB URL PATHS
			 ---------------------------------------->
			<cfset application.url.webroot = attributes.projectURL />
			<cfset application.url.farcry = "#attributes.projectURL#/farcry" />
			<cfset application.url.imageRoot = "#application.url.webroot#">
			<cfset application.url.fileRoot = "#application.url.webroot#/files">
			
			
			<!----------------------------------------
			SHORTCUT PACKAGE PATHS
			 ---------------------------------------->
			<cfset application.packagepath = "farcry.core.packages" />
			<cfset application.custompackagepath = "farcry.projects.#application.projectDirectoryName#.packages" />
			<cfset application.securitypackagepath = "farcry.core.packages.security" />
			
			<!----------------------------------------
			PLUGINS TO INCLUDE
			 ---------------------------------------->
			<cfset application.plugins = attributes.plugins />
			
			
			<!------------------------------------------ 
			USE OBJECT BROKER?
			 ------------------------------------------>
			<cfset application.bObjectBroker = attributes.bObjectBroker />
			<cfset application.ObjectBrokerMaxObjectsDefault = attributes.ObjectBrokerMaxObjectsDefault />
			
			
			<!------------------------------------------ 
			USE MEDIA ARCHIVE?
			 ------------------------------------------>
			<cfset application.bUseMediaArchive = attributes.bUseMediaArchive />
		
			<!---------------------------------------------- 
			INITIALISE THE COAPIUTILITIES SINGLETON
			----------------------------------------------->
			<cfset application.coapi = structNew() />
			<cfset application.coapi.coapiUtilities = createObject("component", "farcry.core.packages.coapi.coapiUtilities").init() />

	
			<!--- Initialise the stPlugins structure that will hold all the plugin specific settings. --->
			<cfset application.stPlugins = structNew() />
			
			
			<!--- ENSURE SYSINFO IS UPDATED EACH INITIALISATION --->
			<cfset application.sysInfo = structNew() />

			<!--- CALL THE PROJECTS SERVER SPECIFIC VARIABLES. --->
			<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVars.cfm" />
			
			
			<!----------------------------------- 
			INITIALISE THE REQUESTED PLUGINS
			 ----------------------------------->
			<cfif isDefined("application.plugins")>
				<cfloop list="#application.plugins#" index="plugin">
					<cfif fileExists("#application.path.plugins#/#plugin#/config/_serverSpecificVars.cfm")>
						<cfinclude template="/farcry/plugins/#plugin#/config/_serverSpecificVars.cfm">
					</cfif>
				</cfloop>
			</cfif>
			
							
			<!----------------------------------------
			SECURITY
			 ---------------------------------------->		
			<!---// dmSecurity settings --->
			<!---//Init Application dmsec scope --->
			<cfset Application.dmSec=StructNew() />
			<!---// --- Initialise the userdirectories --- --->
			<cfset Application.dmSec.UserDirectory = structNew() />
			
			<!---// Client User Directory --->
			<cfset Application.dmSec.UserDirectory.ClientUD = structNew() />
			<cfset temp = Application.dmSec.UserDirectory.ClientUD />
			<cfset temp.type = "Daemon" />
			<cfset temp.datasource = application.dsn />
			
			<!---//Policy Store settings --->
			<cfset Application.dmSec.PolicyStore = StructNew() />
			<cfset ps = Application.dmSec.PolicyStore />
			<cfset ps.dataSource = application.dsn />
			<cfset ps.permissionTable = "dmPermission" />
			<cfset ps.policyGroupTable = "dmPolicyGroup" />
			<cfset ps.permissionBarnacleTable = "dmPermissionBarnacle" />
			<cfset ps.externalGroupToPolicyGroupTable = "dmExternalGroupToPolicyGroup" />

			<!--------------------------------- 
			INITIALISE DMSEC
			 --------------------------------->
			<cfinclude template="/farcry/core/tags/farcry/_dmSec.cfm">


			<!---------------------------------------------- 
			INITIALISE THE COAPIADMIN SINGLETON
			----------------------------------------------->
			<cfset application.coapi.coapiadmin = createObject("component", "farcry.core.packages.coapi.coapiadmin").init() />
			<cfset application.coapi.objectBroker = createObject("component", "farcry.core.packages.fourq.objectBroker").init() />

		
			<!--------------------------------- 
			FARCRY CORE INITIALISATION
			 --------------------------------->
			<cfinclude template="/farcry/core/tags/farcry/_farcryApplicationInit.cfm" />

	
			<!------------------------------------
			OBJECT BROKER
			 ------------------------------------>		
			<cfif structkeyexists(application, "bObjectBroker") AND application.bObjectBroker>
				<cfset objectBroker = createObject("component","farcry.core.packages.fourq.objectBroker")>
				
				<cfloop list="#structKeyList(application.stcoapi)#" index="typename">
					<cfif application.stcoapi[typename].bObjectBroker>
						<cfset bSuccess = objectBroker.configureType(typename=typename, MaxObjects=application.stcoapi[typename].ObjectBrokerMaxObjects) />
					</cfif>
				</cfloop>
			</cfif>
			
	
			<!--- SETUP CATEGORY APPLICATION STRUCTURE --->
			<cfquery datasource="#application.dsn#" name="qCategories">
			SELECT categoryID, categoryLabel
			FROM #application.dbowner#categories
			</cfquery>
			
			<cfparam name="application.catid" default="#structNew()#" />
			<cfloop query="qCategories">
				<cfset application.catID[qCategories.categoryID] = qCategories.categoryLabel>
			</cfloop>
			
			
			<!--- CALL THE PROJECTS SERVER SPECIFIC AFTER INIT VARIABLES. --->
			<cfif fileExists("#application.path.project#/config/_serverSpecificVarsAfterInit.cfm") >
				<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVarsAfterInit.cfm" />
			</cfif>
			
			<!--- set the initialised flag --->
			<cfset application.bInit = true />
		</cfif>
	</cflock>
</cfif>

<cfcatch type="lock">
	<cfoutput><h1>Application Restarting</h1><p>Please come back in a few minutes.</p></cfoutput>
	<cfabort />
</cfcatch>

<cfcatch type="any">
	<!--- remove binit to force reinitialisation on next page request --->
	<cfset structdelete(application,"bInit") />
	<!--- report error to user --->
	<cfoutput><h1>Application Failed to Initialise</h1></cfoutput>
	<cfdump var="#cfcatch#" expand="false" />
	<cfabort />
</cfcatch>

</cftry>
<!---------------------------------------- 
END: Application Initialise 
----------------------------------------->


<!---------------------------------------- 
GENERAL APPLICATION REQUEST PROCESSING
- formally /farcry/core/tags/farcry/_farcryApplication.cfm
----------------------------------------->

<!--- set legacy logout/login parameters --->
<cfif isDefined("url.logout") and url.logout eq 1>
	<cfset application.factory.oAuthentication.logout(bAudit=1) />
</cfif>
<cfset stLoggedIn = application.factory.oAuthentication.getUserAuthenticationData() />
<cfset request.loggedin = stLoggedin.bLoggedIn />


<!-------------------------------------------------------
Run Request Processing
	_serverSpecificRequestScope.cfm
-------------------------------------------------------->
<!--- core request processing --->
<cfinclude template="_requestScope.cfm">

<!--- project and library request processing --->
<cfif application.sysInfo.bServerSpecificRequestScope>
	<cfloop from="1" to="#arraylen(application.sysinfo.aServerSpecificRequestScope)#" index="i">
		<cfinclude template="#application.sysinfo.aServerSpecificRequestScope[i]#" />
	</cfloop>
</cfif>


<!--- This parameter is used by _farcryOnRequestEnd.cfm to determine which javascript libraries to include in the page <head> --->
<cfparam name="Request.inHead" default="#structNew()#">


<!--- IF the project has been set to developer mode, we need to refresh the metadata on each page request. --->
<cfif request.mode.bDeveloper>
	<cfset createObject("component","#application.packagepath#.farcry.alterType").refreshAllCFCAppData() />
</cfif>

<cfsetting enablecfoutputonly="false" />