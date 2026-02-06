<cfset member_name = ''>
<cfset member_surname = ''>
<cfset member_code = ''>
<cfset member_ozel_code = ''>
<cfset company_name = ''>
<cfset member_adres = ''>
<cfset member_tax_no = ''>
<cfset member_tax_office = ''>
<cfset member_county = ''>
<cfset member_city = ''>
<cfset member_tc_no = ''>
<cfset member_tel_cod = ''>
<cfset member_tel = ''>
<cfset member_ims_code_id = ''>
<cfset member_vocation_type=''>
<cfparam name="attributes.member_type" default="2">
<cfparam name="attributes.comp_member_cat" default="">
<cfparam name="attributes.cons_member_cat" default="">
<cfparam name="attributes.field_vocation" default="">
<cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
	<cfquery name="get_consumer" datasource="#dsn#">
		SELECT
            CONSUMER_CAT_ID, 
            CONSUMER_ID, 
            MEMBER_CODE, 
            CONSUMER_NAME, 
            CONSUMER_SURNAME, 
            MOBIL_CODE, 
            MOBIL_CODE_2, 
            CONSUMER_HOMETELCODE, 
            CONSUMER_HOMETEL, 
            COMPANY, 
            CONSUMER_STAGE, 
            HOMEADDRESS, 
            HOME_COUNTY_ID, 
            HOME_CITY_ID, 
            WORKSEMT,
            TAX_OFFICE, 
            TAX_NO, 
            MEMBER_TYPE, 
            DEPARTMENT, 
            OZEL_KOD, 
            TC_IDENTY_NO, 
            IMS_CODE_ID, 
            VOCATION_TYPE_ID, 
            RECORD_DATE, 
            RECORD_MEMBER, 
            RECORD_PAR, 
            RECORD_IP, 
            UPDATE_DATE, 
            UPDATE_EMP, 
            UPDATE_IP
		FROM
			CONSUMER
		WHERE
			CONSUMER_ID = #attributes.consumer_id#
	</cfquery>
<cfelseif isdefined("attributes.company_id") and len(attributes.company_id)>
	<cfquery name="get_company" datasource="#dsn#">
		SELECT 
			COMPANY_ID,
			FULLNAME,
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
			MEMBER_CODE,
			IMS_CODE_ID,
			OZEL_KOD
		FROM
			COMPANY
		WHERE 
			COMPANY.COMPANY_ID=#attributes.company_id#
	</cfquery>
	<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)>
		<cfquery name="get_partner" datasource="#dsn#">
			SELECT 
				PARTNER_ID, 
                COMPANY_ID, 
                MEMBER_CODE, 
                COMPANY_PARTNER_NAME, 
                COMPANY_PARTNER_SURNAME, 
                MOBIL_CODE, 
                MEMBER_TYPE, 
                DEPARTMENT, 
                COUNTY,
                CITY, 
                COUNTRY, 
                RECORD_DATE, 
                RECORD_PAR, 
                RECORD_MEMBER, 
                RECORD_IP, 
                UPDATE_PAR, 
                UPDATE_IP, 
                UPDATE_DATE, 
                WEB_USER_KEY
			FROM 
				COMPANY_PARTNER
			WHERE 
				COMPANY_PARTNER.COMPANY_ID = #attributes.company_id# AND
				PARTNER_ID= #attributes.partner_id#
		</cfquery>
	</cfif>
</cfif>
<cfif isdefined("attributes.consumer_id") and len(attributes.consumer_id)>
	<cfset company_name = ''>
	<cfset member_name = get_consumer.CONSUMER_NAME>
	<cfset member_surname = get_consumer.CONSUMER_SURNAME>
	<cfset member_code = get_consumer.MEMBER_CODE>
	<cfset member_ozel_code = get_consumer.OZEL_KOD>
	<cfset member_adres = get_consumer.HOMEADDRESS>
	<cfset member_tax_no = get_consumer.TAX_NO>
	<cfset member_tax_office = get_consumer.TAX_OFFICE>
	<cfset member_county = get_consumer.HOME_COUNTY_ID>
	<cfset member_city = get_consumer.HOME_CITY_ID>
	<cfset member_tc_no = get_consumer.TC_IDENTY_NO>
	<cfset member_tel_cod = get_consumer.CONSUMER_HOMETELCODE>
	<cfset member_tel = get_consumer.CONSUMER_HOMETEL>
	<cfset member_ims_code_id = get_consumer.IMS_CODE_ID>
	<cfset member_vocation_type=get_consumer.VOCATION_TYPE_ID>
<cfelseif isdefined("attributes.company_id") and len(attributes.company_id)>
	<cfset company_name = get_company.FULLNAME>
	<cfset member_code = get_company.MEMBER_CODE>
	<cfset member_ozel_code = get_company.OZEL_KOD>
	<cfset member_adres = get_company.COMPANY_ADDRESS>
	<cfset member_tax_no = get_company.TAXNO>
	<cfset member_tax_office = get_company.TAXOFFICE>
	<cfset member_county = get_company.COUNTY>
	<cfset member_city = get_company.CITY>
	<cfset member_tel_cod = get_company.COMPANY_TELCODE>
	<cfset member_tel = get_company.COMPANY_TEL1>
	<cfset member_vocation_type=''>
	<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)>
		<cfset member_name = get_partner.COMPANY_PARTNER_NAME>
		<cfset member_surname = get_partner.COMPANY_PARTNER_SURNAME>
		<cfset member_tc_no = ''>
	</cfif>
</cfif>
<cfquery name="get_mobilcat" datasource="#dsn#">
	SELECT MOBILCAT_ID,MOBILCAT	FROM SETUP_MOBILCAT ORDER BY MOBILCAT ASC
</cfquery>
<cfquery name="get_vocation_type" datasource="#dsn#">
	SELECT
		VOCATION_TYPE_ID,
		VOCATION_TYPE
	FROM
		SETUP_VOCATION_TYPE
	ORDER BY
		VOCATION_TYPE
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

<cfquery name="get_city" datasource="#dsn#">
	SELECT CITY_ID, CITY_NAME, PHONE_CODE, COUNTRY_ID,PLATE_CODE FROM SETUP_CITY ORDER BY PRIORITY,CITY_NAME
</cfquery>
<cf_workcube_process_info fuseaction="member.form_add_consumer">
<cfquery name="get_consumer_stage" datasource="#dsn#" maxrows="1">
	SELECT TOP 1
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%member.form_add_consumer%">
		<cfif isDefined("process_rowid_list") and ListLen(process_rowid_list)>
			AND PTR.PROCESS_ROW_ID IN(#process_rowid_list#)
		</cfif>
	ORDER BY 
		PTR.LINE_NUMBER	
</cfquery>
<cfquery name="get_company_stage" datasource="#dsn#" maxrows="1">
	SELECT TOP 1
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%member.form_add_company%">
	ORDER BY 
		PTR.LINE_NUMBER	
</cfquery>
<cfquery name="get_consumer_cat" datasource="#dsn#">
	SELECT CONSCAT_ID FROM CONSUMER_CAT WHERE IS_DEFAULT = 1
</cfquery>
	
		<cf_box_elements>
			<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
				<div class="form-group" id="item-member_name">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57570.Ad Soyad'></label>
					<div class="col col-4 col-xs-12">
						<input type="hidden" name="xml_kontrol_tcnumber" id="xml_kontrol_tcnumber" value="<cfoutput>#xml_kontrol_tcnumber#</cfoutput>">
						<input type="hidden" name="is_new_member" id="is_new_member" value="0">
						<input type="hidden" name="old_stage" id="old_stage" value="0">
						<input type="hidden" name="consumer_cat_id" id="consumer_cat_id" value="<cfif get_consumer_cat.recordcount><cfoutput>#get_consumer_cat.conscat_id#</cfoutput><cfelse>1</cfif>">
						<input type="hidden" name="company_cat_id" id="company_cat_id" value="1">
						<input type="hidden" name="cash" id="cash" value="0">
						<input type="hidden" name="is_pos" id="is_pos" value="0">		
						<input type="hidden" name="country_id" id="country_id" value="0">		
						<input type="hidden" name="company_id" id="company_id" value="<cfif isDefined('attributes.company_id') and len(attributes.company_id)><cfoutput>#attributes.company_id#</cfoutput></cfif>">
						<input type="hidden" name="partner_id" id="partner_id" value="<cfif isDefined('attributes.partner_id') and len(attributes.partner_id)><cfoutput>#attributes.partner_id#</cfoutput></cfif>">
						<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isDefined('attributes.consumer_id') and len(attributes.consumer_id)><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
						<input type="hidden" name="consumer_stage" id="consumer_stage" value="<cfif get_consumer_stage.recordcount><cfoutput>#get_consumer_stage.process_row_id#</cfoutput></cfif>">
						<input type="hidden" name="company_stage" id="company_stage" value="<cfif get_company_stage.recordcount><cfoutput>#get_company_stage.process_row_id#</cfoutput></cfif>">
						<input type="hidden" name="ref_company_id" id="ref_company_id" value="">								  
						<input type="hidden" name="ref_member_type" id="ref_member_type" value="">
						<input type="hidden" name="ref_member_id" id="ref_member_id" value="">
						<input type="hidden" name="ref_company" id="ref_company" value="">
						<input type="hidden" name="sales_member_id" id="sales_member_id" value="">
						<input type="hidden" name="sales_member_type" id="sales_member_type" value="">
						<input type="hidden" name="sales_member" id="sales_member" value="">
						<input type="hidden" name="active_company" id="active_company" value="<cfoutput>#session.ep.company_id#</cfoutput>"> 
						<input type="hidden" name="ship_date" id="ship_date" value="<cfoutput>#dateformat(now(),dateformat_style)#</cfoutput>">
						<input type="hidden" name="search_process_date" id="search_process_date" value="order_date"><!--- basket icin kullanılıyor --->
						<input type="hidden" name="order_head" id="order_head" value="Siparişiniz">
						<cfset belge_no = get_cheque_no(belge_tipi:'voucher_payroll')>
						<input type="hidden" name="payroll_no" id="payroll_no" value="<cfoutput>#belge_no#</cfoutput>">
						<cfset belge_no2 = get_cheque_no(belge_tipi:'payroll')>
						<input type="hidden" name="payroll_no_cheque" id="payroll_no_cheque" value="<cfoutput>#belge_no2#</cfoutput>">
						<cfset belge_no = get_cheque_no(belge_tipi:'voucher_payroll',belge_no:belge_no+1)>
						<cfset belge_no2 = get_cheque_no(belge_tipi:'payroll',belge_no2:belge_no2+1)>
						<input type="text" name="member_name" id="member_name" value="<cfif len(member_name)><cfoutput>#member_name#</cfoutput></cfif>" tabindex="1">
					</div>
					<div class="col col-4 col-xs-12">
						<div class="input-group">
							<input type="text" name="member_surname" id="member_surname" value="<cfif len(member_surname)><cfoutput>#member_surname#</cfoutput></cfif>" tabindex="2" onblur="cons_pre_records();">
							<span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_cons&field_tax_no=form_basket.tax_num&field_tax_office=form_basket.tax_office&field_vocation_id=form_basket.vocation_type&field_tc_identy_no=form_basket.tc_num&field_ozel_code=form_basket.ozel_kod&field_cons_code=form_basket.member_code&field_mobile_tel=form_basket.mobil_tel&field_mobile_tel_code=form_basket.mobil_code&field_hometel=form_basket.tel_number&field_hometel_code=form_basket.tel_code&field_country_id=form_basket.country&field_country=form_basket.country&field_city_id=form_basket.city&field_county=form_basket.county_id&field_county_id=form_basket.county_id&field_home_address=form_basket.address&field_id=form_basket.consumer_id&field_cons_name=form_basket.member_name&field_cons_surname=form_basket.member_surname&field_postcode=form_basket.postcod&func_LoadCity=1&func_LoadCounty=1<cfif is_ims_code eq 1>&field_ims_code_id=form_basket.ims_code_id&field_ims_code_name=form_basket.ims_code_name</cfif><cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&call_function=changeFunc()</cfoutput>');"></span>
						</div>			
					</div>
				</div>
				<div class="form-group" id="item-tc_num">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58025.TC Kimlik No'></label>
					<div class="col col-8 col-xs-12">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id ='58025.TC Kimlik No'></cfsavecontent>
						<cfinput type="text" name="tc_num" value="#member_tc_no#" maxlength="11" validate="integer" message="#message#" tabindex="10" onBlur="cons_pre_records();" onKeyUp="isNumber(this);">
					</div>
				</div>
				<div class="form-group" id="item-comp_name">
					<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58607.Firma'></label>
					<div class="col col-8 col-xs-12">
						<div class="input-group">
							<input name="comp_name" id="comp_name" type="text" value="<cfif len(company_name)><cfoutput>#company_name#</cfoutput></cfif>" tabindex="3" onblur="comp_pre_records();"  maxlength="75">
							<span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_tel=form_basket.tel_number&field_tel_code=form_basket.tel_code&field_ozel_kod=form_basket.ozel_kod&field_tax_no=form_basket.tax_num&field_tax_office=form_basket.tax_office&field_partner_surname=form_basket.member_surname&field_partner_name=form_basket.member_name&field_member_code=form_basket.member_code&field_country_id=form_basket.country&field_city_id=form_basket.selectedCity&field_county_id=form_basket.selectedCounty&field_county=form_basket.county&field_address=form_basket.address&field_partner=form_basket.partner_id&field_comp_id=form_basket.company_id&field_comp_name=form_basket.comp_name<cfif is_ims_code eq 1>&field_ims_code_id=form_basket.ims_code_id&field_ims_code_name=form_basket.ims_code_name</cfif><cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif>&call_function=changeFunc()</cfoutput>');"></span>
						</div>
					</div>
				</div>
				<div class="form-group" id="item-tax_office">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58762.Vergi D'>/<cf_get_lang dictionary_id='57752.Vergi No'></label>
					<div class="col col-4 col-xs-12">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='57752.Vergi No'></cfsavecontent>
						<cfinput type="text" name="tax_office" value="#member_tax_office#"  maxlength="30" tabindex="4">
					</div>
					<div class="col col-4 col-xs-12">
						<div class="input-group">
							<cfinput type="text" name="tax_num" tabindex="5" value="#member_tax_no#" maxlength="10" validate="integer" message="#message#" onKeyUp="isNumber(this);" onblur="tax_num_pre_records();">
							<span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_pars&field_tax_no=form_basket.tax_num&field_tax_office=form_basket.tax_office&field_vocation_id=form_basket.vocation_type&field_tc_identy_no=form_basket.tc_num&field_ozel_code=form_basket.ozel_kod&field_cons_code=form_basket.member_code&field_mobile_tel_code_2=form_basket.mobil_code_2&field_mobile_tel_2=form_basket.mobil_tel_2&field_mobile_tel=form_basket.mobil_tel&field_mobile_tel_code=form_basket.mobil_code&field_hometel=form_basket.tel_number&field_hometel_code=form_basket.tel_code&field_home_city_id=form_basket.city&field_home_county_id=form_basket.county_id&field_home_county=form_basket.county&field_home_address=form_basket.address&field_id=form_basket.consumer_id&field_cons_name=form_basket.member_name&field_cons_surname=form_basket.member_surname<cfif is_ims_code eq 1>&field_ims_code_id=form_basket.ims_code_id&field_ims_code_name=form_basket.ims_code_name</cfif><cfif session.ep.isBranchAuthorization>&is_store_module=1</cfif></cfoutput>');"></span>
						</div>
					</div>
				</div>
				<cfif is_dsp_category eq 1>
					<div class="form-group" id="item-company_cat">
						<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58609.Üye Kategorisi'></label>
						<div class="col col-8 col-xs-12" id="is_company" <cfif attributes.member_type neq 1> style="display:none;"</cfif> >
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
							<select name="comp_member_cat" id="comp_member_cat">
								<option value="" selected><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfoutput query="get_companycat">
									<option value="#COMPANYCAT_ID#" <cfif attributes.comp_member_cat is '#COMPANYCAT_ID#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#COMPANYCAT#</option>
								</cfoutput>
							</select>
						</div>
						<div class="col col-8 col-xs-12" id="is_consumer">
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
							<select name="cons_member_cat" id="cons_member_cat">
								<option value="" selected><cf_get_lang dictionary_id='57734.Seçiniz'></option>
								<cfoutput query="get_consumer_cat">
									<option value="#CONSCAT_ID#" <cfif attributes.cons_member_cat is '#CONSCAT_ID#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#CONSCAT#</option>
								</cfoutput> 
							</select>
						</div>
					</div>
				</cfif>
				<div class="form-group" id="item-vocation_type">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='41195.Meslek Tipi'></label>
					<div class="col col-8 col-xs-12">
						<select name="vocation_type" id="vocation_type" tabindex="13">
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfoutput query="get_vocation_type">
								<option value="#vocation_type_id#" <cfif vocation_type_id eq member_vocation_type>selected</cfif>>#vocation_type#</option>
							</cfoutput>
						</select>
					</div>
				</div>
			</div>
			<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
				<div class="form-group" id="item-country">
					<label for="" class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58219.Ülke'></label>
					<div class="col col-9 col-xs-12">
						<select name="country" id="country" tabindex="19" onchange="LoadCity(this.value,'city','county_id',0)"> 
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfoutput query="get_country">
								<option value="#get_country.country_id#" <cfif is_default eq 1> selected</cfif>>#get_country.country_name#</option>
							</cfoutput>
						</select>
					</div>
				</div>
				<div class="form-group" id="item-city">
					<label for="" class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58608.İl'></label>
					<div class="col col-9 col-xs-12">
						<input type="hidden" name="selectedCity" id="selectedCity">
						<select name="city" id="city" onchange="LoadCounty(this.value,'county_id')">
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfoutput query="get_city">
								<option value="#city_id#" <cfif len(member_city) and member_city eq city_id>selected</cfif>>#city_name#</option>
							</cfoutput>
						</select>
					</div>
				</div>
				<div class="form-group" id="item-county">
					<label for="" class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58638.İlçe'></label>
					<div class="col col-9 col-xs-12">
						<cfif len(member_county)>
							<cfquery name="get_county_name" datasource="#dsn#">
								SELECT COUNTY_NAME	FROM SETUP_COUNTY WHERE COUNTY_ID=#member_county#
							</cfquery>
						</cfif>
							<input type="hidden" name="selectedCounty" id="selectedCounty">
							<select name="county_id" id="county_id" >
								<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>						
								<cfif isdefined('attributes.city') and len(attributes.city)>
									<cfquery name="GET_COUNTY" datasource="#DSN#">
										SELECT COUNTY_ID,COUNTY_NAME FROM SETUP_COUNTY WHERE CITY = #attributes.city# 
									</cfquery>
									<cfoutput query="get_county">
										<option value="#county_id#" <cfif len(member_county) and member_county eq county_id>selected</cfif>>#county_name#</option>
									</cfoutput>
								</cfif>
							</select>
					</div>
				</div>
				<div class="form-group" id="item-postcod">
					<label for="" class="col col-3 col-xs-12"><cf_get_lang dictionary_id='57472.Posta Kodu'></label>
					<div class="col col-9 col-xs-12">
							<input type="text" name="postcod" id="postcod" value="" maxlength="15">
					</div>
				</div>
				<div class="form-group" id="item-adress">
					<label for="" class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58723.Adres'></label>
					<div class="col col-9 col-xs-12">
						<input type="hidden" name="adres_type" id="adres_type" value="1">
						<div class="input-group">
							<textarea name="address" id="address" rows="2" tabindex="7"><cfif len(member_adres)><cfoutput>#member_adres#</cfoutput></cfif></textarea>
							<span class="input-group-addon icon-ellipsis btnPointer"  onclick="add_adresses();"></span>
						</div>
					</div>
				</div>
			</div>
			<div class="col col-4 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
				<div class="form-group" id="item-mail">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='33152.Email'></label>
					<div class="col col-8 col-xs-12">
							<cfsavecontent variable="message"><cf_get_lang dictionary_id='57477.hatalı veri'>:<cf_get_lang dictionary_id='57428.E-mail'></cfsavecontent>
							<cfinput type="text" name="email" id="email" validate="email" message="#message#" maxlength="100" value="">
					</div>
				</div>
				<div class="form-group" id="item-mobile_number">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58473.Mobil'></label>
					<div class="col col-4 col-xs-12">
						<input name="mobil_code" id="mobil_code" type="text" maxlength="7" onKeyUp="isNumber(this);"/>
						<!---
						<select name="mobil_code" id="mobil_code" tabindex="11">
							<option value=""><cf_get_lang dictionary_id='322.Seçiniz'></option>
							<cfoutput query="get_mobilcat">
								<option value="#mobilcat#">#mobilcat#</option>
							</cfoutput>
						</select>
						--->			
					</div>
					<div class="col col-4 col-xs-12">
						<cfinput name="mobil_tel" tabindex="12" maxlength="7" type="text" validate="integer" onKeyUp="isNumber(this);">
					</div>
				</div>
				<div class="form-group" id="item-tel_number">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57499.Telefon'></label>
					<div class="col col-4 col-xs-12">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id ='41193.Telefon Kodu'> !</cfsavecontent>
						<cfinput type="text" name="tel_code" value="#member_tel_cod#"  maxlength="5" validate="integer" message="#message#" tabindex="8" onKeyUp="isNumber(this);">
					</div>
					<div class="col col-4 col-xs-12">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id ='41194.Telefon Numarası'>!</cfsavecontent>
						<cfinput type="text"  name="tel_number" value="#member_tel#" maxlength="10"  validate="integer" message="#message#" tabindex="9" onKeyUp="isNumber(this);">
					</div>
				</div>
				<div class="form-group" id="item-ref_no">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57558.Üye No'>/<cf_get_lang dictionary_id ='57789.Özel Kod'></label>
					<div class="col col-4 col-xs-12">
						<input name="member_code" id="member_code" value="<cfif len(member_code)><cfoutput>#member_code#</cfoutput></cfif>" tabindex="17" type="text" size="10">
					</div>
					<div class="col col-4 col-xs-12">
						<input name="ozel_kod" id="ozel_kod" value="<cfif len(member_ozel_code)><cfoutput>#member_ozel_code#</cfoutput></cfif>" tabindex="18" type="text" size="10">
					</div>
				</div>
				<div class="form-group" id="item-member_code">
					<label for="" class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58794.Referans No'></label>
					<div class="col col-8 col-xs-12"><input type="text" name="ref_no" id="ref_no" value="" maxlength="50"></div>
				</div>
				<div class="form-group" id="add_member_button">
					<label class="col col-2 col-xs-6"><input name="member_type" id="member_type" type="radio" value="1"  onclick="kontrol_member_cat(1);" <cfif attributes.member_type eq 1>checked</cfif>><cf_get_lang dictionary_id='41198.Kurumsal'></label>
					<label class="col col-2 col-xs-6"><input name="member_type" id="member_type" type="radio" value="2" onclick="kontrol_member_cat(2);" <cfif attributes.member_type eq 2>checked</cfif>><cf_get_lang dictionary_id='41200.Bireysel'></label>
				</div>
			</div>
		</cf_box_elements>
		<cf_box_footer>
			<cf_workcube_buttons is_upd='0' is_cancel='0' insert_info='#getLang('','Üye Kaydet',41201)#' add_function='kontrol_member()'>	
		</cf_box_footer>
<script>

	function changeFunc(){
		val = $("select#country").val();
		LoadCity(val,'city','county_id',0);
		selectedCity = $("input#selectedCity").val();
		$("select#city").val(selectedCity);
		LoadCounty(selectedCity,'county_id');
		selectedCounty = $("input#selectedCounty").val();
		$("select#county_id").val(selectedCounty);
	}

</script>