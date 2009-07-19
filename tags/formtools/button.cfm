<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="attributes.value" />
<cfparam name="attributes.type" default="" />
<cfparam name="attributes.text" default="#attributes.value#" />
<cfparam name="attributes.size" default="medium" />
<cfparam name="attributes.color" default="blue" />
<cfparam name="attributes.icon" default="" />
<cfparam name="attributes.overIcon" default="" />
<cfparam name="attributes.iconPos" default="left" /><!--- left,right,top,bottom --->
<cfparam name="attributes.sprite" default="" />
<cfparam name="attributes.id" default="f-btn-#application.fapi.getUUID()#">
<cfparam name="attributes.width" default="auto">
<cfparam name="attributes.validate" default="">
<cfparam name="attributes.SelectedObjectID" default="">
<cfparam name="attributes.onClick" default="">
<cfparam name="attributes.Class" default="">
<cfparam name="attributes.Style" default="">
<cfparam name="attributes.ConfirmText" default="">
<cfparam name="attributes.src" default="">
<cfparam name="attributes.url" default="">
<cfparam name="attributes.target" default="_self">
<cfparam name="attributes.bSpamProtect" default="false"><!--- Instantiates cfformprotection to ensure the button is not clicked by spam. --->
<cfparam name="attributes.stSpamProtectConfig" default="#structNew()#" /><!--- config data that will override the config set in the webtop. --->
<cfparam name="attributes.rbkey" default="forms.buttons.#rereplacenocase(attributes.value,'[^\w\d]','','ALL')#"><!--- The resource path for this button. Default is forms.buttons.value. --->
<cfparam name="attributes.disabled" default="false"><!--- Should the button be disabled --->
<cfparam name="attributes.r_stButton" default=""><!--- the name of the calling scope variable name to return the details of the farcry button --->
<cfparam name="attributes.renderType" default="farcryButton"><!--- How should the button be rendered (button, link) --->


<cfif thistag.executionMode eq "End">

	<!--- Include Prototype light in the head --->
	<skin:loadJS id="jquery" />
	<!--- <skin:loadJS id="farcry-form" /> --->

	<!--- I18 conversion of label --->
	<cfset attributes.text = application.rb.getResource('#attributes.rbkey#@label',attributes.text) />
	
	<!--- If not in a farcry form, make it a button. --->
	<cfif NOT isDefined("Request.farcryForm.Name")>
		<cfif not len(attributes.type)>
			<cfset attributes.Type = "button" />
		</cfif>
	<cfelse>
		<cfif not len(attributes.type)>
			<cfset attributes.Type = "submit" />
		</cfif>
	</cfif>

	<!--- Default validate to true if submitting and false if just a button --->
	<cfif not len(attributes.validate)>
		<cfif attributes.type EQ "submit">
			<cfset attributes.validate = true />
		<cfelse>
			<cfset attributes.validate = false />
		</cfif>
	</cfif>
	
	<cfif isDefined("Request.farcryForm.Name")>
		<cfset attributes.onClick = "#attributes.onClick#;btnClick('#Request.farcryForm.Name#','#jsStringFormat(attributes.value)#');" />
	</cfif>
	
	<cfif isDefined("Request.farcryForm.Name")>
		<cfif attributes.validate>
			<!--- <cfset attributes.onClick = "#attributes.onClick#;if(!validateBtnClick('#Request.farcryForm.Name#')){return false};" />	 --->
		<cfelse>
			<!--- <cfset attributes.onClick = "#attributes.onClick#;btnTurnOffServerSideValidation();" />	 --->
			<cfset attributes.class = listAppend(attributes.class, "cancel", " ") />
		</cfif>
		
	</cfif>
	
	
	<cfif len(attributes.SelectedObjectID)>		
		<cfset attributes.Onclick = "#attributes.OnClick#;selectedObjectID('#attributes.SelectedObjectID#');" />
	</cfif>

	
	<cfif len(attributes.url)>
		<cfset attributes.Type = "button" />
		<cfset attributes.url = jsStringFormat(attributes.url) />
		<cfset attributes.onClick = "#attributes.onClick#;btnURL('#attributes.url#','#attributes.target#');return false;" />
	</cfif>


<!--- 	<cfif attributes.type EQ "submit">
		<cfset attributes.onClick = "#attributes.onClick#;#request.farcryForm.onSubmit#;" />
	</cfif> --->
	
	<!--- Make sure that confirmation is run first for a button --->
	<cfif len(Attributes.ConfirmText)>
		<!--- I18 conversion of label --->
		<cfset Attributes.ConfirmText = application.rb.getResource('#attributes.rbkey#@confirmtext',Attributes.ConfirmText) />
		<cfset attributes.confirmText = jsStringFormat(Attributes.ConfirmText) />
		<cfset attributes.onClick = "if(!confirm('#Attributes.ConfirmText#')){return false};#attributes.onClick#;" />
	</cfif>	
	
	
	
	
	<!--- This is used to submit the form using JS if the user clicks on the table. --->
	<cfif isDefined("Request.farcryForm.Name")>
		<cfset farcryFormName = Request.farcryForm.Name />
	<cfelse>
		<cfset farcryFormName = "" />
	</cfif>
	
	<cfswitch expression="#attributes.color#">
	<cfcase value="red">
		<cfset attributes.sprite = "#application.url.webtop#/css/forms/images/f-btn-red.gif" />
	</cfcase>
	<cfcase value="green">
		<cfset attributes.sprite = "#application.url.webtop#/css/forms/images/f-btn-green.gif" />
	</cfcase>
	<cfcase value="orange">
		<cfset attributes.sprite = "#application.url.webtop#/css/forms/images/f-btn-orange.gif" />
	</cfcase>
	<cfcase value="grey">
		<cfset attributes.sprite = "#application.url.webtop#/css/forms/images/f-btn-grey.gif" />
	</cfcase>
	<cfdefaultcase>
		<!--- EVERYTHING ELSE IS BLUE --->
	</cfdefaultcase>
	</cfswitch>

	<cfif not len(attributes.r_stButton)>
		<cfswitch expression="#attributes.renderType#">
		<cfcase value="link">
			<cfoutput><a id="#attributes.id#" name="#attributes.id#" onclick="#attributes.OnClick#" class="#attributes.class#" style="#attributes.style#">#attributes.text#</a></cfoutput>
		</cfcase>
		<cfdefaultcase>
			<cfoutput><button id="#attributes.id#" name="FarcryForm#attributes.Type#Button=#attributes.value#" type="#attributes.type#" value="#attributes.value#" class="#attributes.class#" style="#attributes.style#" <cfif len(attributes.onClick)>onClick="#attributes.OnClick#"</cfif> <cfif attributes.disabled>disabled</cfif>>#attributes.text#</button></cfoutput>
		</cfdefaultcase>
		</cfswitch>
		

		<cfif attributes.bSpamProtect AND isDefined("Request.farcryForm.Name")>
		
			<cfif not structKeyExists(request, "bRenderFormSpamProtection")>
				<cfinclude template="#application.url.webtop#/cffp/cfformprotect/cffp.cfm" /> 
				<cfset request.bRenderFormSpamProtection = "rendered" />
			</cfif>
			
			<cfset session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']['#attributes.Value#'] = structNew() />
			<cfset session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']['#attributes.Value#'].bSpamProtect = true />
			<cfloop list="#structKeyList(attributes)#" index="protectionAttribute">
				<cfif findNoCase("protection_", protectionAttribute)>
					<cfset protectionAttributeName = mid(protectionAttribute,12,len(protectionAttribute)) />
					<cfset session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']['#attributes.Value#']['#protectionAttributeName#'] = attributes["#protectionAttribute#"] />
				</cfif>
			</cfloop>
			<cfloop collection="#attributes.stSpamProtectConfig#" item="protectionAttributeName">
				<cfset session.stFarCryFormSpamProtection['#Request.farcryForm.Name#']['#attributes.Value#']['#protectionAttributeName#'] = attributes.stSpamProtectConfig["#protectionAttribute#"] />
			</cfloop>
		</cfif>		
	<cfelse>
		<cfset caller[attributes.r_stButton] = duplicate(attributes) />
		<cfset caller[attributes.r_stButton].name = "FarcryForm#attributes.Type#Button=#attributes.value#">
	</cfif>
</cfif>