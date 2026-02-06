# Sipariş Operasyon Görevleri - Proje Durumu

**Tarih:** 2026-02-06 19:31  
**Son Güncelleme:** Cascade AI

---

## 📍 KALDIĞIMIZ YER

### Çalışan Dosyalar (Geri Yüklendi)
```
/Volumes/prod/documents/report/5560605B-BA40-44A6-1E209FF687575FC2.cfm  ← copy 3'ten geri yüklendi
/Volumes/prod/V16/sales/form/dsp_ops_task_matrix.cfm                    ← bak_20260205'ten geri yüklendi
/Volumes/prod/V16/sales/query/ajax_ops_task.cfm                         ← update_percent ve get_project_id eklendi
```

### Git Durumu
- **Son Commit:** `7635ad7` - "Proje durumu ve yapılacaklar notu"
- **Repo:** https://github.com/halitayciceq/W3
- **Branch:** main

### Git Workflow (Önemli!)
```bash
# 1. Dosyayı W3 repo klasörüne kopyala
cp "/Volumes/prod/documents/report/DOSYA_ADI.cfm" ~/Documents/W3/report/

# 2. Git add, commit ve push
cd ~/Documents/W3
git add report/
git commit -m "Açıklama mesajı"
git push

# Tek satırda:
cp "/Volumes/prod/documents/report/DOSYA_ADI.cfm" ~/Documents/W3/report/ && cd ~/Documents/W3 && git add report/ && git commit -m "mesaj" && git push
```

### Repo Yapısı
```
~/Documents/W3/
├── report/
│   ├── 5560605B-BA40-44A6-1E209FF687575FC2.cfm  (Ana rapor)
│   ├── dsp_ops_task_matrix.cfm                   (Matris modal)
│   ├── PROJE_DURUMU_20260206.md                  (Bu dosya)
│   └── ...diğer dosyalar
└── README.md
```

### Prod ve Git Arasındaki İlişki
- **Prod (Canlı):** `/Volumes/prod/documents/report/`
- **Git Repo:** `~/Documents/W3/report/`
- Dosyalar önce prod'da düzenlenir, sonra W3'e kopyalanıp push edilir

### SSH Bilgileri
```bash
# SSH Key Dosyaları
~/.ssh/id_ed25519      # Private key
~/.ssh/id_ed25519.pub  # Public key
~/.ssh/config          # SSH config
~/.ssh/known_hosts     # Bilinen hostlar

# GitHub SSH URL
git@github.com:halitayciceq/W3.git

# SSH Bağlantı Testi
ssh -T git@github.com
# Başarılı çıktı: "Hi halitayciceq! You've successfully authenticated..."

# Public Key'i Görüntüle (GitHub'a eklemek için)
cat ~/.ssh/id_ed25519.pub
```

### SSH Key Yoksa Oluşturma
```bash
# Yeni SSH key oluştur
ssh-keygen -t ed25519 -C "email@example.com"

# SSH agent'a ekle
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Public key'i kopyala ve GitHub > Settings > SSH Keys'e ekle
cat ~/.ssh/id_ed25519.pub
```

---

## ✅ TAMAMLANAN İŞLER

1. **Toggle Butonu** - Sipariş task listesini aç/kapa çalışıyor
2. **Task Listesi** - Siparişe bağlı tasklar görüntüleniyor
3. **Task % Güncelleme** - `updateOrderTaskPercent()` fonksiyonu çalışıyor
4. **Task Aşama Güncelleme** - `updateOrderTaskStage()` fonksiyonu çalışıyor
5. **Matris Modal** - `openOrderTaskMatrix(orderId, taskId)` ile açılıyor
6. **Backend Zincirleme %** - Task % → Sipariş % → Proje % hesaplaması backend'de yapılıyor

---

## ⚠️ YAPILMASI GEREKENLER

### 1. Matris İstasyon Seçimi Sorunu
**Sorun:** İstasyonlar DB'den geliyor ama "Güncelle" butonu çalışmıyor
**Dosya:** `/Volumes/prod/V16/sales/form/dsp_ops_task_matrix.cfm`
**Çözüm:** `saveWorkstationSelection()` fonksiyonu localStorage'a kaydetmeli

```javascript
function saveWorkstationSelection() {
    if (selectedWorkstations.length === 0) {
        alert('En az bir istasyon seçmelisiniz.');
        return;
    }
    
    // Sipariş-Task bazlı: localStorage'a kaydet
    var storageKey = 'matrix_ws_order_' + matrixRefId + '_task_' + matrixTaskId;
    localStorage.setItem(storageKey, JSON.stringify(selectedWorkstations));
    
    // Matrisi oluştur
    renderDefaultMatrix();
}
```

### 2. Matris % Hesaplama ve UI Güncelleme
**Sorun:** Matris kaydedildiğinde Task % → Sipariş % → Proje % zinciri UI'da güncellenmiyor
**Dosya:** `/Volumes/prod/V16/sales/form/dsp_ops_task_matrix.cfm`
**Çözüm:** `saveMatrix()` fonksiyonunda AJAX response'undan gelen order_pct ve project_pct değerlerini UI'a yansıt

### 3. %100 = Tamamlandı Mantığı
**Sorun:** Task %100 olduğunda otomatik "Tamamlandı" aşamasına geçmeli
**Dosya:** `/Volumes/prod/V16/sales/query/ajax_ops_task.cfm`
**Kontrol:** `update_percent` action'ında zaten var, frontend'de doğrula

---

## 📁 ÖNEMLİ DOSYALAR

### Ana Rapor Dosyası
```
/Volumes/prod/documents/report/5560605B-BA40-44A6-1E209FF687575FC2.cfm
```

### Matris Modal
```
/Volumes/prod/V16/sales/form/dsp_ops_task_matrix.cfm
```

### AJAX Endpoint
```
/Volumes/prod/V16/sales/query/ajax_ops_task.cfm
```

### Yedek Dosyalar (Çalışan Versiyonlar)
```
/Volumes/prod/documents/report/5560605B-BA40-44A6-1E209FF687575FC2 copy 3.cfm  ← EN İYİ YEDEK
/Volumes/prod/V16/sales/form/dsp_ops_task_matrix.cfm.bak_20260205              ← EN İYİ YEDEK
/Volumes/prod/V16/sales/form/dsp_ops_task_matrix.cfm.bak_20260206_0945
```

---

## 🔧 TEKNİK DETAYLAR

### Veritabanı
- **DSN:** `dsn` = workcube_prod (OPS_TASK tablosu)
- **DSN3:** `dsn3` = workcube_prod_1 (ORDERS tablosu)

### OPS_TASK Tablosu
```sql
TASK_ID, TASK_HEAD, REF_TYPE='ORDER', REF_ID=ORDER_ID
PERCENT_COMPLETE, STATUS_ID, HAS_MATRIX
```

### Status ID'leri
```
2358 = Planlama
2359 = İş Atandı  
2361 = Devam Ediyor
2364 = Tamamlandı
2365 = Onaylandı
```

### JavaScript Fonksiyonları
```javascript
toggleOrderTasks(orderId, buttonEl)      // Task listesini aç/kapa
updateOrderTaskPercent(taskId, pct, ...)  // Task % güncelle
updateOrderTaskStage(taskId, stageId, ...)// Task aşama güncelle
openOrderTaskMatrix(orderId, taskId)      // Matris modal aç
updateOrderPercentUI(orderId, pct)        // Sipariş % UI güncelle
updateProjectPercentUI(projectId, pct)    // Proje % UI güncelle
```

---

## 🎯 SIRADAKI ADIMLAR

1. **dsp_ops_task_matrix.cfm** dosyasını düzenle:
   - `saveWorkstationSelection()` → localStorage bazlı yap
   - `editWorkstations()` → project_id parametresini kaldır
   - `renderDefaultMatrix()` → seçilen istasyonlara göre hücre oluştur

2. **Test Et:**
   - Matris butonuna tıkla
   - İstasyonları seç
   - Güncelle butonuna tıkla
   - Matris hücreleri görünmeli
   - Değerleri işaretle ve Kaydet
   - Task %, Sipariş % ve Proje % güncellensin

3. **Git'e Yolla:**
   ```bash
   cp dosya ~/Documents/W3/report/
   cd ~/Documents/W3 && git add . && git commit -m "mesaj" && git push
   ```

---

## 📞 YARDIM İÇİN

Sorular için bu dosyayı ve yedek dosyaları incele. Çalışan versiyonlar `copy 3` ve `bak_20260205` dosyalarında.

**Hazırlayan:** Cascade AI  
**Tarih:** 2026-02-06
