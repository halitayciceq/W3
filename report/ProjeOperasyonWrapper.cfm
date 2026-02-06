<!--- Proje ve Operasyon Durumu - İframe Wrapper --->
<!--- Modern, temiz ve yönetilebilir yaklaşım --->

<style>
    #project-report-container {
        width: 100%;
        height: calc(100vh - 100px);
        min-height: 700px;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        background: #ffffff;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    #project-report-frame {
        width: 100%;
        height: 100%;
        border: none;
        border-radius: 8px;
    }
    
    .report-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 15px 20px;
        border-radius: 8px 8px 0 0;
        margin-bottom: 0;
    }
    
    .report-header h2 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }
    
    .loading-overlay {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 10;
        text-align: center;
    }
    
    .spinner {
        border: 3px solid #f3f3f3;
        border-top: 3px solid #667eea;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin: 0 auto 10px;
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
</style>

<div class="report-header">
    <h2>📊 Proje ve Operasyon Durumu Raporu</h2>
</div>

<div id="project-report-container">
    <div class="loading-overlay" id="loading">
        <div class="spinner"></div>
        <div>Rapor yükleniyor...</div>
    </div>
    <iframe 
        id="project-report-frame" 
        src="/documents/report/5560605B-BA40-44A6-1E209FF687575FC2.cfm"
        onload="document.getElementById('loading').style.display='none'"
        allowfullscreen>
    </iframe>
</div>

<script>
// İframe yükleme hatası durumu
document.getElementById('project-report-frame').onerror = function() {
    document.getElementById('loading').innerHTML = '❌ Rapor yüklenemedi!';
};

// Modern browser özellikleri
if (window.ResizeObserver) {
    const resizeObserver = new ResizeObserver(entries => {
        // Container boyutu değişikliklerini handle et
    });
    resizeObserver.observe(document.getElementById('project-report-container'));
}
</script>
