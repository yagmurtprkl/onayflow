# Canlı demo kanıtları — 24 Ekim 2026

Bu görseller, kullanıcının canlı OnayFlow uygulamasında gerçekleştirdiği denemelerden
bu sohbete yüklediği ekran görüntüleridir. Sentetik demo hesapları ve talepleri içerir.
API anahtarı, parola veya Render ortam değişkeni içermez. Görseller düzenlenmeden kopyalandı.
Asistan bu kayıt için üretim veritabanına veya sağlayıcı kullanım kayıtlarına erişmedi.

| Görsel | Görünen kanıt |
| --- | --- |
| [01](01-agent-missing-information.png) | Agent konuşması #2: tutar, para birimi ve ihtiyaç tarihi sorusu. Alttaki boş yanıt uyarısı tarayıcının zorunlu alan kontrolüdür. |
| [02](02-generated-document-pending.png) | Belge #4: 20.000 TRY, 2026-11-10, normal değerlendirmesi, atanmış yönetici ve 48 saatlik karar aralığı. |
| [03](03-employee-approved-document.png) | Çalışan belge listesinde agent'ın oluşturduğu Belge #4 için Onaylandı durumu. |
| [04](04-budget-conflict-handoff.png) | Agent konuşması #3: 20.000/30.000 TRY çelişkisi üzerine insan devri, henüz belge olmadığı açıklaması ve model adı. |

Kullanıcı ayrıca konuşma #2'de de Onaylandı sonucunu gördüğünü bildirdi.
Konuşma #3 için yönetici açıklaması → çalışanın tamamlaması → son onay adımlarının
tamamlandığını ve Onaylandı gördüğünü bildirdi. Bu iki son ekran ayrıca paylaşılmadı;
bu adımlar ekran görüntüsüyle bağımsız olarak doğrulanmış gibi sunulmamalıdır.
Bu kayıt, kullanıcı eşliğinde manuel canlı denemedir; model doğruluğu benchmark'ı,
her senaryonun otomatik üretim testi veya not garantisi değildir.
