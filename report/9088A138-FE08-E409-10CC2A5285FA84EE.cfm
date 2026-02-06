<!--- Irak Depo Raporu - iframe Wrapper --->
<!--- Bu dosya W3 özel raporlarında kullanılır ve asıl raporu iframe içinde gösterir --->

<style>
    #irak-report-container {
        width: 100%;
        height: calc(100vh - 120px);
        min-height: 600px;
        border: none;
        background: #f8fafc;
    }
    #irak-report-frame {
        width: 100%;
        height: 100%;
        border: none;
    }
</style>

<div id="irak-report-container">
    <iframe id="irak-report-frame" src="/V16/stock/popup/irak_reports.cfm" allowfullscreen></iframe>
</div>
