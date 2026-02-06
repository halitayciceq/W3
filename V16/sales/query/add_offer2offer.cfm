<cfif not isdefined('attributes.price') or not len(attributes.price)>
	<cfif isDefined("attributes.basket_net_total") and len(attributes.basket_net_total)>
		<cfset attributes.price = attributes.basket_net_total>
	<cfelse>
		<cfset attributes.price = 0>
	</cfif>
</cfif>
	
<cfif len(DELIVERDATE)>
	<CF_DATE tarih="DELIVERDATE">
</cfif>

<cfif len(FINISHDATE)>
	<CF_DATE tarih="FINISHDATE">
</cfif>

<cfset CC_POS = "">
<cfset CC_PARS = "">
<cfset CC_CONS = "">
<cfset CC_GRPS = "">
<cfloop list="#FORM.CCS#" index="I">
	<cfif I CONTAINS "POS">
		<cfset CC_POS = LISTAPPEND(CC_POS,LISTGETAT(I,2,"-"))>
	<cfelseif I CONTAINS "PAR">
		<cfset CC_PARS = LISTAPPEND(CC_PARS,LISTGETAT(I,2,"-"))>
	<cfelseif I CONTAINS "CON">
		<cfset CC_CONS = LISTAPPEND(CC_CONS,LISTGETAT(I,2,"-"))>
	<cfelseif I CONTAINS "GRP">
		<cfset CC_GRPS = LISTAPPEND(CC_GRPS,LISTGETAT(I,2,"-"))>
	</cfif>
</cfloop> 

<cf_papers paper_type="offer" paper_type2="1">

<CFLOCK name="#CREATEUUID()#" timeout="20">
	<CFTRANSACTION>

	<cfquery name="SET_MAX_PAPER" datasource="#DSN3#">
		UPDATE
			GENERAL_PAPERS
		SET
			OFFER_NUMBER = OFFER_NUMBER+1
		WHERE
			PAPER_TYPE = 1
			AND
			ZONE_TYPE = 0
	</cfquery>

	<cfquery name="ADD_OFFER" datasource="#DSN3#" result="MAX_ID">
		INSERT INTO 
			OFFER 
			(
			<cfif len(SALES_POSITION_CODE) AND len(SALES_POSITION)>
				SALES_POSITION_CODE,
			</cfif>
			<cfif len(SALES_PARTNER_ID) AND len(SALES_PARTNER)>
				SALES_PARTNER_ID,
			</cfif>
			<cfif len(validator_position_code) AND len(validator_position)>
				VALIDATOR_POSITION_CODE,
				VALID,
				OFFER_CURRENCY,
			<cfelse>
				VALIDATOR_POSITION_CODE,
				VALID,
				OFFER_CURRENCY,
				VALID_EMP,
				VALIDDATE,
			</cfif>
			<cfif isdefined('attributes.PRICE') and len(attributes.PRICE)>
				PRICE,
			</cfif>
			<cfif len(PAYMETHOD_ID) AND len(PAYMETHOD)>
				PAYMETHOD,
			</cfif>
			<cfif len(DELIVERDATE)>
				DELIVERDATE,
			</cfif>
			<cfif len(FINISHDATE)>
				FINISHDATE,
			</cfif>
			CC_POSITIONS,
			CC_PARTNER_ID,
			CC_CONS,
			CC_GRPS,
			<cfif attributes.MEMBER_TYPE eq "partner">
				OFFER_TO_PARTNER,
				OFFER_TO,
			<cfelseif attributes.MEMBER_TYPE eq "CONSUMER">
				CONSUMER_ID,
			</cfif>
			OFFER_HEAD,
			OFFER_DETAIL,
			<cfif isdefined('attributes.MONEY') and len(MONEY)>
			OTHER_MONEY,
			</cfif>
			<cfif isdefined('attributes.TAX') and len(TAX)>
			TAX,
			</cfif>
			OFFER_NUMBER,
			OFFER_STATUS,
			PURCHASE_SALES,
			RECORD_DATE,
			RECORD_IP,
			RECORD_MEMBER,
			INCLUDED_KDV,
			OFFER_ZONE,
			IS_PARTNER_ZONE,
			IS_PUBLIC_ZONE
			<cfif len(attributes.project_id)>
			,PROJECT_ID
			</cfif>
			)
		VALUES 
			(
		<cfif len(SALES_POSITION_CODE) AND len(SALES_POSITION)>
			#SALES_POSITION_CODE#,
		</cfif>
		<cfif len(SALES_PARTNER_ID) AND len(SALES_PARTNER)>
			#SALES_PARTNER_ID#,
		</cfif>
		<cfif len(validator_position_code) AND len(validator_position)>
			#validator_position_code#,
			NULL,
			-1,
		<cfelse>
			#SESSION.EP.POSITION_CODE#,
			1,
			-1,
			#SESSION.EP.USERID#,
			#now()#,
		</cfif>
		<cfif isdefined('attributes.PRICE') and len(attributes.PRICE)>
			#attributes.PRICE#,
		</cfif>
		<cfif len(PAYMETHOD_ID) AND len(PAYMETHOD)>
			#PAYMETHOD_ID#,
		</cfif>
		<cfif len(DELIVERDATE)>
			#DELIVERDATE#,
		</cfif>
		<cfif len(FINISHDATE)>
			#FINISHDATE#,
		</cfif>
			',#CC_POS#,',
			',#CC_PARS#,',
			',#CC_CONS#,',
			',#CC_GRPS#,',
		<cfif attributes.MEMBER_TYPE eq "partner">
			',#MEMBER_ID#,',
			',#COMPANY_ID#,',
		<cfelseif attributes.MEMBER_TYPE eq "CONSUMER">
			#MEMBER_ID#,
		</cfif>
			'#OFFER_HEAD#',
			'#offer_detail#',
			<cfif isdefined('attributes.MONEY') and len(MONEY)>
			'#MONEY#',
			</cfif>
			<cfif isdefined('attributes.TAX') and len(TAX)>
			#TAX#,
			</cfif>
			'#paper_full#',
			1,
			1,
			#now()#,
			'#CGI.REMOTE_ADDR#',
			#SESSION.EP.USERID#,
		<cfif isdefined("included_kdv") and included_kdv>
			1,
		<cfelse>
			0,
		</cfif>
			0,
			<cfif isDefined("FORM.IS_PARTNER_ZONE")>
				1,
			<cfelse>
				0,
			</cfif> 
			<cfif isDefined("FORM.IS_PUBLIC_ZONE")>
				1
			<cfelse>
				0
			</cfif>	
			<cfif len(attributes.project_id)>
			,#attributes.PROJECT_ID#
			</cfif>
			)
	</cfquery>
	<cfif isdefined("offer_id")>
		<cfinclude template="get_offer_pages.cfm">
		<cfoutput query="get_offer_pages">
			<cfset attributes.page_id = page_id>
			<cfinclude template="get_offer_page.cfm">
			<cfquery name="ADD_OFFER_PAGE" datasource="#DSN3#">
			INSERT INTO
				OFFER_PAGES
				(
				OFFER_ID,
				PAGE_NAME,
				PAGE_NO,
				PAGE_TYPE,
				PAGE_CONTENT,
				RECORD_DATE,
				RECORD_EMP,
				OFFER_ZONE,
				RECORD_IP
				)
			VALUES
				(
				#MAX_ID.IDENTITYCOL#,
				'#GET_OFFER_PAGE.PAGE_NAME#',
				#GET_OFFER_PAGE.PAGE_NO#,
				#GET_OFFER_PAGE.PAGE_TYPE#,
				'#GET_OFFER_PAGE.PAGE_CONTENT#',
				#now()#,
				#SESSION.EP.USERID#,
				0,
				'#CGI.REMOTE_ADDR#'
				)
			</cfquery>
		</cfoutput>
	</cfif>

	<cfloop from="1" to="#attributes.rows_#" index="I">
		<cf_date tarih="attributes.deliver_date#i#">
		<cfquery name="ADD_OFFER_ROW" datasource="#DSN3#">
			INSERT INTO
				OFFER_ROW
				(
				OFFER_ID,
				PRODUCT_ID,
				STOCK_ID,
				QUANTITY,
				UNIT,
				UNIT_ID,
				PRICE,
				TAX,
				DUEDATE,
				PRODUCT_NAME,
				DELIVER_DATE,
				DELIVER_DEPT,
				DELIVER_LOCATION,
				DISCOUNT_1,
				DISCOUNT_2,
				DISCOUNT_3,
				DISCOUNT_4,
				DISCOUNT_5,
				DISCOUNT_6,
				DISCOUNT_7,
				DISCOUNT_8,
				DISCOUNT_9,
				DISCOUNT_10,
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
			<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
				SPECT_VAR_ID,
				SPECT_VAR_NAME,
			</cfif>
				BASKET_EXTRA_INFO_ID,
				SELECT_INFO_EXTRA,
                DETAIL_INFO_EXTRA,
				PRICE_OTHER,
				NET_MALIYET,
				MARJ,
				WRK_ROW_ID,
				WRK_ROW_RELATION_ID,
				WIDTH_VALUE,
				DEPTH_VALUE,
				HEIGHT_VALUE,
				ROW_PROJECT_ID
				)
			VALUES
				(
				#MAX_ID.IDENTITYCOL#,
				#evaluate('attributes.product_id#i#')#,
				#evaluate('attributes.stock_id#i#')#,
				#evaluate('attributes.amount#i#')#,
				'#wrk_eval('attributes.unit#i#')#',
				#evaluate('attributes.unit_id#i#')#,
				#evaluate('attributes.price#i#')#,
				#evaluate('attributes.tax#i#')#,
				<cfif len(evaluate('attributes.duedate#i#'))>#evaluate('attributes.duedate#i#')#<cfelse>NULL</cfif>,
				'#wrk_eval('attributes.product_name#i#')#',
				<cfif isdefined("attributes.deliver_date#i#") and isdate(evaluate('attributes.deliver_date#i#'))>#evaluate('attributes.deliver_date#i#')#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.deliver_dept#i#") and len(trim(evaluate("attributes.deliver_dept#i#"))) and len(listfirst(evaluate("attributes.deliver_dept#i#"),"-"))>
				#listfirst(evaluate("attributes.deliver_dept#i#"),"-")#,
			<cfelse>
				NULL,
			</cfif>
			<cfif isdefined("attributes.deliver_dept#i#") and listlen(trim(evaluate("attributes.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#i#"),"-"))>
				#listlast(evaluate("attributes.deliver_dept#i#"),"-")#,
			<cfelse>
				NULL,
			</cfif>
			<cfif isdefined('attributes.indirim1#i#') and len(evaluate('attributes.indirim1#i#'))>#evaluate('attributes.indirim1#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim2#i#') and len(evaluate('attributes.indirim2#i#'))>#evaluate('attributes.indirim2#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim3#i#') and len(evaluate('attributes.indirim3#i#'))>#evaluate('attributes.indirim3#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim4#i#') and len(evaluate('attributes.indirim4#i#'))>#evaluate('attributes.indirim4#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim5#i#') and len(evaluate('attributes.indirim5#i#'))>#evaluate('attributes.indirim5#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim6#i#') and len(evaluate('attributes.indirim6#i#'))>#evaluate('attributes.indirim6#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim7#i#') and len(evaluate('attributes.indirim7#i#'))>#evaluate('attributes.indirim7#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim8#i#') and len(evaluate('attributes.indirim8#i#'))>#evaluate('attributes.indirim8#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim9#i#') and len(evaluate('attributes.indirim9#i#'))>#evaluate('attributes.indirim9#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.indirim10#i#') and len(evaluate('attributes.indirim10#i#'))>#evaluate('attributes.indirim10#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.other_money_#i#')>'#wrk_eval('attributes.other_money_#i#')#'<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.other_money_value_#i#') and len(evaluate("attributes.other_money_value_#i#"))>#evaluate('attributes.other_money_value_#i#')#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
				#evaluate('attributes.spect_id#i#')#,
				'#wrk_eval('attributes.spect_name#i#')#',
			</cfif>
			<cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.select_info_extra#i#')#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
			<cfif isdefined('attributes.price_other#i#')>#evaluate('attributes.price_other#i#')#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.net_maliyet#i#') and len(evaluate('attributes.net_maliyet#i#'))>#evaluate('attributes.net_maliyet#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.marj#i#') and len(evaluate('attributes.marj#i#'))>#evaluate('attributes.marj#i#')#<cfelse>0</cfif>,
			<cfif isdefined('attributes.wrk_row_id#i#') and len(evaluate('attributes.wrk_row_id#i#'))>'#wrk_eval('attributes.wrk_row_id#i#')#'<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.wrk_row_relation_id#i#') and len(evaluate('attributes.wrk_row_relation_id#i#'))>'#wrk_eval('attributes.wrk_row_relation_id#i#')#'<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>,
			<cfif isdefined('attributes.row_project_id#i#') and len(evaluate('attributes.row_project_id#i#')) and isdefined('attributes.row_project_name#i#') and len(evaluate('attributes.row_project_name#i#'))>#evaluate('attributes.row_project_id#i#')#<cfelse>NULL</cfif>
				)
		</cfquery>
		
		<!---  urun asortileri --->			
		<cfquery name="get_max_offer_row" datasource="#DSN3#">
			SELECT MAX(OFFER_ROW_ID) AS OFFER_ROW_ID FROM OFFER_ROW
		</cfquery>

		<cfset attributes.ROW_MAIN_ID = get_max_offer_row.OFFER_ROW_ID>
		<cfset row_id = I>
		<cfset ACTION_TYPE_ID = 1>
		<cfset attributes.product_id = evaluate('attributes.product_id#i#')>
		<cfinclude template="add_assortment_textile_js.cfm">
		<!--- //  urun asortileri --->				
	</cfloop>

	<cfscript>basket_kur_ekle(action_id:MAX_ID.IDENTITYCOL,table_type_id:4,process_type:0);</cfscript>
	</CFTRANSACTION>
</CFLOCK>
<cflocation url="#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#MAX_ID.IDENTITYCOL#" addtoken="no">
