<!-- WC_TASKS_BEGIN - Sipariş Operasyon Görevleri Entegrasyonu (2026-01-23 v2) -->
<!--- Görevler Modal Panel (Fixed Position) --->
<div id="wc_tasks_overlay" onclick="WC_TASKS_toggle();" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:9998;"></div>
<div id="wc_tasks_panel" style="display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);width:900px;max-width:90%;max-height:80%;overflow:auto;border-radius:4px;background:##fff;box-shadow:0 4px 20px rgba(0,0,0,0.3);z-index:9999;">
	<div style="background:##3498db;color:##fff;padding:12px 15px;overflow:hidden;position:sticky;top:0;z-index:1;">
		<strong><i class="fa fa-tasks"></i> Görevler (Operasyonlar)</strong>
		<cfoutput><span style="margin-left:8px;font-weight:normal;opacity:0.9;">#get_order_detail.order_number#</span></cfoutput>
		<a href="javascript:void(0);" onclick="WC_TASKS_toggle();" style="float:right;color:##fff;text-decoration:none;font-size:20px;line-height:1;padding:0 5px;" title="Kapat">&times;</a>
	</div>
	<div id="wc_tasks_content" style="min-height:200px;padding:0;"></div>
</div>

<cfoutput>
<script>
(function(){
'use strict';
var WC_TASKS = {
	debug: false,
	loaded: false,
	loading: false,
	cfg: {
		orderId: null,
		orderNo: '#JSStringFormat(get_order_detail.order_number)#',
		companyId: #val(session.ep.company_id)#,
		cfOrderId: #val(attributes.order_id)#,
		listUrl: '/V16/sales/display/ops_task_list.cfm',
		formUrl: '/V16/sales/form/dsp_ops_task.cfm'
	}
};

function _log(){
	if(WC_TASKS.debug && console && console.log){
		console.log.apply(console, ['[WC_TASKS]'].concat(Array.prototype.slice.call(arguments)));
	}
}

function _getOrderId(){
	var inp = document.getElementById('order_id');
	if(inp && inp.value && parseInt(inp.value,10) > 0) return parseInt(inp.value,10);
	var urlParams = new URLSearchParams(window.location.search);
	var urlId = urlParams.get('order_id');
	if(urlId && parseInt(urlId,10) > 0) return parseInt(urlId,10);
	if(WC_TASKS.cfg.cfOrderId > 0) return WC_TASKS.cfg.cfOrderId;
	return 0;
}

function _esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

window.WC_TASKS_toggle = function(){
	_log('toggle');
	var p = document.getElementById('wc_tasks_panel');
	var o = document.getElementById('wc_tasks_overlay');
	if(!p) return;
	if(p.style.display === 'block'){
		p.style.display = 'none';
		if(o) o.style.display = 'none';
	} else {
		if(o) o.style.display = 'block';
		p.style.display = 'block';
		if(!WC_TASKS.loaded && !WC_TASKS.loading) WC_TASKS_load();
	}
};

window.WC_TASKS_load = function(){
	_log('load');
	var c = document.getElementById('wc_tasks_content');
	if(!c) return;
	var oid = _getOrderId();
	WC_TASKS.cfg.orderId = oid;
	if(!oid || oid <= 0){
		c.innerHTML = '<div style="padding:30px;text-align:center;color:##c00;"><i class="fa fa-exclamation-triangle fa-2x"></i><br><br><b>Hata:</b> order_id bulunamadı</div>';
		return;
	}
	WC_TASKS.loading = true;
	c.innerHTML = '<div style="text-align:center;padding:50px;"><i class="fa fa-spinner fa-spin fa-2x"></i><br><br>Yükleniyor...</div>';
	var url = WC_TASKS.cfg.listUrl + '?order_id=' + oid + '&company_id=' + WC_TASKS.cfg.companyId + '&_t=' + Date.now();
	_log('URL:', url);
	var xhr = new XMLHttpRequest();
	xhr.open('GET', url, true);
	xhr.timeout = 30000;
	xhr.onreadystatechange = function(){
		if(xhr.readyState === 4){
			WC_TASKS.loading = false;
			var st = xhr.status, res = xhr.responseText || '';
			_log('Status:', st, 'Len:', res.length);
			if(st === 200){
				if(!res.trim()){
					c.innerHTML = '<div style="padding:30px;text-align:center;color:##666;"><i class="fa fa-info-circle fa-2x"></i><br><br>Boş yanıt</div>';
				} else if(res.indexOf('login') > -1 && res.indexOf('<form') > -1){
					c.innerHTML = '<div style="padding:30px;text-align:center;color:##c00;"><i class="fa fa-lock fa-2x"></i><br><br><b>Session Sorunu</b><br><a href="javascript:location.reload();">Yenile</a></div>';
				} else {
					c.innerHTML = res;
					WC_TASKS.loaded = true;
				}
			} else if(st === 500){
				c.innerHTML = '<div style="padding:20px;color:##c00;"><b>Sunucu Hatası (500)</b><br><pre style="background:##f5f5f5;padding:10px;font-size:11px;max-height:150px;overflow:auto;">'+_esc(res.substring(0,400))+'</pre><button onclick="WC_TASKS_load();">Tekrar</button></div>';
			} else if(st === 404){
				c.innerHTML = '<div style="padding:30px;text-align:center;color:##c00;"><b>404 - Dosya Bulunamadı</b></div>';
			} else {
				c.innerHTML = '<div style="padding:30px;text-align:center;color:##c00;"><b>Hata ('+st+')</b><br><button onclick="WC_TASKS_load();">Tekrar</button></div>';
			}
		}
	};
	xhr.ontimeout = function(){ WC_TASKS.loading = false; c.innerHTML = '<div style="padding:30px;text-align:center;color:##c00;"><b>Zaman Aşımı</b><br><button onclick="WC_TASKS_load();">Tekrar</button></div>'; };
	xhr.onerror = function(){ WC_TASKS.loading = false; c.innerHTML = '<div style="padding:30px;text-align:center;color:##c00;"><b>Ağ Hatası</b><br><button onclick="WC_TASKS_load();">Tekrar</button></div>'; };
	xhr.send();
};

window.WC_TASKS_refresh = function(){ WC_TASKS.loaded = false; WC_TASKS_load(); };

window.WC_TASKS_newTask = function(){
	var oid = _getOrderId();
	if(!oid){ alert('order_id yok!'); return; }
	var url = WC_TASKS.cfg.formUrl + '?order_id=' + oid + '&company_id=' + WC_TASKS.cfg.companyId;
	if(typeof openBoxDraggable === 'function') openBoxDraggable(url, 'wc_task_form');
	else window.open(url, 'wc_task_form', 'width=700,height=500,scrollbars=yes');
};

window.WC_TASKS_debugOn = function(){ WC_TASKS.debug = true; console.log('[WC_TASKS] Debug ON'); };
window.WC_TASKS_debugOff = function(){ WC_TASKS.debug = false; console.log('[WC_TASKS] Debug OFF'); };

// Menu injection
(function(){
	var added = false;
	function addMenu(){
		if(added) return;
		var ul = document.querySelector('ul.dropdown-menu.scrollContentDropDown');
		if(!ul){
			var uls = document.querySelectorAll('ul.dropdown-menu');
			for(var i=0; i<uls.length; i++){
				if(uls[i].innerHTML.indexOf('Fatura') > -1){ ul = uls[i]; break; }
			}
		}
		if(!ul) return;
		if(ul.querySelector('.wc-tasks-menu')){ added = true; return; }
		var li = document.createElement('li');
		li.className = 'wc-tasks-menu';
		li.innerHTML = '<a href="javascript:void(0);" onclick="WC_TASKS_toggle();"><i class="fa fa-tasks"></i> Görevler</a>';
		ul.appendChild(li);
		added = true;
		_log('Menu added');
	}
	setTimeout(addMenu, 500);
	setTimeout(addMenu, 1500);
	setTimeout(addMenu, 3000);
})();

})();
</script>
</cfoutput>
<!-- WC_TASKS_END -->
