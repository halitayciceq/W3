<!---KDV RAPORU QUERSİ --->
<cfparam name="attributes.is_filtre" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfif  isdate(attributes.start_date)>
	<cf_date tarih = "attributes.start_date">
</cfif>
<cfif  isdate(attributes.finish_date)>
	<cf_date tarih = "attributes.finish_date">
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.company" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributres.partner_id" default="">
<cfparam name="attributes.employee_id" default="">
<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.is_acr" default="">
<cfparam name="attributes.is_kdv" default="">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfset genel_total_kdvsiz_nettotal = 0>
<cfset genel_total_kdv_toplam = 0>

 <cfif isdefined("attributes.form_varmi")>
    <cfquery name="get_kdv_report" datasource="#dsn2#">
		SELECT
			NO,
			CARI_ISIM,
			T1.ID,
			SUM(T1.TAXTOTAL_) KDV_TOPLAM,
			SUM(T1.NETTOTAL) KDVSIZ_NETTOTAL,
			(SUM(T1.TAXTOTAL_) * T1.TEVKIFAT_RATE) TEVKIFAT_AMOUNT_TOPLAM_BEYAN_EDILEN,
			T1.SERIAL_NUMBER,
			T1.SERIAL_NO,
            T1.INVOICE_NUMBER,
			T1.INVOICE_DATE,
			T1.PURCHASE_SALES,
			T1.INVOICE_CAT,
			T1.FULLNAME,
			T1.INVOICE_ID,
			T1.EXPENSE_ID
		FROM    
		(
			SELECT 
			 	I.INVOICE_ID ID,
				I.INVOICE_ID,
				'' EXPENSE_ID,
				IR.TAXTOTAL TAXTOTAL_,
				IR.NETTOTAL,
				ISNULL(I.TEVKIFAT_ORAN,0) AS TEVKIFAT_RATE,
				I.SERIAL_NUMBER,
				I.SERIAL_NO,
                I.INVOICE_NUMBER,
				I.INVOICE_DATE,
				I.PURCHASE_SALES,
				I.INVOICE_CAT,
				CM.FULLNAME,
				ISNULL(ISNULL(E.EMPLOYEE_NAME +' '+E.EMPLOYEE_SURNAME,C.CONSUMER_NAME +' '+C.CONSUMER_SURNAME),CP.COMPANY_PARTNER_NAME+' '+CP.COMPANY_PARTNER_SURNAME) CARI_ISIM,
			CASE
				WHEN I.PARTNER_ID<>'' AND CM.TAXNO<>'' THEN CM.TAXNO
				WHEN I.PARTNER_ID<>'' AND CM.IS_PERSON = 1 THEN CP.TC_IDENTITY
				WHEN I.CONSUMER_ID<>'' THEN C.TC_IDENTY_NO
				WHEN I.EMPLOYEE_ID<>'' THEN (SELECT  TC_IDENTY_NO FROM  #dsn_alias#.EMPLOYEES_IDENTY EI WHERE EI.EMPLOYEE_ID=E.EMPLOYEE_ID)
			END AS NO
			FROM 
				INVOICE I
				<cfif isdefined("attributes.is_acr") and (attributes.is_acr eq 1 OR attributes.is_acr eq 2 )>
					LEFT JOIN ACCOUNT_CARD AC ON I.INVOICE_CAT = AC.ACTION_TYPE AND ( I.INVOICE_ID = AC.ACTION_ID OR I.INVOICE_MULTI_ID = AC.ACTION_ID)
				</cfif>
				LEFT JOIN #dsn_alias#.EMPLOYEES E ON E.EMPLOYEE_ID=I.EMPLOYEE_ID
				LEFT JOIN #dsn_alias#.CONSUMER C ON C.CONSUMER_ID=I.CONSUMER_ID
				LEFT JOIN #dsn_alias#.COMPANY CM ON CM.COMPANY_ID=I.COMPANY_ID
				LEFT JOIN #dsn_alias#.COMPANY_PARTNER CP ON CP.PARTNER_ID=I.PARTNER_ID,
				INVOICE_ROW IR
			WHERE
				I.INVOICE_ID=IR.INVOICE_ID
				AND I.INVOICE_ID > 0
				AND I.PURCHASE_SALES = 0
				AND I.IS_IPTAL = 0 
				<cfif isDefined("attributes.is_kdv") and attributes.is_kdv neq 1>
				AND IR.TAX<>0 
				</cfif>
				<cfif len(attributes.is_filtre)>
					AND I.SERIAL_NO LIKE '%#attributes.is_filtre#%'
				</cfif>
                <cfif len(attributes.is_filtre)>
					AND I.INVOICE_NUMBER LIKE '%#attributes.is_filtre#%'
				</cfif>
				<cfif len(attributes.start_date)>
					AND I.INVOICE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
				</cfif>
				<cfif len(attributes.finish_date)>
					AND I.INVOICE_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finish_date#">
				</cfif>
				<cfif len(attributes.company) and len(attributes.consumer_id)>
					AND I.CONSUMER_ID=#attributes.consumer_id#
				<cfelseif len(attributes.company) and len(attributes.employee_id)>
					AND I.EMPLOYEE_ID=#attributes.employee_id#
				<cfelseif len(attributes.company) and len(attributes.partner_id)>
					AND I.PARTNER_ID=#attributes.partner_id#
				</cfif>
				<cfif attributes.is_acr eq 1>
					AND AC.CARD_TYPE IS NOT NULL
				<cfelseif attributes.is_acr eq 2>
					AND AC.CARD_TYPE IS NULL
				</cfif>
			UNION ALL
				SELECT 
				EI.EXPENSE_ID ID,
				'' INVOICE_ID,
				EI.EXPENSE_ID,
				AMOUNT_KDV TAXTOTAL_ ,
			    (AMOUNT*QUANTITY) NETTOTAL,
				ISNULL(EI.TEVKIFAT_ORAN,0) AS TEVKIFAT_RATE,
				EI.SERIAL_NUMBER,
                EI.SERIAL_NO INVOICE_NUMBER,
				EI.PAPER_NO SERIAL_NO,
				EI.EXPENSE_DATE,
				3 PURCHASE_SALES,
				EI.ACTION_TYPE INVOICE_CAT,
				CASE
					WHEN CM.FULLNAME<>'' THEN CM.FULLNAME
					ELSE EIPIP.PROPERTY1
				END AS FULLNAME,
				ISNULL(ISNULL(E.EMPLOYEE_NAME +' '+E.EMPLOYEE_SURNAME,C.CONSUMER_NAME +' '+C.CONSUMER_SURNAME),CP.COMPANY_PARTNER_NAME+' '+CP.COMPANY_PARTNER_SURNAME) CARI_ISIM,
				CASE
					WHEN EI.CH_PARTNER_ID<>'' AND CM.TAXNO<>'' THEN CM.TAXNO
					WHEN EI.CH_PARTNER_ID<>'' AND CM.IS_PERSON = 1 THEN CP.TC_IDENTITY
					WHEN EI.CH_CONSUMER_ID<>'' THEN C.TC_IDENTY_NO
					WHEN EI.CH_EMPLOYEE_ID<>'' THEN (SELECT  TC_IDENTY_NO FROM  #dsn_alias#.EMPLOYEES_IDENTY EI WHERE EI.EMPLOYEE_ID=E.EMPLOYEE_ID)
					ELSE EIPIP.PROPERTY2
				END AS NO
				FROM 
					EXPENSE_ITEMS_ROWS EIR,
					EXPENSE_ITEM_PLANS EI
					<cfif isdefined("attributes.is_acr") and ( attributes.is_acr eq 1 OR attributes.is_acr eq 2 )>
						LEFT JOIN ACCOUNT_CARD AC ON EI.ACTION_TYPE = AC.ACTION_TYPE AND EI.EXPENSE_ID = AC.ACTION_ID
					</cfif>
					LEFT JOIN #dsn_alias#.EMPLOYEES E ON E.EMPLOYEE_ID=EI.CH_EMPLOYEE_ID
					LEFT JOIN #dsn_alias#.CONSUMER C ON C.CONSUMER_ID=EI.CH_CONSUMER_ID
					LEFT JOIN #dsn_alias#.COMPANY_PARTNER CP ON CP.PARTNER_ID=EI.CH_PARTNER_ID
					LEFT JOIN #dsn_alias#.COMPANY CM ON CM.COMPANY_ID=EI.CH_COMPANY_ID
					LEFT JOIN EXPENSE_ITEM_PLANS_INFO_PLUS EIPIP ON EI.EXPENSE_ID=EIPIP.EXPENSE_ID
				WHERE 
					EIR.EXPENSE_ID=EI.EXPENSE_ID
					AND EI.ACTION_TYPE = 120
					AND EIR.KDV_RATE<>0
					<cfif len(attributes.is_filtre)>
						AND EI.SERIAL_NO LIKE '%#attributes.is_filtre#%'
					</cfif>
					<cfif len(attributes.start_date)>
						AND EI.EXPENSE_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.start_date#">
					</cfif>
					<cfif len(attributes.finish_date)>
						AND EI.EXPENSE_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.finish_date#">
					</cfif>
					<cfif len(attributes.company) and len(attributes.consumer_id)>
						AND EI.CH_CONSUMER_ID=#attributes.consumer_id#
					<cfelseif len(attributes.company) and len(attributes.employee_id)>
						AND EI.CH_EMPLOYEE_ID=#attributes.employee_id#
					<cfelseif len(attributes.company) and len(attributes.partner_id)>
						AND EI.CH_PARTNER_ID=#attributes.partner_id#
					</cfif>
					<cfif attributes.is_acr eq 1>
						AND AC.CARD_TYPE IS NOT NULL
					</cfif>
					<cfif attributes.is_acr eq 2>
						AND AC.CARD_TYPE IS NULL
					</cfif>
		)T1
		<!---
		LEFT JOIN INVOICE I_OUT ON T1.INVOICE_ID = I_OUT.INVOICE_ID
		LEFT JOIN EXPENSE_ITEM_PLANS EI_OUT ON T1.EXPENSE_ID = EI_OUT.EXPENSE_ID
		--->
		GROUP BY
			ID,
            INVOICE_NUMBER,
			SERIAL_NUMBER,
			SERIAL_NO,
			INVOICE_DATE,
			NO,
			INVOICE_CAT,
			CARI_ISIM,
			FULLNAME,
			PURCHASE_SALES,
			INVOICE_ID,
			EXPENSE_ID,
			TEVKIFAT_RATE
		HAVING
			SUM(T1.TAXTOTAL_)>0
	</cfquery>

	<cfoutput query="get_kdv_report">
		<cfset genel_total_kdvsiz_nettotal += kdvsiz_nettotal>
		<cfset genel_total_kdv_toplam += kdv_toplam>
	</cfoutput>
	<cfif get_kdv_report.recordcount>
	<cfquery name="get_row_product" datasource="#dsn2#">
		SELECT 
			INVOICE_ID,
			'DGR' CATEGORY,
			INVOICE_ROW.NAME_PRODUCT AS DETAIL
	   FROM 
			INVOICE_ROW,
			#dsn1_alias#.PRODUCT
		 WHERE 
		 	INVOICE_ROW.PRODUCT_ID=PRODUCT.PRODUCT_ID AND
			INVOICE_ROW.TAX<>0  AND
			PRODUCT.IS_INVENTORY=0
		GROUP BY 
			INVOICE_ID,
			INVOICE_ROW.NAME_PRODUCT
	  UNION ALL
		SELECT 
			INVOICE_ROW.INVOICE_ID,
			PRODUCT_CAT.PRODUCT_CAT CATEGORY,
			INVOICE_ROW.NAME_PRODUCT AS DETAIL
		FROM 
			INVOICE_ROW,
			#dsn1_alias#.PRODUCT,
			#dsn1_alias#.PRODUCT_CAT
		WHERE 
			PRODUCT.PRODUCT_CATID=PRODUCT_CAT.PRODUCT_CATID AND
			INVOICE_ROW.PRODUCT_ID=PRODUCT.PRODUCT_ID
			<cfif isDefined("attributes.is_kdv") and attributes.is_kdv neq 1>
			AND INVOICE_ROW.TAX<>0 
			</cfif>
			AND PRODUCT.IS_INVENTORY=1
		GROUP BY 
			INVOICE_ID,
			PRODUCT_CAT.PRODUCT_CAT,
			INVOICE_ROW.NAME_PRODUCT
	  UNION ALL
	  	SELECT 
			INVOICE_ROW.INVOICE_ID,
			SETUP_INVENTORY_CAT.INVENTORY_CAT CATEGORY,
			INVOICE_ROW.NAME_PRODUCT AS DETAIL
		FROM 
			INVOICE_ROW,
			#dsn3#.INVENTORY,
			#dsn3#.SETUP_INVENTORY_CAT
		WHERE 
			INVENTORY.INVENTORY_ID = INVOICE_ROW.INVENTORY_ID AND
			INVENTORY.INVENTORY_CATID = SETUP_INVENTORY_CAT.INVENTORY_CAT_ID 
			<cfif isDefined("attributes.is_kdv") and attributes.is_kdv neq 1>
			AND INVOICE_ROW.TAX<>0
			</cfif>
		GROUP BY 
			INVOICE_ID,
			SETUP_INVENTORY_CAT.INVENTORY_CAT,
			INVOICE_ROW.NAME_PRODUCT
	</cfquery>
	<cfquery name="get_cost" datasource="#dsn2#">
		 	SELECT
				EXPENSE_ID,
				EXPENSE_ITEMS.EXPENSE_ITEM_NAME CATEGORY,
				EXPENSE_ITEMS_ROWS.DETAIL AS DETAIL
			FROM
				EXPENSE_ITEMS_ROWS,
				EXPENSE_ITEMS
			WHERE
				EXPENSE_ITEMS_ROWS.EXPENSE_ITEM_ID = EXPENSE_ITEMS.EXPENSE_ITEM_ID AND
				EXPENSE_ITEMS_ROWS.KDV_RATE<>0
			GROUP BY 
				EXPENSE_ID,
				EXPENSE_ITEMS.EXPENSE_ITEM_NAME,
				EXPENSE_ITEMS_ROWS.DETAIL
	</cfquery>
	<cfquery name="get_top_amount" datasource="#dsn2#">
		SELECT 
			INVOICE_ID,
			cast (SUM(AMOUNT) as nvarchar) +' '+UNIT top_miktar
		FROM 
			INVOICE_ROW 
		WHERE 
			INVOICE_ID IN (#listdeleteduplicates(valuelist(get_kdv_report.invoice_id))#) 
			<cfif isDefined("attributes.is_kdv") and attributes.is_kdv neq 1>
			AND INVOICE_ROW.TAX<>0
			</cfif>
		GROUP BY INVOICE_ID,UNIT
	</cfquery>
	<cfquery name="get_top_amount_cost" datasource="#dsn2#">
		SELECT 
			EXPENSE_ID,
			--cast (SUM(QUANTITY) AS nvarchar)+' '+UNIT top_miktar
			cast (SUM(QUANTITY) AS nvarchar) +' Adet' top_miktar
		FROM
			EXPENSE_ITEMS_ROWS
		WHERE
			EXPENSE_ID IN (#listdeleteduplicates(valuelist(get_kdv_report.expense_id))#) 
			<cfif isDefined("attributes.is_kdv") and attributes.is_kdv neq 1>
			AND EXPENSE_ITEMS_ROWS.KDV_RATE<>0
			</cfif>
	    GROUP BY EXPENSE_ID,UNIT
	</cfquery>
	
	</cfif>
 </cfif>
 <cfif isdefined("attributes.form_varmi")>
	<cfparam name="attributes.totalrecords" default="#get_kdv_report.recordcount#">
<cfelse>
	<cfparam name="attributes.totalrecords" default="0">
</cfif>
 <table width="98%" cellspacing="0" cellpadding="0" border="0" align="center">
    <tr>
        <td  valign="top">
			<cfform name="get_bill" action="#request.self#?fuseaction=#url.fuseaction#&event=det&report_id=#attributes.report_id#">
                <!-- sil -->		
                <table  width="100%" border="0" cellpadding="2" cellspacing="1" align="center" class="color-border">
                    <input name="form_varmi" id="form_varmi" value="1" type="hidden">
                    <cfoutput>
                    <tr class="color-row">
                        <td>
                            <table>
                                <tr style="text-align:left">
                                	<td>Filtre</td>
                                    <td><input type="text" name="is_filtre" id="is_filtre" style="width:100px" value="<cfif len(attributes.is_filtre)>#attributes.is_filtre#</cfif>"></td>
                                    <td nowrap="nowrap"><cf_get_lang_main no ='641.Başlangıç Tarihi'></td>
                                    <td nowrap="nowrap"><cfinput type="text" name="start_date" id="start_date"  value="#dateformat(attributes.start_date,'dd/mm/yyyy')#" style="width:65px;" validate="eurodate" maxlength="10"><cf_wrk_date_image date_field="start_date"></td>
                                    <td nowrap="nowrap"><cf_get_lang_main no ='288.Bitiş Tarihi'></td>
                                    <td nowrap="nowrap"><cfinput type="text" name="finish_date" id="finish_date"  value="#dateformat(attributes.finish_date,'dd/mm/yyyy')#" style="width:65px;" validate="eurodate" maxlength="10"><cf_wrk_date_image date_field="finish_date"></td>
                                    <td><cf_get_lang_main no ='107.Cari Hesap'></td>
                                    <td>
                                        <input type="hidden" name="consumer_id" id="consumer_id"  value="<cfif  len(attributes.company)>#attributes.consumer_id#</cfif>">
                                        <input type="hidden" name="company_id" id="company_id"  value="<cfif len(attributes.company)>#attributes.company_id#</cfif>">
                                        <input type="hidden" name="partner_id"  id="partner_id"  value="<cfif  len(attributes.company)>#attributes.partner_id#</cfif>">
                                        <input type="hidden" name="employee_id" id="employee_id"  value="<cfif len(attributes.company)>#attributes.employee_id#</cfif>">
                                        <input type="text" name="company"  id="company" style="width:100px;" onFocus="AutoComplete_Create('company','MEMBER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_CODE,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2,3\',\'0\',\'0\',\'0\',\'2\',\'0\',\'0\',\'1\'','COMPANY_ID,CONSUMER_ID,EMPLOYEE_ID,PARTNER_ID','company_id,consumer_id,employee_id,partner_id','form','3','250');" value="<cfif len(attributes.company)>#attributes.company#</cfif>" autocomplete="off">
                                        <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_list_pars&is_cari_action=1&field_comp_name=get_bill.company&field_comp_id=get_bill.company_id&field_partner=get_bill.partner_id&field_consumer=get_bill.consumer_id&field_member_name=get_bill.company&field_emp_id=get_bill.employee_id&field_name=get_bill.company&select_list=2,3,1,9','list')"><img src="/images/plus_thin.gif" title="<cf_get_lang_main no='322.seçiniz'>" border="0" align="absbottom"></a>
                                    </td>
                           			<td><cfsavecontent variable="message"><cf_get_lang_main no='125.Sayi_Hatasi_Mesaj'></cfsavecontent>
                                        <cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#" style="width:25px;">
                                    </td>
									<td>
										<select name="is_acr" id="is_acr">
											<option value="">Tümünü Getir</option>
											<option value="1" <cfif attributes.is_acr eq 1> selected </cfif> >Muhasebe Hareketi Olmayanları Getirme</option>
											<option value="2" <cfif attributes.is_acr eq 2> selected </cfif>>Muhasebe Hareketi Olmayanları Getir</option>
										</select>
									<input type="checkbox" name="is_kdv" id="is_kdv" value="1" <cfif attributes.is_kdv eq 1>checked</cfif>>KDV Oranı 0 ve tutarı olanları getir</td>
                                    <td><input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>><cf_get_lang_main no='446.Excel Getir'></td>
                                    <td style="text-align:left" colspan="2"><cf_wrk_search_button button_type="4" search_function="input_control()"></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    </cfoutput>
				</table>
                <!-- sil -->
            </cfform>
        </td>
    <tr>
    <tr><td style="height:20px"></td></tr>
	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
		<cfset filename= "#dateformat(now(),'ddmmyyyy')##timeformat(now(),'hhmm')#">
        <cfheader name="Expires" value="#Now()#">
        <cfcontent type="application/vnd.msexcel;charset=utf-8">
        <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <cfset attributes.startrow=1>
        <cfset attributes.maxrows =attributes.totalrecords>
    </cfif>
	<tr> 
        <td  align="left">
            <table  border="0" cellpadding="2" width="100%" cellspacing="1" class="color-border">
                <tr class="color-header">
                	<td class="form-title"><cf_get_lang dictionary_id='58577.Sira'> <cf_get_lang dictionary_id='57487.no'></td>
                    <td class="form-title"><cf_get_lang dictionary_id='58759.Fatura Tarihi'></td>
                    <!--- <td class="form-title"><cf_get_lang dictionary_id='29412.Seri'></td> --->
                    <td class="form-title"><cf_get_lang dictionary_id='58133.Fatura No'></td>
                    <td class="form-title"><cf_get_lang dictionary_id='58873.Satıcı'> <cf_get_lang dictionary_id='59416.Ad Soyad /Ünvan'></td>
                    <td class="form-title"><cf_get_lang dictionary_id='58873.Satıcı'> <cf_get_lang dictionary_id='32325.TC/Vergi No'></td>
                    <td class="form-title"><cf_get_lang dictionary_id='63138.Alınan Mal ve Hizmetler'> <cf_get_lang dictionary_id='48140.Cinsi'></td>
                    <td class="form-title"><cf_get_lang dictionary_id='63138.Alınan Mal ve Hizmetler'> <cf_get_lang dictionary_id='63411.Miktarı'></td>
                    <td class="form-title">Alınan Mal ve/veya Hizmetin KDV Hariç Tutarı</td>
                    <td class="form-title">KDV'si</td>
                    <td class="form-title">2 No'lu Beyannamede Ödenen KDV Tutarı</td>
                    <td class="form-title">Tevkifata Dahil Olmayan ve Bu Dönemde İndirilecek KDV</td>
                    <td class="form-title">Toplam İndirilecek KDV Tutarı</td>
                    <td class="form-title">GGB Tescil No'su (Alış İthalat İse)</td>
                    <td class="form-title">Belgenin İndirim Hakkının Kullanıldığı KDV Dönemi</td>
                    <td class="form-title">İhracatına Aracılık Edilen Firmanın Vergi Kimlik Numarası/TC Kimlik Numarası</td>
				</tr>
				<cfif isdefined("attributes.form_varmi") and get_kdv_report.recordcount>
					<cfset total_kdvsiz_nettotal = 0>
					<cfset total_kdv_toplam = 0>
                    <cfoutput query="get_kdv_report" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <tr class="color-row">
                        	<td>#currentrow#</td>
                            <td>#dateformat(invoice_date,'dd/mm/yyyy')#</td>
                            <!--- <td>
								<cfif get_kdv_report.purchase_sales eq  3>
                   					<a href="#request.self#?fuseaction=cost.form_add_expense_cost&event=upd&expense_id=#id#" class="tableyazi">#serial_number#</a>
                                <cfelseif get_kdv_report.purchase_sales eq 0>
									<cfif listfind("50,51,52,53,54,55,56,561,57,58,59,60,601,61,62,63,65,66,67,531,591,592,48,49,532",get_kdv_report.invoice_cat,",")>
										<cfif invoice_cat eq 592>
											<a href="#request.self#?fuseaction=invoice.form_upd_marketplace_bill&iid=#get_kdv_report.id#" class="tableyazi">#serial_number#</a>
										<cfelse>
											<cfif get_kdv_report.invoice_cat eq 65>
												<a href="#request.self#?fuseaction=invent.add_invent_purchase&event=upd&invoice_id=#get_kdv_report.id#" class="tableyazi">#serial_number#</a>
											<cfelseif get_kdv_report.invoice_cat eq 66>
												<a href="#request.self#?fuseaction=invent.upd_invent_sale&invoice_id=#get_kdv_report.id#" class="tableyazi">#serial_number#</a>
											<cfelse>
												<a href="#request.self#?fuseaction=invoice.form_add_bill_purchase&event=upd&iid=#get_kdv_report.id#" class="tableyazi">#serial_number#</a>
											</cfif>
										</cfif>   
									<cfelse>
										<a href="#request.self#?fuseaction=invoice.detail_invoice_other&iid=#get_kdv_report.id#" class="tableyazi"><!---#serial_number#--->#invoice_number#</a>
									</cfif>
                                </cfif>
                         	</td> --->
                            <td>
							 	<cfif get_kdv_report.purchase_sales eq 3>
 									<a href="#request.self#?fuseaction=cost.form_add_expense_cost&event=upd&expense_id=#id#" class="tableyazi"><!---#invoice_number#--->#serial_number#-#serial_no#</a>
                                <cfelseif  get_kdv_report.purchase_sales eq 0>
									<cfif listfind("50,51,52,53,54,55,56,561,57,58,59,60,601,61,62,63,65,66,67,531,591,592,48,49,532",get_kdv_report.invoice_cat,",")>
										<cfif invoice_cat eq 592>
											<a href="#request.self#?fuseaction=invoice.form_upd_marketplace_bill&iid=#get_kdv_report.id#" class="tableyazi">#serial_number#-#serial_no#</a>
										<cfelse>
											<cfif get_kdv_report.invoice_cat eq 65>
												<a href="#request.self#?fuseaction=invent.add_invent_purchase&event=upd&invoice_id=#get_kdv_report.id#" class="tableyazi">#serial_number#-#invoice_number#</a>
											<cfelseif get_kdv_report.invoice_cat eq 66>
												<a href="#request.self#?fuseaction=invent.upd_invent_sale&invoice_id=#get_kdv_report.id#" class="tableyazi">#serial_number#-#serial_no#</a>
											<cfelse>
												<a href="#request.self#?fuseaction=invoice.form_add_bill_purchase&event=upd&iid=#get_kdv_report.id#" class="tableyazi">#serial_number#-#serial_no#</a>
											</cfif>
										</cfif>
									<cfelse>
										<a href="#request.self#?fuseaction=invoice.detail_invoice_other&iid=#get_kdv_report.id#" class="tableyazi">#serial_number#-#invoice_number#</a>
									</cfif>
                                </cfif>
   							</td>
                           	<td><cfif len(fullname)>#fullname#</cfif><!---#cari_isim#---></td>
                            <td style="mso-number-format:'\@'">#NO#</td>
                            <td>
								<cfif get_kdv_report.purchase_sales eq 0>
									<cfquery name="get_product_id" dbtype="query">
										SELECT CATEGORY, DETAIL FROM get_row_product WHERE INVOICE_ID=#get_kdv_report.invoice_id#
									</cfquery>
								<cfelse>
									<cfquery name="get_product_id" dbtype="query">
										SELECT CATEGORY, DETAIL FROM get_cost WHERE EXPENSE_ID=#get_kdv_report.expense_id#
									</cfquery>
								</cfif>
								<!--- #listdeleteduplicates(valuelist(get_product_id.CATEGORY,','))#, ---> #listdeleteduplicates(valuelist(get_product_id.DETAIL,','))#
							</td>
								<cfif get_kdv_report.purchase_sales eq 0>
									<cfquery name="get_amount" dbtype="query">
										SELECT top_miktar FROM get_top_amount WHERE INVOICE_ID=#get_kdv_report.invoice_id#
									</cfquery>
								<cfelse>
									<cfquery name="get_amount" dbtype="query">
										SELECT top_miktar FROM get_top_amount_cost WHERE EXPENSE_ID=#get_kdv_report.expense_id#
									</cfquery>
								</cfif>
                            <td>#valuelist(get_amount.top_miktar,',')#</td>
                            <td style="text-align:right" nowrap="nowrap">
								<cfset total_kdvsiz_nettotal +=  kdvsiz_nettotal>
								#TLFormat(kdvsiz_nettotal,2)# TL
							</td>
                            <td style="text-align:right" nowrap="nowrap">
								<cfset total_kdv_toplam +=  kdv_toplam>
								#TLFormat(kdv_toplam,2)# TL
							</td>
                            <td style="text-align:right" nowrap="nowrap">#TLFormat(kdv_toplam - TEVKIFAT_AMOUNT_TOPLAM_BEYAN_EDILEN)# TL</td>
                            <td style="text-align:right" nowrap="nowrap">#TLFormat(TEVKIFAT_AMOUNT_TOPLAM_BEYAN_EDILEN)# TL</td>
                            <td style="text-align:right" nowrap="nowrap">#TLFormat(kdv_toplam - TEVKIFAT_AMOUNT_TOPLAM_BEYAN_EDILEN + TEVKIFAT_AMOUNT_TOPLAM_BEYAN_EDILEN)# TL</td>
                            <td></td>
                            <td>#dateformat(invoice_date,'yyyymm')#</td>
                            <td></td>
                  		</tr>
                    </cfoutput>
					<tr>
						<td colspan="7"></td>
						<td>Sayfa Toplam:</td>
						<td style="text-align:right" nowrap="nowrap" ><cfoutput>#tlformat(total_kdvsiz_nettotal)# TL</cfoutput></td>
						<td style="text-align:right" nowrap="nowrap" ><cfoutput>#tlformat(total_kdv_toplam)# TL</cfoutput></td>
					</tr>
					<tr>
						<td colspan="7"></td>
						<td>Genel Toplam:</td>
						<td style="text-align:right" nowrap="nowrap" ><cfoutput>#tlformat(genel_total_kdvsiz_nettotal)# TL</cfoutput></td>
						<td style="text-align:right" nowrap="nowrap" ><cfoutput>#tlformat(genel_total_kdv_toplam)# TL</cfoutput></td>
					</tr>
                <cfelse>
                    <tr>
                        <td class="color-row" colspan="17"><cfif not isdefined("attributes.form_varmi")>Filtre Ediniz !<cfelse>Kayıt Yok !</cfif></td>
                    </tr>
                </cfif>
            </table>
        </td>
    </tr>
    </br>
<cfif isdefined("attributes.form_varmi")> 
	<cfset url_str = "report.detail_report&report_id=#attributes.report_id#">
	<cfif attributes.totalrecords gt attributes.maxrows>
        <cfif len(attributes.consumer_id) and len(attributes.company)>
            <cfset url_str = "#url_str#&consumer_id=#attributes.consumer_id#&company=#attributes.company#">
        </cfif>
        <cfif len(attributes.company_id) and len(attributes.partner_id) and len(attributes.company)>
            <cfset url_str = "#url_str#&company_id=#attributes.company_id#&partner_id=#attributes.partner_id#&company=#attributes.company#">
        </cfif>
        <cfif len(attributes.employee_id) and len(attributes.company)>
            <cfset url_str = "#url_str#&employee_id=#attributes.employee_id#&company=#attributes.company#">
        </cfif>
        <cfif len(attributes.start_date)>
            <cfset url_str = "#url_str#&start_date=#dateformat(attributes.start_date,'dd/mm/yyyy')#">
        </cfif>
        <cfif len(attributes.finish_date)>
            <cfset url_str = "#url_str#&finish_date=#dateformat(attributes.finish_date,'dd/mm/yyyy')#">
        </cfif>
		<cfif len(attributes.is_filtre)>
			<cfset url_str = "#url_str#&is_filtre=#attributes.is_filtre#">
		</cfif>
		<cfif len(attributes.is_acr)>
			<cfset url_str = "#url_str#&is_acr=#attributes.is_acr#">
		</cfif>
		<tr><td>
        <table width="100%" align="center" cellpadding="0" cellspacing="0">
            <tr>
                <td><cf_pages 
                    page="#attributes.page#"
                    maxrows="#attributes.maxrows#"
                    totalrecords="#attributes.totalrecords#"
                    startrow="#attributes.startrow#"
                    adres="#url_str#&form_varmi=1"></td>
                <td align="right" style="text-align:right;"><cf_get_lang_main no='128.Toplam Kayıt'><cfoutput>:#attributes.totalrecords#&nbsp;-&nbsp;<cf_get_lang_main no='169.Sayfa'>:#attributes.page#/#lastpage#</cfoutput></td>
            </tr>
        </table>
        </td></tr>
     </cfif>
</cfif>
</table>
<script language="javascript">
function input_control()
	{
		if( !date_check(document.getElementById('start_date'), document.getElementById('finish_date'), "<cf_get_lang dictionary_id='58862.Baslangi Tarihi Bitis Tarihinden Byk Olamaz'>!") )
			return false;

		if(document.get_bill.is_excel.checked == false){
			document.get_bill.action="<cfoutput>#request.self#?fuseaction=report.detail_report&event=det&report_id=#attributes.report_id#</cfoutput>";
			return true;
		}else{
			document.get_bill.action="<cfoutput>#request.self#?fuseaction=report.emptypopup_detail_report&event=det&report_id=#attributes.report_id#</cfoutput>";
			document.get_bill.submit();
			return false;
        }
	}
</script>