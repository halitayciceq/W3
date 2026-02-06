<cfquery name="get_subscription" datasource="#dsn3#">
	SELECT
		SUBSCRIPTION_ID,
		PREMIUM_VALUE,
		PREMIUM_DATE,
		RECORD_DATE,
		RECORD_EMP,
		UPDATE_DATE,
		UPDATE_EMP
	FROM
		SUBSCRIPTION_CONTRACT
	WHERE
		SUBSCRIPTION_ID = #url.subscription_id#
</cfquery>
<cfparam name="attributes.modal_id" default="">
<cf_box title="#getLang('sales',329)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="list_premium" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_premium">
		<input type="hidden" name="subscription_id" id="subscription_id" value="<cfoutput>#url.subscription_id#</cfoutput>">
		<cf_box_elements>
			<div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="1" sort="true">
				<div class="form-group" id="item-premium_value">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41074.Prim Değeri'></label>
					<div class="col col-8 col-xs-12">
						<input type="text" name="premium_value" id="premium_value" value="<cfoutput>#tlformat(get_subscription.premium_value)#</cfoutput>" class="moneybox" onkeyup="return(FormatCurrency(this,event));">
					</div>
				</div>	
				<div class="form-group" id="item-premium_date">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41130.Prim Tarihi'></label>
					<div class="col col-8 col-xs-12">
						<div class="input-group">
							<cfinput type="text" name="premium_date" value="#dateformat(get_subscription.PREMIUM_DATE,dateformat_style)#" validate="#validate_style#" maxlength="10">
							<span class="input-group-addon"><cf_wrk_date_image date_field="premium_date"></span>
						</div>	
					</div>
				</div>
			</div>
		</cf_box_elements>
		<cf_box_footer>
			<cf_record_info query_name="get_subscription">
			<cf_workcube_buttons is_upd='0' add_function="kontrol()">
		</cf_box_footer>
	</cfform>
</cf_box>
<script type="text/javascript">
	function kontrol()
	{
	  document.list_premium.premium_value.value = filterNum(document.list_premium.premium_value.value);
	  <cfif isdefined("attributes.draggable")>
		loadPopupBox('list_premium' , <cfoutput>#attributes.modal_id#</cfoutput>)
	</cfif>
	}
	
</script>
