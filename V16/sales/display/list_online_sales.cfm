<cf_get_lang_set module_name="sales"><!--- sayfanin en altinda kapanisi var --->
	<cfparam name="attributes.keyword" default="">
	<cfparam name="attributes.startdate" default="#now()#">
	<cfparam name="attributes.finishdate" default="#dateadd('d',1,now())#">
	<cfparam name="attributes.status" default="">
	<cfif isdefined("attributes.is_submitted")>
		<cfif len(attributes.startdate)><cf_date tarih="attributes.startdate"></cfif>
		<cfif len(attributes.finishdate)><cf_date tarih="attributes.finishdate"></cfif>
		<cfquery name="GET_ONLINE_SALES_ALL" datasource="#DSN3#">
			SELECT
				*
			FROM
			(
			SELECT
				OPR.ORDER_ROW_ID,
				OPR.PRODUCT_ID,
				OPR.STOCK_ID,
				OPR.TAX,
				CP.COMPANY_PARTNER_NAME AS UYE_ADI,
				CP.COMPANY_PARTNER_SURNAME AS UYE_SOYADI,
				C.NICKNAME AS SIRKET,
				'P' + CAST(CP.PARTNER_ID AS CHAR(6)) AS TYPE,
				0 AS TIP,
				C.COMPANY_ID AS MEMBER_COMPANY_ID,
				CP.PARTNER_ID AS MEMBER_ID,
				OPR.RECORD_DATE,
				OPR.PRODUCT_NAME,
				OPR.QUANTITY,
				OPR.PRICE,
				OPR.PRICE_KDV,
				OPR.PRICE_MONEY,
				OPR.PROM_STOCK_AMOUNT,
				OP.ASSET_ID,
				OP.IBAN_NO,
				OP.DOMAIN_NAME,
				ISNULL(OP.STATUS,1) AS STATUS,
				OP.RECORD_DATE AS PRE_RECORD_DATE,
				ORDER_PRE_ID
			FROM
				ORDER_PRE_ROWS OPR
				LEFT JOIN ORDER_PRE OP ON OPR.RECORD_PAR = OP.RECORD_PAR,
				#dsn_alias#.COMPANY C,
				#dsn_alias#.COMPANY_PARTNER CP
			WHERE
				C.COMPANY_ID = CP.COMPANY_ID AND
				CP.PARTNER_ID = OPR.RECORD_PAR AND
				<cfif len(attributes.keyword)>OPR.PRODUCT_NAME LIKE '%#attributes.keyword#%' AND</cfif>
				OPR.RECORD_DATE >= #attributes.startdate# AND
				OPR.RECORD_DATE <= #attributes.finishdate#
				<cfif isdefined("attributes.member_name") and len(attributes.member_name) and attributes.member_type is 'partner' and len(attributes.company_id)>
					AND C.COMPANY_ID = #attributes.company_id#
				<cfelseif isdefined("attributes.member_name") and len(attributes.member_name) and attributes.member_type is 'consumer' and len(attributes.consumer_id)>
					AND C.COMPANY_ID < 0
				</cfif>
				<cfif isdefined("attributes.status") and len(attributes.status)>
					AND ISNULL(OP.STATUS,1) = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.status#">
				</cfif>
			UNION ALL
			SELECT
				OPR.ORDER_ROW_ID,
				OPR.PRODUCT_ID,
				OPR.STOCK_ID,
				OPR.TAX,
				C.CONSUMER_NAME AS UYE_ADI,
				C.CONSUMER_SURNAME AS UYE_SOYADI,
				C.COMPANY AS SIRKET,
				'C' + CAST(C.CONSUMER_ID AS CHAR(6)) AS TYPE,
				1 AS TIP,
				0 AS MEMBER_COMPANY_ID,
				C.CONSUMER_ID AS MEMBER_ID,
				OPR.RECORD_DATE,
				OPR.PRODUCT_NAME,
				OPR.QUANTITY,
				OPR.PRICE,
				OPR.PRICE_KDV,
				OPR.PRICE_MONEY,
				OPR.PROM_STOCK_AMOUNT,
				OP.ASSET_ID,
				OP.IBAN_NO,
				OP.DOMAIN_NAME,
				ISNULL(OP.STATUS,1) AS STATUS,
				OP.RECORD_DATE AS PRE_RECORD_DATE,
				ORDER_PRE_ID
			FROM
				ORDER_PRE_ROWS OPR
				LEFT JOIN ORDER_PRE OP ON OPR.RECORD_CONS = OP.RECORD_CONS,
				#dsn_alias#.CONSUMER C
			WHERE
				C.CONSUMER_ID = OPR.RECORD_CONS	AND
				<cfif len(attributes.keyword)>OPR.PRODUCT_NAME LIKE '%#attributes.keyword#%' AND</cfif>
				OPR.RECORD_DATE >= #attributes.startdate# AND
				OPR.RECORD_DATE <= #attributes.finishdate#
				<cfif isdefined("attributes.member_name") and len(attributes.member_name) and attributes.member_type is 'partner' and len(attributes.company_id)>
					AND C.CONSUMER_ID < 0
				<cfelseif isdefined("attributes.member_name") and len(attributes.member_name) and attributes.member_type is 'consumer' and len(attributes.consumer_id)>
					AND C.CONSUMER_ID = #attributes.consumer_id#
				</cfif>
				<cfif isdefined("attributes.status") and len(attributes.status)>
					AND ISNULL(OP.STATUS,1) = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.status#">
				</cfif>
			UNION ALL
			SELECT
				OPR.ORDER_ROW_ID,
				OPR.PRODUCT_ID,
				OPR.STOCK_ID,
				OPR.TAX,
				'Ziyaretçi' UYE_ADI,
				'' AS UYE_SOYADI,
				OPR.RECORD_IP AS SIRKET,
				'Z' + OPR.RECORD_IP AS TYPE,
				2 AS TIP,
				0 AS MEMBER_COMPANY_ID,
				0 AS MEMBER_ID,
				OPR.RECORD_DATE,
				OPR.PRODUCT_NAME,
				OPR.QUANTITY,
				OPR.PRICE,
				OPR.PRICE_KDV,
				OPR.PRICE_MONEY,
				OPR.PROM_STOCK_AMOUNT,
				'' AS ASSET_ID,
				'' AS IBAN_NO,
				'' AS DOMAIN_NAME,
				1 AS STATUS,
				'' AS PRE_RECORD_DATE,
				'' AS ORDER_PRE_ID
			FROM
				ORDER_PRE_ROWS OPR
			WHERE
				OPR.RECORD_GUEST = 1 AND
				<cfif len(attributes.keyword)>OPR.PRODUCT_NAME LIKE '%#attributes.keyword#%' AND</cfif>
				OPR.RECORD_DATE >= #attributes.startdate# AND
				OPR.RECORD_DATE <= #attributes.finishdate#
				<cfif isdefined("attributes.member_name") and len(attributes.member_name) and attributes.member_type is 'partner' and len(attributes.company_id)>
					AND OPR.RECORD_PAR IS NULL
				<cfelseif isdefined("attributes.member_name") and len(attributes.member_name) and attributes.member_type is 'consumer' and len(attributes.consumer_id)>
					AND OPR.RECORD_CONS IS NULL
				</cfif>
			)T1
			ORDER BY
				RECORD_DATE DESC
		</cfquery>
		<cfquery name="GET_ONLINE_SALES_TYPES" dbtype="query">
			SELECT DISTINCT
				TYPE,
				UYE_ADI,
				UYE_SOYADI,
				SIRKET,
				TIP,
				MEMBER_COMPANY_ID,
				MEMBER_ID,
				PRE_RECORD_DATE,
				ASSET_ID,
				IBAN_NO,
				DOMAIN_NAME,
				STATUS,
				ORDER_PRE_ID
			FROM
				GET_ONLINE_SALES_ALL
			ORDER BY
				TIP
		</cfquery>
	<cfelse>
		<cfset get_online_sales_types.recordcount = 0>
	</cfif>
	<cfscript>
		url_str = "keyword=#attributes.keyword#";
	</cfscript>
	<cfparam name="attributes.page" default="1">
	<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
	<cfparam name="attributes.totalrecords" default="#get_online_sales_types.recordcount#">
	<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >
	<cfquery name="GET_MONEY" datasource="#DSN#">
		SELECT
			COMPANY_ID,
			PERIOD_ID,
			MONEY,
			RATE1,
			RATE2,
			RATEPP2,
			RATEWW2
		FROM
			SETUP_MONEY
		WHERE
			PERIOD_ID = #session.ep.period_id#
	</cfquery>
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
		<cf_box>
			<cfform name="order_form" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_online_sales">
				<input name="is_submitted" id="is_submitted" value="1" type="hidden">
				<cf_box_search more="0">
					<div class="form-group">
						<input type="text" name="keyword" id="keyword" placeholder="<cfoutput>#getLang('','Filtre',57460)#</cfoutput>" value="">
					</div>
					<div class="form-group">
						<div class="input-group">
							<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
							<input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
							<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
							<input name="member_name" type="text" id="member_name" value="<cfif isdefined("attributes.member_name")><cfoutput>#attributes.member_name#</cfoutput></cfif>" placeholder="<cfoutput>#getLang('','Müşteri',57457)#</cfoutput>">	
							<cfset str_linke_ait="field_consumer=order_form.consumer_id&field_comp_id=order_form.company_id&field_comp_name=order_form.member_name&field_name=order_form.member_name&field_type=order_form.member_type">					 
							<span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&is_period_kontrol=0<cfoutput>#str_linke_ait#</cfoutput>&select_list=7,8');return false"></span>
						</div>
					</div>
					<div class="form-group">
						<div class="input-group">
							<cfinput required="Yes" validate="#validate_style#" maxlength="10" message="#getLang('','Başlama Tarihi Girmelisiniz',58745)#" type="text" name="startdate" value="#dateformat(attributes.startdate,dateformat_style)#">
							<span class="input-group-addon"><cf_wrk_date_image date_field="startdate"></span>
						</div>
					</div>
					<div class="form-group">
						<div class="input-group">	
							<cfinput required="yes" validate="#validate_style#" maxlength="10" message="#getLang('','Bitiş Tarihi Girmelisiniz',57739)#" type="text" name="finishdate" value="#dateformat(attributes.finishdate,dateformat_style)#">
							<span class="input-group-addon"><cf_wrk_date_image date_field="finishdate"></span>
						</div>
					</div>
					<div class="form-group small">
						<select name="status" id="status">
							<option value="">Status</option>
							<option value="1" <cfif attributes.status eq 1 > selected </cfif>><cf_get_lang dictionary_id='48405.Alışveriş Devam Ediyor'></option>
							<option value="2" <cfif attributes.status eq 2 > selected </cfif>><cf_get_lang dictionary_id='53544.Havale Kontrol'></option>
							<option value="3" <cfif attributes.status eq 3 > selected </cfif>><cf_get_lang dictionary_id='33122.Satış Uzmanı ile Görüşülecek'></option>
							<option value="4" <cfif attributes.status eq 4 > selected </cfif>><cf_get_lang dictionary_id='51060.Siparişe Dönüşenler'></option>
						</select>
					</div>
					<div class="form-group small">
						<input type="text" name="maxrows" value="<cfoutput>#attributes.maxrows#</cfoutput>" onKeyUp="isNumber(this)" required="yes" validate="integer" range="1,999" message="<cfoutput>#getLang('','Kayıt Sayısı Hatalı',57537)#</cfoutput>" maxlength="3">
					</div>
					<div class="form-group">
						<cf_wrk_search_button button_type="4">
					</div>	
					<div class="form-group">
						<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
					</div> 
				</cf_box_search>
			</cfform>
		</cf_box>
		<cf_box title="#getLang(384,'Online Satışlar',48330)#" uidrop="1" hide_table_column="1">
			<cf_grid_list>
				<thead>
					<tr>
						<th><cf_get_lang dictionary_id ='58577.Sıra'></th>
						<th><cf_get_lang dictionary_id ='57892.Domain'></th>
						<th><cf_get_lang dictionary_id ='30631.Tarih'></th>
						<th><cf_get_lang dictionary_id ='57574.Şirket'></th>
						<th><cf_get_lang dictionary_id ='57578.Yetkili'></th>
						<th class="text-center">W</th>
						<th class="text-center">M</th>
						<th class="text-center">P</th>
						<th><cf_get_lang dictionary_id='58777.Ürün Miktarı'></th>
						<th class="text-center">B</th>
						<th><cf_get_lang dictionary_id ='41209.Sepet Tutarı'></th>
						<th class="form-title" nowrap><cf_get_lang dictionary_id ='57489.Para Br'></th>
						<th><cf_get_lang dictionary_id ='32736.Havale'>-IBAN</th>
						<th class="text-center">D</th>
						<th class="text-center">B</th>
						<th><cf_get_lang dictionary_id ='57756.Durum'></th>
						<th></th>					
					</tr>
				</thead>
				<tbody>
					<cfif get_online_sales_types.recordcount>
						<cfoutput query="get_online_sales_types" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
							<cfquery name="GET_ROWS_" dbtype="query">
								SELECT * FROM GET_ONLINE_SALES_ALL WHERE TYPE = '#TYPE#'
							</cfquery>
							<cfset total_ = 0>
							<cfset toplam_quantity = 0>
							<cfloop query="get_rows_">
								<cfquery name="GET_MONEY_RATE2" dbtype="query">
									SELECT
										RATE2
									FROM
										GET_MONEY
									WHERE
										MONEY = '#PRICE_MONEY#'
								</cfquery>
								<cfset total_ = total_ + (PRICE * QUANTITY * PROM_STOCK_AMOUNT * GET_MONEY_RATE2.RATE2)>
								<cfset toplam_quantity = toplam_quantity +quantity>
							</cfloop>
							<tr>
								<td>#currentrow#</td>
								<td>#DOMAIN_NAME#</td>
								<td>#dateformat(PRE_RECORD_DATE, dateformat_style)#</td>
								<td>
									<cfif tip eq 0>
										<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_com_det&company_id=#member_company_id#');" class="tableyazi">#sirket#</a>
									<cfelse>
										#sirket#
									</cfif>
								</td>
								<td>
									<cfif tip eq 0>
										<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_par_det&par_id=#member_id#','list');" class="tableyazi">#uye_adi# #uye_soyadi#</a>
									<cfelseif tip eq 1>
										<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_con_det&con_id=#member_id#','list');" class="tableyazi">#uye_adi# #uye_soyadi#</a>
									<cfelse>
										#uye_adi# #uye_soyadi#
									</cfif>
								</td>
								<td class="text-center"><span class="fa fa-whatsapp fa-1-5x text-primary"></span></td>
								<td class="text-center"><span class="fa fa-paper-plane fa-1-5x text-info"></td>
								<td class="text-center"><span class="fa fa-phone fa-1-5x text-warning"></td>
								<td>#toplam_quantity#</td>
								<td class="text-center"><a href="javascript://" onclick="gizle_goster(tr_#currentrow#);"><span class="fa fa-shopping-basket fa-1-5x text-end"></a></td>
								<td align="right" style="text-align:right;">#tlformat(total_)# </td>
								<td style="text-align:right;">&nbsp;#session.ep.money#</td>
								<td>#IBAN_NO#</td>
								<td class="text-center">
									<cfif len(asset_id)>
										<cfquery name="get_asset" datasource="#dsn#">
											SELECT ASSET_FILE_NAME, ASSETCAT_PATH, ASSET.ASSETCAT_ID FROM ASSET, ASSET_CAT WHERE ASSET.ASSETCAT_ID = ASSET_CAT.ASSETCAT_ID AND ASSET_ID = #asset_id#
										</cfquery>
										<cfif get_asset.assetcat_id gte 0>
											<cfset path_ = "asset/#get_asset.assetcat_path#">
										<cfelse>
											<cfset path_ = "#get_asset.assetcat_path#">
										</cfif>
										<cfset url_ = "#file_web_path#/#path_#/">
										<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_download_file&direct_show=1&file_name=#url_##get_asset.asset_file_name#&file_control=asset.form_upd_asset&asset_id=#asset_id#&assetcat_id=#get_asset.assetcat_id#','medium');return false;"><span class="fa fa-archive fa-1-5x"></span></a>
									</cfif>
								</td>
								<td class="text-center"><a href="#request.self#?fuseaction=bank.wodiba_bank_actions" target="_blank"><span class="fa fa-bank fa-1-5x"></a></td>
								<td>
									<cfif STATUS eq 1>
										<cf_get_lang dictionary_id='48405.Alışveriş Devam Ediyor'>
									<cfelseif STATUS eq 2>
										<cf_get_lang dictionary_id='53544.Havale Kontrol'>
									<cfelseif STATUS eq 3>
										<cf_get_lang dictionary_id='33122.Satış Uzmanı ile Görüşülecek'>
									<cfelseif STATUS eq 4>
										<cf_get_lang dictionary_id='51060.Siparişe Dönüşenler'>
									</cfif>
								</td>
								<td class="text-center">
									<cfif len(asset_id) and len(iban_no) and status eq 2>
										<a href="javascript://" onclick="addorder('#ORDER_PRE_ID#')"><span class="fa fa-bus fa-1-5x text-danger"></span></a>
									</cfif>
								</td>
							</tr>
							<tr id="tr_#currentrow#" style="display:none;" class="nohover">
								<td colspan="17">
									<!---<div id="UPD_ROW#currentrow#"></div>--->
								<cfform name="upd_online_sale#currentrow#" action="#request.self#?fuseaction=sales.emptypopup_upd_online_sales">
									<cf_grid_list>
										<thead>
											<tr>
												<th><cf_get_lang dictionary_id ='57657.Ürün'></th>
												<th align="center"><cf_get_lang dictionary_id ='57635.Miktar'></th>
												<th align="center"><cf_get_lang dictionary_id ='57673.Tutar'></th>
												<th align="center"><cf_get_lang dictionary_id ='41211.KDV li Tutar'></th>
												<th nowrap><cf_get_lang dictionary_id ='57489.Para Br'></th>
												<th><cf_get_lang dictionary_id ='41212.Eklenme Tarihi'></th>
											</tr>
										</thead>
										<tbody>
											<cfset order_list=''>
											<cfloop query="get_rows_">
											<cfset order_list=listappend(order_list,order_row_id)>
											</cfloop>
												<input type="hidden" name="crrntrow" id="crrntrow" value="#currentrow#" />
												<input type="hidden" name="recordcount#currentrow#" id="recordcount#currentrow#" value="#get_rows_.recordcount#" />
												<input type="hidden" name="order_list" id="order_list" value="#order_list#"/>
											<cfloop query="get_rows_">
												<tr>
													<td>
														#get_rows_.product_name#
													</td>
													<td><input type="hidden" name="tax#order_row_id#" id="tax#order_row_id#"  value="#get_rows_.tax#" />
														<input type="text" name="quantity#order_row_id#" id="quantity#order_row_id#"  class="moneybox" style="width:60px;border:none; color:black;" <cfif session.ep.admin eq 1>onkeyup="hesapla('#order_row_id#');" </cfif>value="#get_rows_.quantity#"<cfif session.ep.admin neq 1>readonly="yes"</cfif>/></td>
													<td><input type="hidden" name="kdv#order_row_id#" id="kdv#order_row_id#" value="#tlformat(get_rows_.price_kdv-get_rows_.price)#" />
														<input type="text" name="price#order_row_id#" id="price#order_row_id#" class="moneybox" style="width:90px;border:none; color:black;"  onkeyup="hesapla('#order_row_id#');" value="#tlformat(get_rows_.price)#"<cfif session.ep.admin neq 1>readonly="yes"</cfif>/></td>
													<td style="text-align:right;"><input type="text" name="price_kdv#order_row_id#" id="price_kdv#order_row_id#" class="moneybox" style="border:none; color:black;" value="#tlformat(get_rows_.price_kdv)#" readonly="yes"/></td>
													<td>&nbsp;#get_rows_.price_money#</td>
													<td>#dateformat(date_add('h',session.ep.time_zone,get_rows_.record_date),dateformat_style)# (#timeformat(date_add('h',session.ep.time_zone,get_rows_.record_date),timeformat_style)#)</td>
												</tr>
											</cfloop>
											<tr>
												<td colspan="6" style="text-align:right;">
													<cfif session.ep.admin eq 1>
														<input type="button" name="updte" id="updte" value="Güncelle" onclick="update_row('#currentrow#')" />
													</cfif>
												</td>
											</tr>
										</tbody>
									</cf_grid_list>
									<div id="SHOW_MESSAGE_#currentrow#"></div>
								</cfform>
						</cfoutput>
					<cfelse>
						<tr>
							<td colspan="6">
								<cfif isdefined("is_submitted")><cf_get_lang dictionary_id ='58486.Kayıt Bulunamadı'>!<cfelse><cf_get_lang dictionary_id ='57701.Filtre Ediniz!'>!</cfif>
							</td>
						</tr>
					</cfif>
				</tbody>
			</cf_grid_list>
			<cfif get_online_sales_types.recordcount and (attributes.totalrecords gte attributes.maxrows)>
				<cfif isdefined("attributes.company_id") and len(attributes.company_id) and len(attributes.member_name)>
					<cfset url_str = url_str & "&member_type=#attributes.member_type#">
					<cfset url_str = url_str & "&company_id=#attributes.company_id#">
					<cfset url_str = url_str & "&member_name=#attributes.member_name#">
				<cfelseif isdefined("attributes.consumer_id") and len(attributes.consumer_id) and len(attributes.member_name)>
					<cfset url_str = url_str & "&member_type=#attributes.member_type#">
					<cfset url_str = url_str & "&consumer_id=#attributes.consumer_id#">
					<cfset url_str = url_str & "&member_name=#attributes.member_name#">
				</cfif>
				<cf_paging page="#attributes.page#" page_type="2" maxrows="#attributes.maxrows#" totalrecords="#attributes.totalrecords#" startrow="#attributes.startrow#" adres="#listgetat(attributes.fuseaction,1,'.')#.list_online_sales&#url_str#&is_submitted=1&startdate=#dateformat(attributes.startdate,dateformat_style)#&finishdate=#dateformat(attributes.finishdate,dateformat_style)#">
			</cfif>
		</cf_box>
	</div>
	<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->
	<script type="text/javascript">
		document.getElementById('keyword').focus();
		function hesapla(orrid){
			st = filterNum(eval('document.getElementById("price'+orrid+'")').value); /* eval('document.getElementById("quantity'+orrid+'")').value;*/
			eval('document.getElementById("price_kdv'+orrid+'")').value = commaSplit(st + (st * (eval('document.getElementById("tax'+orrid+'")').value/100)));
		}
	
		function update_row(crntrow){
			 AjaxFormSubmit('upd_online_sale'+crntrow,'SHOW_MESSAGE_'+crntrow,'1','','','<cfoutput>#request.self#?fuseaction=sales.emptypopup_upd_online_sales&crrntrow='+crntrow+'</cfoutput>'/*,'tr_'+crntrow*/);
		}
	
		function addorder(pre_id){
			if( confirm("İlgili Satır Siparişe Dönüştürülecektir. Onaylıyor musunuz ?") ){
				var data = new FormData();
				data.append('order_pre_id', pre_id );
	
				AjaxControlPostDataJson('V16/sales/cfc/PreOrderAction.cfc?method=PreOrderAction',data,function(response) { 
					alert(response.MESSAGE);
					window.location.reload();
				});
			}
			
		}
	</script>
	