<cfparam name="attributes.keyword" default="">
<cf_xml_page_edit fuseact="objects.popup_list_opportunities">
<cf_get_lang_set module_name="sales">
<cfif isdefined("attributes.is_submitted")>
	<cfquery name="GET_OPPORTUNITIES" datasource="#DSN3#">
		SELECT
			OPP_HEAD,
			OPP_ID,
			OPP_DATE,
			PARTNER_ID,
			CONSUMER_ID,
			SALES_EMP_ID,
			SALES_PARTNER_ID,
			COMPANY_ID,
			COMPANY_NAME=(select C.FULLNAME FROM #dsn#.COMPANY C WHERE C.COMPANY_ID= OPPORTUNITIES.COMPANY_ID ),
			cons_name=(select CS.CONSUMER_NAME +' '+CS.CONSUMER_SURNAME FROM #dsn#.CONSUMER CS WHERE CS.CONSUMER_ID= OPPORTUNITIES.CONSUMER_ID ),
			PARTNER_NAME=(select CP.COMPANY_PARTNER_NAME +' '+CP.COMPANY_PARTNER_SURNAME FROM #dsn#.COMPANY_PARTNER CP WHERE CP.COMPANY_ID= OPPORTUNITIES.COMPANY_ID and CP.PARTNER_ID=OPPORTUNITIES.PARTNER_ID )
		FROM
			OPPORTUNITIES 
		WHERE
			OPP_ID IS NOT NULL
			<cfif isdefined('attributes.keyword') and len(attributes.keyword)>
				AND OPP_HEAD LIKE '%#attributes.keyword#%'
			</cfif>
			<cfif isdefined('attributes.account') and len(attributes.account)>
				<cfif isdefined('attributes.company_id') and len(attributes.company_id)>
					AND COMPANY_ID=#attributes.company_id#
				</cfif>
				<cfif isdefined('attributes.partner_id') and len(attributes.partner_id)>
					AND PARTNER_ID=#attributes.partner_id#
				</cfif>
				<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
					AND CONSUMER_ID=#attributes.consumer_id# 
				</cfif>
			</cfif>
			
	</cfquery>
<cfelse>
	<cfset get_opportunities.recordcount=0>
</cfif>

<script type="text/javascript">
function gonder(opp_id,opp_head,company_id,consumer_id,COMPANY_NAME,cons_name,partner_id)
	{
	<cfoutput>
		<cfif isdefined("field_opp_id")>
			<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.#field_opp_id#.value = opp_id;
		</cfif>
		<cfif isdefined("field_opp_head")>
			<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.#field_opp_head#.value = opp_head;
		</cfif>
		<cfif isdefined("field_comp_id")>
			<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.#field_comp_id#.value = company_id;
		</cfif>
		<cfif isdefined("field_cons_id")>
			<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.#field_cons_id#.value = consumer_id;
		</cfif>
		<cfif isdefined("field_partner")>
			<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.#field_partner#.value = partner_id;
		</cfif>
		<cfif isdefined("field_cons_name")>
			<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.#field_cons_name#.value = cons_name;
		</cfif>
		<cfif isdefined("field_company_name")>
			<cfif isdefined("attributes.draggable")>document<cfelse>window.opener.document</cfif>.#field_company_name#.value = COMPANY_NAME;
		</cfif>
	</cfoutput>
		<cfif not isdefined("attributes.draggable")>window.close();<cfelseif isdefined("attributes.draggable")>closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>' );</cfif>
	}
</script>
<cfset url_str = "">
<cfif isdefined("attributes.field_opp_id")>
	<cfset url_str = "#url_str#&field_opp_id=#attributes.field_opp_id#">
</cfif>
<cfif isdefined("attributes.field_opp_head")>
	<cfset url_str = "#url_str#&field_opp_head=#attributes.field_opp_head#">
</cfif>
<cfif isdefined("attributes.field_comp_id") and len(attributes.field_comp_id)>
	<cfset url_str = "#url_str#&field_comp_id=#attributes.field_comp_id#">
</cfif>
<cfif isdefined("attributes.field_cons_id") and len(attributes.field_cons_id)>
	<cfset url_str = "#url_str#&field_cons_id=#attributes.field_cons_id#">
</cfif>
<cfif isdefined("attributes.field_company_name") and len(attributes.field_company_name)>
	<cfset url_str = "#url_str#&field_company_name=#attributes.field_company_name#">
</cfif>
<cfif isdefined("attributes.field_cons_name") and len(attributes.field_cons_name)>
	<cfset url_str = "#url_str#&field_cons_name=#attributes.field_cons_name#">
</cfif>
<cfif isdefined("attributes.field_partner") and len(attributes.field_partner)>
	<cfset url_str = "#url_str#&field_partner=#attributes.field_partner#">
</cfif>


<cfif isdefined("attributes.is_submitted") >
	<cfset url_str = "#url_str#&is_submitted=#attributes.is_submitted#">
</cfif>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.modal_id" default="">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default ="#get_opportunities.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#getLang('','Fırsatlar',58694)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
		<cfform name="opp_search" method="post" action="#request.self#?fuseaction=objects.popup_list_opportunities#url_str#">
			<cfinput type="hidden" name="is_submitted" id="is_submitted" value="1">
			<cf_box_search more="0">
				<div class="form-group" id="keyword">
					<cfinput type="text" name="keyword" placeholder= "#getLang('main','Filtre',57460)#" value="#attributes.keyword#">
				</div>   
				<cfif isdefined('is_current_account') and is_current_account eq 1>
					<div class="form-group" id="account">
						<div class="input-group">
							<cfoutput>
								<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")>#attributes.company_id#</cfif>"/>
								<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")>#attributes.consumer_id#</cfif>"/>
								<input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined("attributes.partner_id")>#attributes.partner_id#</cfif>"/>
								<input type="text" name="account" placeholder= "#getLang('main','Cari Hesap',57519)#" id="account" value="<cfif isdefined("attributes.account")>#attributes.account#</cfif>" onFocus="AutoComplete_Create('account','MEMBER_NAME,MEMBER_CODE,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_CODE,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\',\'<cfif session.ep.isBranchAuthorization>1<cfelse>0</cfif>\',\'0\',\'0\',\'2\',\'0\'','COMPANY_ID,CONSUMER_ID,PARTNER_ID,MEMBER_TYPE','company_id,consumer_id,partner_id,member_type','form','3','250');"/>
								<span class="input-group-addon btnPointer icon-ellipsis" onclick="sec();"></span>
							</cfoutput>
						</div>
					</div>
				</cfif>
				<div class="form-group">
					<cf_wrk_search_button button_type="4" search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('opp_search' , #attributes.modal_id#)"),DE(""))#">
				</div>  
			</cf_box_search>
		</cfform>
		<cf_flat_list>
			<thead>
				<tr>
				<th width="60"><cf_get_lang dictionary_id='57742.tarih'></th>
				<th><cf_get_lang dictionary_id='57480.Konu'></th>
				<th width="120"><cf_get_lang dictionary_id='57574.şirket'> - <cf_get_lang dictionary_id='57578.yetkili'></th>
				<th width="120"><cf_get_lang dictionary_id='40842.satis ekibi'></th>
				</tr>
			</thead>
			<tbody>
				<cfif get_opportunities.recordcount>
					<cfoutput query="get_opportunities" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
						<tr>
							<cfif isdefined("COMPANY_NAME") and len(COMPANY_NAME)>
								<cfset m_name='#COMPANY_NAME#'>
								<cfset p_name='#partner_name#'>
							<cfelseif isdefined("cons_name") and len(cons_name)>
								<cfset m_name='#cons_name#'>
								<cfset p_name='#cons_name#'>
							</cfif>
							
							<td>#dateformat(opp_date,dateformat_style)#</td>
							<td><a href="javascript://" onclick="gonder('#opp_id#','#opp_head#','#company_id#','#consumer_id#','#m_name#','#partner_id#','#p_name#');" class="tableyazi">#opp_head#</a></td>
							<td>
								<cfif len(get_opportunities.partner_id)>
									<cfset partner_id = get_opportunities.partner_id>
									<cfinclude template="../query/get_partner_company_and_authority.cfm">
									#get_par_info(get_opportunities.partner_id,0,-1,0)#
								<cfelseif len(get_opportunities.consumer_id)>
									- 
								</cfif>
							</td>
							<td>
								<cfif len(get_opportunities.sales_emp_id)>
									#get_emp_info(get_opportunities.sales_emp_id,0,0)#
								</cfif> -
								<cfif len(get_opportunities.sales_partner_id)>
									#get_par_info(get_opportunities.sales_partner_id,0,-1,0)#
								</cfif>
							</td>
						</tr>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="4"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='57484.Kayıt Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'>!</cfif></td>
					</tr>
				</cfif>
			</tbody>
		</cf_flat_list>
		<cfif isdefined("attributes.keyword")>
			<cfset url_str = "#url_str#&keyword=#attributes.keyword#">
		</cfif>
		<cfif attributes.totalrecords gt attributes.maxrows>
			<cf_paging page="#attributes.page#"
				maxrows="#attributes.maxrows#"
				totalrecords="#attributes.totalrecords#"
				startrow="#attributes.startrow#"
				adres="objects.popup_list_opportunities#url_str#&is_submitted=#attributes.is_submitted#"
				isAjax="#iif(isdefined("attributes.draggable"),1,0)#">
		</cfif>
	</cf_box>
</div>
<script type="text/javascript">
document.getElementById('keyword').focus();
function sec()
{
	openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_comp_name=opp_search.account&field_comp_id=opp_search.company_id&field_partner=opp_search.partner_id&field_consumer=opp_search.consumer_id&field_name=opp_search.account&select_list=2,3');
}
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
