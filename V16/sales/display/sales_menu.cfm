<cfsavecontent variable="m_dil_1"><cf_get_lang_main no='36.Satış'></cfsavecontent>
<cfsavecontent variable="m_dil_2"><cf_get_lang_main no='1282.Firsatlar'></cfsavecontent>
<cfsavecontent variable="m_dil_3"><cf_get_lang no='4.Teklifler'></cfsavecontent>
<cfsavecontent variable="m_dil_4"><cf_get_lang no='6.Siparisler'></cfsavecontent>
<cfsavecontent variable="m_dil_5"><cf_get_lang_main no='796.Taksitli Satışlar'></cfsavecontent>
<cfsavecontent variable="m_dil_6"><cf_get_lang_main no='2206.Aboneler'></cfsavecontent>
<cfsavecontent variable="m_dil_7"><cf_get_lang no='79.Uyelerim'></cfsavecontent>
<cfsavecontent variable="m_dil_8"><cf_get_lang_main no='152.Urunler'></cfsavecontent>
<cfsavecontent variable="m_dil_9"><cf_get_lang_main no='754.stoklar'></cfsavecontent>
<cfsavecontent variable="m_dil_10"><cf_get_lang_main no='171.promosyonlar'></cfsavecontent>
<cfsavecontent variable="m_dil_11"><cf_get_lang no ='384.Online Satışlar'></cfsavecontent>
<cfsavecontent variable="m_dil_12"><cf_get_lang_main no='558.Ziyaretler'></cfsavecontent>
<cfsavecontent variable="m_dil_13"><cf_get_lang no ='62.Takipler'></cfsavecontent>
<cfsavecontent variable="m_dil_14"><cf_get_lang no ='125.Parapuan'></cfsavecontent>
<cfsavecontent variable="m_dil_15"><cf_get_lang no ='643.Hediye Çeki'></cfsavecontent>
<!--- Şirket Akış Parametreleri - Abonelik Sözleşmesi Çalışsın Mı Seçeneğine Bağlı Olarak Aboneler Linki Gelir --->
<cfquery name="GET_OUR_COMP_INFO" datasource="#DSN#">
	SELECT IS_SUBSCRIPTION_CONTRACT FROM OUR_COMPANY_INFO WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
</cfquery>
<cfif (session.ep.our_company_info.subscription_contract eq 1 and get_our_comp_info.recordcount and get_our_comp_info.is_subscription_contract eq 1)>
	<cfset add_adm_ = "sales.list_subscription_contract*0*0*#m_dil_6#">
<cfelse>
	<cfset add_adm_ = "">
</cfif>
<cfset f_n_action_list = "sales.list_order*0*0*#m_dil_1#,sales.list_opportunity*0*0*#m_dil_2#,sales.list_offer*0*0*#m_dil_3#,sales.list_order*0*0*#m_dil_4#,sales.list_order_instalment*0*0*#m_dil_5#,#add_adm_#,myhome.my_companies*0*0*#m_dil_7#,sales.list_product*0*0*#m_dil_8#,sales.list_stock*0*0*#m_dil_9#,sales.list_proms*0*0*#m_dil_10#,sales.list_online_sales*0*0*#m_dil_11#,sales.list_visit*0*0*#m_dil_12#,sales.list_order_demands*0*0*#m_dil_13#,sales.list_money_credits&act_type=1*0*0*#m_dil_14#,sales.list_money_credits&act_type=2*0*0*#m_dil_15#">
<cfset menu_module_layer = "sales">
<cfinclude template="../../design/module_menu.cfm">
