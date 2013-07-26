<cfsetting enablecfoutputonly="true">

<!--- ignore end tag --->
<cfif thistag.executionmode eq "end">
	<cfsetting enablecfoutputonly="false">
	<cfexit method="exittag" />
</cfif>

<!--- params --->
<cfparam name="attributes.navID" default="#request.navID#">
<cfparam name="attributes.depth" default="1">
<cfparam name="attributes.currentNavID" default="#request.navID#">

<cfparam name="attributes.bIncludeHome" default="true">
<cfparam name="attributes.homeAlias" default="home">

<cfparam name="attributes.tag" default="ul">
<cfparam name="attributes.id" default="">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.style" default="">
<cfparam name="attributes.activeClass" default="active">

<cfparam name="attributes.itemTag" default="li">
<cfparam name="attributes.itemNestedClass" default="parent">
<cfparam name="attributes.itemMarkupStart" default=""><!--- eg. <span> --->
<cfparam name="attributes.itemMarkupEnd" default=""><!--- eg. </span> --->

<cfparam name="attributes.nestedTag" default="ul">

<cfparam name="attributes.functionMethod" default="getDescendants">
<cfparam name="attributes.functionArgs" default="depth=attributes.depth">

<cfparam name="attributes.lColumns" default="externallink,lNavIDAlias">
<cfparam name="attributes.aFilter" default="#arrayNew(1)#">

<!--- create tree object --->
<cfset o = createObject("component", "#application.packagepath#.farcry.tree")>

<!--- set filter --->
<cfset arrayAppend(attributes.aFilter, "status IN (#listQualify(request.mode.lvalidstatus, '''')#)")>

<!--- get tree --->
<cfset qNav = evaluate("o."&attributes.functionMethod&"(objectid=attributes.navID, lColumns=attributes.lColumns, "&attributes.functionArgs&", aFilter=attributes.aFilter)")>
<!--- <cfdump var="#qNav#"> --->

<!--- get ancestors --->
<cfset qAncestors = o.getAncestors(objectid=attributes.currentNavID, bIncludeSelf=true)>
<cfset lAncestors = valuelist(qAncestors.objectid)>


<cfsavecontent variable="out">
<cfif qNav.recordCount>

	<cfset treeMaxLevel = qNav.nlevel + attributes.depth>

	<!--- open nav container --->
	<cfoutput><#attributes.tag#<cfif len(attributes.id)> id="#attributes.id#"</cfif><cfif len(attributes.class)> class="#attributes.class#"</cfif><cfif len(attributes.style)> style="#attributes.style#"</cfif>></cfoutput>

	<!--- output home --->
	<cfif qNav.currentRow eq 1 AND attributes.bIncludeHome>
		<cfset stHome = application.fapi.getContentObject(typename="dmNavigation", objectid=application.fapi.getNavId(attributes.homeAlias))>
		<cfoutput><#attributes.itemTag# class="#stHome.lNavIDAlias#<cfif request.navID eq stHome.objectid> active</cfif>">#attributes.itemMarkupStart#</cfoutput>
		<cfset href = application.fapi.getLink(type="dmNavigation", objectid="#stHome.objectid#")>
		<cfoutput><a href="#href#">#stHome.title#</a></cfoutput>
		<cfoutput>#attributes.itemMarkupEnd#</#attributes.itemTag#></cfoutput>
	</cfif>

	<!--- output the nav --->
	<cfloop query="qNav">

		<cfset thisClass = "#trim(replace(qNav.lNavIDAlias, ",", " ", "all"))#">
		<cfset hasChildren = false>

		<!--- find child folders --->
		<cfif qNav.nRight - qNav.nLeft gt 1 AND qNav.nlevel+1 lt treeMaxLevel>
			<cfset hasChildren = true>
			<cfset thisClass = listAppend(thisClass, "#attributes.itemNestedClass#", " ")>
		</cfif>
		<!--- find active nav item --->
		<cfif listFindNoCase(lAncestors, qNav.objectid)>
			<cfset thisClass = listAppend(thisClass, "#attributes.activeClass#", " ")>
		</cfif>

		<!--- get href --->
		<cfif (structKeyExists(qNav,"navType") and qNav.navType eq "externallink") or ((not structKeyExists(qNav,"navType") or qNav.navType eq "") and structKeyExists(qNav,"externallink") and len(qNav.externallink))>
			<cfset href = application.fapi.getLink(type="dmNavigation", objectid="#qNav.objectid#")>
		<cfelseif structKeyExists(qNav,"navType") and qNav.navType eq "internalRedirectID">
			<cfset href = application.fapi.getLink(objectid=qNav.internalRedirectID)>
		<cfelseif structKeyExists(qNav,"navType") and qNav.navType eq "externalRedirectURL">
			<cfset href = qNav.externalRedirectURL>
		<cfelse>
			<cfset href = application.fapi.getLink(type="dmNAvigation", objectid=qNav.objectid)>
		</cfif>

		<!--- output opening item --->
		<cfoutput><#attributes.itemTag#<cfif len(thisClass)> class="#thisClass#"</cfif>>#attributes.itemMarkupStart#</cfoutput>
		<cfoutput><a href="#href#">#qNav.objectname#</a></cfoutput>

		<!--- output closing nested tag for the last item --->
		<cfif qNav.recordCount gt qNav.currentRow AND qNav.nlevel[qNav.currentRow+1] lt qNav.nlevel[qNav.currentRow]>
			<cfoutput></#attributes.tag#></cfoutput>		
		<!--- output opening nested tag for children items --->
		<cfelseif hasChildren>
			<cfoutput><#attributes.tag#></cfoutput>		
		<!--- output closing item tag --->
		<cfelse>
			<cfoutput>#attributes.itemMarkupEnd#</#attributes.itemTag#></cfoutput>
		</cfif>

	</cfloop>

	<!--- close nav container --->
	<cfoutput></#attributes.tag#></cfoutput>

</cfif>
</cfsavecontent>

<cfoutput>#out#</cfoutput>

<cfsetting enablecfoutputonly="false">