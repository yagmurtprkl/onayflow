# CHALLENGE_LOG

## Başlangıç noktası

- Klonlanan ürün: Docusign'ın küçük bir iç belge onay akışı; elektronik imza ürünü değil.
- Canlı URL: https://onayflow.onrender.com (24 Ekim 2026: kullanıcı eşliğinde canlı LLM ve onay akışı denendi; kanıtlar aşağıda).
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
Bu cümle kod, kontrollü testler ve aşağıda ayrıştırılmış canlı demo kanıtlarıyla desteklenmiştir.
Arkadaş projesiyle yan yana slop testi henüz yapılmadı; bunu yapılmış saymıyorum.

## Yapılanlar ve kanıt

- [Uygulama ve test commit'i: 9baa64f](https://github.com/yagmurtprkl/onayflow/commit/9baa64fe740de56cde309018a0b8510447c7f667)
- [Canlı bağlantı için model düzeltmesi: 6eb186f](https://github.com/yagmurtprkl/onayflow/commit/6eb186f)
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

### İlk canlı deneme sonrası model düzeltmesi — 24 Ekim 2026

Kullanıcının paylaştığı canlı ekranlarda istek kaydedildi ve atanmış yöneticiye
göründü; sağlayıcı hatası/geçersiz yanıt nedeniyle insan devri gerçekleşti.
Bu ilk başarısız deneme, başarılı LLM yanıtı değildir. Render ortamı ve sağlayıcı hata kaydı okunmadığı
için kesin HTTP hata kodu bilinmiyor.

Kod incelemesinde varsayılan llama-3.3-70b-versatile modelinin Groq Free/Developer
katmanlarında 16 Ağustos 2026'da kaldırıldığı doğrulandı. Varsayılan model,
desteklenen openai/gpt-oss-120b olarak değiştirildi. Akıl yürütme ve JSON yanıtı
için çıktı token bütçesi 4096'ya çıkarıldı. GROQ_MODEL ortam değişkeni varsa hâlâ
önceliklidir; Render'da eski modele ayarlıysa güncellenmelidir.

- [Groq model kullanım sonları](https://console.groq.com/docs/deprecations)
- [Desteklenen modeller](https://console.groq.com/docs/models)
- Düzeltme sonrası kullanıcı yeni canlı taleplerle tekrar denedi; sonuçlar aşağıda.
- İlk #1 konuşması hata kaynaklı insan devri olarak kaldı; başarılı demo diye sayılmadı.

### Canlı demo sonuçları — 24 Ekim 2026

Ortam: https://onayflow.onrender.com. Son değerlendirme modeli kullanıcı ekranında
`openai/gpt-oss-120b` olarak görünüyor. Kullanıcı Groq anahtarını Render'da kendisi
tanımladı; anahtar bu sohbete veya depoya alınmadı.

Kanıt türü: kullanıcı uygulamayı kullandı; asistan paylaşılan ekran görüntülerini
inceleyip adımları yönlendirdi. Üretim veritabanı/sağlayıcı kayıtları okunmadı.
[Görsel kanıt dizini ve kapsamı](docs/evidence/2026-10-24/README.md).

#### A. Eksik bilgiden yönetici kararına

1. Çalışan, iki 27 inç monitörün amacını anlattı; tutar ve tarih vermedi.
2. **Agent konuşması #2** toplam tutarı, para birimini ve ihtiyaç tarihini sordu.
   [Ekran görüntüsü](docs/evidence/2026-10-24/01-agent-missing-information.png).
3. Çalışan toplam bütçeyi KDV dahil 20.000 TRY ve ihtiyaç tarihini 2026-11-10 olarak tamamladı.
4. Agent, **Belge #4 / 27 inç Monitör Alımı** kaydını oluşturup seçilen yöneticiye gönderdi.
   [Yönetici belge ekranı](docs/evidence/2026-10-24/02-generated-document-pending.png).
5. Belge ekranında tutar ve tarih doğru göründü. “Planlı bir alım; acil değil” ifadesine
   karşılık agent normal değerlendirmesi ve gerekçesi üretti. Bu tek örnek, anlamın
   dikkate alındığı bir canlı gözlemdir; tüm ifadelerde doğruluk garantisi değildir.
6. Gönderim 24.10.2026 23:06, karar son tarihi 26.10.2026 23:06 olarak göründü:
   mevcut 48 saatlik kural korundu. İhtiyaç tarihi ve karar son tarihi ayrı alanlardır.
7. Yönetici onay verdi; çalışanın belge listesinde Belge #4 **Onaylandı** göründü.
   [Çalışan ekranı](docs/evidence/2026-10-24/03-employee-approved-document.png).
8. Kullanıcı, Talep #2 konuşmasında da **Onaylandı** gördüğünü açıkça bildirdi.
   Bu son konuşma ekranı ayrıca paylaşılmadı; kullanıcı teyidi olarak kaydedildi.

#### B. Bütçe çelişkisi → insan devri → devam

1. Çalışan 20.000 TRY ve 30.000 TRY şeklinde iki çelişkili bütçe bildirdi ve yöneticinin
   incelemesini istedi.
2. **Agent konuşması #3** “İnsan incelemesine devredildi” durumuna geçti.
   Agent bütçedeki çelişkiyi açıkladı; ekran henüz onaya gönderilmiş belge olmadığını belirtti.
   [İnsan devri ekranı](docs/evidence/2026-10-24/04-budget-conflict-handoff.png).
3. Yöneticiyle devralma, bütçeyi 20.000 TRY olarak netleştiren açıklamayı çalışana
   geri iletme ve çalışanın iki monitör/2026-11-10 bilgilerini tamamlaması yönlendirildi.
4. Kullanıcı bu akışın sağlandığını ve sonucun **Onaylandı** göründüğünü bildirdi.
   Devir başlangıcı görselle, devam/son karar kullanıcı teyidiyle desteklenir; aradaki
   yönetici notu ve son belge ekranı ayrıca paylaşılmadı. Son belge ID'si varsayılmadı.

Sunumda bu iki senaryo canlı tekrar edilebilir; eski demo kayıtlarının yeni ortamda
aynı ID'leri alacağı varsayılmamalı. İnsana devir örneği hem çelişki hem açık insan
isteği içerdiğinden, açık insan isteği olmadan çelişki tespitini ayrıca kanıtlamaz.

Vaat edilip henüz kanıtlanmayanlar / sınırlar:

- Gerçek LLM akışı ve “acil değil” bağlam örneği yukarıdaki canlı kayıtlarla destekleniyor.
  Kapsamlı anlamsal doğruluk, yük ve tüm sağlayıcı hata türleri canlıda sınanmadı.
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
- Agent-first ve LLM canlı demo kanıtları eklendi. Nihai not öğretim elemanının
  değerlendirmesine bağlıdır; 85/100 veya 100/100 alındığı iddia edilmiyor.

## Zaman

- İnsan zamanı: kullanıcı planı değerlendirdi, uygulamayı onayladı, ardından Groq/Render
  ayarlarını yaptı ve çalışan/yönetici hesaplarıyla iki canlı akışı denedi. Kullanıcının
  harcadığı dakika ölçülmedi; sayı uydurulmadı.
- Agent zamanı: ilk proje yazma işlemi 24.10.2026 20:39 UTC+03:00'da gözlendi.
  İlk kodlama günlüğü 24.10.2026 20:50 UTC+03:00 itibarıyla hazırlanmıştı. Aradaki süre araç/izin
  beklemelerini içerir; saf üretim süresi veya token maliyeti değildir.
- İlk aşamanın ve bu haftanın planlama süresi bu uygulama aralığına dahil değildir.
- İlk kodlama kaydındaki 20:39–20:50 aralığı, sonraki model düzeltmesi, kurulum ve
  canlı denemeler dahil projenin toplam süresi değildir. Canlı Belge #4'teki 23:06
  damgası bir olay zamanıdır; kesintisiz çalışma süresi olarak kullanılmadı.
- Canlı denemelerde Groq API kullanıldı. Gerçek token tüketimi, faturalama ekranı ve
  abonelik payı ölçülmedi/okunmadı; toplam maliyet veya kesin 0 USD iddiası yapılmıyor.

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
