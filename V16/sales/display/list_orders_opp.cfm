<!---
    Author : Fatma Zehra Dere
    Create Date : 23/03/2024
--->
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.modal_id" default="">
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
    <cfset attributes.maxrows = session.ep.maxrows />
</cfif>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.status" default="">
<cfparam name="attributes.order_stage" default="">
<cfparam name="attributes.opp_id" default="">
<cfparam name="attributes.keyword_orderno" default="">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfset comp    = createObject("component","V16.sales.cfc.order_opportunity") />
<cfset get_process_type = comp.get_process_type()>
<cfset get_order_list = comp.get_order_list_fnc(
	status : '#IIf(IsDefined("attributes.status"),"attributes.status",DE(""))#',
	keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
	keyword_orderno : '#IIf(IsDefined("attributes.keyword_orderno"),"attributes.keyword_orderno",DE(""))#',
	order_stage : '#IIf(IsDefined("attributes.order_stage"),"attributes.order_stage",DE(""))#',
	startrow : '#attributes.startrow#',
	maxrows : '#attributes.maxrows#',
	dsn2_alias : '#dsn2_alias#'
	
)>
<cfparam name="attributes.totalrecords" default="#get_order_list.recordcount#">
<cfscript>
	if (isdefined("attributes.keyword")) url_str = "keyword=#attributes.keyword#"; else attributes.keyword = "";
	if (isdefined("attributes.opp_id")) url_str = "opp_id=#attributes.opp_id#"; else attributes.opp_id = "";
	if (isdefined("attributes.keyword_orderno")) url_str = "#url_str#&keyword_orderno=#attributes.keyword_orderno#"; else attributes.keyword_orderno = "";
	if (isdefined("attributes.status"))	url_str = "#url_str#&status=#attributes.status#"; else attributes.status = 1;
</cfscript>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#getLang('','Siparişler',45228)#" scroll="1" closable="1" collapsable="1" resize="0" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="order_form" action="#request.self#?fuseaction=sales.popup_list_orders&opp_id=#attributes.opp_id#">
			<cf_box_search>
					<CFinput name="opp_id" id="opp_id" value="#attributes.opp_id#" type="hidden">
				<input name="form_varmi" id="form_varmi" value="1" type="hidden">
				
				<div class="form-group">
					<div class="input-group">
						<cfoutput><input type="text" name="keyword" id="keyword" placeholder="<cf_get_lang dictionary_id='57460.Filtre'>" value="#attributes.keyword#" maxlength="50"></cfoutput>
					</div>
				</div>
				<div class="form-group">
					<div class="input-group">
						<cfoutput><input type="text" name="keyword_orderno" id="keyword_orderno" placeholder="<cf_get_lang dictionary_id='66478.Sertifika No'>" value="#attributes.keyword_orderno#" maxlength="50"></cfoutput>
					</div>
				</div>
				<div class="form-group" id="item-order_stage">	
					<select name="order_stage" id="order_stage">
						<option value=""><cf_get_lang dictionary_id='58859.Surec'></option>
						<cfoutput query="get_process_type" group="process_id">
							<optgroup label="#process_name#"></optgroup>
							<cfoutput>
							<option value="#get_process_type.process_row_id#" <cfif Len(attributes.order_stage) and attributes.order_stage eq get_process_type.process_row_id>selected</cfif>>&nbsp;&nbsp;#get_process_type.stage#</option>
							</cfoutput>
						</cfoutput>
					</select>    
				</div>
				<cfoutput>
				<div class="form-group">
					<div class="input-group">
						<select name="status" id="status">
							<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
							<option value="0"<cfif isdefined('attributes.status') and (attributes.status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
							<option value="1"<cfif isdefined('attributes.status') and (attributes.status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<div class="input-group small">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
						<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3">
					</div>
				</div> 
				<div class="form-group">
					<cf_wrk_search_button button_type="4" search_function="#iif(isdefined("attributes.draggable"),DE("loadPopupBox('order_form' , #attributes.modal_id#)"),DE(""))#">
				</div>
				</cfoutput>    
			</cf_box_search>
		</cfform>
        <cf_grid_list>
            <thead>        
                <tr>
                    <th width="30"><cf_get_lang dictionary_id='57487.no'></th>
                    <th width="60"><cf_get_lang dictionary_id='57742.tarih'></th>
                    <th><cf_get_lang dictionary_id='57480.Başlık'></th>
                    <th width="100"><cf_get_lang dictionary_id='57673.tutar'></th>
                    <th width="100"><cf_get_lang dictionary_id='57482.Aşama'></th>
                    <th width="100"><cf_get_lang dictionary_id='40842.satis ekibi'></th>
                </tr>
            </thead>
            <cfif get_order_list.recordcount>
				<cfscript>
					order_stage_list='';
				</cfscript>
				<cfoutput query="get_order_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
					<tbody>
                        <cfif len(order_stage) and not listfind(order_stage_list,order_stage)>
                            <cfset order_stage_list=listappend(order_stage_list,order_stage)>
                        </cfif>
                        <cfif len(order_stage_list)>
							<cfset order_stage_list=listsort(order_stage_list,"numeric","ASC",",")>
							<cfquery name="process_type" datasource="#dsn#">
								SELECT STAGE, PROCESS_ROW_ID FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#order_stage_list#) ORDER BY PROCESS_ROW_ID
							</cfquery>
							<cfset order_stage_list=valuelist(process_type.PROCESS_ROW_ID)>
						</cfif>
                        <tr onclick="gonder_('#order_id#');" style="cursor:pointer;">
                            <td>#order_number#</td>
                            <td>#dateformat(order_date,dateformat_style)#</td>
                            <td>#order_head#</td>
                            <td style="text-align:right;">#TLFormat(NETTOTAL)#</td>
                            <td><cfif len(ORDER_STAGE)>#process_type.stage[listfind(order_stage_list,ORDER_STAGE,',')]#</cfif></td>
                            <td> 
                                <cfif len(ORDER_EMPLOYEE_ID)><a href="javascript://" class="tableyazi" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_emp_det&EMP_ID=#ORDER_EMPLOYEE_ID#');">#ORDER_EMPLOYEE_NAME# #ORDER_EMPLOYEE_SURNAME#</a></cfif>
                            </td>
                        </tr>
					</tbody>
                </cfoutput> 
            <cfelse>
				<tr> 
					<td colspan="8"><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</td>
				</tr>
            </cfif>
            
        </cf_grid_list>
		<cfif attributes.totalrecords gte attributes.maxrows>
			<cf_paging page="#attributes.page#"
				maxrows="#attributes.maxrows#" 
				totalrecords="#attributes.totalrecords#"
				startrow="#attributes.startrow#"
				adres="#attributes.fuseaction#&#url_str#&form_varmi=1"
				isAjax="#iif(isdefined("attributes.draggable"),1,0)#">
		</cfif>
	
    </cf_box>
</div>
<script type="text/javascript">

    function gonder_(orderId) {

        $.ajax({
            url: "V16/sales/cfc/order_opportunity.cfc?method=del_orders_opp",
            method: "post",
            data: { ORDER_ID: orderId ,opp_id:<cfoutput>#attributes.opp_id#</cfoutput>}
        });
		closeBoxDraggable( '<cfoutput>#attributes.modal_id#</cfoutput>', 'opp_order' );
    }

</script>
