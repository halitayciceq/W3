<!--- Modern Cash Flow Report - Updated: 2026-01-15 --->
<cfsavecontent variable="ay1"><cf_get_lang dictionary_id='57592.Ocak'></cfsavecontent>
<cfsavecontent variable="ay2"><cf_get_lang dictionary_id='57593.Subat'></cfsavecontent>
<cfsavecontent variable="ay3"><cf_get_lang dictionary_id='57594.Mart'></cfsavecontent>
<cfsavecontent variable="ay4"><cf_get_lang dictionary_id='57595.Nisan'></cfsavecontent>
<cfsavecontent variable="ay5"><cf_get_lang dictionary_id='57596.Mayis'></cfsavecontent>
<cfsavecontent variable="ay6"><cf_get_lang dictionary_id='57597.Haziran'></cfsavecontent>
<cfsavecontent variable="ay7"><cf_get_lang dictionary_id='57598.Temmuz'></cfsavecontent>
<cfsavecontent variable="ay8"><cf_get_lang dictionary_id='57599.Agustos'></cfsavecontent>
<cfsavecontent variable="ay9"><cf_get_lang dictionary_id='57600.Eylül'></cfsavecontent>
<cfsavecontent variable="ay10"><cf_get_lang dictionary_id='57601.Ekim'></cfsavecontent>
<cfsavecontent variable="ay11"><cf_get_lang dictionary_id='57602.Kasim'></cfsavecontent>
<cfsavecontent variable="ay12"><cf_get_lang dictionary_id='57603.Aralik'></cfsavecontent>
<cfset ay_listesi = "#ay1#,#ay2#,#ay3#,#ay4#,#ay5#,#ay6#,#ay7#,#ay8#,#ay9#,#ay10#,#ay11#,#ay12#">
<cfparam name="attributes.money" default="#session.ep.money#,1">
<cfparam name="attributes.view_mode" default="monthly">
<cfparam name="attributes.include_2025" default="0">

<!--- Chart.js CDN --->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<!--- SheetJS for Excel Export --->
<script src="https://cdn.sheetjs.com/xlsx-0.20.1/package/dist/xlsx.full.min.js"></script>
<!--- SortableJS for Drag-Drop Column Reordering --->
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>

<style>
:root {
    --primary-color: #2c3e50;
    --success-color: #27ae60;
    --danger-color: #c0392b;
    --warning-color: #f39c12;
    --info-color: #3498db;
    --light-bg: #f8f9fa;
    --border-color: #dee2e6;
    --shadow-sm: 0 1px 3px rgba(0,0,0,0.08);
    --shadow-md: 0 2px 6px rgba(0,0,0,0.1);
    --border-radius: 6px;
    --transition: all 0.2s ease;
}

.cash-flow-container {
    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
    padding: 15px;
    background: #fff;
}

.dashboard-header {
    background: var(--primary-color);
    border-radius: var(--border-radius);
    padding: 16px 24px;
    margin-bottom: 16px;
    color: white;
}

.dashboard-header h1 {
    margin: 0 0 4px 0;
    font-size: 20px;
    font-weight: 600;
}

.dashboard-header .subtitle {
    opacity: 0.8;
    font-size: 12px;
}

.controls-panel {
    display: flex;
    gap: 24px;
    align-items: flex-end;
    flex-wrap: wrap;
    margin-bottom: 24px;
    padding: 20px;
    background: white;
    border-radius: var(--border-radius);
    box-shadow: var(--shadow-sm);
}

.control-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.control-group label {
    font-size: 12px;
    font-weight: 600;
    color: #6c757d;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.control-group select, .control-group input[type="text"] {
    padding: 10px 16px;
    border: 2px solid var(--border-color);
    border-radius: 8px;
    font-size: 14px;
    transition: var(--transition);
    min-width: 150px;
}

.control-group select:focus, .control-group input:focus {
    border-color: var(--primary-color);
    outline: none;
    box-shadow: 0 0 0 3px rgba(44, 62, 80, 0.2);
}

/* Modern Select Styling */
.modern-select {
    appearance: none;
    background: white url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%236c757d' d='M6 8L1 3h10z'/%3E%3C/svg%3E") no-repeat right 12px center;
    padding-right: 36px !important;
}

.custom-select-wrapper {
    min-width: 180px;
}

/* Şirket dropdown - aynı stil Para Birimi ile */
.custom-select-wrapper .ui-multiselect,
.custom-select-wrapper .ui-state-default,
.custom-select-wrapper button.ui-multiselect {
    width: 100% !important;
    padding: 10px 36px 10px 16px !important;
    border: 1px solid #dee2e6 !important;
    border-radius: 8px !important;
    font-size: 14px !important;
    background: white !important;
    height: 42px !important;
    box-sizing: border-box !important;
    line-height: 1.4 !important;
    outline: none !important;
}

.actions-group {
    margin-left: auto;
}

.action-buttons {
    display: flex;
    gap: 8px;
}

.btn-modern svg {
    flex-shrink: 0;
}

.btn-modern {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: var(--transition);
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

.btn-primary {
    background: var(--primary-color);
    color: white;
}

.btn-success {
    background: var(--success-color);
    color: white;
}

.btn-danger {
    background: var(--danger-color);
    color: white;
}

.btn-modern:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 16px;
    margin-bottom: 24px;
}

.stat-card {
    background: white;
    border-radius: var(--border-radius);
    padding: 20px;
    box-shadow: var(--shadow-sm);
    transition: var(--transition);
    position: relative;
    overflow: hidden;
}

.stat-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
}

.stat-card.income::before { background: var(--success-color); }
.stat-card.expense::before { background: var(--danger-color); }
.stat-card.balance::before { background: var(--info-color); }
.stat-card.forecast::before { background: var(--warning-color); }

.stat-card:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-lg);
}

.stat-card .label {
    font-size: 12px;
    color: #6c757d;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
}

.stat-card .value {
    font-size: 24px;
    font-weight: 700;
    color: #212529;
}

.stat-card .trend {
    font-size: 12px;
    margin-top: 8px;
}

.trend.up { color: #28a745; }
.trend.down { color: #dc3545; }

.chart-container {
    background: white;
    border-radius: var(--border-radius);
    padding: 24px;
    margin-bottom: 24px;
    box-shadow: var(--shadow-sm);
}

.chart-container h3 {
    margin: 0 0 16px 0;
    font-size: 18px;
    color: #212529;
}

.table-container {
    background: white;
    border-radius: var(--border-radius);
    box-shadow: var(--shadow-sm);
    overflow: hidden;
}

.table-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 24px;
    background: linear-gradient(180deg, #f8f9fa 0%, #fff 100%);
    border-bottom: 1px solid #e9ecef;
}

.table-header h3 {
    margin: 0;
    font-size: 18px;
    color: #212529;
}

.table-actions {
    display: flex;
    gap: 8px;
}

.modern-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
    border: 2px solid #4472C4;
}

.modern-table thead {
    position: sticky;
    top: 0;
    z-index: 10;
}

.modern-table th {
    background: #4472C4;
    color: white;
    padding: 12px 8px;
    text-align: center;
    font-weight: 600;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    border: 1px solid #8EA9DB;
    white-space: nowrap;
}

.modern-table th a {
    color: white;
    text-decoration: none;
}

.modern-table th a:hover {
    text-decoration: underline;
}

.modern-table th.income-header {
    background: #27ae60;
}

.modern-table th.expense-header {
    background: #c0392b;
}

.modern-table th.balance-header {
    background: #2980b9;
}

.modern-table th.forecast-header {
    background: #f39c12;
}

.modern-table tbody tr {
    transition: var(--transition);
}

.modern-table tbody tr:nth-child(even) {
    background: #f8f9fa;
}

.modern-table tbody tr:hover {
    background: #e3f2fd;
    transform: scale(1.002);
}

.modern-table tbody tr.future-month {
    opacity: 0.5;
    background: #f1f3f4;
}

.modern-table td {
    padding: 12px 8px;
    text-align: right;
    border: 1px solid #B4C6E7;
    font-family: 'JetBrains Mono', 'Consolas', monospace;
}

.modern-table td:first-child {
    text-align: left;
    font-weight: 600;
    font-family: 'Segoe UI', sans-serif;
}

.modern-table td.positive {
    color: #28a745;
}

.modern-table td.negative {
    color: #dc3545;
}

.modern-table td.highlight {
    background: rgba(102, 126, 234, 0.1);
    font-weight: 600;
}

.modern-table td.drilldown {
    cursor: pointer;
    position: relative;
}

.modern-table td.drilldown:hover {
    background: #e3f2fd !important;
    text-decoration: underline;
}

.modern-table td.drilldown::after {
    content: '🔍';
    position: absolute;
    right: 4px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 10px;
    opacity: 0;
    transition: opacity 0.2s;
}

.modern-table td.drilldown:hover::after {
    opacity: 0.7;
}

.modern-table td.has-breakdown {
    cursor: help;
    position: relative;
}

.modern-table td.has-breakdown::before {
    content: attr(data-breakdown);
    position: absolute;
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    background: #1a1a2e;
    color: #fff;
    padding: 10px 14px;
    border-radius: 6px;
    font-size: 11px;
    white-space: pre-line;
    width: 220px;
    text-align: left;
    line-height: 1.6;
    opacity: 0;
    visibility: hidden;
    transition: all 0.2s;
    z-index: 1000;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
}

.modern-table td.has-breakdown:hover::before {
    opacity: 1;
    visibility: visible;
    bottom: calc(100% + 8px);
}

.modern-table tfoot tr {
    background: #2c3e50;
    color: white;
    font-weight: 600;
}

.modern-table tfoot td {
    padding: 14px 8px;
    border: none;
}

/* Modern Tooltip Styles */
.modern-table th[data-tooltip] {
    position: relative;
    cursor: help;
}

.modern-table th[data-tooltip]::after {
    content: attr(data-tooltip);
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    background: #1a1a2e;
    color: #fff;
    padding: 12px 16px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 400;
    text-transform: none;
    letter-spacing: normal;
    white-space: normal;
    width: 260px;
    text-align: left;
    line-height: 1.6;
    opacity: 0;
    visibility: hidden;
    transition: all 0.2s ease;
    z-index: 1000;
    box-shadow: 0 8px 24px rgba(0,0,0,0.4);
    pointer-events: none;
}

.modern-table th[data-tooltip]::before {
    content: '';
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    border: 8px solid transparent;
    border-bottom-color: #1a1a2e;
    opacity: 0;
    visibility: hidden;
    transition: all 0.2s ease;
    z-index: 1001;
}

.modern-table th[data-tooltip]:hover::after,
.modern-table th[data-tooltip]:hover::before {
    opacity: 1;
    visibility: visible;
}

.modern-table th[data-tooltip]:hover::after {
    top: calc(100% + 10px);
}

.modern-table th[data-tooltip]:hover::before {
    top: calc(100% - 6px);
}

.modern-table th .info-icon {
    display: inline-block;
    width: 14px;
    height: 14px;
    background: rgba(255,255,255,0.3);
    border-radius: 50%;
    font-size: 10px;
    line-height: 14px;
    margin-left: 4px;
    vertical-align: middle;
}

.view-toggle {
    display: flex;
    background: #e9ecef;
    border-radius: 8px;
    padding: 4px;
}

.view-toggle button {
    padding: 8px 16px;
    border: none;
    background: transparent;
    border-radius: 6px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: var(--transition);
    color: #495057;
}

.view-toggle button.active {
    background: white;
    color: #667eea;
    box-shadow: var(--shadow-sm);
}

.column-toggle {
    position: relative;
}

.column-toggle-btn {
    padding: 8px 12px;
    background: #e9ecef;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
}

.column-toggle-menu {
    position: absolute;
    top: 100%;
    right: 0;
    background: white;
    border-radius: 8px;
    box-shadow: var(--shadow-lg);
    padding: 12px;
    min-width: 200px;
    z-index: 100;
    display: none;
}

.column-toggle-menu.show {
    display: block;
}

.column-toggle-menu label {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 6px 0;
    cursor: pointer;
    font-size: 13px;
}

.table-scroll {
    overflow-x: auto;
    overflow-y: auto;
    max-height: 70vh;
    position: relative;
}

/* Excel-like Freeze Panes */
.modern-table {
    border-collapse: separate;
    border-spacing: 0;
}

/* Sticky Header - First row */
.modern-table thead tr:first-child th {
    position: sticky;
    top: 0;
    z-index: 20;
}

/* Sticky Header - Second row */
.modern-table thead tr:nth-child(2) th {
    position: sticky;
    top: 34px;
    z-index: 10;
    border-top: 1px solid #ccc;
}

/* Sticky First Column (AYLAR only - row 1) */
.modern-table tbody td:first-child,
.modern-table thead tr:first-child th:first-child {
    position: sticky;
    left: 0;
    z-index: 30;
    background: #34495e !important;
    color: white;
    min-width: 100px;
    box-shadow: 2px 0 5px rgba(0,0,0,0.1);
}

.modern-table tbody td:first-child {
    background: #f8f9fa !important;
    color: #212529;
    font-weight: 600;
    z-index: 15;
}

.modern-table tbody tr:nth-child(even) td:first-child {
    background: #ecf0f1 !important;
}

.modern-table tbody tr:hover td:first-child {
    background: #e3f2fd !important;
}

/* Sticky Footer (TOPLAM) */
.modern-table tfoot td {
    position: sticky;
    bottom: 0;
    z-index: 20;
    background: #e8f5e9 !important;
    color: #1a1a1a !important;
    font-weight: 700;
    border-top: 3px solid #27ae60;
    font-size: 12px;
}

.modern-table tfoot td:first-child {
    z-index: 30;
    left: 0;
    background: #27ae60 !important;
    color: #fff !important;
}

/* Corner cell - AYLAR has highest z-index */
.modern-table thead tr:first-child th:first-child {
    z-index: 40;
}

/* BANKA (second row first-child) - lower z-index than AYLAR */
.modern-table thead tr:nth-child(2) th:first-child {
    z-index: 10;
}

@media (max-width: 768px) {
    .controls-panel {
        flex-direction: column;
    }
    
    .stats-grid {
        grid-template-columns: 1fr 1fr;
    }
    
    .dashboard-header h1 {
        font-size: 20px;
    }
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.animate-in {
    animation: fadeIn 0.3s ease forwards;
}

.loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255,255,255,0.9);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    display: none;
}

.spinner {
    width: 48px;
    height: 48px;
    border: 4px solid #e9ecef;
    border-top-color: #667eea;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    to { transform: rotate(360deg); }
}
</style>

<cfset scenarioActions = createObject("component","V16.add_options.ugilo.cfc.scenario")>

<cfset get_order_plan_rows = scenarioActions.get_order_plan()>
<cfset our_company = scenarioActions.get_our_company()>
<cfset get_money_rate = scenarioActions.get_money_rate()>
<cfif not isDefined("attributes.our_company_ids")>
    <cfparam name="attributes.our_company_ids" default="#session.ep.company_id#">
</cfif>

<!--- Get 2026 data (current year) --->
<cfset get_scen_2026 = scenarioActions.get_scen(our_company_ids: attributes.our_company_ids, year: session.ep.period_year)>

<!--- If 2025 is selected, get 2025 data too --->
<cfif attributes.include_2025 eq 1>
    <cfset get_scen_2025 = scenarioActions.get_scen(our_company_ids: attributes.our_company_ids, year: 2025)>
</cfif>

<!--- For backward compatibility --->
<cfset get_scen = get_scen_2026>

<cfquery name="get_setup_money" dbtype="query">
    SELECT RATE2 FROM get_money_rate WHERE MONEY = 'USD'
</cfquery>
<cfquery name="get_setup_money2" dbtype="query">
    SELECT RATE2 FROM get_money_rate WHERE MONEY = 'EUR'
</cfquery>

<cfset dsn = application.systemParam.systemParam().dsn & '_' & session.ep.period_year & '_' & session.ep.company_id>
<!--- Updated: 2026-01-15 - Fixed to include opening balance (devir) from mizan --->
<cfquery name="getMonthlyBalance" datasource="#dsn#">
    DECLARE @KurUSD FLOAT = <cfif get_setup_money.recordcount>#get_setup_money.RATE2#<cfelse>1</cfif>;
    DECLARE @KurEUR FLOAT = <cfif get_setup_money2.recordcount>#get_setup_money2.RATE2#<cfelse>1</cfif>;
    DECLARE @Secilen NVARCHAR(10) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listFirst(attributes.money,',')#">;

    ;WITH Aylar AS (
        SELECT 1 AS Ay UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
        SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL
        SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL
        SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    )
    <!--- Aylık Hareketler (100/102 hesapları) --->
    , Hareketler AS (
        SELECT
            MONTH(AC.ACTION_DATE) AS Ay,
            ISNULL(ACR.OTHER_CURRENCY, '#session.ep.money#') AS DvzCinsi,
            SUM(CASE WHEN ACR.BA = 0 THEN ACR.AMOUNT ELSE 0 END) - SUM(CASE WHEN ACR.BA = 1 THEN ACR.AMOUNT ELSE 0 END) AS BakiyeTL,
            SUM(CASE WHEN ACR.BA = 0 THEN ISNULL(ACR.OTHER_AMOUNT,0) ELSE 0 END) - SUM(CASE WHEN ACR.BA = 1 THEN ISNULL(ACR.OTHER_AMOUNT,0) ELSE 0 END) AS BakiyeDoviz
        FROM ACCOUNT_CARD_ROWS ACR
        INNER JOIN ACCOUNT_CARD AC ON ACR.CARD_ID = AC.CARD_ID
        WHERE (ACR.ACCOUNT_ID LIKE '100%' OR ACR.ACCOUNT_ID LIKE '102%')
          AND YEAR(AC.ACTION_DATE) = #session.ep.period_year#
        GROUP BY MONTH(AC.ACTION_DATE), ACR.OTHER_CURRENCY
    )
    , KurCevrilmis AS (
        SELECT 
            Ay,
            CASE 
                WHEN DvzCinsi = '#session.ep.money#' OR DvzCinsi IS NULL THEN BakiyeTL
                WHEN DvzCinsi = 'USD' THEN BakiyeDoviz * @KurUSD
                WHEN DvzCinsi IN ('EUR','EURO') THEN BakiyeDoviz * @KurEUR
                ELSE BakiyeTL
            END AS BakiyeTL,
            CASE 
                WHEN DvzCinsi = 'USD' THEN BakiyeDoviz
                WHEN DvzCinsi = '#session.ep.money#' OR DvzCinsi IS NULL THEN BakiyeTL / NULLIF(@KurUSD,0)
                WHEN DvzCinsi IN ('EUR','EURO') THEN (BakiyeDoviz * @KurEUR) / NULLIF(@KurUSD,0)
                ELSE BakiyeTL / NULLIF(@KurUSD,0)
            END AS BakiyeUSD,
            CASE 
                WHEN DvzCinsi IN ('EUR','EURO') THEN BakiyeDoviz
                WHEN DvzCinsi = '#session.ep.money#' OR DvzCinsi IS NULL THEN BakiyeTL / NULLIF(@KurEUR,0)
                WHEN DvzCinsi = 'USD' THEN (BakiyeDoviz * @KurUSD) / NULLIF(@KurEUR,0)
                ELSE BakiyeTL / NULLIF(@KurEUR,0)
            END AS BakiyeEUR
        FROM Hareketler
    )
    , AylikToplam AS (
        SELECT 
            Ay,
            SUM(BakiyeTL) AS BakiyeTL,
            SUM(BakiyeUSD) AS BakiyeUSD,
            SUM(BakiyeEUR) AS BakiyeEUR
        FROM KurCevrilmis
        GROUP BY Ay
    )
    <!--- Kümülatif Bakiye Hesaplama --->
    , KumulatifBakiye AS (
        SELECT 
            A.Ay,
            ISNULL(T.BakiyeTL, 0) AS AylikTL,
            ISNULL(T.BakiyeUSD, 0) AS AylikUSD,
            ISNULL(T.BakiyeEUR, 0) AS AylikEUR,
            SUM(ISNULL(T2.BakiyeTL, 0)) AS KumulatifTL,
            SUM(ISNULL(T2.BakiyeUSD, 0)) AS KumulatifUSD,
            SUM(ISNULL(T2.BakiyeEUR, 0)) AS KumulatifEUR
        FROM Aylar A
        LEFT JOIN AylikToplam T ON T.Ay = A.Ay
        LEFT JOIN AylikToplam T2 ON T2.Ay <= A.Ay
        GROUP BY A.Ay, T.BakiyeTL, T.BakiyeUSD, T.BakiyeEUR
    )
    SELECT 
        K.Ay,
        CASE 
            WHEN @Secilen = 'USD' THEN CAST(K.KumulatifUSD AS DECIMAL(18,2))
            WHEN @Secilen IN ('EUR','EURO') THEN CAST(K.KumulatifEUR AS DECIMAL(18,2))
            ELSE CAST(K.KumulatifTL AS DECIMAL(18,2))
        END AS [T_BAKIYE],
        @Secilen AS ParaBirimi
    FROM KumulatifBakiye K
    ORDER BY K.Ay;
</cfquery>

<cfset dip_top_kasa_banka_total = dip_top_kasa_banka_total2= dip_top_cek_total = dip_top_tahsil_cek_total = dip_top_krediler_ve_diger_total = dip_top_cari_emanet_total = dip_top_cari_tashilat = dip_top_avans_tahsilat = dip_top_tahsilat = dip_top = 0>
<cfset dip_top_cikis_cek_total = dip_top_odenen_cikis_cek_total = dip_top_cikis_krediler_total = dip_top_odenen_cikis_krediler_total = dip_top_cikis_maaslar_total = dip_top_cikis_kk_total = dip_top_giris_kk_total = dip_top_cikis_diger_total = dip_top_cikis_cari_odeme_total = dip_top_cikis_avans_odeme_total = dip_top_cikis_emanet_odeme_total = dip_top_cikis_diger_odeme_total = 0>
<cfset dip_top_nakit_cikislar_toplam = dip_top_bakiye = dip_top_yurtici_alicilar_total = dip_top_yurtdisi_alicilar_total = fon_bakiye_dip_toplam = 0>

<div class="cash-flow-container">
    <!--- Modern Dashboard Header --->
    <div class="dashboard-header">
        <h1> Nakit Akış Tablosu</h1>
        <div class="subtitle">ARNİKON <cfoutput>#session.ep.period_year#</cfoutput> Yılı Finansal Özet</div>
    </div>
    
    <!--- Controls Panel --->
    <cfform name="akis" id="akis">
    <div class="controls-panel">
        <div class="control-group">
            <label>ŞİRKET</label>
            <div class="custom-select-wrapper">
                <cf_multiselect_check 
                    query_name="our_company"  
                    name="our_company_ids"
                    option_value="comp_id"
                    option_name="nick_name"
                    value="#attributes.our_company_ids#">
            </div>
        </div>
        <div class="control-group">
            <label>PARA BİRİMİ</label>
            <select name="money" id="money" class="modern-select" onchange="this.form.submit();">
                <option value="<cfoutput>#session.ep.money#</cfoutput>,1"<cfif session.ep.money eq listFirst(attributes.money,',')>selected</cfif>><cf_get_lang_main no='265.Döviz'></option>
                <cfoutput query="get_money_rate">
                    <option value="#money#,#rate1/rate2#"<cfif get_money_rate.money eq listFirst(attributes.money,',')>selected</cfif>>#money#</option>
                </cfoutput>
            </select>
        </div>
        <div class="control-group">
            <label>DÖNEM</label>
            <div style="display:flex; align-items:center; gap:8px; padding:10px 0;">
                <label style="display:flex; align-items:center; gap:6px; cursor:pointer; font-size:14px; text-transform:none; font-weight:500;">
                    <input type="checkbox" name="include_2025" value="1" <cfif attributes.include_2025 eq 1>checked</cfif> style="width:18px; height:18px; cursor:pointer;">
                    2025 Dahil Et
                </label>
            </div>
        </div>
        <div class="control-group">
            <label>&nbsp;</label>
            <button type="submit" class="btn-modern btn-primary">
                <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M11.534 7h3.932a.25.25 0 0 1 .192.41l-1.966 2.36a.25.25 0 0 1-.384 0l-1.966-2.36a.25.25 0 0 1 .192-.41zm-11 2h3.932a.25.25 0 0 0 .192-.41L2.692 6.23a.25.25 0 0 0-.384 0L.342 8.59A.25.25 0 0 0 .534 9z"/><path d="M8 3c-1.552 0-2.94.707-3.857 1.818a.5.5 0 1 1-.771-.636A6.002 6.002 0 0 1 13.917 7H12.9A5.002 5.002 0 0 0 8 3zM3.1 9a5.002 5.002 0 0 0 8.757 2.182.5.5 0 1 1 .771.636A6.002 6.002 0 0 1 2.083 9H3.1z"/></svg>
                Güncelle
            </button>
        </div>
        <div class="control-group actions-group">
            <label>&nbsp;</label>
            <div class="action-buttons">
                <button type="button" class="btn-modern btn-success" onclick="exportToExcel()">
                    <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z"/><path d="M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z"/></svg>
                    Excel
                </button>
                <button type="button" class="btn-modern btn-danger" onclick="window.print()">
                    <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M2.5 8a.5.5 0 1 0 0-1 .5.5 0 0 0 0 1z"/><path d="M5 1a2 2 0 0 0-2 2v2H2a2 2 0 0 0-2 2v3a2 2 0 0 0 2 2h1v1a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2v-1h1a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-1V3a2 2 0 0 0-2-2H5zM4 3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2H4V3zm1 5a2 2 0 0 0-2 2v1H2a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3a1 1 0 0 1-1 1h-1v-1a2 2 0 0 0-2-2H5zm7 2v3a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-3a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1z"/></svg>
                    Yazdır
                </button>
            </div>
        </div>
    </div>
    
    <!--- Table Container --->
    <div class="table-container">
        <div class="table-scroll">
            <table class="modern-table" id="cashFlowTable">
                <thead>
                    <tr>
                        <th rowspan="2" style="background:#34495e">AYLAR</th>
                        <th colspan="9" class="income-header">💵 NAKİT GİRİŞLER</th>
                        <th colspan="12" class="expense-header">💸 NAKİT ÇIKIŞLAR</th>
                        <th colspan="3" class="forecast-header">📊 TAHMİN</th>
                    </tr>
                    <tr>
                        <th class="income-header" style="background:#1e8449 !important;" data-tooltip="📍 Kaynak: Mizan 100 (Kasa) + 102 (Bankalar) hesapları. 💡 Şirketin kasasında ve banka hesaplarında bulunan toplam nakit para. Ay sonundaki kümülatif bakiyeyi gösterir."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=account.list_scale">BANKA</a> <span class="info-icon">?</span></th>
                        <th class="income-header" data-tooltip="📍 Kaynak: Çek modülü - Portföydeki çekler. 💡 Müşterilerden alınan ve henüz tahsil edilmemiş çekler. Bu çekler kasada bekliyor, vadesi gelince bankaya verilecek."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=cheque.list_cheques">ÇEKLER</a> <span class="info-icon">?</span></th>
                        <th class="income-header" data-tooltip="📍 Kaynak: Çek modülü - Tahsil edilen çekler. 💡 Bankaya verilen ve parası hesaba geçen çekler. Artık nakit olarak elimizde."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=cheque.list_cheques">TAHSİL ÇEK</a> <span class="info-icon">?</span></th>
                        <th class="income-header" data-tooltip="📍 Kaynak: Kredi sözleşmeleri. 💡 Bankalardan kullanılan krediler. Şirkete giren para, ileride geri ödenecek."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=report.detail_credit_report">KREDİLER</a> <span class="info-icon">?</span></th>
                        <th class="income-header" data-tooltip="📍 Kaynak: Banka hareketleri - Emanet girişleri. 💡 Geçici olarak şirkete bırakılan paralar. Müşteri veya tedarikçiden alınan teminat/depozito."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=bank.list_bank_actions">EMANET</a> <span class="info-icon">?</span></th>
                        <th class="income-header" data-tooltip="📍 Kaynak: Banka hareketleri - Avans tahsilatları. 💡 Müşterilerden sipariş öncesi alınan ön ödemeler. Henüz mal/hizmet verilmeden alınan para."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=bank.list_bank_actions">AVANS TAH.</a> <span class="info-icon">?</span></th>
                        <th class="income-header" data-tooltip="📍 Kaynak: Banka hareketleri - Cari tahsilatlar. 💡 Müşterilerden yapılan normal tahsilatlar. Satılan mal/hizmet karşılığı alınan ödemeler."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=bank.list_bank_actions">CARİ TAH.</a> <span class="info-icon">?</span></th>
                        <th class="income-header" style="background:#5d6d7e" data-tooltip="📊 Hesaplama: Banka + Çekler + Krediler + Emanet + Avans + Cari tahsilatların toplamı. 💡 O ay şirkete giren tüm paraların toplamı.">TAH. TOP. <span class="info-icon">?</span></th>
                        <th class="income-header" style="background:#2980b9" data-tooltip="📊 Hesaplama: Tahsilat Toplamı + Önceki ayların kümülatif toplamı. 💡 Yılbaşından bu aya kadar şirkete giren toplam para.">TOPLAM <span class="info-icon">?</span></th>
                        <!--- Çıkışlar --->
                        <th class="expense-header" data-tooltip="📍 Kaynak: Çek modülü - Verilen çekler. 💡 Tedarikçilere verilen ve henüz ödenmemiş çekler. Vadesi gelince bankadan çekilecek."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=cheque.list_cheques">ÖDENMEMİŞ ÇEK</a> <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Çek modülü - Ödenen çekler. 💡 Tedarikçilere verilen ve bankadan ödenen çekler. Para hesaptan çıktı."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=cheque.list_cheques">ÖDENEN ÇEK</a> <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Kredi sözleşmeleri - Kalan borç. 💡 Bankalardan kullanılan kredilerin henüz ödenmemiş kısmı. İleride ödenmesi gereken tutar."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=report.detail_credit_report">KALAN KREDİ</a> <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Kredi sözleşmeleri - Yapılan ödemeler. 💡 Kredi taksitleri için bankaya yapılan ödemeler. Ana para + faiz."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=report.detail_credit_report">ÖDENEN KREDİ</a> <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Bordro sistemi. 💡 Çalışanlara ödenen maaşlar. Net maaş + SGK + Vergi kesintileri dahil toplam işçilik maliyeti.">MAAŞLAR <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Mizan 309 hesabı. 💡 Şirket kredi kartlarından yapılan harcamalar. Ay sonunda bankaya ödenen kredi kartı borçları."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=account.list_scale">K.KARTI</a> <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Banka hareketleri - Emanet iadeleri. 💡 Daha önce alınan emanetlerin geri ödemesi. Teminat/depozito iadeleri.">EMANET ÖD. <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Banka hareketleri - Cari ödemeler. 💡 Tedarikçilere yapılan normal ödemeler. Alınan mal/hizmet karşılığı ödemeler."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=bank.list_bank_actions">CARİ ÖD.</a> <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Banka hareketleri - Avans ödemeleri. 💡 Tedarikçilere verilen ön ödemeler. Mal/hizmet almadan önce yapılan ödemeler."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=bank.list_bank_actions">AVANS ÖD.</a> <span class="info-icon">?</span></th>
                        <th class="expense-header" data-tooltip="📍 Kaynak: Banka hareketleri - Diğer ödemeler. 💡 Kira, fatura, vergi gibi diğer giderler. Kategorize edilmemiş çıkışlar."><a href="https://e-arn.arnikon.com/index.cfm?fuseaction=bank.list_bank_actions">DİĞER ÖD.</a> <span class="info-icon">?</span></th>
                        <th class="expense-header" style="background:#922b21" data-tooltip="📊 Hesaplama: Tüm çıkış kalemlerinin toplamı. 💡 O ay şirketten çıkan tüm paraların toplamı. Ne kadar harcadık?">ÖD. TOP. <span class="info-icon">?</span></th>
                        <th class="balance-header" data-tooltip="📊 Hesaplama: Girişler - Çıkışlar. 💡 Ay sonunda elimizde kalan net para. Pozitif = kar, Negatif = zarar.">BAKİYE <span class="info-icon">?</span></th>
                        <th class="forecast-header" data-tooltip="📍 Kaynak: Sipariş planlaması. 💡 Yurtiçi müşterilerden beklenen alacaklar. Kesilmiş faturalar, henüz tahsil edilmemiş.">Y.İÇİ <span class="info-icon">?</span></th>
                        <th class="forecast-header" data-tooltip="📍 Kaynak: Sipariş planlaması. 💡 Yurtdışı müşterilerden beklenen alacaklar. İhracat faturaları, henüz tahsil edilmemiş.">Y.DIŞI <span class="info-icon">?</span></th>
                        <th class="forecast-header" style="background:#b7950b" data-tooltip="📊 Hesaplama: Bakiye + Yurtiçi + Yurtdışı alacaklar. 💡 Beklenen alacaklar dahil toplam fon durumu. Gelecek tahminimiz.">FON +/- <span class="info-icon">?</span></th>
                    </tr>
                </thead>
                <tbody>
                <!--- 2025 DATA (if selected) --->
                <cfif attributes.include_2025 eq 1>
                <cfoutput query="get_scen_2025">
                    <cfset kasa_total = banka_total = cek_total = tahsil_cek_total = krediler_ve_diger_total = cari_emanet_total = cari_tashilat = avans_tahsilat = 0>
                    <cfset cikis_cek_total = cikis_odenen_cek_total = cikis_krediler_total = odenen_cikis_krediler_total = cikis_maaslar_total = cikis_kk_total = giris_kk_total = cikis_diger_total = cikis_cari_odeme_total = cikis_avans_odeme_total = diger_odeme_total = cikis_emanet_odenen= 0>
                    <cfset cikis_cek_total = cikis_odenen_cek_total = cikis_krediler_total = odenen_cikis_krediler_total = cikis_maaslar_total = cikis_kk_total = giris_kk_total = cikis_diger_total = cikis_cari_odeme_total = cikis_avans_odeme_total = cikis_emanet_odeme_total = diger_odeme_total = cikis_emanet_odenen= 0>
                    <cfset nakit_girisler_toplam = nakit_cikislar_toplam = yurtici_alicilar_total = yurtdisi_alicilar_total = bakiye = 0>
                    <cfset current_year = 2025>
                    <tr style="background:##fff3cd;">
                        <td class="text-center text-bold font-dark" style="background:##ffc107; color:##000;">#ListGetAt(ay_listesi,thedate)# - 2025</td>
                        <td class="text-center" style="background:##fff8e1">
                            #TLFormat(BORC_CHEQUE_TOTAL*ListLast(attributes.money,','))#
                            <cfset banka_total += BORC_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_kasa_banka_total += BORC_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            #TLFormat(BORC_CHEQUE_TOTAL*ListLast(attributes.money,','))#
                            <cfset cek_total += BORC_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cek_total += BORC_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            #TLFormat(BORC_TAHSIL_CHEQUE_TOTAL*ListLast(attributes.money,','))#
                            <cfset tahsil_cek_total += BORC_TAHSIL_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_tahsil_cek_total += BORC_TAHSIL_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            #TLFormat(BORC_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,','))#
                            <cfset krediler_ve_diger_total += BORC_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_krediler_ve_diger_total += BORC_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            #TLFormat((BORC_CARI_EMANET+BORC_KK_EMANET)*ListLast(attributes.money,','))#
                            <cfset cari_emanet_total += (BORC_CARI_EMANET+BORC_KK_EMANET)*ListLast(attributes.money,',')>
                            <cfset dip_top_cari_emanet_total += (BORC_CARI_EMANET+BORC_KK_EMANET)*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            #TLFormat(BORC_AVANS_OTHER_TOTAL*ListLast(attributes.money,','))#
                            <cfset cari_tashilat += BORC_AVANS_OTHER_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cari_tashilat += BORC_AVANS_OTHER_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            #TLFormat(BORC_AVANS_TOTAL*ListLast(attributes.money,','))#
                            <cfset avans_tahsilat += BORC_AVANS_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_avans_tahsilat += BORC_AVANS_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffe082">
                            #TLFormat(banka_total+cek_total+tahsil_cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat)#
                            <cfset dip_top_tahsilat += banka_total+cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            #TLFormat(banka_total+cek_total+tahsil_cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat+dip_top)#
                            <cfset nakit_girisler_toplam += banka_total+cek_total+tahsil_cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat>
                            <cfset dip_top += banka_total+cek_total+tahsil_cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat>
                        </td>
                        <!--- Çıkışlar 2025 --->
                        <td class="text-center" style="background:##ffebee">#TLFormat(ALACAK_CHEQUE_TOTAL*ListLast(attributes.money,','))#<cfset cikis_cek_total += ALACAK_CHEQUE_TOTAL*ListLast(attributes.money,',')><cfset dip_top_cikis_cek_total += ALACAK_CHEQUE_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(ALACAK_ODENEN_CHEQUE_TOTAL*ListLast(attributes.money,','))#<cfset cikis_odenen_cek_total += ALACAK_ODENEN_CHEQUE_TOTAL*ListLast(attributes.money,',')><cfset dip_top_odenen_cikis_cek_total += ALACAK_ODENEN_CHEQUE_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,','))#<cfset cikis_krediler_total += ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')><cfset dip_top_cikis_krediler_total += ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(ODENEN_ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,','))#<cfset odenen_cikis_krediler_total += ODENEN_ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')><cfset dip_top_odenen_cikis_krediler_total += ODENEN_ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(ALACAK_MAAS_TOTAL*ListLast(attributes.money,','))#<cfset cikis_maaslar_total += ALACAK_MAAS_TOTAL*ListLast(attributes.money,',')><cfset dip_top_cikis_maaslar_total += ALACAK_MAAS_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(BORC_KK_TOTAL*ListLast(attributes.money,','))#<cfset cikis_kk_total += BORC_KK_TOTAL*ListLast(attributes.money,',')><cfset dip_top_cikis_kk_total += BORC_KK_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(ALACAK_EMANET_TOTAL*ListLast(attributes.money,','))#<cfset cikis_emanet_odeme_total += ALACAK_EMANET_TOTAL*ListLast(attributes.money,',')><cfset dip_top_cikis_emanet_odeme_total += ALACAK_EMANET_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(ALACAK_AVANS_OTHER_TOTAL*ListLast(attributes.money,','))#<cfset cikis_cari_odeme_total += ALACAK_AVANS_OTHER_TOTAL*ListLast(attributes.money,',')><cfset dip_top_cikis_cari_odeme_total += ALACAK_AVANS_OTHER_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(ALACAK_AVANS_TOTAL*ListLast(attributes.money,','))#<cfset cikis_avans_odeme_total += ALACAK_AVANS_TOTAL*ListLast(attributes.money,',')><cfset dip_top_cikis_avans_odeme_total += ALACAK_AVANS_TOTAL*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffebee">#TLFormat(ALACAK_DIGER_ODEME*ListLast(attributes.money,','))#<cfset diger_odeme_total += ALACAK_DIGER_ODEME*ListLast(attributes.money,',')><cfset dip_top_cikis_diger_odeme_total += ALACAK_DIGER_ODEME*ListLast(attributes.money,',')></td>
                        <td class="text-center" style="background:##ffcdd2">
                            #TLFormat(cikis_cek_total+cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total)#
                            <cfset nakit_cikislar_toplam += cikis_cek_total+cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total>
                            <cfset dip_top_nakit_cikislar_toplam += cikis_cek_total+cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total>
                        </td>
                        <td class="text-center" style="background:##ecf0f1">
                            #TLFormat(nakit_girisler_toplam-nakit_cikislar_toplam+dip_top_bakiye)#
                            <cfset bakiye += nakit_girisler_toplam-nakit_cikislar_toplam>
                            <cfset dip_top_bakiye += nakit_girisler_toplam-nakit_cikislar_toplam>
                        </td>
                        <td class="text-center" style="background:##fff8e1">0,00</td>
                        <td class="text-center" style="background:##fff8e1">0,00</td>
                        <td class="text-center" style="background:##ffe0b2">#TLFormat(nakit_girisler_toplam-nakit_cikislar_toplam)#</td>
                    </tr>
                </cfoutput>
                </cfif>
                <!--- 2026 DATA (current year) --->
                <cfoutput query="get_scen">
                    <cfset kasa_total = banka_total = cek_total = tahsil_cek_total = krediler_ve_diger_total = cari_emanet_total = cari_tashilat = avans_tahsilat = 0>
                    <cfset cikis_cek_total = cikis_odenen_cek_total = cikis_krediler_total = odenen_cikis_krediler_total = cikis_maaslar_total = cikis_kk_total = giris_kk_total = cikis_diger_total = cikis_cari_odeme_total = cikis_avans_odeme_total = diger_odeme_total = cikis_emanet_odenen= 0>
                    <cfset cikis_cek_total = cikis_odenen_cek_total = cikis_krediler_total = odenen_cikis_krediler_total = cikis_maaslar_total = cikis_kk_total = giris_kk_total = cikis_diger_total = cikis_cari_odeme_total = cikis_avans_odeme_total = cikis_emanet_odeme_total = diger_odeme_total = cikis_emanet_odenen= 0>
                    <cfset nakit_girisler_toplam = nakit_cikislar_toplam = yurtici_alicilar_total = yurtdisi_alicilar_total = bakiye = 0>
                    <tr>
                        <td class="text-center text-bold font-dark" style="background:##f8f9fa">#ListGetAt(ay_listesi,thedate)# - #session.ep.period_year#</td>
                        <td class="text-center" title="Banka: #TLFormat(BANK_TOTAL)# Devir: #TLFormat(dip_top_kasa_banka_total2)# Zirve: #TLFormat(filterNum(getMonthlyBalance["T_BAKIYE"][currentrow]))#" style="background:##e8f5e9">
                            <cfif thedate lte month(now())>
                                #TLFormat((BANK_TOTAL+filterNum(getMonthlyBalance["T_BAKIYE"][currentrow])+dip_top_kasa_banka_total2)*ListLast(attributes.money,','))#
                                <cfset banka_total += (BANK_TOTAL+filterNum(getMonthlyBalance["T_BAKIYE"][currentrow])+dip_top_kasa_banka_total2)*ListLast(attributes.money,',')>
                                <cfset dip_top_kasa_banka_total += banka_total>
                                <cfset dip_top_kasa_banka_total2 += BANK_TOTAL+filterNum(getMonthlyBalance["T_BAKIYE"][currentrow])>
                            <cfelse>
                                0,00
                            </cfif>
                        </td>
                        <td class="text-center" style="background:##e8f5e9">
                            #TLFormat(BORC_CHEQUE_TOTAL*ListLast(attributes.money,','))#
                            <cfset cek_total += BORC_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cek_total += BORC_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##e8f5e9">
                            #TLFormat(BORC_TAHSIL_CHEQUE_TOTAL*ListLast(attributes.money,','))#
                            <cfset tahsil_cek_total += BORC_TAHSIL_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_tahsil_cek_total += BORC_TAHSIL_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##e8f5e9">
                            #TLFormat(BORC_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,','))#
                            <cfset krediler_ve_diger_total += BORC_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_krediler_ve_diger_total += BORC_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##e8f5e9">
                            #TLFormat((BORC_CARI_EMANET+BORC_KK_EMANET)*ListLast(attributes.money,','))#
                            <cfset cari_emanet_total += (BORC_CARI_EMANET+BORC_KK_EMANET)*ListLast(attributes.money,',')>
                            <cfset dip_top_cari_emanet_total += (BORC_CARI_EMANET+BORC_KK_EMANET)*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##e8f5e9">
                            #TLFormat(BORC_AVANS_OTHER_TOTAL*ListLast(attributes.money,','))#
                            <cfset cari_tashilat += BORC_AVANS_OTHER_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cari_tashilat += BORC_AVANS_OTHER_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##e8f5e9">
                            #TLFormat(BORC_AVANS_TOTAL*ListLast(attributes.money,','))#
                            <cfset avans_tahsilat += BORC_AVANS_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_avans_tahsilat += BORC_AVANS_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center has-breakdown" style="background:##c8e6c9" data-breakdown="📊 TAHSİLAT TOPLAMI:
➕ Banka: #TLFormat(banka_total)#
➕ Çekler: #TLFormat(cek_total)#
➕ Tahsil Çek: #TLFormat(tahsil_cek_total)#
➕ Krediler: #TLFormat(krediler_ve_diger_total)#
➕ Emanet: #TLFormat(cari_emanet_total)#
➕ Avans Tah: #TLFormat(cari_tashilat)#
➕ Cari Tah: #TLFormat(avans_tahsilat)#">
                            #TLFormat(banka_total+cek_total+tahsil_cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat)#
                            <cfset dip_top_tahsilat += banka_total+cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat>
                        </td>
                        <td class="text-center" style="background:##e8f5e9">
                            #TLFormat(banka_total+cek_total+tahsil_cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat+dip_top)#
                            <cfset nakit_girisler_toplam += banka_total+cek_total+tahsil_cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat>
                            <cfset dip_top += banka_total+cek_total+tahsil_cek_total+krediler_ve_diger_total+cari_emanet_total+cari_tashilat+avans_tahsilat>
                        </td>
                        <!--- Çıkışlar --->
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_CHEQUE_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_cek_total += ALACAK_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_cek_total += ALACAK_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_ODENEN_CHEQUE_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_odenen_cek_total += ALACAK_ODENEN_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_odenen_cikis_cek_total += ALACAK_ODENEN_CHEQUE_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_krediler_total += ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_krediler_total += ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(ODENEN_ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,','))#
                            <cfset odenen_cikis_krediler_total += ODENEN_ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_odenen_cikis_krediler_total += ODENEN_ALACAK_CREDIT_CONTRACT_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_MAAS_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_maaslar_total += ALACAK_MAAS_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_maaslar_total += ALACAK_MAAS_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(BORC_KK_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_kk_total += BORC_KK_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_kk_total += BORC_KK_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffebee" alt="Emanet Ödenen">
                            #TLFormat(ALACAK_EMANET_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_emanet_odeme_total += ALACAK_EMANET_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_emanet_odeme_total += ALACAK_EMANET_TOTAL*ListLast(attributes.money,',')>                        
                         </td>
                        <!-- <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_KK_TOTAL*ListLast(attributes.money,','))#
                            <cfset giris_kk_total += ALACAK_KK_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_giris_kk_total += ALACAK_KK_TOTAL*ListLast(attributes.money,',')>
                        </td>-->
                        <!-- <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_DIGER_GIDER_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_diger_total += ALACAK_DIGER_GIDER_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_diger_total += ALACAK_DIGER_GIDER_TOTAL*ListLast(attributes.money,',')>
                        </td>-->
                        <!--- <td class="text-center" style="background:##ffebee">
                            #TLFormat((ALACAK_AVANS_OTHER_TOTAL+ALACAK_AVANS_TOTAL)*ListLast(attributes.money,','))#
                            <cfset cikis_cari_odeme_total += (ALACAK_AVANS_OTHER_TOTAL+ALACAK_AVANS_TOTAL)*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_cari_odeme_total += (ALACAK_AVANS_OTHER_TOTAL+ALACAK_AVANS_TOTAL)*ListLast(attributes.money,',')>
                        </td> --->
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_AVANS_OTHER_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_cari_odeme_total += ALACAK_AVANS_OTHER_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_cari_odeme_total += ALACAK_AVANS_OTHER_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_AVANS_TOTAL*ListLast(attributes.money,','))#
                            <cfset cikis_avans_odeme_total += ALACAK_AVANS_TOTAL*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_avans_odeme_total += ALACAK_AVANS_TOTAL*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffebee">
                            #TLFormat(ALACAK_DIGER_ODEME*ListLast(attributes.money,','))#
                            <cfset diger_odeme_total += ALACAK_DIGER_ODEME*ListLast(attributes.money,',')>
                            <cfset dip_top_cikis_diger_odeme_total += ALACAK_DIGER_ODEME*ListLast(attributes.money,',')>
                        </td>
                        <td class="text-center" style="background:##ffcdd2" title="#cikis_kk_total#">
                            <!---#TLFormat(cikis_cek_total+cikis_odenen_cek_total+cikis_krediler_total+odenen_cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+giris_kk_total+cikis_diger_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total)#
                            <cfset nakit_cikislar_toplam += cikis_cek_total+cikis_odenen_cek_total+cikis_krediler_total+odenen_cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+giris_kk_total+cikis_diger_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total>
                            <cfset dip_top_nakit_cikislar_toplam += cikis_cek_total+cikis_odenen_cek_total+cikis_krediler_total+odenen_cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+giris_kk_total+cikis_diger_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total>--->

                            #TLFormat(cikis_cek_total+cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total)#
                            <cfset nakit_cikislar_toplam += cikis_cek_total+cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total>
                            <cfset dip_top_nakit_cikislar_toplam += cikis_cek_total+cikis_krediler_total+cikis_maaslar_total+cikis_kk_total+cikis_cari_odeme_total+cikis_avans_odeme_total+diger_odeme_total>
                        </td>
                        <td class="text-center" style="background:##ecf0f1">
                            #TLFormat(nakit_girisler_toplam-nakit_cikislar_toplam+dip_top_bakiye)#
                            <cfset bakiye += nakit_girisler_toplam-nakit_cikislar_toplam>
                            <cfset dip_top_bakiye += nakit_girisler_toplam-nakit_cikislar_toplam>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            <cfquery name="get_plan_rows" dbtype="query">
                                SELECT * FROM get_order_plan_rows WHERE MONTH_DATE = #THEDATE#
                            </cfquery>
                            <cfif thedate lte month(now()) and get_plan_rows.recordcount>
                                #TLFormat(get_plan_rows.YURTICI_ALICILAR*ListLast(attributes.money,','))#
                                <cfset yurtici_alicilar_total += get_plan_rows.YURTICI_ALICILAR*ListLast(attributes.money,',')>
                                <cfset dip_top_yurtici_alicilar_total += get_plan_rows.YURTICI_ALICILAR*ListLast(attributes.money,',')>
                            <cfelse>
                                0,00
                                <cfset yurtici_alicilar_total += 0>
                                <cfset dip_top_yurtici_alicilar_total += 0>
                            </cfif>
                        </td>
                        <td class="text-center" style="background:##fff8e1">
                            <cfif thedate lte month(now()) and get_plan_rows.recordcount>
                                #TLFormat(get_plan_rows.YURTDISI_ALICILAR*ListLast(attributes.money,','))#
                                <cfset yurtdisi_alicilar_total += get_plan_rows.YURTDISI_ALICILAR*ListLast(attributes.money,',')>
                                <cfset dip_top_yurtdisi_alicilar_total += get_plan_rows.YURTDISI_ALICILAR*ListLast(attributes.money,',')>
                            <cfelse>
                                0,00
                                <cfset yurtdisi_alicilar_total += 0>
                                <cfset dip_top_yurtdisi_alicilar_total += 0>
                            </cfif>
                        </td>
                        <td class="text-center" style="background:##ffe0b2">
                            #TLFormat(nakit_girisler_toplam-nakit_cikislar_toplam+yurtici_alicilar_total+yurtdisi_alicilar_total)#
                            <cfset fon_bakiye_dip_toplam += nakit_girisler_toplam-nakit_cikislar_toplam+yurtici_alicilar_total+yurtdisi_alicilar_total>
                        </td>
                    </tr>
                </cfoutput>
            </tbody>
            <tfoot>
                <cfoutput>
                    <tr>
                        <td class="text-center text-bold font-dark" style="background:##34495e;color:##fff">G.TOPLAM</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_kasa_banka_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cek_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_tahsil_cek_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_krediler_ve_diger_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cari_emanet_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cari_tashilat)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_avans_tahsilat)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_tahsilat)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top)#</td>
                        <!--- çıkışlar --->
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_cek_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_odenen_cikis_cek_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_krediler_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_odenen_cikis_krediler_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_maaslar_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_kk_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_emanet_odeme_total)#</td>
                        <!--<td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_giris_kk_total)#</td>-->
                        <!--<td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_diger_total)#</td>-->
                        <!--- <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_cari_odeme_total)#</td> --->
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_cari_odeme_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_avans_odeme_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_cikis_diger_odeme_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_nakit_cikislar_toplam)#</td>
                        <td class="text-center text-bold font-dark" style="background:##e3f2fd">#TLFormat(dip_top_bakiye)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_yurtici_alicilar_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(dip_top_yurtdisi_alicilar_total)#</td>
                        <td class="text-center text-bold font-dark" style="background:##fff3e0">#TLFormat(fon_bakiye_dip_toplam)#</td>
                    </tr>
                </cfoutput>
            </tfoot>
            </table>
        </div>
    </div>
    
    <!--- Modern Dashboard with Charts --->
    <div class="chart-container animate-in" style="margin-top:24px;">
        <h3>📊 Nakit Akış Grafiği</h3>
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:20px;">
            <div>
                <canvas id="cashFlowChart" height="300"></canvas>
            </div>
            <div>
                <canvas id="balanceChart" height="300"></canvas>
            </div>
        </div>
    </div>
    
    <!--- Stats Summary Cards --->
    <div class="stats-grid animate-in" style="margin-top:24px;">
        <cfoutput>
        <div class="stat-card income">
            <div class="label">💰 Toplam Girişler</div>
            <div class="value">#TLFormat(dip_top)# #listFirst(attributes.money,',')#</div>
            <div class="trend up">▲ Bu yılın toplamı</div>
        </div>
        <div class="stat-card expense">
            <div class="label">💸 Toplam Çıkışlar</div>
            <div class="value">#TLFormat(dip_top_nakit_cikislar_toplam)# #listFirst(attributes.money,',')#</div>
            <div class="trend down">▼ Bu yılın toplamı</div>
        </div>
        <div class="stat-card balance">
            <div class="label">📈 Net Bakiye</div>
            <div class="value">#TLFormat(dip_top_bakiye)# #listFirst(attributes.money,',')#</div>
            <div class="trend #iif(dip_top_bakiye gte 0, de('up'), de('down'))#">#iif(dip_top_bakiye gte 0, de('▲ Pozitif'), de('▼ Negatif'))#</div>
        </div>
        <div class="stat-card forecast">
            <div class="label">🔮 Fon Bakiyesi</div>
            <div class="value">#TLFormat(fon_bakiye_dip_toplam)# #listFirst(attributes.money,',')#</div>
            <div class="trend">Alacaklar dahil</div>
        </div>
        </cfoutput>
    </div>
    
    <!--- Export Buttons --->
    <div style="display:flex; gap:12px; margin-top:20px; justify-content:flex-end;">
        <button class="btn-modern btn-success" onclick="exportToExcel()">
            <span>📥</span> Excel'e Aktar
        </button>
        <button class="btn-modern btn-danger" onclick="window.print()">
            <span>🖨️</span> PDF / Yazdır
        </button>
    </div>
</cfform>
</div>

<!--- Chart.js Initialization --->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Chart Data from ColdFusion
    const months = [<cfoutput>#ListQualify(ay_listesi, "'")#</cfoutput>];
    const incomeData = [<cfoutput query="get_scen">#BORC_CHEQUE_TOTAL+BORC_TAHSIL_CHEQUE_TOTAL+BORC_CREDIT_CONTRACT_TOTAL+BORC_CARI_EMANET+BORC_AVANS_OTHER_TOTAL+BORC_AVANS_TOTAL#<cfif currentrow lt recordcount>,</cfif></cfoutput>];
    const expenseData = [<cfoutput query="get_scen">#ALACAK_CHEQUE_TOTAL+ALACAK_CREDIT_CONTRACT_TOTAL+ALACAK_MAAS_TOTAL+BORC_KK_TOTAL+ALACAK_AVANS_OTHER_TOTAL+ALACAK_AVANS_TOTAL+ALACAK_DIGER_ODEME#<cfif currentrow lt recordcount>,</cfif></cfoutput>];
    
    // Calculate cumulative balance
    let cumulativeBalance = [];
    let runningTotal = 0;
    for(let i = 0; i < 12; i++) {
        runningTotal += (incomeData[i] || 0) - (expenseData[i] || 0);
        cumulativeBalance.push(runningTotal);
    }
    
    // Cash Flow Bar Chart
    const ctx1 = document.getElementById('cashFlowChart');
    if(ctx1) {
        new Chart(ctx1, {
            type: 'bar',
            data: {
                labels: months,
                datasets: [
                    {
                        label: 'Girişler',
                        data: incomeData,
                        backgroundColor: 'rgba(40, 167, 69, 0.7)',
                        borderColor: 'rgba(40, 167, 69, 1)',
                        borderWidth: 1,
                        borderRadius: 4
                    },
                    {
                        label: 'Çıkışlar',
                        data: expenseData,
                        backgroundColor: 'rgba(220, 53, 69, 0.7)',
                        borderColor: 'rgba(220, 53, 69, 1)',
                        borderWidth: 1,
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: true,
                        text: 'Aylık Nakit Girişler vs Çıkışlar'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return new Intl.NumberFormat('tr-TR').format(value);
                            }
                        }
                    }
                }
            }
        });
    }
    
    // Balance Line Chart
    const ctx2 = document.getElementById('balanceChart');
    if(ctx2) {
        new Chart(ctx2, {
            type: 'line',
            data: {
                labels: months,
                datasets: [{
                    label: 'Kümülatif Bakiye',
                    data: cumulativeBalance,
                    fill: true,
                    backgroundColor: 'rgba(102, 126, 234, 0.2)',
                    borderColor: 'rgba(102, 126, 234, 1)',
                    borderWidth: 3,
                    tension: 0.4,
                    pointBackgroundColor: 'rgba(102, 126, 234, 1)',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: true,
                        text: 'Kümülatif Nakit Akış Bakiyesi'
                    }
                },
                scales: {
                    y: {
                        ticks: {
                            callback: function(value) {
                                return new Intl.NumberFormat('tr-TR').format(value);
                            }
                        }
                    }
                }
            }
        });
    }
});

// Excel Export Function
function exportToExcel() {
    const table = document.querySelector('table');
    if(!table) {
        alert('Tablo bulunamadı!');
        return;
    }
    
    try {
        const wb = XLSX.utils.table_to_book(table, {sheet: "Nakit Akış"});
        XLSX.writeFile(wb, 'NakitAkis_<cfoutput>#session.ep.period_year#</cfoutput>.xlsx');
    } catch(e) {
        console.error('Excel export error:', e);
        alert('Excel export hatası: ' + e.message);
    }
}

// Print styles
const printStyles = `
    @media print {
        .btn-modern, .controls-panel, .chart-container, .stats-grid { display: none !important; }
        .modern-table { font-size: 10px !important; }
        body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
    }
`;
const styleSheet = document.createElement('style');
styleSheet.textContent = printStyles;
document.head.appendChild(styleSheet);

// Draggable Column Reordering
function initColumnDrag() {
    const table = document.getElementById('cashFlowTable');
    if (!table) return;
    
    const headerRow = table.querySelector('thead tr:last-child');
    if (!headerRow) return;
    
    // Make header cells draggable
    const headers = headerRow.querySelectorAll('th');
    headers.forEach((th, index) => {
        th.setAttribute('draggable', 'true');
        th.style.cursor = 'grab';
        th.dataset.colIndex = index;
        
        th.addEventListener('dragstart', (e) => {
            e.dataTransfer.setData('text/plain', index);
            th.style.opacity = '0.5';
        });
        
        th.addEventListener('dragend', () => {
            th.style.opacity = '1';
        });
        
        th.addEventListener('dragover', (e) => {
            e.preventDefault();
            th.style.background = '#667eea';
        });
        
        th.addEventListener('dragleave', () => {
            th.style.background = '';
        });
        
        th.addEventListener('drop', (e) => {
            e.preventDefault();
            const fromIndex = parseInt(e.dataTransfer.getData('text/plain'));
            const toIndex = index;
            
            if (fromIndex !== toIndex) {
                reorderColumns(table, fromIndex, toIndex);
            }
            th.style.background = '';
        });
    });
}

function reorderColumns(table, fromIndex, toIndex) {
    const rows = table.querySelectorAll('tr');
    
    rows.forEach(row => {
        const cells = Array.from(row.children);
        if (cells[fromIndex] && cells[toIndex]) {
            const cell = cells[fromIndex];
            if (fromIndex < toIndex) {
                row.insertBefore(cell, cells[toIndex].nextSibling);
            } else {
                row.insertBefore(cell, cells[toIndex]);
            }
        }
    });
    
    // Save column order to localStorage
    const headerRow = table.querySelector('thead tr:last-child');
    const headers = headerRow.querySelectorAll('th');
    const order = Array.from(headers).map(th => th.textContent.trim());
    localStorage.setItem('cashFlowColumnOrder', JSON.stringify(order));
}

// Initialize drag on page load
document.addEventListener('DOMContentLoaded', initColumnDrag);

// Force multiselect styling to match modern-select (jQuery)
$(document).ready(function() {
    setTimeout(function() {
        $('.custom-select-wrapper .ui-multiselect').css({
            'border': '1px solid #dee2e6',
            'border-radius': '8px',
            'height': '42px',
            'padding': '10px 36px 10px 16px',
            'font-size': '14px',
            'background': 'white',
            'box-sizing': 'border-box',
            'width': '100%'
        });
    }, 100);
});
</script>