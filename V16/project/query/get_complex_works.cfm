<!---
	TYPE 1 ise isler
	2 ise teklif
	3 ise siparis
	4 ise uretim emri
 --->
<cfquery name="GET_WORK" datasource="#DSN3#">
	<!--- Satış Teklifler--->	
			SELECT
				0 AS WORK_CAT,
				O.OFFER_ID AS WORK_ID,
				O.OFFER_HEAD  AS WORK_HEAD,
				0 AS OUTSRC_PARTNER_ID,
				RECORD_DATE AS TARGET_START,
				DELIVERDATE AS TARGET_FINISH,
				'' AS PRIORITY,
				'' AS COLOR,
				'' AS CURRENCY,
				OFFER_CURRENCY AS STR_CURRENCY,
				SALES_EMP_ID EMPLOYEE_ID,
				2 AS TYPE,
				'Satış Teklifleri ' AS TASK_TYPE,
				'sales.list_offer&event=upd&offer_id='  AS LINK,
				1 AS LINK_TYPE			
			FROM
				OFFER O
			WHERE
				OFFER_ZONE=0 AND 
				PURCHASE_SALES=1 AND
				OFFER_STATUS = 1 AND
				IS_PROCESSED=0 AND
				PROJECT_ID=#URL.ID#
		 
	<!--- Satınalma Teklifler--->	
	UNION ALL
			
				SELECT
					0 AS WORK_CAT,
					O.OFFER_ID AS WORK_ID,
					O.OFFER_HEAD  AS WORK_HEAD,
					0 AS OUTSRC_PARTNER_ID,
					RECORD_DATE AS TARGET_START,
					DELIVERDATE AS TARGET_FINISH,
					'' AS PRIORITY,
					'' AS COLOR,
					'' AS CURRENCY,
					OFFER_CURRENCY AS STR_CURRENCY,
					0 EMPLOYEE_ID,
					2 AS TYPE,
					'Satınalma Teklifleri ' AS TASK_TYPE,
					'purchase.list_offer&event=upd&offer_id=' AS LINK,
					1 AS LINK_TYPE			
				FROM
					OFFER O
				WHERE
					PROJECT_ID=#URL.ID# AND 
					OFFER_ZONE=0 AND 
					PURCHASE_SALES=0 AND 
					OFFER_STATUS = 1 AND 
					IS_PROCESSED=0
			UNION ALL
				SELECT
					0 AS WORK_CAT,
					O.OFFER_ID AS WORK_ID,
					O.OFFER_HEAD  AS WORK_HEAD,
					0 AS OUTSRC_PARTNER_ID,
					RECORD_DATE AS TARGET_START,
					DELIVERDATE AS TARGET_FINISH,
					'' AS PRIORITY,
					'' AS COLOR,
					'' AS CURRENCY,
					OFFER_CURRENCY AS STR_CURRENCY,
					0 EMPLOYEE_ID,
					2 AS TYPE,
					'Satınalma Teklifleri ' AS TASK_TYPE,
					'purchase.detail_offer_ptv&offer_id='  AS LINK,
					1 AS LINK_TYPE
				FROM
					OFFER O
				WHERE
					PROJECT_ID=#URL.ID# AND 
					OFFER_ZONE=1 AND 
					PURCHASE_SALES=1 AND 
					OFFER_STATUS = 1 AND 
					IS_PROCESSED=0
	<!--- Satış Siparişleri--->	
	UNION ALL
		
			SELECT
				0 AS WORK_CAT,
				O.ORDER_ID AS WORK_ID,
				O.ORDER_HEAD  AS WORK_HEAD,
				0 AS OUTSRC_PARTNER_ID,
				RECORD_DATE AS TARGET_START,
				DELIVERDATE AS TARGET_FINISH,
				'' AS PRIORITY,
				'' AS COLOR,
				'' AS CURRENCY,
				ORDER_CURRENCY AS STR_CURRENCY,
				<!--- SALES_POSITION_CODE AS  POSITION_CODE, --->
				ORDER_EMPLOYEE_ID AS EMPLOYEE_ID,
				3 AS TYPE,
				'Satış Siparişleri ' AS TASK_TYPE,
				'sales.detail_order_sa&order_id='   AS LINK,
				1 AS LINK_TYPE
			FROM
				ORDERS O
			WHERE
				PROJECT_ID=#URL.ID# AND
				ORDER_ZONE=0 AND 
				PURCHASE_SALES=1 AND 
				ORDER_STATUS = 1 AND 
				IS_PROCESSED=0
			
		UNION ALL
			SELECT
				0 AS WORK_CAT,
				O.ORDER_ID AS WORK_ID,
				O.ORDER_HEAD  AS WORK_HEAD,
				0 AS OUTSRC_PARTNER_ID,
				RECORD_DATE AS TARGET_START,
				DELIVERDATE AS TARGET_FINISH,
				'' AS PRIORITY,
				'' AS COLOR,
				'' AS CURRENCY,
				ORDER_CURRENCY AS STR_CURRENCY,
				<!--- SALES_POSITION_CODE POSITION_CODE, --->
				ORDER_EMPLOYEE_ID EMPLOYEE_ID,
				3 AS TYPE,
				'Satış Siparişleri ' AS TASK_TYPE,
				'sales.detail_order_psv&order_id=' AS LINK,
				1 AS LINK_TYPE
			FROM
				ORDERS O
			WHERE
				PROJECT_ID=#URL.ID# AND 
				ORDER_ZONE=1 AND 
				PURCHASE_SALES=0 AND 
				ORDER_STATUS = 1 AND 
				IS_PROCESSED=0
		UNION ALL
			SELECT
				0 AS WORK_CAT,
				O.ORDER_ID AS WORK_ID,
				O.ORDER_HEAD  AS WORK_HEAD,
				0 AS OUTSRC_PARTNER_ID,
				RECORD_DATE AS TARGET_START,
				DELIVERDATE AS TARGET_FINISH,
				'' AS PRIORITY,
				'' AS COLOR,
				'' AS CURRENCY,
				ORDER_CURRENCY AS STR_CURRENCY,
				0 EMPLOYEE_ID,
				3 AS TYPE,
				'Satınalma Siparişleri ' AS TASK_TYPE,
				'purchase.list_order&event=upd&order_id=' AS LINK,
				1 AS LINK_TYPE
			FROM
				ORDERS O
			WHERE
				PROJECT_ID=#URL.ID# AND 
				ORDER_ZONE=0 AND 
				PURCHASE_SALES=0 AND 
				ORDER_STATUS = 1 AND 
				IS_PROCESSED=0
		
		UNION ALL
	<!--- Üretim Emirleri--->						
			SELECT
				0 AS WORK_CAT,
				PO.P_ORDER_ID  AS WORK_ID,
				'Üretim Emri'  AS WORK_HEAD,
				0 AS OUTSRC_PARTNER_ID,
				PO.START_DATE AS TARGET_START,
				PO.FINISH_DATE AS TARGET_FINISH,
				'' AS PRIORITY,
				'' AS COLOR,
				'' AS CURRENCY,
				-1000 AS STR_CURRENCY,
				0 EMPLOYEE_ID,
				4 AS TYPE,
				'Üretim Emri ' AS TASK_TYPE,
				'prod.form_upd_prod_order&upd=' AS LINK,
				1 AS LINK_TYPE
			FROM
				PRODUCTION_ORDERS PO,
				WORKSTATIONS W
			WHERE
				W.STATION_ID=PO.STATION_ID AND
				PO.DP_ORDER_ID  IS NULL AND 
				PO.PROJECT_ID=#URL.ID#	
		ORDER BY TARGET_START	
</cfquery>
