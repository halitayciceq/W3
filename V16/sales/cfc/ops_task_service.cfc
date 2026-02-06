<cfcomponent displayname="OpsTaskService" hint="OPS_TASK Görev Yönetimi Servisi">
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         OPS_TASK_SERVICE.CFC
         Merkezi Kilit, Yetki ve İş Kuralları Yönetimi
         Tarih: 2026-02-05
         Versiyon: 2.0
         
         DSN SABİTLERİ (DEĞİŞMEZ):
           dsn  (Main)   : workcube_prod       → OPS_TASK, EMPLOYEES
           dsn3 (Şirket) : workcube_prod_1     → OPS_TASK_TEMPLATE, _ITEM, _BATCH_LOG, ORDERS
         
         ÖNEMLİ: Her cfquery'de datasource AÇIKÇA belirtilmeli!
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <!--- DSN Sabitleri --->
    <cfset variables.dsn = "workcube_prod">
    <cfset variables.dsn3 = "workcube_prod_1">
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         MERKEZI KİLİT VE İŞ KURALI KONTROLÜ
         Tüm görev oluşturma/güncelleme kararları bu fonksiyondan geçer
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <cffunction name="canEditTasks" returntype="struct" access="public" 
                hint="Görev düzenleme yetkisi kontrolü - UI ve Backend aynı fonksiyonu kullanır">
        <cfargument name="ref_type" type="string" required="true">
        <cfargument name="ref_id" type="numeric" required="true">
        <cfargument name="employee_id" type="numeric" required="true">
        <cfargument name="action" type="string" default="create" hint="create|update|delete|batch_create">
        <cfargument name="company_id" type="numeric" default="0">
        
        <cfset var result = {
            allowed: false,
            reason: "",
            reason_code: "",
            override_available: false,
            order_status: 0,
            is_locked: false
        }>
        
        <cftry>
            <!--- 1. REF_TYPE Kontrolü --->
            <cfif arguments.ref_type NEQ "ORDER">
                <cfset result.reason = "Sadece ORDER tipi desteklenmektedir">
                <cfset result.reason_code = "INVALID_REF_TYPE">
                <cfreturn result>
            </cfif>
            
            <!--- 2. Sipariş Bilgisi Sorgula (ORDERS → DSN3: workcube_prod_1) --->
            <cfquery name="qOrder" datasource="#variables.dsn3#">
                SELECT 
                    ORDER_ID, 
                    STATUS_ID, 
                    ISNULL(IS_LOCKED, 0) AS IS_LOCKED,
                    COMPANY_ID,
                    SHIP_DATE,
                    DELIVERY_DATE
                FROM ORDERS 
                WHERE ORDER_ID = <cfqueryparam value="#arguments.ref_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfif qOrder.recordCount EQ 0>
                <cfset result.reason = "Sipariş bulunamadı">
                <cfset result.reason_code = "ORDER_NOT_FOUND">
                <cfreturn result>
            </cfif>
            
            <cfset result.order_status = qOrder.STATUS_ID>
            <cfset result.is_locked = qOrder.IS_LOCKED EQ 1>
            
            <!--- 3. Şirket Erişim Kontrolü --->
            <cfset var userCompanyId = arguments.company_id GT 0 ? arguments.company_id : session.ep.company_id>
            <cfif qOrder.COMPANY_ID NEQ userCompanyId>
                <cfset result.reason = "Bu siparişe erişim yetkiniz yok">
                <cfset result.reason_code = "COMPANY_MISMATCH">
                <cfreturn result>
            </cfif>
            
            <!--- 4. Sipariş Statüsü Kontrolü --->
            <!--- 90: Sevk Edildi, 95: Teslim Edildi, 99: Kapandı/İptal --->
            <cfif qOrder.STATUS_ID GTE 90>
                <cfset result.reason = "Sipariş kapatılmış/sevk edilmiş (Statü: #qOrder.STATUS_ID#)">
                <cfset result.reason_code = "ORDER_CLOSED">
                <cfset result.override_available = hasPermission(arguments.employee_id, "OPS_TASK_ADMIN_OVERRIDE")>
                <cfreturn result>
            </cfif>
            
            <!--- 5. Kilit Kontrolü --->
            <cfif qOrder.IS_LOCKED EQ 1>
                <cfset result.reason = "Sipariş kilitlenmiş">
                <cfset result.reason_code = "ORDER_LOCKED">
                <cfset result.override_available = hasPermission(arguments.employee_id, "OPS_TASK_ADMIN_OVERRIDE")>
                <cfreturn result>
            </cfif>
            
            <!--- 6. Sevk/Teslim Tarihi Kontrolü --->
            <cfif isDate(qOrder.SHIP_DATE) AND qOrder.SHIP_DATE LT now()>
                <cfset result.reason = "Sevk tarihi geçmiş, görev düzenlenemez">
                <cfset result.reason_code = "SHIPPED">
                <cfset result.override_available = hasPermission(arguments.employee_id, "OPS_TASK_ADMIN_OVERRIDE")>
                <cfreturn result>
            </cfif>
            
            <!--- 7. Aksiyon Bazlı Yetki Kontrolü --->
            <cfswitch expression="#arguments.action#">
                <cfcase value="create">
                    <cfif NOT hasPermission(arguments.employee_id, "OPS_TASK_CREATE")>
                        <cfset result.reason = "Görev oluşturma yetkiniz yok">
                        <cfset result.reason_code = "NO_CREATE_PERMISSION">
                        <cfreturn result>
                    </cfif>
                </cfcase>
                
                <cfcase value="batch_create">
                    <cfif NOT hasPermission(arguments.employee_id, "OPS_TASK_CREATE_BATCH")>
                        <cfset result.reason = "Toplu görev oluşturma yetkiniz yok">
                        <cfset result.reason_code = "NO_BATCH_PERMISSION">
                        <cfreturn result>
                    </cfif>
                </cfcase>
                
                <cfcase value="update">
                    <cfif NOT hasPermission(arguments.employee_id, "OPS_TASK_UPDATE_EXISTING")>
                        <cfset result.reason = "Görev güncelleme yetkiniz yok">
                        <cfset result.reason_code = "NO_UPDATE_PERMISSION">
                        <cfreturn result>
                    </cfif>
                </cfcase>
                
                <cfcase value="delete">
                    <cfif NOT hasPermission(arguments.employee_id, "OPS_TASK_DELETE")>
                        <cfset result.reason = "Görev silme yetkiniz yok">
                        <cfset result.reason_code = "NO_DELETE_PERMISSION">
                        <cfreturn result>
                    </cfif>
                </cfcase>
            </cfswitch>
            
            <!--- Tüm kontroller geçildi --->
            <cfset result.allowed = true>
            <cfset result.reason = "">
            <cfset result.reason_code = "">
            
        <cfcatch type="any">
            <cflog file="ops_task_error" type="error" 
                   text="canEditTasks ERROR: #cfcatch.message# | ref_type=#arguments.ref_type# ref_id=#arguments.ref_id# emp=#arguments.employee_id#">
            <cfset result.reason = "Sistem hatası oluştu">
            <cfset result.reason_code = "SYSTEM_ERROR">
        </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>
    
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         YETKİ KONTROLÜ
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <cffunction name="hasPermission" returntype="boolean" access="public"
                hint="Kullanıcının belirtilen yetkiye sahip olup olmadığını kontrol eder">
        <cfargument name="employee_id" type="numeric" required="true">
        <cfargument name="permission_code" type="string" required="true">
        
        <cftry>
            <!--- 
                Yetki Kodları:
                - OPS_TASK_CREATE: Tek görev oluşturma
                - OPS_TASK_CREATE_BATCH: Toplu görev oluşturma
                - OPS_TASK_UPDATE_EXISTING: Mevcut görevi güncelleme
                - OPS_TASK_DELETE: Görev silme
                - OPS_TASK_ADMIN_OVERRIDE: Kilitli kayıtlarda işlem
            --->
            
            <!--- MVP için basit kontrol: Tüm yetkiler açık --->
            <!--- TODO: Gerçek yetki sistemi entegrasyonu yapılacak --->
            
            <cfswitch expression="#arguments.permission_code#">
                <cfcase value="OPS_TASK_CREATE">
                    <!--- Herkes oluşturabilir --->
                    <cfreturn true>
                </cfcase>
                
                <cfcase value="OPS_TASK_CREATE_BATCH">
                    <!--- Proje yöneticisi veya admin --->
                    <cfreturn isProjectManagerOrAdmin(arguments.employee_id)>
                </cfcase>
                
                <cfcase value="OPS_TASK_UPDATE_EXISTING">
                    <!--- Görev sorumlusu veya yönetici --->
                    <cfreturn true>
                </cfcase>
                
                <cfcase value="OPS_TASK_DELETE">
                    <!--- Sadece yönetici --->
                    <cfreturn isProjectManagerOrAdmin(arguments.employee_id)>
                </cfcase>
                
                <cfcase value="OPS_TASK_ADMIN_OVERRIDE">
                    <!--- Sadece admin --->
                    <cfreturn isAdmin(arguments.employee_id)>
                </cfcase>
                
                <cfdefaultcase>
                    <cfreturn false>
                </cfdefaultcase>
            </cfswitch>
            
        <cfcatch type="any">
            <cflog file="ops_task_error" type="error" 
                   text="hasPermission ERROR: #cfcatch.message# | emp=#arguments.employee_id# perm=#arguments.permission_code#">
            <cfreturn false>
        </cfcatch>
        </cftry>
    </cffunction>
    
    
    <cffunction name="isProjectManagerOrAdmin" returntype="boolean" access="private">
        <cfargument name="employee_id" type="numeric" required="true">
        
        <!--- MVP: Session'dan kontrol --->
        <cfif isDefined("session.ep.is_admin") AND session.ep.is_admin>
            <cfreturn true>
        </cfif>
        
        <!--- TODO: EMPLOYEE_ROLES veya benzeri tablodan kontrol --->
        <cfreturn true> <!--- MVP için true --->
    </cffunction>
    
    
    <cffunction name="isAdmin" returntype="boolean" access="private">
        <cfargument name="employee_id" type="numeric" required="true">
        
        <cfif isDefined("session.ep.is_admin") AND session.ep.is_admin>
            <cfreturn true>
        </cfif>
        
        <!--- TODO: Gerçek admin kontrolü --->
        <cfreturn false>
    </cffunction>
    
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         ŞABLON SORGULARI
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <cffunction name="getTemplates" returntype="query" access="public"
                hint="Aktif görev şablonlarını getirir">
        <cfargument name="company_id" type="numeric" required="true">
        
        <cftry>
            <!--- OPS_TASK_TEMPLATE → DSN3: workcube_prod_1 --->
            <cfquery name="qTemplates" datasource="#variables.dsn3#">
                SELECT 
                    TEMPLATE_ID,
                    TEMPLATE_CODE,
                    TEMPLATE_NAME,
                    DESCRIPTION,
                    IS_DEFAULT,
                    (SELECT COUNT(*) FROM OPS_TASK_TEMPLATE_ITEM 
                     WHERE TEMPLATE_ID = t.TEMPLATE_ID AND IS_ACTIVE = 1) AS ITEM_COUNT
                FROM OPS_TASK_TEMPLATE t
                WHERE (COMPANY_ID = <cfqueryparam value="#arguments.company_id#" cfsqltype="cf_sql_integer">
                       OR COMPANY_ID = 1)
                AND IS_ACTIVE = 1
                ORDER BY IS_DEFAULT DESC, TEMPLATE_NAME
            </cfquery>
            
            <cfif qTemplates.recordCount GT 0>
                <cfreturn qTemplates>
            </cfif>
        <cfcatch type="any">
            <cflog file="ops_task_error" type="error" text="getTemplates ERROR: #cfcatch.message#">
        </cfcatch>
        </cftry>
        
        <!--- Fallback: Hardcoded şablon (DB'de yoksa) --->
        <cfset var qFallback = queryNew("TEMPLATE_ID,TEMPLATE_CODE,TEMPLATE_NAME,DESCRIPTION,IS_DEFAULT,ITEM_COUNT", "integer,varchar,varchar,varchar,bit,integer")>
        <cfset queryAddRow(qFallback)>
        <cfset querySetCell(qFallback, "TEMPLATE_ID", -1)>
        <cfset querySetCell(qFallback, "TEMPLATE_CODE", "STD_ORDER")>
        <cfset querySetCell(qFallback, "TEMPLATE_NAME", "Standart Sipariş Görevleri")>
        <cfset querySetCell(qFallback, "DESCRIPTION", "Varsayılan görev şablonu")>
        <cfset querySetCell(qFallback, "IS_DEFAULT", 1)>
        <cfset querySetCell(qFallback, "ITEM_COUNT", 6)>
        <cfreturn qFallback>
    </cffunction>
    
    
    <cffunction name="getTemplateItems" returntype="query" access="public"
                hint="Şablon görev satırlarını getirir">
        <cfargument name="template_id" type="numeric" required="true">
        
        <!--- Fallback: Hardcoded görevler (template_id = -1) --->
        <cfif arguments.template_id EQ -1>
            <!--- Varsayılan sorumluları EMPLOYEES tablosundan çek --->
            <cfquery name="qDefaultEmps" datasource="#variables.dsn#">
                SELECT EMPLOYEE_ID, EMPLOYEE_NAME, EMPLOYEE_SURNAME,
                       EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS FULL_NAME
                FROM EMPLOYEES
                WHERE (EMPLOYEE_NAME = 'Abdullah' AND EMPLOYEE_SURNAME LIKE 'Taha%')
                   OR (EMPLOYEE_NAME = 'Ahmet' AND EMPLOYEE_SURNAME LIKE 'Rahim%')
                   OR (EMPLOYEE_NAME = 'Öztürk' AND EMPLOYEE_SURNAME = 'Sezgin')
                   OR (EMPLOYEE_NAME = 'Mehmet' AND EMPLOYEE_SURNAME LIKE 'Esat%')
            </cfquery>
            
            <!--- Kullanıcı ID'lerini map'e al --->
            <cfset var empMap = {}>
            <cfloop query="qDefaultEmps">
                <cfset empMap[qDefaultEmps.FULL_NAME] = {id: qDefaultEmps.EMPLOYEE_ID, name: qDefaultEmps.FULL_NAME}>
            </cfloop>
            
            <!--- Görev-Kullanıcı eşleştirmesi --->
            <cfset var abdullahTaha = structKeyExists(empMap, "Abdullah Taha Avcılar") ? empMap["Abdullah Taha Avcılar"] : {id:0, name:""}>
            <cfset var ahmetRahim = structKeyExists(empMap, "Ahmet Rahim Mutlu") ? empMap["Ahmet Rahim Mutlu"] : {id:0, name:""}>
            <cfset var ozturkSezgin = structKeyExists(empMap, "Öztürk Sezgin") ? empMap["Öztürk Sezgin"] : {id:0, name:""}>
            <cfset var mehmetEsat = structKeyExists(empMap, "Mehmet Esat Avcılar") ? empMap["Mehmet Esat Avcılar"] : {id:0, name:""}>
            
            <cfset var qFallback = queryNew("ITEM_ID,TASK_CODE,TASK_HEAD,TASK_DETAIL,SORT_ORDER,DEFAULT_EMP_ID,DEFAULT_EMP_NAME,DEFAULT_PRIORITY_ID,DEFAULT_DAYS_OFFSET,DEFAULT_ESTIMATED_MINUTES,HAS_PRODUCTION_MATRIX,IS_MANDATORY")>
            <cfset var items = [
                {code:"SIPARIS_ONAYI", head:"SİPARİŞ ONAYI", days:-30, priority:3, mandatory:1, emp:abdullahTaha},
                {code:"AVANS_ODEME", head:"AVANS / ÖDEME ONAY", days:-29, priority:3, mandatory:1, emp:abdullahTaha},
                {code:"KESIF_DURUMU", head:"KEŞİF DURUMU", days:-28, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"ON_TASARIM", head:"ÖN TASARIM", days:-27, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"ON_TASARIM_MUSTERI_ONAYI", head:"ÖN TASARIM MÜŞTERİ ONAYI", days:-26, priority:2, mandatory:1, emp:abdullahTaha},
                {code:"DETAY_TASARIM", head:"DETAY TASARIM", days:-25, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"IMALAT_RESIMLERI", head:"İMALAT RESİMLERİ", days:-22, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"KESIM_BUKUM_LISTELERI", head:"KESİM BÜKÜM LİSTELERİ", days:-21, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"URUN_AGACI", head:"ÜRÜN AĞACI", days:-20, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"SEVKIYAT_CHECKLIST", head:"SEVKİYAT CHECKLİST", days:-5, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"ELEKTRIK_URUN_AGACI", head:"ELEKTRİK ÜRÜN AĞACI", days:-18, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"MEKANIK_URUN_AGACI", head:"MEKANİK ÜRÜN AĞACI", days:-17, priority:2, mandatory:0, emp:ahmetRahim},
                {code:"TEDARIK_SURECI", head:"TEDARİK SÜRECİ", days:-15, priority:2, mandatory:1, emp:ozturkSezgin},
                {code:"URETIM_SURECI", head:"ÜRETİM SÜRECİ", days:-10, priority:2, mandatory:1, emp:mehmetEsat, hasMatrix:1},
                {code:"MONTAJ_SURECI", head:"MONTAJ SÜRECİ", days:-7, priority:2, mandatory:1, emp:mehmetEsat},
                {code:"SEVKIYAT", head:"SEVKİYAT", days:-3, priority:2, mandatory:1, emp:mehmetEsat},
                {code:"SAHA_MONTAJ", head:"SAHA MONTAJ", days:0, priority:2, mandatory:1, emp:mehmetEsat}
            ]>
            <cfloop array="#items#" index="i" item="itm">
                <cfset queryAddRow(qFallback)>
                <cfset querySetCell(qFallback, "ITEM_ID", i)>
                <cfset querySetCell(qFallback, "TASK_CODE", itm.code)>
                <cfset querySetCell(qFallback, "TASK_HEAD", itm.head)>
                <cfset querySetCell(qFallback, "TASK_DETAIL", "")>
                <cfset querySetCell(qFallback, "SORT_ORDER", i)>
                <cfset querySetCell(qFallback, "DEFAULT_EMP_ID", itm.emp.id)>
                <cfset querySetCell(qFallback, "DEFAULT_EMP_NAME", itm.emp.name)>
                <cfset querySetCell(qFallback, "DEFAULT_PRIORITY_ID", itm.priority)>
                <cfset querySetCell(qFallback, "DEFAULT_DAYS_OFFSET", itm.days)>
                <cfset querySetCell(qFallback, "DEFAULT_ESTIMATED_MINUTES", 60)>
                <cfset querySetCell(qFallback, "HAS_PRODUCTION_MATRIX", structKeyExists(itm, "hasMatrix") ? itm.hasMatrix : 0)>
                <cfset querySetCell(qFallback, "IS_MANDATORY", itm.mandatory)>
            </cfloop>
            <cfreturn qFallback>
        </cfif>
        
        <!--- OPS_TASK_TEMPLATE_ITEM → DSN3: workcube_prod_1 
              EMPLOYEES → DSN: workcube_prod (cross-db join) --->
        <cfquery name="qItems" datasource="#variables.dsn3#">
            SELECT 
                i.ITEM_ID,
                i.TASK_CODE,
                i.TASK_HEAD,
                i.TASK_DETAIL,
                i.SORT_ORDER,
                i.DEFAULT_EMP_ID,
                i.DEFAULT_PRIORITY_ID,
                i.DEFAULT_DAYS_OFFSET,
                i.DEFAULT_ESTIMATED_MINUTES,
                i.HAS_PRODUCTION_MATRIX,
                i.IS_MANDATORY,
                ISNULL(e.EMPLOYEE_NAME + ' ' + e.EMPLOYEE_SURNAME, '') AS DEFAULT_EMP_NAME
            FROM OPS_TASK_TEMPLATE_ITEM i
            LEFT JOIN workcube_prod.EMPLOYEES e ON e.EMPLOYEE_ID = i.DEFAULT_EMP_ID
            WHERE i.TEMPLATE_ID = <cfqueryparam value="#arguments.template_id#" cfsqltype="cf_sql_integer">
            AND i.IS_ACTIVE = 1
            ORDER BY i.SORT_ORDER
        </cfquery>
        
        <cfreturn qItems>
    </cffunction>
    
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         MEVCUT GÖREV KONTROLÜ (N+1 YASAĞI - TEK SORGU)
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <cffunction name="getExistingTasks" returntype="struct" access="public"
                hint="Verilen TASK_CODE listesi için mevcut görevleri tek sorguda getirir">
        <cfargument name="ref_type" type="string" required="true">
        <cfargument name="ref_id" type="numeric" required="true">
        <cfargument name="task_codes" type="array" required="true">
        
        <cfset var result = {}>
        
        <cfif arrayLen(arguments.task_codes) EQ 0>
            <cfreturn result>
        </cfif>
        
        <cfquery name="qExisting" datasource="#variables.dsn#">
            SELECT TASK_ID, TASK_CODE, STATUS_ID, ASSIGNED_EMP_ID
            FROM OPS_TASK 
            WHERE REF_TYPE = <cfqueryparam value="#arguments.ref_type#" cfsqltype="cf_sql_varchar">
            AND REF_ID = <cfqueryparam value="#arguments.ref_id#" cfsqltype="cf_sql_integer">
            AND TASK_CODE IN (<cfqueryparam value="#arrayToList(arguments.task_codes)#" cfsqltype="cf_sql_varchar" list="true">)
            AND IS_ACTIVE = 1
        </cfquery>
        
        <!--- Map'e çevir: TASK_CODE => {task_id, status_id, ...} --->
        <cfloop query="qExisting">
            <cfset result[qExisting.TASK_CODE] = {
                task_id: qExisting.TASK_ID,
                status_id: qExisting.STATUS_ID,
                assigned_emp_id: qExisting.ASSIGNED_EMP_ID
            }>
        </cfloop>
        
        <cfreturn result>
    </cffunction>
    
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         BATCH CACHE KONTROLÜ
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <cffunction name="getBatchResult" returntype="struct" access="public"
                hint="Önceki batch sonucunu getirir (idempotency için)">
        <cfargument name="batch_id" type="string" required="true">
        
        <cfset var result = {found: false}>
        
        <!--- OPS_TASK_BATCH_LOG → DSN3: workcube_prod_1 --->
        <cfquery name="qBatch" datasource="#variables.dsn3#">
            SELECT 
                BATCH_ID, REF_TYPE, REF_ID, TEMPLATE_ID, ACTION_TYPE,
                TOTAL_ITEMS, CREATED_COUNT, UPDATED_COUNT, SKIPPED_COUNT, ERROR_COUNT,
                CREATED_BY, CREATED_DATE, DURATION_MS
            FROM OPS_TASK_BATCH_LOG
            WHERE BATCH_ID = <cfqueryparam value="#arguments.batch_id#" cfsqltype="cf_sql_varchar">
            AND ACTION_TYPE = 'CREATE'
        </cfquery>
        
        <cfif qBatch.recordCount GT 0>
            <cfset result = {
                found: true,
                batch_id: qBatch.BATCH_ID,
                ref_type: qBatch.REF_TYPE,
                ref_id: qBatch.REF_ID,
                template_id: qBatch.TEMPLATE_ID,
                total_items: qBatch.TOTAL_ITEMS,
                created_count: qBatch.CREATED_COUNT,
                updated_count: qBatch.UPDATED_COUNT,
                skipped_count: qBatch.SKIPPED_COUNT,
                error_count: qBatch.ERROR_COUNT,
                created_by: qBatch.CREATED_BY,
                created_date: qBatch.CREATED_DATE,
                duration_ms: qBatch.DURATION_MS
            }>
        </cfif>
        
        <cfreturn result>
    </cffunction>
    
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         TERMİN HESAPLAMA (Europe/Istanbul, Takvim Günü)
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <cffunction name="calculateDeadline" returntype="date" access="public"
                hint="Sipariş tarihine göre termin hesaplar">
        <cfargument name="base_date" type="date" required="true">
        <cfargument name="days_offset" type="numeric" required="true">
        
        <!--- Takvim günü ekleme (iş günü DEĞİL) --->
        <cfreturn dateAdd("d", arguments.days_offset, arguments.base_date)>
    </cffunction>
    
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         AUDIT LOG
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <cffunction name="logBatchOperation" returntype="void" access="public"
                hint="Batch işlem logunu kaydeder">
        <cfargument name="batch_id" type="string" required="true">
        <cfargument name="ref_type" type="string" required="true">
        <cfargument name="ref_id" type="numeric" required="true">
        <cfargument name="template_id" type="numeric" default="0">
        <cfargument name="action_type" type="string" required="true">
        <cfargument name="strategy" type="string" default="skip_existing">
        <cfargument name="matrix_mode" type="string" default="lenient">
        <cfargument name="summary" type="struct" required="true">
        <cfargument name="error_details" type="string" default="">
        <cfargument name="employee_id" type="numeric" required="true">
        <cfargument name="duration_ms" type="numeric" default="0">
        
        <!--- OPS_TASK_BATCH_LOG → DSN3: workcube_prod_1 --->
        <cfquery datasource="#variables.dsn3#">
            INSERT INTO OPS_TASK_BATCH_LOG (
                BATCH_ID, REF_TYPE, REF_ID, TEMPLATE_ID, ACTION_TYPE,
                STRATEGY, MATRIX_MODE,
                TOTAL_ITEMS, CREATED_COUNT, UPDATED_COUNT, SKIPPED_COUNT, ERROR_COUNT,
                ERROR_DETAILS, CREATED_BY, DURATION_MS
            ) VALUES (
                <cfqueryparam value="#arguments.batch_id#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.ref_type#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.ref_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.template_id#" cfsqltype="cf_sql_integer" null="#arguments.template_id EQ 0#">,
                <cfqueryparam value="#arguments.action_type#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.strategy#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.matrix_mode#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.summary.total#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.summary.created#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.summary.updated#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.summary.skipped#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.summary.errors#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.error_details#" cfsqltype="cf_sql_nvarchar" null="#NOT len(arguments.error_details)#">,
                <cfqueryparam value="#arguments.employee_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.duration_ms#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cffunction>
    
    
    <cffunction name="logBatchItem" returntype="void" access="public"
                hint="Batch işlem satır detayını kaydeder">
        <cfargument name="batch_id" type="string" required="true">
        <cfargument name="task_code" type="string" required="true">
        <cfargument name="action" type="string" required="true">
        <cfargument name="existing_task_id" type="numeric" default="0">
        <cfargument name="new_task_id" type="numeric" default="0">
        <cfargument name="reason" type="string" default="">
        <cfargument name="error_detail" type="string" default="">
        
        <!--- OPS_TASK_BATCH_LOG_ITEM → DSN3: workcube_prod_1 --->
        <cfquery datasource="#variables.dsn3#">
            INSERT INTO OPS_TASK_BATCH_LOG_ITEM (
                BATCH_ID, TASK_CODE, ACTION, 
                EXISTING_TASK_ID, NEW_TASK_ID, REASON, ERROR_DETAIL
            ) VALUES (
                <cfqueryparam value="#arguments.batch_id#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.task_code#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.action#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.existing_task_id#" cfsqltype="cf_sql_integer" null="#arguments.existing_task_id EQ 0#">,
                <cfqueryparam value="#arguments.new_task_id#" cfsqltype="cf_sql_integer" null="#arguments.new_task_id EQ 0#">,
                <cfqueryparam value="#arguments.reason#" cfsqltype="cf_sql_nvarchar" null="#NOT len(arguments.reason)#">,
                <cfqueryparam value="#arguments.error_detail#" cfsqltype="cf_sql_nvarchar" null="#NOT len(arguments.error_detail)#">
            )
        </cfquery>
    </cffunction>
    
    
    <!--- ═══════════════════════════════════════════════════════════════════════════════
         BATCH PREVIEW + CREATE
    ═══════════════════════════════════════════════════════════════════════════════ --->
    
    <cffunction name="batchPreview" returntype="struct" access="public">
        <cfargument name="ref_type" type="string" required="true">
        <cfargument name="ref_id" type="numeric" required="true">
        <cfargument name="template_id" type="numeric" required="true">
        <cfargument name="selected_codes" type="string" default="">
        <cfargument name="strategy" type="string" default="skip_existing">
        <cfargument name="employee_id" type="numeric" required="true">
        <cfargument name="company_id" type="numeric" required="true">
        
        <cfset var result = {success:false, message:"", base_date:"", items:[], summary:{total:0, will_create:0, will_update:0, will_skip:0, existing:0}}>
        
        <cftry>
            <cfset var authCheck = canEditTasks(arguments.ref_type, arguments.ref_id, arguments.employee_id, "batch_create", arguments.company_id)>
            <cfif NOT authCheck.allowed>
                <cfset result.message = authCheck.reason>
                <cfreturn result>
            </cfif>
            
            <cfset var qItems = getTemplateItems(arguments.template_id)>
            <cfif qItems.recordCount EQ 0>
                <cfset result.message = "Şablonda görev bulunamadı">
                <cfreturn result>
            </cfif>
            
            <cfquery name="qOrder" datasource="#variables.dsn3#">
                SELECT ORDER_DATE FROM ORDERS WHERE ORDER_ID = <cfqueryparam value="#arguments.ref_id#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfset var baseDate = isDate(qOrder.ORDER_DATE) ? qOrder.ORDER_DATE : now()>
            <cfset result.base_date = dateFormat(baseDate, "yyyy-mm-dd")>
            
            <cfset var taskCodes = []>
            <cfloop query="qItems"><cfset arrayAppend(taskCodes, qItems.TASK_CODE)></cfloop>
            <cfset var existingTasks = getExistingTasks(arguments.ref_type, arguments.ref_id, taskCodes)>
            
            <cfset var selectedList = listToArray(arguments.selected_codes)>
            
            <cfloop query="qItems">
                <cfset var item = {
                    task_code: qItems.TASK_CODE, task_head: qItems.TASK_HEAD, task_detail: qItems.TASK_DETAIL,
                    sort_order: qItems.SORT_ORDER, default_emp_id: qItems.DEFAULT_EMP_ID, default_emp_name: qItems.DEFAULT_EMP_NAME,
                    priority_id: qItems.DEFAULT_PRIORITY_ID, days_offset: qItems.DEFAULT_DAYS_OFFSET,
                    estimated_minutes: qItems.DEFAULT_ESTIMATED_MINUTES, has_matrix: qItems.HAS_PRODUCTION_MATRIX,
                    is_mandatory: qItems.IS_MANDATORY, deadline: dateFormat(calculateDeadline(baseDate, qItems.DEFAULT_DAYS_OFFSET), "yyyy-mm-dd"),
                    exists: false, existing_task_id: 0, action: "create", selected: true
                }>
                
                <cfif structKeyExists(existingTasks, qItems.TASK_CODE)>
                    <cfset item.exists = true>
                    <cfset item.existing_task_id = existingTasks[qItems.TASK_CODE].task_id>
                    <cfset result.summary.existing++>
                    <cfif arguments.strategy EQ "skip_existing">
                        <cfset item.action = "skip">
                        <cfset item.selected = false>
                        <cfset result.summary.will_skip++>
                    <cfelse>
                        <cfset item.action = "update">
                        <cfset result.summary.will_update++>
                    </cfif>
                <cfelse>
                    <cfset result.summary.will_create++>
                </cfif>
                
                <cfif arrayLen(selectedList) GT 0 AND NOT arrayFindNoCase(selectedList, qItems.TASK_CODE)>
                    <cfset item.selected = false>
                </cfif>
                
                <cfset arrayAppend(result.items, item)>
                <cfset result.summary.total++>
            </cfloop>
            
            <cfset result.success = true>
        <cfcatch type="any">
            <cflog file="ops_task_error" type="error" text="batchPreview ERROR: #cfcatch.message#">
            <cfset result.message = "Önizleme hatası: BP001">
        </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>
    
    
    <cffunction name="batchCreate" returntype="struct" access="public">
        <cfargument name="ref_type" type="string" required="true">
        <cfargument name="ref_id" type="numeric" required="true">
        <cfargument name="template_id" type="numeric" required="true">
        <cfargument name="selected_codes" type="string" default="">
        <cfargument name="strategy" type="string" default="skip_existing">
        <cfargument name="employee_id" type="numeric" required="true">
        <cfargument name="company_id" type="numeric" required="true">
        <cfargument name="branch_id" type="numeric" default="0">
        
        <cfset var result = {success:false, message:"", batch_id:"", summary:{total:0, created:0, updated:0, skipped:0, errors:0}, items:[]}>
        <cfset var startTime = getTickCount()>
        <cfset var batchId = createUUID()>
        <cfset result.batch_id = batchId>
        
        <cftry>
            <cfset var preview = batchPreview(arguments.ref_type, arguments.ref_id, arguments.template_id, arguments.selected_codes, arguments.strategy, arguments.employee_id, arguments.company_id)>
            <cfif NOT preview.success>
                <cfset result.message = preview.message>
                <cfreturn result>
            </cfif>
            
            <cfset var baseDate = parseDateTime(preview.base_date)>
            
            <cftransaction>
                <cfloop array="#preview.items#" index="item">
                    <cfif NOT item.selected>
                        <cfset result.summary.skipped++>
                        <cfset logBatchItem(batchId, item.task_code, "SKIP", item.existing_task_id, 0, "Not selected")>
                        <cfcontinue>
                    </cfif>
                    
                    <cftry>
                        <cfif item.action EQ "skip">
                            <cfset result.summary.skipped++>
                            <cfset logBatchItem(batchId, item.task_code, "SKIP", item.existing_task_id, 0, "Already exists")>
                            <cfset arrayAppend(result.items, {task_code: item.task_code, action: "skipped", task_id: item.existing_task_id})>
                            
                        <cfelseif item.action EQ "update">
                            <cfquery datasource="#variables.dsn#">
                                UPDATE OPS_TASK SET
                                    TASK_HEAD = <cfqueryparam value="#item.task_head#" cfsqltype="cf_sql_nvarchar">,
                                    DEADLINE = <cfqueryparam value="#item.deadline#" cfsqltype="cf_sql_date">,
                                    UPDATED_BY = <cfqueryparam value="#arguments.employee_id#" cfsqltype="cf_sql_integer">,
                                    UPDATED_DATE = GETDATE()
                                WHERE TASK_ID = <cfqueryparam value="#item.existing_task_id#" cfsqltype="cf_sql_integer">
                            </cfquery>
                            <cfset result.summary.updated++>
                            <cfset logBatchItem(batchId, item.task_code, "UPDATE", item.existing_task_id, item.existing_task_id, "Updated")>
                            <cfset arrayAppend(result.items, {task_code: item.task_code, action: "updated", task_id: item.existing_task_id})>
                            
                        <cfelse>
                            <!--- Varsayılan STATUS_ID = 2359 (İş Atandı) --->
                            <cfquery name="qInsert" datasource="#variables.dsn#" result="insertResult">
                                INSERT INTO OPS_TASK (
                                    TASK_CODE, TASK_HEAD, TASK_DETAIL, REF_TYPE, REF_ID,
                                    TEMPLATE_ID, TEMPLATE_ITEM_ID, BATCH_ID,
                                    ASSIGNED_EMP_ID, PRIORITY_ID, STATUS_ID, DEADLINE, ESTIMATED_MINUTES,
                                    COMPANY_ID, BRANCH_ID, CREATED_BY, CREATED_DATE, IS_ACTIVE
                                ) VALUES (
                                    <cfqueryparam value="#item.task_code#" cfsqltype="cf_sql_varchar">,
                                    <cfqueryparam value="#item.task_head#" cfsqltype="cf_sql_nvarchar">,
                                    <cfqueryparam value="#item.task_detail#" cfsqltype="cf_sql_nvarchar" null="#NOT len(item.task_detail)#">,
                                    <cfqueryparam value="#arguments.ref_type#" cfsqltype="cf_sql_varchar">,
                                    <cfqueryparam value="#arguments.ref_id#" cfsqltype="cf_sql_integer">,
                                    <cfqueryparam value="#arguments.template_id#" cfsqltype="cf_sql_integer">,
                                    <cfqueryparam value="#item.sort_order#" cfsqltype="cf_sql_integer">,
                                    <cfqueryparam value="#batchId#" cfsqltype="cf_sql_varchar">,
                                    <cfqueryparam value="#item.default_emp_id#" cfsqltype="cf_sql_integer" null="#item.default_emp_id EQ 0 OR NOT isNumeric(item.default_emp_id)#">,
                                    <cfqueryparam value="#item.priority_id#" cfsqltype="cf_sql_integer">,
                                    <cfqueryparam value="2359" cfsqltype="cf_sql_integer">,<!--- İş Atandı --->
                                    <cfqueryparam value="#item.deadline#" cfsqltype="cf_sql_date">,
                                    <cfqueryparam value="#item.estimated_minutes#" cfsqltype="cf_sql_integer">,
                                    <cfqueryparam value="#arguments.company_id#" cfsqltype="cf_sql_integer">,
                                    <cfqueryparam value="#arguments.branch_id#" cfsqltype="cf_sql_integer" null="#arguments.branch_id EQ 0#">,
                                    <cfqueryparam value="#arguments.employee_id#" cfsqltype="cf_sql_integer">,
                                    GETDATE(), 1
                                )
                            </cfquery>
                            <cfset var newTaskId = insertResult.generatedKey>
                            <cfset result.summary.created++>
                            <cfset logBatchItem(batchId, item.task_code, "CREATE", 0, newTaskId, "Created")>
                            <cfset arrayAppend(result.items, {task_code: item.task_code, action: "created", task_id: newTaskId})>
                        </cfif>
                        
                    <cfcatch type="any">
                        <cfset result.summary.errors++>
                        <cfset logBatchItem(batchId, item.task_code, "ERROR", item.existing_task_id, 0, "", cfcatch.message)>
                        <cflog file="ops_task_error" type="error" text="batchCreate item ERROR: #item.task_code# - #cfcatch.message#">
                    </cfcatch>
                    </cftry>
                </cfloop>
            </cftransaction>
            
            <cfset result.summary.total = result.summary.created + result.summary.updated + result.summary.skipped + result.summary.errors>
            <cfset var duration = getTickCount() - startTime>
            
            <cfset logBatchOperation(batchId, arguments.ref_type, arguments.ref_id, arguments.template_id, "CREATE", arguments.strategy, "lenient", result.summary, "", arguments.employee_id, duration)>
            
            <cfset result.success = true>
            <cfset result.message = "#result.summary.created# görev oluşturuldu, #result.summary.updated# güncellendi, #result.summary.skipped# atlandı">
            
        <cfcatch type="any">
            <cflog file="ops_task_error" type="error" text="batchCreate ERROR: #cfcatch.message#">
            <cfset result.message = "Toplu oluşturma hatası: BC001">
        </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>
    
    
    <cffunction name="saveSingleTask" returntype="struct" access="public">
        <cfargument name="task_id" type="numeric" default="0">
        <cfargument name="ref_type" type="string" required="true">
        <cfargument name="ref_id" type="numeric" required="true">
        <cfargument name="task_head" type="string" required="true">
        <cfargument name="task_detail" type="string" default="">
        <cfargument name="assigned_emp_id" type="numeric" default="0">
        <cfargument name="priority_id" type="numeric" default="2">
        <cfargument name="deadline" type="string" default="">
        <cfargument name="estimated_minutes" type="numeric" default="0">
        <cfargument name="status_id" type="numeric" default="0">
        <cfargument name="percent_complete" type="numeric" default="0">
        <cfargument name="employee_id" type="numeric" required="true">
        <cfargument name="company_id" type="numeric" required="true">
        <cfargument name="branch_id" type="numeric" default="0">
        
        <cfset var result = {success:false, message:"", task_id:0}>
        
        <cftry>
            <cfset var action = arguments.task_id GT 0 ? "update" : "create">
            <cfset var authCheck = canEditTasks(arguments.ref_type, arguments.ref_id, arguments.employee_id, action, arguments.company_id)>
            <cfif NOT authCheck.allowed>
                <cfset result.message = authCheck.reason>
                <cfreturn result>
            </cfif>
            
            <cfif arguments.task_id GT 0>
                <cfquery datasource="#variables.dsn#">
                    UPDATE OPS_TASK SET
                        TASK_HEAD = <cfqueryparam value="#arguments.task_head#" cfsqltype="cf_sql_nvarchar">,
                        TASK_DETAIL = <cfqueryparam value="#arguments.task_detail#" cfsqltype="cf_sql_nvarchar" null="#NOT len(arguments.task_detail)#">,
                        ASSIGNED_EMP_ID = <cfqueryparam value="#arguments.assigned_emp_id#" cfsqltype="cf_sql_integer" null="#arguments.assigned_emp_id EQ 0#">,
                        PRIORITY_ID = <cfqueryparam value="#arguments.priority_id#" cfsqltype="cf_sql_integer">,
                        DEADLINE = <cfqueryparam value="#arguments.deadline#" cfsqltype="cf_sql_date" null="#NOT len(arguments.deadline)#">,
                        ESTIMATED_MINUTES = <cfqueryparam value="#arguments.estimated_minutes#" cfsqltype="cf_sql_integer">,
                        STATUS_ID = <cfqueryparam value="#arguments.status_id#" cfsqltype="cf_sql_integer" null="#arguments.status_id EQ 0#">,
                        PERCENT_COMPLETE = <cfqueryparam value="#arguments.percent_complete#" cfsqltype="cf_sql_decimal">,
                        UPDATED_BY = <cfqueryparam value="#arguments.employee_id#" cfsqltype="cf_sql_integer">,
                        UPDATED_DATE = GETDATE()
                    WHERE TASK_ID = <cfqueryparam value="#arguments.task_id#" cfsqltype="cf_sql_integer">
                </cfquery>
                <cfset result.task_id = arguments.task_id>
                <cfset result.message = "Görev güncellendi">
            <cfelse>
                <cfquery name="qInsert" datasource="#variables.dsn#" result="insertResult">
                    INSERT INTO OPS_TASK (
                        TASK_HEAD, TASK_DETAIL, REF_TYPE, REF_ID,
                        ASSIGNED_EMP_ID, PRIORITY_ID, DEADLINE, ESTIMATED_MINUTES,
                        STATUS_ID, PERCENT_COMPLETE, COMPANY_ID, BRANCH_ID,
                        CREATED_BY, CREATED_DATE, IS_ACTIVE
                    ) VALUES (
                        <cfqueryparam value="#arguments.task_head#" cfsqltype="cf_sql_nvarchar">,
                        <cfqueryparam value="#arguments.task_detail#" cfsqltype="cf_sql_nvarchar" null="#NOT len(arguments.task_detail)#">,
                        <cfqueryparam value="#arguments.ref_type#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.ref_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.assigned_emp_id#" cfsqltype="cf_sql_integer" null="#arguments.assigned_emp_id EQ 0#">,
                        <cfqueryparam value="#arguments.priority_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.deadline#" cfsqltype="cf_sql_date" null="#NOT len(arguments.deadline)#">,
                        <cfqueryparam value="#arguments.estimated_minutes#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.status_id#" cfsqltype="cf_sql_integer" null="#arguments.status_id EQ 0#">,
                        <cfqueryparam value="#arguments.percent_complete#" cfsqltype="cf_sql_decimal">,
                        <cfqueryparam value="#arguments.company_id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.branch_id#" cfsqltype="cf_sql_integer" null="#arguments.branch_id EQ 0#">,
                        <cfqueryparam value="#arguments.employee_id#" cfsqltype="cf_sql_integer">,
                        GETDATE(), 1
                    )
                </cfquery>
                <cfset result.task_id = insertResult.generatedKey>
                <cfset result.message = "Görev oluşturuldu">
            </cfif>
            
            <cfset result.success = true>
        <cfcatch type="any">
            <cflog file="ops_task_error" type="error" text="saveSingleTask ERROR: #cfcatch.message#">
            <cfset result.message = "Kayıt hatası: ST001">
        </cfcatch>
        </cftry>
        <cfreturn result>
    </cffunction>

</cfcomponent>
