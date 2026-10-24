# CHALLENGE_LOG

## Başlangıç noktası

- Klonlanan ürün: Docusign'ın küçük bir iç belge onay akışı; elektronik imza ürünü değil.
- Canlı URL: https://onayflow.onrender.com (ikinci aşama deploy/gerçek LLM demosu henüz doğrulanmadı).
- Repo: https://github.com/yagmurtprkl/onayflow
- Geçen haftanın son commit'i: [5aa6a34](https://github.com/yagmurtprkl/onayflow/commit/5aa6a34021b10b3ef7cd04f72fac13da0a995aba).
- Başlangıçta çalışan özellikler: oturum, çalışan/yönetici rolleri, taslak, gönderim,
  atanmış yöneticinin onayı/gerekçeli reddi, 48 saatlik süre ve öncelik kuyruğu.
- Docusign'a belge hazırlama, gönderme ve anlaşma işlerini merkezileştirmek isteyen
  kurumlar para ödüyor. Birinci aşamadaki ücretli kullanım kanıtı:
  [Estée Lauder müşteri hikâyesi](https://www.docusign.com/customer-stories/the-estee-lauder-companies-unifies-agreement-management-across-the-enterprise-with-docusign-iam).
  Bu kaynak ve araştırmanın sınırları README.md'de kayıtlıdır.
- OnayFlow için henüz ücret ödeyen müşteri veya doğrulanmış ödeme isteği yoktur.

## Acı

Hedef kullanıcı, kurum içinde satın alma talebi hazırlayan çalışan ve eksik/çelişkili
bilgiyi tamamlatmak zorunda kalan yöneticidir. Denediğimiz hipotez: çalışan niyetini
anlattığında eksik alanları agent'ın sorması, talebi elle belgeye dönüştürme yükünü azaltabilir.

Kaynak: [Docusign ürün ekibinin kullanıcıların bildirdiği manuel alan eşleme hatalarını
anlattığı yazı](https://www.docusign.com/blog/how-ai-streamlined-workflow-building),
24 Ekim 2026'da incelendi. Yazı, veri yeniden girişinin ve manuel aktarımların hata
ve gecikmeye neden olduğunu açıklıyor; kullanıcıların boş ulaşan belgelerle ilgili
sorunlarını aktarıyor. Bu bir sağlayıcı anlatımıdır, bağımsız müşteri görüşmesi değildir.
OnayFlow'un serbest metinden satın alma talebine dönüşümü bu geniş sorunun dar bir
denemesidir; Docusign'ın PDF alan eşlemesini uyguladığımızı iddia etmiyoruz.

Birinci aşamadaki [G2 Docusign incelemeleri](https://www.g2.com/products/docusign/reviews)
ve “sıradaki işlem” araştırması README.md'de duruyor. Bu hafta yeni bağımsız kullanıcı
görüşmesi veya süre tasarrufu ölçümü yapılmadı; ticari hipotez henüz doğrulanmadı.

## Bu haftanın vaadi

“Şuraya kadar getirdim: çalışan belgeyi oluşturuyor, yöneticiye gönderiyor ve karar
izleniyor. Üzerine, doğal dille satın alma talebini alan, eksikleri soran, tamamlanınca
gerçek belgeyi onaya gönderen ve belirsizlikte atanmış yöneticiye devreden bir agent ekleyeceğim.”

Listede adım olmadığı için madde 3'ten **agent-first ve LLM zekâsını** seçiyorum.
LLM, bilgiyi bağlamıyla değerlendirir; sunucu agent'ı izin verilen belge oluşturma/
gönderme işlemlerini yapar. İnsan, kurum içi onayın karar sahibidir.

Fark cümlesi: “Benim projemde agent, doğal dille gelen talebi eksiklerini sorarak
gerçek bir onay kaydına dönüştürüyor ve belirsizlikte insana devrediyor.”
Bu cümle kod ve kontrollü testlerle desteklenmiştir; gerçek LLM canlı kanıtı bekliyor.
Arkadaş projesiyle yan yana slop testi henüz yapılmadı; bunu yapılmış saymıyorum.

## Yapılanlar ve kanıt

- [Uygulama ve test commit'i: 9baa64f](https://github.com/yagmurtprkl/onayflow/commit/9baa64fe740de56cde309018a0b8510447c7f667)
- [Başlangıçtan itibaren commit geçmişi](https://github.com/yagmurtprkl/onayflow/commits/main/)
- AgentRequest modeli konuşmayı, durumunu, seçilen yöneticiyi ve oluşturulan belgeyi saklıyor.
- Agent::LlmClient, Groq HTTPS chat completions ve JSON object modu kullanıyor;
  anahtar kaynak kodda değil ortam değişkeninde. Model GROQ_MODEL ile seçilebiliyor.
- Agent::Runner eksik bilgi, hazır talep ve insan devri sonuçlarını işler.
  Hazır talep alanları uygulamada doğrulanır; geçersiz çıktı belge oluşturmadan devredilir.
- Belge mevcut ApprovalDocument#submit! üzerinden gönderilir. Agent yönetici kararı
  veremez; 48 saatlik kural değişmez. Konuşma kilidi tamamlanmış bir talebin tekrar
  gönderilerek ikinci belge oluşturmasını engeller.
- Atanmış yönetici insan devrini görür ve kayda geçen bir açıklamayla çalışana geri verir.
- Çalışan ve atanmış yönetici dışındaki hesaplar konuşmayı göremez.
- Konuşma ekranında güncel onay/ret durumu veritabanından gösterilir.
- AGENTS.md, AGENT.md'deki kuralları tamamlar; Render build/start/health ve LLM ayarlarını açıklar.
- SQLite üzerinde mevcut thread tabanlı test paralelliği transaction çakışması ürettiği
  için küçük test paketi seri çalışacak şekilde düzeltildi.

Yerel doğrulama (24 Ekim 2026):

- `ruby bin/rails test`: **58 test, 307 assertion, 0 failure, 0 error, 0 skip**.
- Sağlayıcı isteğinin JSON biçimi, eksik anahtar, bozuk yanıt, rate limit, DNS/timeout,
  eksik bilgi, tek belge gönderimi, insan devri, rol/erişim ve XSS sınırları test edildi.
- Testlerde sağlayıcı taşıması/sınıflandırma yanıtları kontrollü taklitlerdir; gerçek
  LLM performansı veya anlamsal doğruluk kanıtı değildir.
- `ruby bin/rubocop --cache false`: biçim düzeltmelerinden sonra ihlal yok.
- `ruby bin/rails zeitwerk:check`: tüm sınıflar başarıyla yüklendi.
- Tam `ruby bin/brakeman --no-pager`: 0 tarama hatası; yalnız mevcut Rails 8.0.5.1
  desteğinin 7 Kasım 2026'da bitmesine ilişkin EOLRails uyarısı. Tarama kapatılmadı.
- `ruby bin/importmap audit`: açık bulunan paket yok.

Canlı demo adımları: [docs/STAGE2_DEMO.md](docs/STAGE2_DEMO.md).
Sıra: canlı URL → eksik bilgiyi tamamlatıp belge oluşturma → yönetici kararı →
konuşmada sonucu gösterme → insan devri → CHALLENGE_LOG.md → commit geçmişi.

Vaat edilip henüz kanıtlanmayanlar / sınırlar:

- Kullanıcı API bağlantısını sonraya bıraktı. Gerçek Groq çağrısı, anlamsal bağlam
  testleri ve Render üzerinde ikinci aşamanın uçtan uca demosu **yapılmadı**.
- Anahtar yokken sistem insan devrini gösterir. Bu davranış başarılı LLM demosu değildir.
- Otomatik testler canlı demodaki gerçek model davranışının yerine geçmez.
- RAG, harici agent istemcilerine bearer-token API, çoklu agent, PDF/dosya işleme yok.
  Agent bu sürümde Rails içinde çalışır; sohbetten belge işlemine geçer.
- Yönetici kararı mevcut güvenli belge ekranında verilir. Serbest metinden çıkarılan
  alanların anlamsal doğruluğunu LLM garantileyemez; yönetici belgeyi incelemelidir.
- HTTP tekrarında tamamlanmış aynı konuşma tek belgeye bağlı kalır. Ayrı ayrı yeni
  konuşma açmak veya ilk oluşturma isteğini ayrı POST'larla tekrarlamak için global
  idempotency anahtarı bu sürümde yoktur.
- Çağrılar eşzamanlıdır; yüksek trafik için ayrı iş kuyruğu ve oran sınırlaması gerekir.
- 85/100 veya 100/100 alındığı iddia edilmiyor. Özellikle 100 koşulu gerçek LLM ve
  canlı demo kanıtı eklenince değerlendirilebilir.

## Zaman

- İnsan zamanı: kullanıcı planı değerlendirdi, uygulamayı onayladı ve API bağlantısını
  sonraya bırakmayı seçti. Kullanıcının harcadığı dakika ölçülmedi; sayı uydurulmadı.
- Agent zamanı: ilk proje yazma işlemi 24.10.2026 20:39 UTC+03:00'da gözlendi.
  Bu günlük kaydı 24.10.2026 20:50 UTC+03:00 itibarıyla hazırlanmıştır. Aradaki süre araç/izin
  beklemelerini içerir; saf üretim süresi veya token maliyeti değildir.
- İlk aşamanın ve bu haftanın planlama süresi bu uygulama aralığına dahil değildir.
- Token tüketimi / abonelik payı ölçülmedi. Gerçek sağlayıcı çağrısı yapılmadığı için
  bu çalışmada Groq API kullanımı gerçekleşmedi; toplam agent maliyeti bilinmiyor.

İlk uygulama prompt'u (kullanıcının onay mesajı, olduğu gibi):

> [https://github.com/yagmurtprkl/onayflow](https://github.com/yagmurtprkl/onayflow)   bu benim github hesabım projeyi buraua yaptıktan sonra pushlayacagız bu arada değerlendirmemi yaptım ve onaylıyorum o sebeple çalışmaya başlayabilirsin

Bu mesajdan önce bu sohbet içinde PDF'ye göre yalnız plan istenmiş ve proje
değiştirilmemişti. İlk haftanın ilk prompt'u bu kayıtla karıştırılmamıştır.

## Karar

**Devam.** Var olan rol, süre ve belge durum altyapısı kullanılabilir; sıfırdan başka
ürün açmak yerine girişteki elle hazırlama işini azaltmayı deniyoruz. Potansiyel alıcı,
tekrarlanan küçük satın alma taleplerini yöneten bir kurumun operasyon yöneticisi.
Ödeme gerekçesi ancak daha az eksik talep ve daha kısa hazırlama süresi ölçülürse
güçlenir. Bu nedenle sonraki ürün doğrulaması, birkaç kullanıcıyla aynı talebi manuel
ve agent ile hazırlatıp tamamlama süresi, eksik bilgi ve yeniden işlemeyi ölçmektir.

Bu, başka bir öğrencinin sözleşme yaşam döngüsü hedefini üstlenme kararı değildir.
Listede olmayanlar için madde 3 yönünü seçip gerekçelendirme kuralına göre ilerledim.


### İlk canlı deneme sonrası model düzeltmesi — 24 Ekim 2026

Kullanıcının paylaştığı canlı ekranlarda istek kaydedildi ve atanmış yöneticiye
göründü; sağlayıcı hatası/geçersiz yanıt nedeniyle insan devri gerçekleşti.
Bu, başarılı LLM yanıtı değildir. Render ortamı ve sağlayıcı hata kaydı okunmadığı
için kesin HTTP hata kodu bilinmiyor.

Kod incelemesinde varsayılan llama-3.3-70b-versatile modelinin Groq Free/Developer
katmanlarında 16 Ağustos 2026'da kaldırıldığı doğrulandı. Varsayılan model,
desteklenen openai/gpt-oss-120b olarak değiştirildi. Akıl yürütme ve JSON yanıtı
için çıktı token bütçesi 4096'ya çıkarıldı. GROQ_MODEL ortam değişkeni varsa hâlâ
önceliklidir; Render'da eski modele ayarlıysa güncellenmelidir.

- [Groq model kullanım sonları](https://console.groq.com/docs/deprecations)
- [Desteklenen modeller](https://console.groq.com/docs/models)
- Yeni sürüm deploy edildikten sonra çalışan hesabıyla yeni agent talebi denenmeli.
  Eski #1 konuşması yönetici incelemesinde kalır; otomatik olarak yeniden çalışmaz.
- Gerçek LLM başarı kanıtı yeni denemeden sonra eklenecektir.
