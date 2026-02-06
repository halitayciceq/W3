<cftry>
    <cfquery name="GET_MNG_RESULT" datasource="SorunTakip" maxrows="1">
        SELECT FATSERI,FATNO FROM MNG WHERE REF_NO = '#get_order_detail.order_number#' AND FATSERI IS NOT NULL AND FATNO IS NOT NULL							
    </cfquery>
    <cfif get_mng_result.recordcount>
        <a href="javascript://" onclick="windowopen('http://service.mngkargo.com.tr/iactive/takip.asp?fatseri=<cfoutput>#get_mng_result.fatseri#&fatnumara=#get_mng_result.fatno#</cfoutput>&fi=2','horizantal');"><img src="/images/mng.png" title="MNG Kargo Bilgileri" border="0"></a>
    </cfif>
<cfcatch>
	<script type="text/javascript">
		alert("MNG Entegrasyonu Datası Çekildiği İçin Production Ortamında Hata Verebilir. XML Tanımını Kontrol Ediniz.");
	</script>
</cfcatch>
</cftry> 
