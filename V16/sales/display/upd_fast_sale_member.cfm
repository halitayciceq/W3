<cfif len(get_order_detail.company_id) and get_order_detail.company_id neq 0>
	<cfset comp = "comp">
	<cfquery name="get_order_comp" datasource="#dsn#">
		SELECT 
			COMPANY_ID,
            COMPANYCAT_ID,
			TAXOFFICE,
			TAXNO,
			COMPANY_ADDRESS,
			COUNTY,
			CITY,
			COUNTRY,
			FULLNAME,
			COMPANY_TELCODE,
			COMPANY_TEL1,
			COMPANY_FAX,
			COMPANY_ADDRESS,
			COMPANY_EMAIL,
			IMS_CODE_ID,
			MEMBER_CODE,
			OZEL_KOD,
			MOBIL_CODE,
			MOBILTEL,
			COMPANY_POSTCODE
		FROM
			COMPANY
		WHERE 
			COMPANY.COMPANY_ID=#get_order_detail.company_id#
	</cfquery>
	<cfif len(get_order_detail.partner_id)>
	<cfquery name="get_order_partner" datasource="#dsn#">
		SELECT 
			PARTNER_ID,
			COMPANY_PARTNER_NAME,
			COMPANY_PARTNER_SURNAME
		FROM 
			COMPANY_PARTNER
		WHERE 
			PARTNER_ID= #get_order_detail.partner_id#
	</cfquery>
	</cfif>
<cfelseif len(get_order_detail.consumer_id)>
	<cfquery name="get_order_consumer" datasource="#dsn#">
		SELECT 
            CONSUMER_CAT_ID, 
            CONSUMER_ID,
            MEMBER_CODE, 
            CONSUMER_NAME, 
            CONSUMER_SURNAME, 
            CONSUMER_EMAIL, 
            MOBIL_CODE, 
            MOBILTEL, 
            MOBIL_CODE_2, 
            MOBILTEL_2, 
            CONSUMER_FAX, 
            CONSUMER_HOMETELCODE, 
            CONSUMER_HOMETEL, 
            COMPANY, 
            HOMEADDRESS, 
            HOME_COUNTY_ID, 
            HOME_CITY_ID, 
            TAX_OFFICE, 
            TAX_NO, 
            MEMBER_TYPE, 
            PERIOD_ID, 
            TITLE, 
            DEPARTMENT, 
            OZEL_KOD, 
            TC_IDENTY_NO, 
            IMS_CODE_ID, 
            VOCATION_TYPE_ID, 
            RECORD_DATE, 
            RECORD_MEMBER, 
            RECORD_IP, 
            UPDATE_DATE, 
            UPDATE_EMP, 
            UPDATE_IP, 
            IS_DELETE,
			HOMEPOSTCODE
		FROM 
			CONSUMER
		WHERE 
			CONSUMER_ID=#get_order_detail.consumer_id#
	</cfquery>		
</cfif>
<cfquery name="GET_BANK_ACTION_INFO" datasource="#dsn3#">
	SELECT
		ORDERS.ORDER_ID 
	FROM
		ORDERS,
		ORDER_CASH_POS,
		CREDIT_CARD_BANK_PAYMENTS_ROWS CC
	WHERE
		ORDERS.ORDER_ID = ORDER_CASH_POS.ORDER_ID AND
		ORDER_CASH_POS.POS_ACTION_ID = CC.CREDITCARD_PAYMENT_ID AND
		CC.BANK_ACTION_ID IS NOT NULL AND
		ORDER_CASH_POS.IS_CANCEL = 0 AND
		ORDERS.ORDER_ID = #get_order_detail.ORDER_ID#
</cfquery>
<cfquery name="GET_COUNTRY" datasource="#DSN#">
	SELECT
		COUNTRY_ID,
		COUNTRY_NAME,
		COUNTRY_PHONE_CODE,
		IS_DEFAULT
	FROM
		SETUP_COUNTRY
	ORDER BY
		COUNTRY_NAME
</cfquery>

<cfscript>
	session_basket_kur_ekle(action_id=attributes.order_id,table_type_id:3,process_type:1);
	if (len(get_order_detail.company_id))
		{
		member_tax_office=get_order_comp.TAXOFFICE;
		member_tax_no=get_order_comp.TAXNO;
		member_tel_cod=get_order_comp.COMPANY_TELCODE;
		member_tel=get_order_comp.COMPANY_TEL1;
		member_fax=get_order_comp.COMPANY_FAX;											
		member_adres=get_order_comp.COMPANY_ADDRESS;
		member_city=get_order_comp.CITY;
		member_county=get_order_comp.COUNTY;
		member_mail=get_order_comp.COMPANY_EMAIL;
		member_code=get_order_comp.MEMBER_CODE;
		ozel_kod=get_order_comp.OZEL_KOD;
		if (is_ims_code eq 1)
		{
			member_ims_code_id =get_order_comp.IMS_CODE_ID;
		}
		member_mobil_cod=get_order_comp.MOBIL_CODE;
		member_mobil=get_order_comp.MOBILTEL;
		member_mobil_cod_2='';
		member_mobil_2='';
		member_tc_no='';
		member_postcode=get_order_comp.company_postcode;
		member_vocation_type='';
		}
	else if(len(get_order_detail.consumer_id))
		{
		member_tax_office=get_order_consumer.TAX_OFFICE;
		member_tax_no=get_order_consumer.TAX_NO;
		member_tel_cod=get_order_consumer.CONSUMER_HOMETELCODE;
		member_tel=get_order_consumer.CONSUMER_HOMETEL;
		member_fax=get_order_consumer.CONSUMER_FAX;											
		member_adres=get_order_consumer.HOMEADDRESS;
		member_city=get_order_consumer.HOME_CITY_ID;
		member_county=get_order_consumer.HOME_COUNTY_ID;
		member_mail=get_order_consumer.CONSUMER_EMAIL;
		member_code=get_order_consumer.MEMBER_CODE;
		ozel_kod=get_order_consumer.OZEL_KOD;
		if (is_ims_code eq 1)
		{
			member_ims_code_id =get_order_consumer.IMS_CODE_ID;
		}
		member_mobil_cod=get_order_consumer.MOBIL_CODE;
		member_mobil=get_order_consumer.MOBILTEL;
		member_mobil_cod_2=get_order_consumer.MOBIL_CODE_2;
		member_mobil_2=get_order_consumer.MOBILTEL_2;
		member_tc_no=get_order_consumer.TC_IDENTY_NO;
		member_postcode=get_order_consumer.HOMEPOSTCODE;
		member_vocation_type=get_order_consumer.VOCATION_TYPE_ID;
		}
</cfscript>
<cfparam name="attributes.member_type" default="2">
<cfparam name="attributes.comp_member_cat" default="">
<cfparam name="attributes.cons_member_cat" default="">
<cfquery name="get_vocation_type" datasource="#dsn#">
	SELECT
		VOCATION_TYPE_ID,
		VOCATION_TYPE
	FROM
		SETUP_VOCATION_TYPE
	ORDER BY
		VOCATION_TYPE
</cfquery>
<cfquery name="get_city" datasource="#dsn#">
	SELECT CITY_ID, CITY_NAME, PHONE_CODE, COUNTRY_ID,PLATE_CODE FROM SETUP_CITY ORDER BY PRIORITY,CITY_NAME
</cfquery>
<div id="minfo" class="content" style="display:block;">
	<cf_box_elements>
		<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
			<div class="form-group" id="item-member_name">
				<label for="" class="col col-4 col-xs-12"><cf_get_lang_main no ='158.Ad Soyad'></label>			
				<div class="col col-4 col-xs-5">
					<input type="hidden" name="old_stage" id="old_stage" value="<cfoutput>#get_order_detail.order_stage#</cfoutput>">
					<input type="hidden" name="cash" id="cash" value="0">
					<input type="hidden" name="old_nettotal" id="old_nettotal" value="<cfoutput>#wrk_round(get_order_detail.nettotal,2)#</cfoutput>">
					<input type="hidden" name="is_pos" id="is_pos" value="0">
					<input type="hidden" name="basket_id" id="basket_id" value="51">		
					<input type="hidden" name="active_company" id="active_company" value="<cfoutput>#session.ep.company_id#</cfoutput>"> 
					<input type="hidden" name="order_id" id="order_id" value="<cfoutput>#get_order_detail.order_id#</cfoutput>">
					<input type="hidden" name="ship_date" id="ship_date" value="<cfoutput>#dateformat(get_order_detail.ship_date,dateformat_style)#</cfoutput>">
					<input type="hidden" name="ref_company_id" id="ref_company_id" value="">
					<input type="hidden" name="ref_member_type" id="ref_member_type" value="">
					<input type="hidden" name="ref_member_id" id="ref_member_id" value="">
					<input type="hidden" name="ref_company" id="ref_company" value="">
					<input type="hidden" name="sales_member_id" id="sales_member_id" value="">
					<input type="hidden" name="sales_member_type" id="sales_member_type" value="">
					<input type="hidden" name="sales_member" id="sales_member" value="">
					<input type="hidden" name="order_head" id="order_head" value="<cfoutput>#get_order_detail.order_head#</cfoutput>">
					<input type="hidden" name="order_number" id="order_number" value="<cfoutput>#get_order_detail.order_number#</cfoutput>">
					<input type="hidden" name="search_process_date" id="search_process_date" value="order_date"><!--- basket icin kullanılıyor --->
					<cfif len(get_order_detail.offer_id)>
						<input type="hidden" name="offer_id" id="offer_id" value="<cfoutput>#get_order_detail.offer_id#</cfoutput>">
					<cfelse>
						<input type="hidden" name="offer_id" id="offer_id" value="">
					</cfif>
					<cfset str_par_names = "">
					<cfif len(get_order_detail.partner_id)>
						<cfset str_par_name = "#get_order_partner.COMPANY_PARTNER_NAME#">
						<cfset str_par_surname = "#get_order_partner.COMPANY_PARTNER_SURNAME#">
						<input type="hidden" name="member_type" id="member_type" value="partner">	
						<input type="hidden" name="member_id" id="member_id" value="<cfoutput>#get_order_detail.partner_id#</cfoutput>">
					<cfelseif len(get_order_detail.company_id)>
						<cfset str_par_name =''>
						<cfset str_par_surname =''>
					<cfelseif len(get_order_detail.consumer_id)>
						<cfset str_par_name = "#get_order_consumer.consumer_name#">
						<cfset str_par_surname = "#get_order_consumer.consumer_surname#">
						<input type="hidden" name="member_type" id="member_type" value="consumer">
						<input type="hidden" name="member_id" id="member_id" value="<cfoutput>#get_order_detail.consumer_id#</cfoutput>">
					</cfif>
					<input type="text" name="member_name" id="member_name" value="<cfoutput>#str_par_name#</cfoutput>" readonly>
				</div>
				<div class="col col-4 col-xs-7">
					<input type="text" name="member_surname" id="member_surname" value="<cfoutput>#str_par_surname#</cfoutput>" readonly>	
				</div>
			</div>
			<div class="form-group" id="item-tc_num">
				<label for="" class="col col-4 col-xs-12"><cf_get_lang_main no ='613.TC Kimlik No'></label>
				<div class="col col-8 col-xs-12">
					<cfsavecontent variable="message"><cf_get_lang_main no ='613.TC Kimlik No'></cfsavecontent>
					<cfinput type="text" name="tc_num" maxlength="11" validate="integer" message="#message#" tabindex="10" value="#member_tc_no#" onKeyUp="isNumber(this);" style="width:120px;">
				</div>
			</div>
            <div class="form-group" id="item-comp_name">
				<label class="col col-4 col-xs-12"><cf_get_lang_main no ='1195.Firma'></label>
				<div class="col col-8 col-xs-12">
					<input type="hidden" name="consumer_id" id="consumer_id" value="<cfoutput>#get_order_detail.consumer_id#</cfoutput>">
					<input type="hidden" name="company_id" id="company_id" value="<cfoutput>#get_order_detail.company_id#</cfoutput>">
					<cfif len(get_order_detail.company_id) and get_order_detail.company_id neq 0>
					<input type="text" name="comp_name" id="comp_name" value="<cfoutput>#get_order_comp.fullname#</cfoutput>" readonly>
					<cfelseif len(get_order_detail.consumer_id)>
					<input type="text" name="comp_name" id="comp_name" value="<cfoutput>#get_order_consumer.company#</cfoutput>" readonly>
					</cfif>
				</div>
			</div>
			<div class="form-group" id="item-tax_office">
				<label for="" class="col col-4 col-4 col-xs-12"><cf_get_lang_main no='1350.Vergi D'>/<cf_get_lang_main no='340.Vergi No'></label>
				<div class="col col-4 col-xs-5">
					<cfinput type="text" name="tax_office"  maxlength="30" value="#member_tax_office#">
				</div>
				<div class="col col-4 col-xs-7">
					<cfsavecontent variable="message"><cf_get_lang_main no='340.Vergi Numarası'></cfsavecontent>
					<cfinput type="text" name="tax_num" value="#member_tax_no#" maxlength="10" validate="integer" message="!" onKeyUp="isNumber(this);">
				</div>
			</div>
			<cfif is_dsp_category eq 1>
				<div class="form-group" id="item-company_cat">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang_main no='1197.Üye Kategorisi'></label>
					<cfif len(GET_ORDER_DETAIL.COMPANY_ID)>
						<div class="col col-8 col-xs-12" id="is_company" >
							<cfquery name="GET_COMPANYCAT" datasource="#DSN#">
								SELECT DISTINCT	
									COMPANYCAT_ID,
									COMPANYCAT
								FROM
									GET_MY_COMPANYCAT
								WHERE
									EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND
									OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
								ORDER BY
									COMPANYCAT
							</cfquery>
							<select name="comp_member_cat" id="comp_member_cat" style="width:120px;">
								<option value="" selected><cf_get_lang_main no='322.Seçiniz'></option>
								<cfoutput query="get_companycat">
									<option value="#COMPANYCAT_ID#" <cfif GET_ORDER_COMP.COMPANYCAT_ID eq COMPANYCAT_ID>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#COMPANYCAT#</option>
								</cfoutput>
							</select>
						</div>
					</cfif>
					<cfif len(GET_ORDER_DETAIL.CONSUMER_ID)>
						<div class="col col-8 col-xs-12" id="is_consumer" <cfif attributes.member_type neq 2> style="display:none;"</cfif> >
							<cfquery name="GET_CONSUMER_CAT" datasource="#DSN#">
								SELECT DISTINCT
									CONSCAT_ID,
									CONSCAT,
									HIERARCHY
								FROM
									GET_MY_CONSUMERCAT
								WHERE
									EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#"> AND
									OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
									AND IS_ACTIVE = 1
								ORDER BY
									CONSCAT	
							</cfquery>
							<select name="cons_member_cat" id="cons_member_cat" style="width:120px;">
								<option value="" selected><cf_get_lang_main no='322.Seçiniz'></option>
								<cfoutput query="get_consumer_cat">
									<option value="#CONSCAT_ID#" <cfif GET_ORDER_CONSUMER.CONSUMER_CAT_ID eq CONSCAT_ID>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#CONSCAT#</option>
								</cfoutput> 
							</select>
						</div>
					</cfif>
				</div>
			</cfif> 
			<div class="form-group" id="item-vocation_type">
				<label for="" class="col col-4 col-4 col-xs-12"><cf_get_lang no ='393.Meslek Tipi'></label>
				<div class="col col-8 col-xs-12">
					<select name="vocation_type" id="vocation_type" style="width:120px;" tabindex="13">
						<option value=""><cf_get_lang_main no='322.Seçiniz'></option>
						<cfoutput query="get_vocation_type">
							<option value="#vocation_type_id#" <cfif vocation_type_id eq member_vocation_type>selected</cfif>>#vocation_type#</option>
						</cfoutput>
					</select>			
				</div>
			</div>
		</div>
		<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
			<div class="form-group" id="item-country">
				<label for="" class="col col-3 col-xs-12"><cfoutput>#getLang('main',807,'ulke')#</cfoutput></label>
				<div class="col col-9 col-xs-12">
					<select name="country" id="country" onchange="LoadCity(this.value,'city','county_id',0);">
                        <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                        <cfoutput query="get_country">
                            <option value="#country_id#" <cfif get_order_detail.country_id eq country_id>selected</cfif>>#country_name#</option>
                        </cfoutput>
                    </select>
				</div>
			</div>
			<div class="form-group" id="item-city">
				<label for="" class="col col-3 col-xs-12"><cfoutput>#getLang('main',1196,'il')#</cfoutput></label>
				<div class="col col-9 col-xs-12">
					<cfquery name="get_cities" datasource="#dsn#">
                        SELECT CITY_ID,CITY_NAME FROM SETUP_CITY WHERE <cfif len(get_order_detail.country_id)>COUNTRY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_order_detail.country_id#"><cfelse> 1=0</cfif>
                    </cfquery>
                    <select name="city" id="city" onchange="LoadCounty(this.value,'county_id')">
                        <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                        <cfoutput query="get_cities">
                            <option value="#city_id#" <cfif get_order_detail.city_id eq city_id>selected</cfif>>#city_name#</option>
                        </cfoutput>
                    </select>
				</div>
			</div>
			<div class="form-group" id="item-county">
				<label for="" class="col col-3 col-xs-12"><cfoutput>#getLang('main',1226,'ilce')#</cfoutput></label>
				<div class="col col-9 col-xs-12">
                    <select name="county_id" id="county_id">
                        <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                        <cfif len(get_order_detail.city_id)>
                            <cfquery name="GET_COUNTY" datasource="#DSN#">
                                SELECT COUNTY_ID,COUNTY_NAME FROM SETUP_COUNTY WHERE CITY = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_order_detail.city_id#"> ORDER BY COUNTY_NAME
                            </cfquery>
                            <cfoutput query="get_county">
                                <option value="#county_id#" <cfif get_order_detail.county_id eq county_id>selected</cfif>>#county_name#</option>
                            </cfoutput>
                        </cfif>
                    </select>				
                </div>
			</div>		
			<div class="form-group" id="item-postcod">
				<label for="" class="col col-3 col-xs-12"><cfoutput>#getLang('main',60,'posta kodu')#</cfoutput></label>
				<div class="col col-9 col-xs-12">
                     <cfinput type="text" name="postcode" id="postcode" maxlength="10" value="#member_postcode#">
				</div>
			</div>
			<div class="form-group" id="item-adress">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no='1311.Adres'></label>
				<div class="col col-9 col-xs-12">
					<div class="input-group">
						<textarea name="address" id="address" rows="2" tabindex="7"><cfoutput>#get_order_detail.SHIP_ADDRESS#</cfoutput></textarea>
						<span class="input-group-addon icon-ellipsis btnPointer"  onClick="add_adresses();"></span>
					</div>
				</div>
			</div>
		</div>
		<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
			<div class="form-group" id="item-email">
				<label for="" class="col col-3 col-xs-12"><cfoutput>#getLang('objects',762,'email')#</cfoutput></label>
				<div class="col col-9 col-xs-12">
                    <cfsavecontent variable="message"><cf_get_lang_main no='65.hatalı veri'>:<cf_get_lang_main no='16.E-mail'>!</cfsavecontent>
                    <cfinput type="text" name="email" id="email" maxlength="100" value="#member_mail#" validate="email" message="#message#">
				</div>
			</div>
			<div class="form-group" id="item-mobile_number">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no ='1061.Mobil'></label>
				<div class="col col-4 col-xs-5">
					<cfinput type="text" name="mobil_code" id="mobil_code" maxlength="7"  tabindex="2" onKeyUp="isNumber(this);" style="width:45px;" value="#member_mobil_cod#">
				</div>
				<div class="col col-5 col-xs-7">
					<cfsavecontent variable="message"><cf_get_lang no ='435.Mobil Telefon'></cfsavecontent>
					<cfinput name="mobil_tel" value="#member_mobil#" tabindex="12" maxlength="20" type="text" validate="integer"  message="#message#" onKeyUp="isNumber(this);" style="width:72px;">
				</div>
			</div>
			<div class="form-group" id="item-tel_number">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no='87.Telefon'></label>
				<div class="col col-4 col-xs-5">
					<cfsavecontent variable="message"><cf_get_lang no ='391.Telefon Kodu'> !</cfsavecontent>
					<cfinput type="text" name="tel_code" style="width:45px;" maxlength="7" validate="integer" message="#message#" tabindex="8" value="#member_tel_cod#" onKeyUp="isNumber(this);">
				</div>
				<div class="col col-5 col-xs-7">
					<cfsavecontent variable="message"><cf_get_lang no ='392.Telefon Numarası'>!</cfsavecontent>
					<cfinput type="text"  name="tel_number" maxlength="20"  validate="integer" message="#message#" tabindex="9" value="#member_tel#" onKeyUp="isNumber(this);" style="width:72px;">
				</div>
			</div>
			<div class="form-group" id="item-ref_no">
				<label for="" class="col col-3 col-3 col-xs-12"><cf_get_lang_main no='1382.Referans No'></label>
				<div class="col col-9 col-xs-12">
					<input type="text"  name="ref_no" id="ref_no" value="<cfif len(get_order_detail.ref_no)><cfoutput>#get_order_detail.ref_no#</cfoutput></cfif>" maxlength="50" style="width:135px;">
				</div>
			</div>
            <div class="form-group" id="item-member_code">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no ='146.Üye No'>/<cf_get_lang_main no ='377.Özel Kod'></label>
				<div class="col col-4 col-xs-5">
					<input name="member_code" id="member_code" tabindex="17" type="text" size="10" value="<cfoutput>#member_code#</cfoutput>">
				</div>
				<div class="col col-5 col-xs-7">
					<input name="ozel_kod" id="ozel_kod" tabindex="18" type="text" size="10" value="<cfoutput>#ozel_kod#</cfoutput>">
				</div>
			</div>
			<cfif is_dsp_category eq 1>
				<div class="form-group" id="add_member_button">
                	<label class="hide">Submit Button</label>
					<cfsavecontent variable="message"><cf_get_lang_main no='45.Müşteri'><cf_get_lang_main no='52.Güncelle'></cfsavecontent>
					<label><input name="member_type" id="member_type" type="radio" value="1" <cfif len(GET_ORDER_DETAIL.COMPANY_ID)>checked</cfif>><cf_get_lang no='396.Kurumsal'></label>
					<label><input name="member_type" id="member_type" type="radio" value="2" <cfif len(GET_ORDER_DETAIL.CONSUMER_ID)>checked</cfif>><cf_get_lang no='398.Bireysel'></label>
				</div>
			</cfif>
		</div>
	</cf_box_elements>
</div>
<div id="siparis" class="content">
	<cf_box_elements>
		<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
			<div class="form-group" id="item-reserved">
				<label>
				<input type="checkbox" name="reserved" id="reserved" tabindex="28" value="1" onClick="check_reserved_rows();" <cfif get_order_detail.reserved eq 1>checked</cfif>><cf_get_lang no ='383.Stok Rezerve Et'>
				</label>
			</div>
			<div class="form-group" id="item-process">
				<label for="" class="col col-4 col-xs-12"><cf_get_lang_main no ='1447.Süreç'></label>
				<div class="col col-8 col-xs-12">	
					<cfif not listfindnocase(denied_pages,'#fusebox.circuit#.emptypopup_upd_fast_sale_deliverdate')>
						<div class="input-group">
					</cfif>	
					<cf_workcube_process is_upd='0' select_value='#get_order_detail.order_stage#' process_cat_width='120' is_detail='1'>
					<cfif not listfindnocase(denied_pages,'#fusebox.circuit#.emptypopup_upd_fast_sale_deliverdate')>
							<span class="input-group-addon" onClick="sayfa_getir_2();"><i class="icon-refresh" title="<cf_get_lang no='19.Aşamayı Güncelle'>"></i></span>
						</div>
						<div id="process_div" style="display:none;"></div>
					</cfif>			
				</div>
			</div>
			<div class="form-group" id="item-order_date">
				<label for="" class="col col-4 col-xs-12"><cf_get_lang_main no='1704.Sipariş Tarihi'></label>
				<div class="col col-8 col-xs-12">
					<cfif isdefined("is_readonly_orderdate") and is_readonly_orderdate neq 1>
						<div class="input-group">
					</cfif>
						<input type="text" name="order_date" id="order_date" tabindex="25" style="width:90px;" <cfif isdefined("is_readonly_orderdate") and is_readonly_orderdate eq 1>readonly</cfif> value="<cfoutput>#dateformat(get_order_detail.order_date,dateformat_style)#</cfoutput>" validate="#validate_style#" maxlength="10">
					<cfif isdefined("is_readonly_orderdate") and is_readonly_orderdate neq 1>
							<span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="order_date" call_function="change_money_info"></span>
						</div>
					</cfif>				
				</div>
			</div>
			<div class="form-group" id="item-order_employee">
				<label for="" class="col col-4 col-xs-12"><cf_get_lang no ='101.Satış Yapan'></label>
				<div class="col col-8 col-xs-12">
					<cfif len(get_order_detail.order_employee_id)>
						<input type="hidden" name="order_employee_id" id="order_employee_id" value="<cfoutput>#get_order_detail.order_employee_id#</cfoutput>">
						<input type="text" name="order_employee" id="order_employee" tabindex="22" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','120');" value="<cfoutput>#get_emp_info(get_order_detail.order_employee_id,0,0)#</cfoutput>" style="width:120px;">
					<cfelse>
						<div class="input-group">
							<input type="hidden" name="order_employee_id" id="order_employee_id" value="">
							<input type="text" name="order_employee" id="order_employee" tabindex="23" onFocus="AutoComplete_Create('order_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','order_employee_id','','3','120');" value="">
							<span class="input-group-addon icon-ellipsis btnPointer" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=form_basket.order_employee_id&field_name=form_basket.order_employee&select_list=1','list');"></span>
						</div>
					</cfif>
				</div>
			</div>		
			<div class="form-group" id="item-project_head">
				<label class="col col-4 col-xs-12"><cf_get_lang_main no ='4.Proje'></label>
				<div class="col col-8 col-xs-12">
					<div class="input-group">
						<input type="hidden" name="project_id" id="project_id" value="<cfoutput>#get_order_detail.project_id#</cfoutput>">
						<input type="text" name="project_head" id="project_head" tabindex="27" value="<cfif len(get_order_detail.project_id)><cfoutput>#GET_PROJECT_NAME(get_order_detail.project_id)#</cfoutput></cfif>" readonly>
						<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=form_basket.project_id&project_head=form_basket.project_head');"></span>
					</div>
				</div>
			</div>	
		</div>
		<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="5" sort="true">
			<div class="form-group" id="item-deliver_dept_name">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no='1351.Depo'></label>
				<div class="col col-9 col-xs-12">
					<cfset location_info_ = get_location_info(get_order_detail.deliver_dept_id,get_order_detail.location_id,1,1)>
					<cf_wrkdepartmentlocation 
						returnInputValue="deliver_loc_id,deliver_dept_name,deliver_dept_id,branch_id"
						returnQueryValue="LOCATION_ID,LOCATION_NAME,DEPARTMENT_ID,BRANCH_ID"
						fieldName="deliver_dept_name"
						fieldid="deliver_loc_id"
						department_fldId="deliver_dept_id"
						branch_fldId="branch_id"
						branch_id="#listlast(location_info_,',')#"
						department_id="#get_order_detail.deliver_dept_id#"
						location_id="#get_order_detail.location_id#"
						user_level_control="#session.ep.OUR_COMPANY_INFO.IS_LOCATION_FOLLOW#"
						xml_all_depo = "#IIf(isDefined("x_dsp_all_departmants") and x_dsp_all_departmants eq 1,'1',de('0'))#"
						width="135"
						is_branch="1">
				</div>
			</div>
			<div class="form-group" id="item-ship_method_name">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no='1703.Sevk Yontemi'></label>
				<div class="col col-9 col-xs-12">
					<div class="input-group">
					<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfoutput>#get_order_detail.SHIP_METHOD#</cfoutput>">
					<cfif len(get_order_detail.SHIP_METHOD)>
						<cfset attributes.ship_method=get_order_detail.SHIP_METHOD>
						<cfinclude template="../query/get_ship_method.cfm">
						<cfset ship_method = GET_SHIP_METHOD.SHIP_METHOD>
						<cfelse>
						<cfset ship_method = "">
					</cfif>
					<input type="text" name="ship_method_name" id="ship_method_name" tabindex="21" value="<cfoutput>#SHIP_METHOD#</cfoutput>">
						<span class="input-group-addon icon-ellipsis btnPointer" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=ship_method_name&field_id=ship_method_id','','ui-draggable-box-small');"></span>
					</div>
				</div>
			</div>
			<div class="form-group" id="item-deliverdate">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no='233.Teslim Tarihi'>*</label>
				<div class="col col-9 col-xs-12">
					<div class="input-group">
						<cfinput type="text" name="deliverdate" tabindex="24" value="#dateformat(get_order_detail.deliverdate,dateformat_style)#" validate="#validate_style#" maxlength="10">
						<span class="input-group-addon"><cf_wrk_date_image date_field="deliverdate"></span>
						<cfif not listfindnocase(denied_pages,'#fusebox.circuit#.emptypopup_upd_fast_sale_deliverdate')>
							<span class="input-group-addon" onClick="sayfa_getir();"><i class="icon-refresh" title="<cf_get_lang no='18.Teslim Tarihini Güncelle'>"></i></span>
						</cfif>
					</div>
					<div id="deliverdate_div" style="display:none;"></div>
				</div>
			</div>
			<div class="form-group" id="item-ship_address">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no='1037.Teslim Yeri'></label>
				<div class="col col-9 col-xs-12">
					<cfoutput>
						<div class="input-group">
							<input type="hidden" name="ship_address_city_id" id="ship_address_city_id" value="<cfoutput>#get_order_detail.city_id#</cfoutput>">
							<input type="hidden" name="ship_address_county_id" id="ship_address_county_id" value="<cfoutput>#get_order_detail.county_id#</cfoutput>">
							<input type="text" name="ship_address" id="ship_address" tabindex="26" value="<cfoutput>#get_order_detail.ship_address#</cfoutput>">
							<span class="input-group-addon icon-ellipsis btnPointer" onClick="add_adress();"></span>	
						</div>
					</cfoutput>
				</div>
			</div>
			<div class="form-group" id="item-paymethod">
				<label for="" class="col col-3 col-xs-12"><cf_get_lang_main no='1104.Ödeme Yöntemi'>/<cf_get_lang_main no ='228.Vade'></label>
				<div class="col col-4 col-xs-5">
					<cfif len(get_order_detail.paymethod)>
						<cfset attributes.paymethod_id = get_order_detail.paymethod>
						<cfinclude template="../query/get_paymethod.cfm">
						<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="">
						<input type="hidden" name="commission_rate" id="commission_rate" value="">
						<cfoutput>
						<input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="#get_paymethod.payment_vehicle#">
						<input type="hidden" name="paymethod_id" id="paymethod_id" value="#get_order_detail.paymethod#">
						<input type="text" name="paymethod" id="paymethod" value="#get_paymethod.paymethod#" readonly style="width:90px;" tabindex="19">
						</cfoutput>
					<cfelseif len(get_order_detail.card_paymethod_id)>
						<cfquery name="get_card_paymethod" datasource="#dsn3#">
							SELECT 
								CARD_NO
								<cfif get_order_detail.commethod_id eq 6>
								,PUBLIC_COMMISSION_MULTIPLIER AS COMMISSION_MULTIPLIER
								<cfelse> 
								,COMMISSION_MULTIPLIER 
								</cfif>
							FROM 
								CREDITCARD_PAYMENT_TYPE 
							WHERE 
								PAYMENT_TYPE_ID=#get_order_detail.card_paymethod_id#
						</cfquery>
						<cfoutput>
							<input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="-1">
							<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="#get_order_detail.card_paymethod_id#">
							<input type="hidden" name="commission_rate" id="commission_rate" value="#get_card_paymethod.commission_multiplier#">
							<input type="hidden" name="paymethod_id" id="paymethod_id" value="">
							<input type="text" name="paymethod" id="paymethod" value="#get_card_paymethod.card_no#" readonly style="width:100px;" tabindex="19">
						</cfoutput>
					<cfelse>
						<input type="hidden" name="paymethod_vehicle" id="paymethod_vehicle" value="">
						<input type="hidden" name="card_paymethod_id" id="card_paymethod_id" value="">
						<input type="hidden" name="commission_rate" id="commission_rate" value="">
						<input type="hidden" name="paymethod_id" id="paymethod_id" value="">
						<input type="text" name="paymethod" id="paymethod" value="" readonly style="width:90px;" tabindex="19">
					</cfif>		
				</div>
				<div class="col col-5 col-xs-7">
					<cfif get_order_detail.is_paid neq 1>
						<div class="input-group">
					</cfif>
						<input name="basket_due_value" id="basket_due_value" type="text" tabindex="20" readonly value="<cfif len(get_order_detail.due_date) and len(get_order_detail.order_date)><cfoutput>#datediff('d',get_order_detail.order_date,get_order_detail.due_date)#</cfoutput></cfif>">
						<cfset card_link="&field_card_payment_id=form_basket.card_paymethod_id&field_card_payment_name=form_basket.paymethod&field_commission_rate=form_basket.commission_rate&field_paymethod_vehicle=form_basket.paymethod_vehicle">
					<cfif get_order_detail.is_paid neq 1>
							<span class="input-group-addon icon-ellipsis btnPointer" onClick="pencere_ac_paymethod();"></span>
						</div>
					</cfif>
				</div>
			</div>	
		</div>
		<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="6" sort="true">
			<div class="form-group" id="item-order_detail">
				<label for="" class="col col-4 col-xs-12"><cf_get_lang_main no='217.Açıklama'></label>
				<div class="col col-8 col-xs-12">
					<textarea name="order_detail" id="order_detail" style="width:137px;height:45px;"><cfoutput>#get_order_detail.order_detail#</cfoutput></textarea>
				</div>
			</div>
			<cfif x_branch_info eq 1>
				<div class="form-group" id="item-project_head">
					<label class="col col-4 col-xs-12 bold"><cf_get_lang dictionary_id='57453.Şube'></label>
					<div class="col col-8 col-xs-12">
						<cfif len(get_order_detail.frm_branch_id)><cfoutput>#get_branch.branch_name#</cfoutput></cfif>
					</div>
				</div>
			</cfif>		
			<cfif is_ims_code eq 1>
				<div class="form-group" id="item-ims_code_name">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang_main no='722.Mikro Bölge Kodu'></label>
					<div class="col col-8 col-xs-12">
						<div class="input-group">
							<cfif len(member_ims_code_id)>
								<cfquery name="get_ims" datasource="#dsn#">
									SELECT 
										IMS_CODE_ID, 
										IMS_CODE, 
										IMS_CODE_NAME, 
										RECORD_DATE, 
										RECORD_EMP, 
										RECORD_IP, 
										UPDATE_DATE, 
										UPDATE_EMP, 
										UPDATE_IP
									FROM 
										SETUP_IMS_CODE 
									WHERE 
										IMS_CODE_ID = #member_ims_code_id#
								</cfquery>
							</cfif>
							<input type="hidden" name="ims_code_id" id="ims_code_id" value="<cfif len(member_ims_code_id)><cfoutput>#member_ims_code_id#</cfoutput></cfif>">
							<input type="text" name="ims_code_name" id="ims_code_name" value="<cfif len(member_ims_code_id)><cfoutput>#get_ims.ims_code# #get_ims.ims_code_name#</cfoutput></cfif>" style="width:145px;" onFocus="AutoComplete_Create('ims_code_name','IMS_CODE,IMS_CODE_NAME','IMS_NAME','get_ims_code','\'1,2\'','IMS_CODE_ID','ims_code_id','form_basket','1')" tabindex="44" autocomplete="off">
							<span class="input-group-addon icon-ellipsis"  onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ims_code&field_name=form_basket.ims_code_name&field_id=form_basket.ims_code_id&select_list=1','','ui-draggable-box-small');return false"></span>
						</div>					 
					</div>
				</div>
			</cfif>
		</div>
	</cf_box_elements>	
</div>


