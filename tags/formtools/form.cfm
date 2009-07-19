<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/core/" prefix="core" />


<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag..." />
</cfif>


<!--- We only render the form if FarcryForm OnExit has not been Fired. --->
<cfif structKeyExists(request, "FarcryFormOnExitRun") AND Request.FarcryFormOnExitRun>
	<cfsetting enablecfoutputonly="false" />			
	<cfexit method="exittag">			
</cfif>




<!--- MJB
This enables the developer to wrap a <ft:form> around anything without worrying about whether it will be called within an outer <ft:form>. 
It just ignores the inner ones.
--->
<cfif ListValueCountNoCase(getbasetaglist(),"CF_FORM") EQ 1>

	
	<!--- Check to make sure that Request.farcryForm.Name exists. This is because other tags may have created Request.farcryForm but only this tag creates "Name" --->
	<cfif thistag.ExecutionMode EQ "Start" AND NOT isDefined("Request.farcryForm.Name")>

		<cfset Variables.CorrectForm = 1>
		
		
		<!--- import Javascript Libraries libraries --->
		<skin:loadJS id="jquery" />
		<skin:loadJS id="farcry-form" />
	
		
		<cfparam name="attributes.Name" default="farcryForm#randrange(1,999999999)#">
		<cfparam name="attributes.Target" default="">
		<cfparam name="attributes.Action" default="">
		<cfparam name="attributes.method" default="post">
		<cfparam name="attributes.onsubmit" default="">
		<cfparam name="attributes.Class" default="">
		<cfparam name="attributes.Style" default="">
		<cfparam name="attributes.Validation" default="1">
		<cfparam name="attributes.bAjaxSubmission" default="false">
		<cfparam name="attributes.bUniForm" default="true"><!--- Make the form a uniform (http://sprawsm.com/uni-form/) --->


		<!--- Keeps track of all the form name in the request to make sure they are all unique --->
		<cfparam name="Request.farcryFormList" default="">		
		<cfif listFindNoCase(request.farcryFormList, attributes.Name)>
			<cfset attributes.Name = "#attributes.Name##ListLen(request.farcryFormList) + 1#">			
		</cfif>		
		<cfset Request.farcryFormList = listAppend(Request.farcryFormList,attributes.Name) />
		
		
		<!--- If we have not received an action url, get the default cgi.script_name?cgi.query_string --->
		<cfif not len(attributes.action)>
			<cfset attributes.Action = "#application.fapi.fixURL()#" />
		</cfif>
		
		<!--- If this is going to be a uniform, include relevent js and css --->
		<cfif attributes.bUniForm>
			<cfset attributes.class = listAppend(attributes.class,"uniForm"," ") />
			<skin:loadJS id="uni-form" />
			<skin:loadCSS id="uni-form" />				
		</cfif>
		

		<!--- Keep the form information available in the request scope --->
		<cfset Request.farcryForm = "#StructNew()#" />
		<cfset Request.farcryForm.Name = "#attributes.Name#" />
		<cfset Request.farcryForm.Target = "#attributes.Target#" />
		<cfset Request.farcryForm.Action = "#attributes.Action#" />
		<cfset Request.farcryForm.Method = "#attributes.Method#" />
		<cfset Request.farcryForm.onSubmit = "#attributes.onSubmit#" />
		<cfset Request.farcryForm.Validation = "#attributes.Validation#" />
		<cfset Request.farcryForm.stObjects = "#StructNew()#" />
		<cfset Request.farcryForm.bAjaxSubmission = "#attributes.bAjaxSubmission#" />
		<cfset Request.farcryForm.lFarcryObjectsRendered = "" />	
		

		<!--- Add form protection --->
		<cfparam name="session.stFarCryFormSpamProtection" default="#structNew()#" />
		<cfparam name="session.stFarCryFormSpamProtection['#attributes.Name#']" default="#structNew()#" />
			
		
		<cfoutput>
			
			<!--- Setup the ajax wrapper if this is the first render of the form. When the ajax submission is made, the returned HTML is placed in this div. --->
			<cfif attributes.bAjaxSubmission AND NOT structKeyExists(form, "farcryformajaxsubmission")>
				<style type="text/css">
				.farcry-form-ajax-loader {
					background: ##666666 url(#application.url.webtop#/thirdparty/jquery/css/ui-lightness/images/ui-bg_diagonals-thick_20_666666_40x40.png) 50% 50% repeat;
					opacity: .50;
					filter:	Alpha(Opacity=50);
					position:absolute;
					z-index:99;
					width:100%;
					height:100%;
				}
				</style>
				<div id="#attributes.Name#formwrap" class="ajaxformwrap">				
			</cfif>
			
			
			<form 	action="#attributes.Action#" 
					method="#attributes.Method#" 
					id="#attributes.Name#" 
					name="#attributes.Name#" 
					<cfif len(attributes.Target)> target="#attributes.Target#"</cfif> 
					enctype="multipart/form-data" 
					class="#attributes.class#"  
					style="#attributes.style#" >
			
			
			<cfif attributes.bAjaxSubmission>
				<!--- We use the hidden field to tell the submission that we do not need to include the wrap. --->
				<input type="hidden" name="farcryformajaxsubmission" value="1" />
				
				<!--- We use this div to render the overlay while the ajax form submission is taking place. --->
				<div class="farcry-form-ajax-loader" style="display:none;"></div>
			</cfif>
					
		</cfoutput> 
	
	</cfif>
	
	<cfif thistag.ExecutionMode EQ "End" and isDefined("Variables.CorrectForm")>
	
		<!--- Render the hidden form fields used to post the state of the farcry form. --->
		<cfoutput>
			<input type="hidden" name="FarcryFormPrefixes" value="" />
			<input type="hidden" name="FarcryFormSubmitButton" value="" /><!--- This is an empty field so that if the form is submitted, without pressing a farcryFormButton, the FORM.FarcryFormSubmitButton variable will still exist. --->
			<input type="hidden" name="FarcryFormSubmitButtonClicked#attributes.Name#" id="FarcryFormSubmitButtonClicked#attributes.Name#" class="fc-button-clicked" value="" /><!--- This contains the name of the farcry button that was clicked --->
			<input type="hidden" name="FarcryFormSubmitted"  value="#attributes.Name#" /><!--- Contains the name of the farcry form submitted --->
			<input type="hidden" name="SelectedObjectID" class="fc-selected-object-id" value="" /><!--- Hidden Field to take a UUID from the attributes.SelectedObjectID on ft:button --->
		
			<input type="hidden" name="farcryFormValidation" id="farcryFormValidation#attributes.Name#" class="fc-server-side-validation" value="#attributes.Validation#" /><!--- Let the form submission know if it to perform serverside validation --->
	
		</form>
		</cfoutput>	
		
		<!--- If we are validating this form, load and initialise the validation engine.  --->
		<cfif attributes.validation EQ 1>
			<skin:loadJS id="jquery-validate" />
			
			<skin:onReady>
				<cfoutput>
				$j("###attributes.Name#").validate({
					onsubmit: false, // let the onsubmit function handle the validation
					errorElement: "p",
					errorClass: "errorField",					   
					errorPlacement: function(error, element) {
					   error.prependTo( element.parent("div.ctrlHolder") );
					},
					highlight: function(element, errorClass) {
					   $j(element).parent("div.ctrlHolder").addClass('error');
					},
					unhighlight: function(element, errorClass) {
					   $j(element).parent("div.ctrlHolder").removeClass('error');
					}

				});
				</cfoutput>
			</skin:onReady>
		</cfif>
			
		<!--- If submitting by ajax, append the ajax submission function call to the onsubmit. --->
		<cfif attributes.bAjaxSubmission>

			<!--- Make sure the ajax submission is told to go into ajax mode. --->
			<cfset attributes.action = application.fapi.fixURL(url=attributes.action,addvalues="ajaxmode=true") />
					
			<!--- Add the function call to onsubmit --->
			<cfsavecontent variable="sAjaxSubmission">
				<cfoutput>
		        farcryForm_ajaxSubmission('#attributes.Name#','#attributes.Action#');
		        return false;
				</cfoutput>				
			</cfsavecontent>
			
			<cfset attributes.onSubmit = "#attributes.onSubmit#;#sAjaxSubmission#" />
			
		</cfif>			
			
		<!--- If we have anything in the onsubmit, use jquery to run it --->
		<skin:onReady>
			<cfoutput>
			$j('###attributes.Name#').submit(function(){
				<cfif attributes.validation EQ 1>
					var valid = $j('###attributes.Name#').valid();
				<cfelse>
					var valid = true;
				</cfif>			
					 
				if(valid){
					#attributes.onSubmit#;
				} else {
					return false;
				}
		    });
			</cfoutput>				
		</skin:onReady>
		
			
		<!--- Close the dive if we have the ajax wrapper --->
		<cfif attributes.bAjaxSubmission AND NOT structKeyExists(form, "farcryformajaxsubmission")>
			<cfoutput></div></cfoutput>
		</cfif>
			
			
		<!--- Clear the farcry form from the request scope now that it is complete. --->
		<cfset dummy = structdelete(request,"farcryForm")>

	
	</cfif>

</cfif>


<cfsetting enablecfoutputonly="false" />