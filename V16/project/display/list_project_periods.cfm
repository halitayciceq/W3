<cfinclude template="../query/get_project_account_function.cfm">
<cfquery name="GET_COMPANY_PERIODS" datasource="#DSN#">
	SELECT PERIOD_ID,PERIOD FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> ORDER BY PERIOD_ID DESC
</cfquery>

<cfif not isdefined("attributes.period_id")>
	<cfset attributes.period_id = session.ep.period_id>
</cfif>
<cfquery name="GET_OTHER_PERIOD" datasource="#DSN#">
	SELECT	
		PERIOD_ID,
        PERIOD,
        PERIOD_YEAR,
        OUR_COMPANY_ID
	FROM 
		SETUP_PERIOD 
	WHERE 
		OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND 
		PERIOD_ID = #attributes.period_id#
</cfquery>
<cfquery name="GET_PROJECT_PERIODS" datasource="#DSN3#">
	SELECT
		*
	FROM
		PROJECT_PERIOD
	WHERE
		PROJECT_ID = #attributes.id# AND
		PERIOD_ID = #attributes.period_id#
</cfquery>
<cfif GET_PROJECT_PERIODS.recordcount eq 0>
	<cfquery name="GET_PROJECT_PERIODS" datasource="#dsn3#">
    	SELECT
        	<cfloop list="#GET_PROJECT_PERIODS.columnlist#" index="columnname">
        	'' AS #columnname#,
            </cfloop>
            '' AS PROJECT_PERIOD_CAT_ID
    </cfquery>
</cfif>
<cfset period_selected = ValueList(GET_PROJECT_PERIODS.PERIOD_ID)>
<cfquery name="GET_EXPENSE_ITEM" datasource="#dsn2#">
	SELECT EXPENSE_ITEM_ID, EXPENSE_ITEM_NAME FROM EXPENSE_ITEMS WHERE IS_EXPENSE = 1 ORDER BY EXPENSE_ITEM_NAME
</cfquery>
<cfquery name="GET_EXPENSE_INCOME" datasource="#dsn2#">
	SELECT EXPENSE_ITEM_ID, EXPENSE_ITEM_NAME FROM EXPENSE_ITEMS WHERE INCOME_EXPENSE = 1 ORDER BY EXPENSE_ITEM_NAME
</cfquery>
<cfquery name="GET_EXPENSE_CENTER" datasource="#dsn2#">
	SELECT EXPENSE_ID, EXPENSE FROM EXPENSE_CENTER ORDER BY  EXPENSE
</cfquery>
<cfquery name="GET_EXPENSE_TEMPLATE" datasource="#dsn2#">
	SELECT TEMPLATE_ID, TEMPLATE_NAME,IS_INCOME FROM EXPENSE_PLANS_TEMPLATES ORDER BY TEMPLATE_NAME
</cfquery>
<cfquery name="GET_EXPENSE_TEMPLATE_EXPENSE" dbtype="query">
	SELECT TEMPLATE_ID, TEMPLATE_NAME FROM GET_EXPENSE_TEMPLATE WHERE IS_INCOME<>1 ORDER BY TEMPLATE_NAME
</cfquery>
<cfquery name="GET_EXPENSE_TEMPLATE_INCOME" dbtype="query">
	SELECT TEMPLATE_ID, TEMPLATE_NAME FROM GET_EXPENSE_TEMPLATE WHERE IS_INCOME=1 ORDER BY TEMPLATE_NAME
</cfquery>
<cfquery name="GET_ACTIVITY_TYPES" datasource="#dsn#">
	SELECT ACTIVITY_ID, ACTIVITY_NAME FROM SETUP_ACTIVITY ORDER BY ACTIVITY_NAME
</cfquery>
<cfset attributes.active_cat = 1>
<cfinclude template="../query/get_code_cat.cfm">
<cfsavecontent variable="title"><cf_get_lang dictionary_id='58811.Muhasebe Kodu'></cfsavecontent>
	<cfparam name="attributes.modal_id" default="">
	<cfparam name="attributes.draggable" default="">
<div class="col col-12 col-md-12col-sm-12 col-xs-12">
	<cf_box title="#title#" popup_box="#iif(isdefined("attributes.draggable"),1,0)#"> 
		<cfform name="add_period" method="post" action="#request.self#?fuseaction=project.emptypopup_add_periods_to_project">
			<input name="modal_id" id="modal_id" type="hidden" value="<cfoutput>#attributes.modal_id#</cfoutput>">
			<input name="draggable" id="draggable" type="hidden" value="<cfoutput>#attributes.draggable#</cfoutput>">
			<input name="project_id" id="project_id" type="hidden" value="<cfoutput>#attributes.id#</cfoutput>">
			<cfif get_other_period.recordcount>
				<input name="record_num" id="record_num" value="<cfoutput>#get_other_period.recordcount#</cfoutput>" type="hidden">
				<cfoutput query="GET_OTHER_PERIOD">
					<cf_box_elements>
						<div class="col col-5 col-md-5 col-sm-6 col-xs-12" type="column" index="1" sort="true">	
							<div class="form-group">
								<label class="headbold font-red-sunglo col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id ='38369.Muhasebe Kodları'></label>
							</div>
							<div class="form-group" id="item-period_main_id">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38371.Dönem Yıl'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<select name="period_main_id" id="period_main_id" onchange="javascript:window.location.href='<cfoutput>#request.self#?fuseaction=project.popup_list_period&id=#attributes.id#&period_id=</cfoutput>' + add_period.period_main_id.options[add_period.period_main_id.options.selectedIndex].value;">
										<cfloop query="get_company_periods">
											<option value="#period_id#" <cfif get_company_periods.period_id eq attributes.period_id> selected</cfif>>#period#</option>
										</cfloop>
									</select>
									<input type="hidden" name="for_control" id="for_control" value="#period_year#-#our_company_id#-#period_id#">
									<input type="hidden" name="project_period_cat_id" id="project_period_cat_id" value="#get_project_periods.project_period_cat_id#" />
								</div>
							</div>
							<div class="form-group" id="item-period_code_cat">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38372.Muhasebe Kod Grubu'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
											<cfset old_code_list = "#get_project_periods.project_period_cat_id#,#get_project_periods.ACCOUNT_CODE#,#get_project_periods.ACCOUNT_CODE_PUR#,#get_project_periods.ACCOUNT_DISCOUNT#,#get_project_periods.ACCOUNT_PRICE#,#get_project_periods.ACCOUNT_PRICE_PUR#,#get_project_periods.ACCOUNT_PUR_IADE#,#get_project_periods.ACCOUNT_IADE#,#get_project_periods.ACCOUNT_YURTDISI#,#get_project_periods.ACCOUNT_YURTDISI_PUR#,#get_project_periods.ACCOUNT_DISCOUNT_PUR#,#get_project_periods.ACCOUNT_LOSS#,#get_project_periods.ACCOUNT_EXPENDITURE#,#get_project_periods.OVER_COUNT#,#get_project_periods.UNDER_COUNT#,#get_project_periods.PRODUCTION_COST#,#get_project_periods.HALF_PRODUCTION_COST#,#get_project_periods.SALE_PRODUCT_COST#,#get_project_periods.MATERIAL_CODE#,#get_project_periods.KONSINYE_PUR_CODE#,#get_project_periods.KONSINYE_SALE_CODE#,#get_project_periods.KONSINYE_SALE_NAZ_CODE#,#get_project_periods.DIMM_CODE#,#get_project_periods.DIMM_YANS_CODE#,#get_project_periods.PROMOTION_CODE#,#get_project_periods.INVENTORY_CAT_ID#,#get_project_periods.INVENTORY_CODE#,#get_project_periods.AMORTIZATION_METHOD_ID#,#get_project_periods.AMORTIZATION_TYPE_ID#,#get_project_periods.AMORTIZATION_EXP_CENTER_ID#,#get_project_periods.AMORTIZATION_EXP_ITEM_ID#,#get_project_periods.AMORTIZATION_CODE#,#get_project_periods.RECEIVED_PROGRESS_CODE#,#get_project_periods.SALE_MANUFACTURED_COST#,#get_project_periods.MATERIAL_CODE_SALE#,#get_project_periods.PRODUCTION_COST_SALE#,#get_project_periods.SCRAP_CODE_SALE#,#get_project_periods.SCRAP_CODE#,#get_project_periods.EXE_VAT_SALE_INVOICE#">
										<select name="period_code_cat" id="period_code_cat" onchange="cat_kontrol();">
											<option value=""><cf_get_lang dictionary_id ='57734.Seçiniz'></option>
											<cfloop query="get_code_cat">
												<cfset period_code_list =  "#PRO_CODE_CATID#,#ACCOUNT_CODE#,#ACCOUNT_CODE_PUR#,#ACCOUNT_DISCOUNT#,#ACCOUNT_PRICE#,#ACCOUNT_PUR_IADE#,#ACCOUNT_IADE#,#ACCOUNT_YURTDISI#,#ACCOUNT_YURTDISI_PUR#,#ACCOUNT_DISCOUNT_PUR#,#ACCOUNT_LOSS#,#ACCOUNT_EXPENDITURE#,#OVER_COUNT#,#UNDER_COUNT#,#PRODUCTION_COST#,#HALF_PRODUCTION_COST#,#SALE_PRODUCT_COST#,#MATERIAL_CODE#,#KONSINYE_PUR_CODE#,#KONSINYE_SALE_CODE#,#KONSINYE_SALE_NAZ_CODE#,#DIMM_CODE#,#DIMM_YANS_CODE#,#PROMOTION_CODE#,#ACCOUNT_PRICE_PUR#,#RECEIVED_PROGRESS_CODE#,#PROVIDED_PROGRESS_CODE#,#INVENTORY_CAT_ID#,#INVENTORY_CODE#,#AMORTIZATION_METHOD_ID#,#AMORTIZATION_TYPE_ID#,#AMORTIZATION_EXP_CENTER_ID#,#AMORTIZATION_EXP_ITEM_ID#,#AMORTIZATION_CODE#,#SCRAP_CODE#,#MATERIAL_CODE_SALE#,#PRODUCTION_COST_SALE#,#SCRAP_CODE_SALE#,#SALE_MANUFACTURED_COST#,#EXP_CENTER_ID#,#EXP_ITEM_ID#,#EXP_ACTIVITY_TYPE_ID#,#EXP_TEMPLATE_ID#,#INC_CENTER_ID#,#INC_ITEM_ID#,#INC_ACTIVITY_TYPE_ID#,#INC_TEMPLATE_ID#,#EXPENSE_PROGRESS_CODE#,#INCOME_PROGRESS_CODE#,#EXE_VAT_SALE_INVOICE#">
												<option value="#period_code_list#" <cfif period_code_list eq old_code_list or get_project_periods.PROJECT_PERIOD_CAT_ID eq PRO_CODE_CATID>selected</cfif>>#PRO_CODE_CAT_NAME#</option>
											</cfloop>
										</select>
									</div>
							</div>
							<div class="form-group" id="item-account_code_sale">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38373.Satış Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,1)>
										<cf_wrk_account_codes form_name='add_period' account_code="account_code_sale" is_sub_acc='0' is_multi_no = '1'>
										<input type="text" name="account_code_sale" id="account_code_sale" value="#acc_code#" onfocus="AutoComplete_Create('account_code_sale','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','account_code_sale','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','account_code_sale');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-account_code_purchase">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38375.Alış Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,2)>
										<cf_wrk_account_codes form_name='add_period' account_code="account_code_purchase" is_sub_acc='0' is_multi_no = '2'>
										<input type="text" name="account_code_purchase" id="account_code_purchase" value="#acc_code#" onfocus="AutoComplete_Create('account_code_purchase','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','account_code_purchase','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','account_code_purchase');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-account_discount">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38377.Satış İskonto'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,3)>
										<input type="text" name="account_discount" id="account_discount" value="#acc_code#" onfocus="AutoComplete_Create('account_discount','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','account_discount','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','account_discount');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-ACCOUNT_DISCOUNT_PUR">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38379.Alış İskonto'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,8)>
										<input type="text" name="ACCOUNT_DISCOUNT_PUR" id="ACCOUNT_DISCOUNT_PUR" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_DISCOUNT_PUR','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_DISCOUNT_PUR','','3','200');">                    
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_DISCOUNT_PUR');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-ACCOUNT_IADE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38381.Satış İade'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,6)>
										<input type="text" name="ACCOUNT_IADE" id="ACCOUNT_IADE" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_IADE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_IADE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_IADE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-ACCOUNT_PUR_IADE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38383.Alış İade'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,5)>
										<input type="text" name="ACCOUNT_PUR_IADE" id="ACCOUNT_PUR_IADE" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_PUR_IADE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_PUR_IADE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_PUR_IADE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-ACCOUNT_PRICE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12">Satış <cf_get_lang dictionary_id ='38385.Fiyat Farkı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,4)>
										<input type="text" name="ACCOUNT_PRICE" id="ACCOUNT_PRICE" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_PRICE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_PRICE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_PRICE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-ACCOUNT_PRICE_PUR">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12">Alış <cf_get_lang dictionary_id ='38385.Fiyat Farkı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,24)>
										<cf_wrk_account_codes form_name='add_period' account_code="ACCOUNT_PRICE_PUR" is_sub_acc='0' is_multi_no = '32'>
										<input type="text" name="ACCOUNT_PRICE_PUR" id="ACCOUNT_PRICE_PUR" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_PRICE_PUR','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_PRICE_PUR','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_PRICE_PUR');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-ACCOUNT_YURTDISI">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38387.Yurtdışı Satış'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,7)>
										<input type="text" name="ACCOUNT_YURTDISI" id="ACCOUNT_YURTDISI" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_YURTDISI','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_YURTDISI','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_YURTDISI');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-ACCOUNT_YURTDISI_PUR">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38388.Yurtdışı Alış'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,9)>
										<input type="text" name="ACCOUNT_YURTDISI_PUR" id="ACCOUNT_YURTDISI_PUR" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_YURTDISI_PUR','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_YURTDISI_PUR','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_YURTDISI_PUR');"></span>
									</div>
								</div>
							</div>		
							<div class="form-group" id="item-MATERIAL_CODE_SALE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38390.Hammadde'><cf_get_lang dictionary_id='57448.Satis'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,38)>
										<input type="text" name="MATERIAL_CODE_SALE" id="MATERIAL_CODE_SALE" value="#acc_code#" onfocus="AutoComplete_Create('MATERIAL_CODE_SALE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','MATERIAL_CODE_SALE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','MATERIAL_CODE_SALE');"></span>
									</div>
								</div>
							</div>		
							<div class="form-group" id="item-MATERIAL_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38390.Hammadde'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">	
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,17)>
										<input type="text" name="MATERIAL_CODE" id="MATERIAL_CODE" value="#acc_code#" onfocus="AutoComplete_Create('MATERIAL_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','MATERIAL_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','MATERIAL_CODE');"></span>
									</div>
								</div>
							</div>		
							<div class="form-group" id="item-ACCOUNT_LOSS">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38391.Fireler'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,10)>
										<input type="text" name="ACCOUNT_LOSS" id="ACCOUNT_LOSS" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_LOSS','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_LOSS','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_LOSS');"></span> 
									</div>
								</div>
							</div>		
							<div class="form-group" id="item-ACCOUNT_EXPENDITURE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='30009.Sarflar'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,11)>
										<input type="text" name="ACCOUNT_EXPENDITURE" id="ACCOUNT_EXPENDITURE" value="#acc_code#" onfocus="AutoComplete_Create('ACCOUNT_EXPENDITURE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','ACCOUNT_EXPENDITURE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','ACCOUNT_EXPENDITURE');"></span> 
									</div>
								</div>
							</div>
							<div class="form-group" id="item-OVER_COUNT">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57753.Sayım Fazlası'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,12)>
										<input type="text" name="OVER_COUNT" id="OVER_COUNT" value="#acc_code#" onfocus="AutoComplete_Create('OVER_COUNT','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','OVER_COUNT','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','OVER_COUNT');"></span> 
									</div>
								</div>
							</div>		
							<div class="form-group" id="item-UNDER_COUNT">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57754.Sayım Eksiği'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,13)>
										<input type="text" name="UNDER_COUNT" id="UNDER_COUNT" value="#acc_code#" onfocus="AutoComplete_Create('UNDER_COUNT','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','UNDER_COUNT','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','UNDER_COUNT');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-PRODUCTION_COST_SALE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='59122.Mamül Satış'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,39)>
										<input type="text" name="PRODUCTION_COST_SALE" id="PRODUCTION_COST_SALE" value="#acc_code#" onfocus="AutoComplete_Create('PRODUCTION_COST_SALE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','PRODUCTION_COST_SALE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','PRODUCTION_COST_SALE');"></span>
									</div>
								</div>
							</div>		
							<div class="form-group" id="item-PRODUCTION_COST">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38395.Üretim/Mamül'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,14)>
										<input type="text" name="PRODUCTION_COST" id="PRODUCTION_COST" value="#acc_code#" onfocus="AutoComplete_Create('PRODUCTION_COST','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','PRODUCTION_COST','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','PRODUCTION_COST');"></span>
									</div>
								</div>
							</div>		
							<div class="form-group" id="item-HALF_PRODUCTION_COST">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38396.Üretim/Yarı Mamül'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,15)>
										<input type="text" name="HALF_PRODUCTION_COST" id="HALF_PRODUCTION_COST" value="#acc_code#" onfocus="AutoComplete_Create('HALF_PRODUCTION_COST','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','HALF_PRODUCTION_COST','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','HALF_PRODUCTION_COST');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-SALE_PRODUCT_COST">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38397.Satılan Malın Maliyeti'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,16)>
										<input type="text" name="SALE_PRODUCT_COST" id="SALE_PRODUCT_COST" value="#acc_code#" onfocus="AutoComplete_Create('SALE_PRODUCT_COST','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','SALE_PRODUCT_COST','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','SALE_PRODUCT_COST');"></span>
									</div>
								</div>
							</div>		
							<div class="form-group" id="item-SALE_MANUFACTURED_COST">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='59119.Satılan Mamülün Maliyeti'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,29)>
										<input type="text"  name="SALE_MANUFACTURED_COST" id="SALE_MANUFACTURED_COST" value="#acc_code#" onfocus="AutoComplete_Create('SALE_MANUFACTURED_COST','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','SALE_MANUFACTURED_COST','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','SALE_MANUFACTURED_COST');"></span> 
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-KONSINYE_PUR_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38398.Konsinye Alış Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,18)>
										<input type="text" name="KONSINYE_PUR_CODE" id="KONSINYE_PUR_CODE" value="#acc_code#" onfocus="AutoComplete_Create('KONSINYE_PUR_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','KONSINYE_PUR_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','KONSINYE_PUR_CODE');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-KONSINYE_SALE_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38399.Diger Satış Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,19)>
										<input type="text" name="KONSINYE_SALE_CODE" id="KONSINYE_SALE_CODE" value="#acc_code#" onfocus="AutoComplete_Create('KONSINYE_SALE_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','KONSINYE_SALE_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','KONSINYE_SALE_CODE');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-KONSINYE_SALE_NAZ_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38400.Diger Satış Nazım Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,20)>
										<input type="text" name="KONSINYE_SALE_NAZ_CODE" id="KONSINYE_SALE_NAZ_CODE" value="#acc_code#" onfocus="AutoComplete_Create('KONSINYE_SALE_NAZ_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','KONSINYE_SALE_NAZ_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','KONSINYE_SALE_NAZ_CODE');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-RECEIVED_PROGRESS_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='37034.Alınan Hakediş Muhasebe Kodu'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,25)>
										<input type="text" name="RECEIVED_PROGRESS_CODE" id="RECEIVED_PROGRESS_CODE" value="#acc_code#" onfocus="AutoComplete_Create('RECEIVED_PROGRESS_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','RECEIVED_PROGRESS_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','RECEIVED_PROGRESS_CODE');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-PROVIDED_PROGRESS_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='37036.Verilen Hakediş Muhasebe Kodu'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,26)>
										<input type="text" name="PROVIDED_PROGRESS_CODE" id="PROVIDED_PROGRESS_CODE" value="#acc_code#" onfocus="AutoComplete_Create('PROVIDED_PROGRESS_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','PROVIDED_PROGRESS_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','PROVIDED_PROGRESS_CODE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-SCRAP_CODE_SALE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='37093.Hurda Hesabı'> <cf_get_lang dictionary_id ='57448.Satış'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,40)>
										<input type="text" name="SCRAP_CODE_SALE" id="SCRAP_CODE_SALE" value="#acc_code#" onfocus="AutoComplete_Create('SCRAP_CODE_SALE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','SCRAP_CODE_SALE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','SCRAP_CODE_SALE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-SCRAP_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='37093.Hurda Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,37)>
										<input type="text" name="SCRAP_CODE" id="SCRAP_CODE" value="#acc_code#" onfocus="AutoComplete_Create('SCRAP_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','SCRAP_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','SCRAP_CODE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-DIMM_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38401.Direk İlk Madde Malz Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,21)>
										<input type="text" name="DIMM_CODE" id="DIMM_CODE" value="#acc_code#" onfocus="AutoComplete_Create('DIMM_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','DIMM_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','DIMM_CODE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-DIMM_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38402.D İ Mad Malz Yans Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">	
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,22)>
										<input type="text" name="DIMM_YANS_CODE" id="DIMM_YANS_CODE" value="#acc_code#" onfocus="AutoComplete_Create('DIMM_YANS_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','DIMM_YANS_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','DIMM_YANS_CODE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-PROMOTION_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='37559.Promosyon Hesabı'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,23)>
										<input type="text" name="PROMOTION_CODE" id="PROMOTION_CODE" value="#acc_code#" onfocus="AutoComplete_Create('PROMOTION_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','PROMOTION_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','PROMOTION_CODE');"></span> 
									</div>
								</div>
							</div>
						</div>	
						<div class="col col-5 col-md-5 col-sm-6 col-xs-12" type="column" index="2" sort="true">
							<div class="form-group">
								<label class="headbold font-red-sunglo col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id ='38370.Gider Dağılım'></label>
							</div>
							<div class="form-group" id="item-expense_center_gider">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38374.Gider Merkezi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">	
									<select name="expense_center_gider" id="expense_center_gider" onchange="kontrol(1);">
										<option value=""></option>
										<cfloop query="get_expense_center">
										<option value="#expense_id#" <cfif expense_id eq get_project_periods.cost_expense_center_id>selected</cfif>>#expense#</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-expense_item">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58551.Gider Kalemi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<select name="expense_item" id="expense_item" onchange="kontrol(1);">
										<option value=""></option>
										<cfloop query="get_expense_item">
											<option value="#expense_item_id#" <cfif expense_item_id eq get_project_periods.expense_item_id>selected</cfif>>#expense_item_name#</option>
										</cfloop>
										<option value="-1" <cfif get_project_periods.expense_item_id eq '-1'>selected</cfif>><cf_get_lang dictionary_id ='38132.Üründen İşlem Yapılsın'></option>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-EXPENSE_PROGRESS_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='37297.Gider Muhasebe Kodu'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,28)>
										<input type="text" name="EXPENSE_PROGRESS_CODE" id="EXPENSE_PROGRESS_CODE" value="#acc_code#" onfocus="AutoComplete_Create('EXPENSE_PROGRESS_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','EXPENSE_PROGRESS_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','EXPENSE_PROGRESS_CODE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-activity_type">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38378.Aktivite Tipi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">	
									<select name="activity_type" id="activity_type" onchange="kontrol(1);">
									<option value=""></option>
										<cfloop query="get_activity_types">
											<option value="#activity_id#" <cfif activity_id eq get_project_periods.activity_type_id>selected</cfif>>#activity_name#</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-expense_template">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58822.Masraf Şablonu'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<select name="expense_template" id="expense_template" onchange="kontrol(2);">
										<option value=""></option>
										<cfloop query="get_expense_template_expense">
											<option value="#template_id#" <cfif template_id eq get_project_periods.expense_template_id>selected</cfif>>#template_name#</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="form-group">
								<label class="headbold font-red-sunglo col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id ='38382.Gelir Dağılım'></label>
							</div>
							<div class="form-group" id="item-expense_center">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58172.Gelir Merkezi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<select name="expense_center" id="expense_center" onchange="kontrol2(1);">
										<option value=""></option>
										<cfloop query="get_expense_center">
											<option value="#expense_id#" <cfif expense_id eq get_project_periods.expense_center_id>selected</cfif>>#expense#</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-income_item">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58173.Gelir Kalemi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<select name="income_item" id="income_item" onchange="kontrol2(1);">
										<option value=""></option>
										<cfloop query="get_expense_income">
											<option value="#expense_item_id#" <cfif expense_item_id eq get_project_periods.income_item_id>selected</cfif>>#expense_item_name#</option>
										</cfloop>
										<option value="-1" <cfif get_project_periods.income_item_id eq '-1'>selected</cfif>><cf_get_lang dictionary_id ='38132.Üründen İşlem Yapılsın'></option>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-INCOME_PROGRESS_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='37298.Gelir Muhasebe Kodu'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,27)>
										<input type="text" name="INCOME_PROGRESS_CODE" id="INCOME_PROGRESS_CODE" value="#acc_code#" onfocus="AutoComplete_Create('INCOME_PROGRESS_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','INCOME_PROGRESS_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','INCOME_PROGRESS_CODE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-activity_type_income">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id ='38378.Aktivite Tipi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<select name="activity_type_income" id="activity_type_income" onchange="kontrol2(1);">
									<option value=""></option>
										<cfloop query="get_activity_types">
											<option value="#activity_id#" <cfif activity_id eq get_project_periods.income_activity_type_id>selected</cfif>>#activity_name#</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-expense_template_income">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58823.Gelir Şablonu'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<select name="expense_template_income" id="expense_template_income" onchange="kontrol2(2);">
										<option value=""></option>
										<cfloop query="get_expense_template_income">
											<option value="#template_id#" <cfif template_id eq get_project_periods.income_template_id>selected</cfif>>#template_name#</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="form-group">
								<label class="headbold font-red-sunglo col col-12 col-md-12 col-sm-12 col-xs-12"><cf_get_lang dictionary_id='58478.Sabit Kıymet'></label>
							</div>
							<div class="form-group" id="item-INVENTORY_CAT_ID">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57486.Kategori'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset inv_cat_id = get_account_code(attributes.ID,PERIOD_ID,30)>
										<cfif len(inv_cat_id)>
											<cfquery name="GET_INV_CAT" datasource="#dsn3#">
												SELECT INVENTORY_CAT FROM SETUP_INVENTORY_CAT WHERE INVENTORY_CAT_ID = #inv_cat_id#
											</cfquery>
											<cfset inv_cat = GET_INV_CAT.INVENTORY_CAT>
										<cfelse>
											<cfset inv_cat = "">
										</cfif>
										<input type="hidden" name="INVENTORY_CAT_ID" id="INVENTORY_CAT_ID" value="#inv_cat_id#" />
										<input type="text" name="inventory_cat" id="inventory_cat" value="<cfif len(inv_cat)>#inv_cat#</cfif>" />
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_inventory_cat&field_id=add_period.INVENTORY_CAT_ID&field_name=add_period.inventory_cat','list');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-INVENTORY_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58811.Muhasebe Kodu'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">	
										<cfset inv_code = get_account_code(attributes.ID,PERIOD_ID,31)>
										<input type="text" name="INVENTORY_CODE" id="INVENTORY_CODE" value="#inv_code#" onfocus="AutoComplete_Create('INVENTORY_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','INVENTORY_CODE','','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','INVENTORY_CODE');"></span>
									</div>
								</div>
							</div>	
							<div class="form-group" id="item-AMORTIZATION_METHOD_ID">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='29420.Amortisman Yöntemi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<cfset amortization_method_id = get_account_code(attributes.ID,PERIOD_ID,32)>
									<select name="AMORTIZATION_METHOD_ID" id="AMORTIZATION_METHOD_ID">
										<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
										<option value="0" <cfif amortization_method_id eq 0>selected</cfif>><cf_get_lang dictionary_id='29421.Azalan Bakiye Üzerinden'></option>
										<option value="1" <cfif amortization_method_id eq 1>selected</cfif>><cf_get_lang dictionary_id='29422.Sabit Miktar Üzeriden'></option>
										<option value="2" <cfif amortization_method_id eq 2>selected</cfif>><cf_get_lang dictionary_id='29423.Hızlandırılmış Azalan Bakiye'></option>
										<option value="3" <cfif amortization_method_id eq 3>selected</cfif>><cf_get_lang dictionary_id='29424.Hızlandırılmış Sabit Değer'></option>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-AMORTIZATION_TYPE_ID">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='29425.Amortisman Türü'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<cfset amortization_type_id = get_account_code(attributes.ID,PERIOD_ID,33)>
									<select name="AMORTIZATION_TYPE_ID" id="AMORTIZATION_TYPE_ID">
										<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
										<option value="1" <cfif amortization_type_id eq 1>selected</cfif>><cf_get_lang dictionary_id='29426.Kıst Amortismana Tabi'></option>
										<option value="2" <cfif amortization_type_id eq 2>selected</cfif>><cf_get_lang dictionary_id='29427.Kıst Amortismana Tabi Değil'></option>
									</select>
								</div>
							</div>	
							<div class="form-group" id="item-AMORTIZATION_EXP_CENTER_ID">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58460.Masraf Merkezi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<cfset amortization_exp_center_id = get_account_code(attributes.ID,PERIOD_ID,34)>
									<select name="AMORTIZATION_EXP_CENTER_ID" id="AMORTIZATION_EXP_CENTER_ID">
										<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
										<cfloop query="get_expense_center">
											<option value="#expense_id#" title="#expense#" <cfif get_expense_center.expense_id eq amortization_exp_center_id>selected</cfif>>#expense#</option>
										</cfloop>
									</select>
								</div>
							</div>	
							<div class="form-group" id="item-AMORTIZATION_EXP_CENTER_ID">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58551.Gider Kalemi'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12">
									<cfset amortization_exp_item_id = get_account_code(attributes.ID,PERIOD_ID,35)>
									<select name="AMORTIZATION_EXP_ITEM_ID" id="AMORTIZATION_EXP_ITEM_ID">
										<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
										<cfloop query="get_expense_item">
											<option value="#expense_item_id#" title="#expense_item_name#" <cfif get_expense_item.expense_item_id eq amortization_exp_item_id>selected</cfif>>#expense_item_name#</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="form-group" id="item-AMORTIZATION_CODE">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='58298.Birikmiş Amortisman'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">
										<cfset amortization_code = get_account_code(attributes.ID,PERIOD_ID,36)>
										<input type="text" name="AMORTIZATION_CODE" id="AMORTIZATION_CODE" value="#amortization_code#" onfocus="AutoComplete_Create('AMORTIZATION_CODE','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','ACCOUNT_CODE','AMORTIZATION_CODE','','3','200');" />
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','AMORTIZATION_CODE');"></span>
									</div>
								</div>
							</div>
							<div class="form-group" id="item-exe_vat_sale_invoice">
								<label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='49548.KDV den Muaf Satış Faturası'></label>
								<div class="col col-8 col-md-8 col-sm-8 col-xs-12"> 
									<div class="input-group">	
										<cfset acc_code = get_account_code(attributes.ID,PERIOD_ID,41)>
										<input type="text"  name="exe_vat_sale_invoice" id="exe_vat_sale_invoice" value="#acc_code#" onfocus="AutoComplete_Create('exe_vat_sale_invoice','ACCOUNT_CODE','ACCOUNT_CODE,ACCOUNT_NAME','get_account_code','\'0\',0','','','pro_period_cat','3','200');">
										<span class="input-group-addon icon-ellipsis btnPoniter" href="javascript://" onclick="pencere_ac('#PERIOD_YEAR#','#OUR_COMPANY_ID#','exe_vat_sale_invoice');"></span>									 
									</div>
								</div>
							</div>
						</div>	
					</cf_box_elements>
				</cfoutput>
				<input type="hidden" name="periods" id="periods" value="<cfoutput>#valuelist(GET_OTHER_PERIOD.PERIOD_ID)#</cfoutput>">
			</cfif>
		
				<div class="col col-10 col-md-10 col-sm-10 col-xs-12 ui-form-list-btn">
					<cf_record_info query_name="GET_PROJECT_PERIODS">
				</div>
				<div class="ui-form-list-btn">
				<a href="javascript://control_period()" class="ui-btn ui-btn-success" onclick="<cfoutput>#iif(isdefined("attributes.draggable"),DE("loadPopupBox('add_period')"),DE(""))#</cfoutput>"><cf_get_lang dictionary_id='59031.Kaydet'></a>
				</div>
			
		</cfform>
	</cf_box>
</div>
<script type="text/javascript">
	function pencere_ac(period,company,isim)
	{
		temp_account_code = eval('document.add_period.'+isim);
		if (temp_account_code.value.length >= 3)
			windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_account_plan&db_source='+company+'&PERIOD_YEAR='+period+'&field_id=add_period.'+isim+'&account_code=' + temp_account_code.value</cfoutput>, 'list');
		else
			windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_account_plan&db_source='+company+'&PERIOD_YEAR='+period+'&field_id=add_period.'+isim+'</cfoutput>', 'list');
	}
	function kontrol(degerid)
	{
		if(degerid == 1)
		{
			document.add_period.expense_template.selectedIndex = 0;
		}
		else
		{
			document.add_period.expense_center_gider.selectedIndex = 0;
			document.add_period.expense_item.selectedIndex = 0;
			document.add_period.activity_type.selectedIndex = 0;
		}
	}
	
	function cat_kontrol()
	{
		degerler=document.add_period.period_code_cat.value.split(',');//hepsii için list_getat kullanmaktansa bir kere split yapıyoruz...
		document.add_period.project_period_cat_id.value=degerler[0];
		document.add_period.account_code_sale.value=degerler[1];
		document.add_period.account_code_purchase.value=degerler[2];
		document.add_period.account_discount.value=degerler[3];
		document.add_period.ACCOUNT_PRICE.value=degerler[4];
		document.add_period.ACCOUNT_PUR_IADE.value=degerler[5];
		document.add_period.ACCOUNT_IADE.value=degerler[6];
		document.add_period.ACCOUNT_YURTDISI.value=degerler[7];
		document.add_period.ACCOUNT_YURTDISI_PUR.value=degerler[8];
		document.add_period.ACCOUNT_DISCOUNT_PUR.value=degerler[9];
		document.add_period.ACCOUNT_LOSS.value=degerler[10];
		document.add_period.ACCOUNT_EXPENDITURE.value=degerler[11];
		document.add_period.OVER_COUNT.value=degerler[12];
		document.add_period.UNDER_COUNT.value=degerler[13];
		document.add_period.PRODUCTION_COST.value=degerler[14];
		document.add_period.HALF_PRODUCTION_COST.value=degerler[15];
		document.add_period.SALE_PRODUCT_COST.value=degerler[16];
		document.add_period.MATERIAL_CODE.value=degerler[17];	
		document.add_period.KONSINYE_PUR_CODE.value=degerler[18];	
		document.add_period.KONSINYE_SALE_CODE.value=degerler[19];	
		document.add_period.KONSINYE_SALE_NAZ_CODE.value=degerler[20];	
		document.add_period.DIMM_CODE.value=degerler[21];	
		document.add_period.DIMM_YANS_CODE.value=degerler[22];	
		document.add_period.PROMOTION_CODE.value=degerler[23];
		document.add_period.ACCOUNT_PRICE_PUR.value=degerler[24];
		document.add_period.RECEIVED_PROGRESS_CODE.value=degerler[25];	
		document.add_period.PROVIDED_PROGRESS_CODE.value=degerler[26];
		document.add_period.INVENTORY_CAT_ID.value=degerler[27];
		if(degerler[27] != "")
		{
			var get_inv_info = wrk_safe_query('prd_get_inv_info','dsn3',0,degerler[27]);
			document.getElementById("inventory_cat").value=get_inv_info.INVENTORY_CAT;
		}
		else 
			document.getElementById("inventory_cat").value="";	
		document.add_period.INVENTORY_CODE.value=degerler[28];
		document.add_period.AMORTIZATION_METHOD_ID.value=degerler[29];
		document.add_period.AMORTIZATION_TYPE_ID.value=degerler[30];
		document.add_period.AMORTIZATION_EXP_CENTER_ID.value=degerler[31];
		document.add_period.AMORTIZATION_EXP_ITEM_ID.value=degerler[32];
		document.add_period.AMORTIZATION_CODE.value=degerler[33];
		document.add_period.SCRAP_CODE.value=degerler[34];
		document.add_period.MATERIAL_CODE_SALE.value=degerler[35];
		document.add_period.PRODUCTION_COST_SALE.value=degerler[36];
		document.add_period.SCRAP_CODE_SALE.value=degerler[37];
		document.add_period.SALE_MANUFACTURED_COST.value=degerler[38];
		document.getElementById("expense_center_gider").value=degerler[39];	
		document.getElementById("expense_item").value=degerler[40];	
		document.getElementById("activity_type").value=degerler[41];	
		document.getElementById("expense_template").value=degerler[42];	
		document.getElementById("expense_center").value=degerler[43];	
		document.getElementById("income_item").value=degerler[44];	
		document.getElementById("activity_type_income").value=degerler[45];	
		document.getElementById("expense_template_income").value=degerler[46];
		document.getElementById("EXPENSE_PROGRESS_CODE").value=degerler[47];	
		document.getElementById("INCOME_PROGRESS_CODE").value=degerler[48];
		document.getElementById("exe_vat_sale_invoice").value=degerler[49];
	}
	
	function kontrol2(degerid)
	{
		if(degerid == 1)
		{
			document.add_period.expense_template_income.selectedIndex = 0;
		}
		else
		{
			document.add_period.expense_center.selectedIndex = 0;
			document.add_period.income_item.selectedIndex = 0;
			document.add_period.activity_type_income.selectedIndex = 0;
		}
	}
	function control_period()
	{
		
		<!---Muhasebe hesabı alt hesaplar gelirken üst hesapların yazılamaması kontrolü--->
		var account_code_sale = document.getElementById("account_code_sale").value;
		if(account_code_sale != "")
		{ 
			if(WrkAccountControl(account_code_sale,'Satış Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var account_code_purchase = document.getElementById("account_code_purchase").value;
		if(account_code_purchase != "")
		{ 
			if(WrkAccountControl(account_code_purchase,'Alış Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var account_discount = document.getElementById("account_discount").value;
		if(account_discount != "")
		{ 
			if(WrkAccountControl(account_discount,'Satış İskonto Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_DISCOUNT_PUR = document.getElementById("ACCOUNT_DISCOUNT_PUR").value;
		if(ACCOUNT_DISCOUNT_PUR != "")
		{ 
			if(WrkAccountControl(ACCOUNT_DISCOUNT_PUR,'Alış İskonto Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_IADE = document.getElementById("ACCOUNT_IADE").value;
		if(ACCOUNT_IADE != "")
		{ 
			if(WrkAccountControl(ACCOUNT_IADE,'Satış İade Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_PUR_IADE = document.getElementById("ACCOUNT_PUR_IADE").value;
		if(ACCOUNT_PUR_IADE != "")
		{ 
			if(WrkAccountControl(ACCOUNT_PUR_IADE,'Alış İade Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_PRICE = document.getElementById("ACCOUNT_PRICE").value;
		if(ACCOUNT_PRICE != "")
		{ 
			if(WrkAccountControl(ACCOUNT_PRICE,'Satış Fiyat Farkı Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_PRICE_PUR = document.getElementById("ACCOUNT_PRICE_PUR").value;
		if(ACCOUNT_PRICE_PUR != "")
		{ 
			if(WrkAccountControl(ACCOUNT_PRICE_PUR,'Alış Fiyat Farkı Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_YURTDISI = document.getElementById("ACCOUNT_YURTDISI").value;
		if(ACCOUNT_YURTDISI != "")
		{ 
			if(WrkAccountControl(ACCOUNT_YURTDISI,'Yurdışı Satış Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_YURTDISI_PUR = document.getElementById("ACCOUNT_YURTDISI_PUR").value;
		if(ACCOUNT_YURTDISI_PUR != "")
		{ 
			if(WrkAccountControl(ACCOUNT_YURTDISI_PUR,'Yurdışı Alış Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var MATERIAL_CODE_SALE = document.getElementById("MATERIAL_CODE_SALE").value;
		if(MATERIAL_CODE_SALE != "")
		{ 
			if(WrkAccountControl(MATERIAL_CODE_SALE,'Hammadde Satış Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var MATERIAL_CODE = document.getElementById("MATERIAL_CODE").value;
		if(MATERIAL_CODE != "")
		{ 
			if(WrkAccountControl(MATERIAL_CODE,'Hammadde Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_LOSS = document.getElementById("ACCOUNT_LOSS").value;
		if(ACCOUNT_LOSS != "")
		{ 
			if(WrkAccountControl(ACCOUNT_LOSS,'Fireler Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var ACCOUNT_EXPENDITURE = document.getElementById("ACCOUNT_EXPENDITURE").value;
		if(ACCOUNT_EXPENDITURE != "")
		{ 
			if(WrkAccountControl(ACCOUNT_EXPENDITURE,'Sarflar Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var OVER_COUNT = document.getElementById("OVER_COUNT").value;
		if(OVER_COUNT != "")
		{ 
			if(WrkAccountControl(OVER_COUNT,'Sayım Fazlası Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var UNDER_COUNT = document.getElementById("UNDER_COUNT").value;
		if(UNDER_COUNT != "")
		{ 
			if(WrkAccountControl(UNDER_COUNT,'Sayım Eksiği Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var PRODUCTION_COST_SALE = document.getElementById("PRODUCTION_COST_SALE").value;
		if(PRODUCTION_COST_SALE != "")
		{ 
			if(WrkAccountControl(PRODUCTION_COST_SALE,'Mamül Satış Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var PRODUCTION_COST = document.getElementById("PRODUCTION_COST").value;
		if(PRODUCTION_COST != "")
		{ 
			if(WrkAccountControl(PRODUCTION_COST,'Üretim / Mamül Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var HALF_PRODUCTION_COST = document.getElementById("HALF_PRODUCTION_COST").value;
		if(HALF_PRODUCTION_COST != "")
		{ 
			if(WrkAccountControl(HALF_PRODUCTION_COST,'Üretim / Yarı Mamül Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var SALE_PRODUCT_COST = document.getElementById("SALE_PRODUCT_COST").value;
		if(SALE_PRODUCT_COST != "")
		{ 
			if(WrkAccountControl(SALE_PRODUCT_COST,'Satılan Malın Maliyeti Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var SALE_MANUFACTURED_COST = document.getElementById("SALE_MANUFACTURED_COST").value;
		if(SALE_MANUFACTURED_COST != "")
		{ 
			if(WrkAccountControl(SALE_MANUFACTURED_COST,'Satılan Mamülün Maliyeti Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var KONSINYE_PUR_CODE = document.getElementById("KONSINYE_PUR_CODE").value;
		if(KONSINYE_PUR_CODE != "")
		{ 
			if(WrkAccountControl(KONSINYE_PUR_CODE,'Diğer Alış Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var KONSINYE_SALE_CODE = document.getElementById("KONSINYE_SALE_CODE").value;
		if(KONSINYE_SALE_CODE != "")
		{ 
			if(WrkAccountControl(KONSINYE_SALE_CODE,'Diğer Satış Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var KONSINYE_SALE_NAZ_CODE = document.getElementById("KONSINYE_SALE_NAZ_CODE").value;
		if(KONSINYE_SALE_NAZ_CODE != "")
		{ 
			if(WrkAccountControl(KONSINYE_SALE_NAZ_CODE,'Diğer Satış Nazım Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var RECEIVED_PROGRESS_CODE = document.getElementById("RECEIVED_PROGRESS_CODE").value;
		if(RECEIVED_PROGRESS_CODE != "")
		{ 
			if(WrkAccountControl(RECEIVED_PROGRESS_CODE,'Alınan Hakediş Muhasebe Kodu Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var PROVIDED_PROGRESS_CODE = document.getElementById("PROVIDED_PROGRESS_CODE").value;
		if(PROVIDED_PROGRESS_CODE != "")
		{ 
			if(WrkAccountControl(PROVIDED_PROGRESS_CODE,'Verilen Hakediş Muhasebe Kodu Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var SCRAP_CODE_SALE = document.getElementById("SCRAP_CODE_SALE").value;
		if(SCRAP_CODE_SALE != "")
		{ 
			if(WrkAccountControl(SCRAP_CODE_SALE,'Hurda Hesabı Satış Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var SCRAP_CODE = document.getElementById("SCRAP_CODE").value;
		if(SCRAP_CODE != "")
		{ 
			if(WrkAccountControl(SCRAP_CODE,'Hurda Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var DIMM_CODE = document.getElementById("DIMM_CODE").value;
		if(DIMM_CODE != "")
		{ 
			if(WrkAccountControl(DIMM_CODE,'Dirk.İlk.Mad. Malz. Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var DIMM_YANS_CODE = document.getElementById("DIMM_YANS_CODE").value;
		if(DIMM_YANS_CODE != "")
		{ 
			if(WrkAccountControl(DIMM_YANS_CODE,'Dirk.İlk.Mad. Malz. Yans. Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var PROMOTION_CODE = document.getElementById("PROMOTION_CODE").value;
		if(PROMOTION_CODE != "")
		{ 
			if(WrkAccountControl(PROMOTION_CODE,'Promosyon Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var EXPENSE_PROGRESS_CODE = document.getElementById("EXPENSE_PROGRESS_CODE").value;
		if(EXPENSE_PROGRESS_CODE != "")
		{ 
			if(WrkAccountControl(EXPENSE_PROGRESS_CODE,'Gider Muhasebe Kodu Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var INCOME_PROGRESS_CODE = document.getElementById("INCOME_PROGRESS_CODE").value;
		if(INCOME_PROGRESS_CODE != "")

		{ 
			if(WrkAccountControl(INCOME_PROGRESS_CODE,'Gelir Muhasebe Kodu Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var INVENTORY_CODE = document.getElementById("INVENTORY_CODE").value;
		if(INVENTORY_CODE != "")
		{ 
			if(WrkAccountControl(INVENTORY_CODE,'Muhasebe Kodu Hesabı Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var AMORTIZATION_CODE = document.getElementById("AMORTIZATION_CODE").value;
		if(AMORTIZATION_CODE != "")
		{ 
			if(WrkAccountControl(AMORTIZATION_CODE,'Birikmiş Amortismanlar (-) Hesap Planında Tanımlı Değildir!') == 0)
			return false;
		}
		var konsinye_code_value = document.getElementById("konsinye_code#PERIOD_ID#").value;
		if(konsinye_code_value != "")
		{ 
			if(WrkAccountControl(konsinye_code_value,'#currentrow#. Satır: Konsinye Kod Hesabı Tanımlı Değildir!') == 0)
			return false;
			
		}
		var advance_payment_value = document.getElementById("advance_payment_code#PERIOD_ID#").value;
		if(advance_payment_value != "")
		{ 
			if(WrkAccountControl(advance_payment_value,'#currentrow#. Satır: Avans Kod Hesabı Tanımlı Değildir!') == 0)
			return false;
		}
		
		var x = document.add_period.expense_template.selectedIndex;
		var y = document.add_period.expense_center_gider.selectedIndex;
		var z = document.add_period.expense_item.selectedIndex;
		var f = document.add_period.income_item.selectedIndex;
		var h = document.add_period.expense_center.selectedIndex;
		if ((document.add_period.expense_center[h].value != "") && (document.add_period.income_item[f].value == ""))
		{
			alert("<cf_get_lang dictionary_id ='38404.Masraf Gelir Merkezi Seçtiniz Lütfen Gelir Kalemi Seçiniz'> !");
			return false;
		}
		if ((document.add_period.expense_center[h].value == "") && (document.add_period.income_item[f].value != ""))
		{
			alert("<cf_get_lang dictionary_id ='38405.Gelir Kalemi Seçiniz Lütfen Masraf Gelir Merkezi Seçiniz'> !");
			return false;
		}
		if ((document.add_period.expense_center_gider[y].value == "") && (document.add_period.expense_item[z].value != ""))
		{
			alert("<cf_get_lang dictionary_id ='38406.Gider Kalemi Seçiniz Lütfen Masraf Gider Merkezi Seçiniz'> !");
			return false;
		}
		if ((document.add_period.expense_center_gider[y].value != "") && (document.add_period.expense_item[z].value == ""))
		{
			alert("<cf_get_lang dictionary_id ='38407.Masraf Gider Merkezi Seçiniz Lütfen Gider Kalemi Seçiniz'> !");
			return false;
		}
		
	}
</script>
