<cfsetting showdebugoutput="no">
<!--- TO_COMPLETE ve WORK_CURRENCY_ID güncelle --->
<!--- %0 = boş (NULL), %1-99 = Başlandı-Devam (2361), %100 = Tamamlandı (2364) --->
<cfset stageId = "">
<cfif len(deger) AND isNumeric(deger)>
    <cfif deger GTE 100>
        <cfset stageId = 2364><!--- Tamamlandı --->
    <cfelseif deger GT 0>
        <cfset stageId = 2361><!--- Başlandı - Devam --->
    </cfif>
</cfif>

<cfquery name="upd_work_complate" datasource="#dsn#">
	UPDATE 
		PRO_WORKS
	SET
		TO_COMPLETE = <cfif len(deger)>#deger#<cfelse>NULL</cfif>,
		WORK_CURRENCY_ID = <cfif len(stageId)>#stageId#<cfelse>NULL</cfif>
	WHERE
		PRO_WORKS.WORK_ID=#attributes.WORK_ID#
</cfquery>

<!--- Güncel stage bilgisini döndür - sayfayı yenile --->
<cfoutput>
<script>
    // Tüm select'leri tara ve work_id ile eşleşeni bul
    (function() {
        var workId = '#attributes.WORK_ID#';
        var newStageId = '<cfif len(stageId)>#stageId#<cfelse></cfif>';
        var allSelects = document.querySelectorAll('select');
        for(var i = 0; i < allSelects.length; i++) {
            var sel = allSelects[i];
            var onChangeAttr = sel.getAttribute('onchange') || '';
            if(onChangeAttr.indexOf('TaskStage(' + workId + ',') > -1 || onChangeAttr.indexOf('TaskStage(' + workId + ' ,') > -1) {
                sel.value = newStageId;
                break;
            }
        }
    })();
</script>
</cfoutput>
