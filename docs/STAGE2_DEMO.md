# İkinci aşama: kurulum ve canlı demo

## Kurulum

Mevcut Ruby/Bundler kurulumuyla `ruby bin/rails db:prepare` çalıştırın.
LLM bağlantısı için PowerShell oturumunda `GROQ_API_KEY` ortam değişkenini güvenli
biçimde tanımlayın. Anahtarı sohbete, kaynak koda veya Git'e yazmayın.
Varsayılan model `openai/gpt-oss-120b`; gerekirse `GROQ_MODEL` ile değiştirin.
Modelin Groq chat completions ve JSON object modunu desteklemesi gerekir.
Ortam değişkenleri tanımlandıktan sonra Rails sunucusunu yeniden başlatın.

Render'da aynı secret ve isteğe bağlı model değişkenini tanımlayıp deploy edin.
Mevcut `bin/render-build.sh` migration ve asset hazırlığını yapar.
Yeni bir worker veya Solid Queue gerekmez; çağrılar eşzamanlıdır ve timeout'ludur.
Anahtar yoksa talepler açıkça insan incelemesine devredilir; sahte LLM kullanılmaz.
Konuşmalar veritabanında saklanır ve LLM'e iletilir; yalnız sentetik demo verisi kullanın.

## 1. Eksik bilgiden gerçek onay talebine

1. Çalışan hesabıyla canlı URL'de giriş yapın, **Agent talepleri > Yeni agent talebi** açın.
2. Yönetici seçin. “Tasarım ekibi için iki monitör almak istiyorum.” yazın.
3. Agent'ın tutar, para birimi ve ihtiyaç tarihi gibi eksik bilgileri sormasını bekleyin.
4. “Toplam bütçe 20000 TRY. İhtiyaç tarihi: [bugünden sonraki gerçek bir YYYY-MM-DD tarihi].
   Tasarım dosyalarında yan yana çalışmak için kullanılacak. Acil değil.” yanıtını verin.
5. Bir belge oluştuğunu ve onaya gönderildiğini gösterin. Tekrar gönderim mevcut
   konuşmada ikinci belge oluşturmamalı. 48 saatlik süreyi belge ekranından gösterin.
6. Atanmış yönetici hesabıyla Onay panelinden belgeyi onaylayın veya gerekçeyle reddedin.
7. Çalışan hesabında agent konuşmasını yeniden açın; güncel karar veritabanından okunur.

## 2. Bağlam testi

Yeni bir talepte “Acil değil; gelecek ayın planlı alımı” ifadesini kullanın.
Tam bir talep oluştuğunda belge içeriğindeki LLM gerekçesini inceleyin.
Bu senaryo, “acil” sözcüğünü yakalayan sabit bir filtreden farklılığı sınar.
Modelin yanlış değerlendirme yapabileceğini saklamayın; sonuç insan kararı değildir.

## 3. Human-in-the-loop

1. Yeni talepte “Satın alma bütçesinde iki farklı rakam var. İnsanla görüşmek istiyorum.” yazın.
2. “İnsan incelemesine devredildi” durumunu ve belge oluşturulmadığını gösterin.
3. Atanmış yöneticiyle Agent talepleri ekranını açın. Açıklama/bilgi isteği gönderin.
4. Çalışanla konuşmayı açın; yönetici mesajını görün ve bilgileri tamamlayın.
5. Talep tamamlanınca agent'ın belgeyi onaya gönderdiğini gösterin.
6. Başka yöneticinin veya çalışanın konuşmaya erişemediğini otomatik testlerle destekleyin.

## Sunum sırası

Canlı URL → yeni agent akışı → CHALLENGE_LOG.md → commit geçmişi.
İlk haftayı tekrar anlatmayın. AGENTS.md, AGENT.md, render.yaml ve
bin/render-build.sh üzerinden coding agent'ın dağıtım kurallarını nasıl öğrendiğini açıklayın.

## Dürüst tamamlanma ölçütü

API anahtarı olmadan geçen testler yalnız uygulama davranışını kanıtlar.
Gerçek LLM ve Render demo adımları uygulanmadan 100 puanlık canlı kanıt tamamlanmış değildir.
Harici agent istemcileri için bearer-token API, RAG ve çoklu agent bu sürümde yoktur.
Agent sunucu içinde araç işlevi çağırır; kullanıcı arayüzündeki konuşmayı satın alma talebine dönüştürür.
Yönetici kararı doğal dil komutuyla verilmez; mevcut güvenli onay ekranında verilir.

## Teknik kaynak

- Groq Chat Completions: https://console.groq.com/docs/api-reference
- JSON çıktı modu: https://console.groq.com/docs/structured-outputs
