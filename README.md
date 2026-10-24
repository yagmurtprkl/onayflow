# OnayFlow

[![CI](https://github.com/yagmurtprkl/onayflow/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/yagmurtprkl/onayflow/actions/workflows/ci.yml)

## OnayFlow nedir?

OnayFlow, çalışanların iç belgeleri taslak olarak hazırlayıp bir yöneticiye
gönderdiği; yöneticilerin de kendilerine atanmış belgeleri onayladığı veya
gerekçeli olarak reddettiği bir Ruby on Rails uygulamasıdır. Ürün elektronik
imza değil, kurum içi belge onay akışıdır.

- **Canlı uygulama:** https://onayflow.onrender.com
- **Kaynak kod:** https://github.com/yagmurtprkl/onayflow
- **Teslim tarihi:** 19 Ekim 2026

## İlham kaynağı ve SaaS seçimi

Ürün araştırmasında Docusign seçildi. Bunun nedeni yalnızca elektronik imza
işlevi değil; belge gönderme, durum izleme ve sıradaki işlemi anlama gibi bir
iş akışını SaaS olarak sunmasıdır. OnayFlow, bu geniş ürünün küçük ve bağımsız
bir bölümünü ele alır: çalışanın metin tabanlı bir iç belgeyi belirli bir
yöneticiye göndermesi ve yöneticinin süreyi görerek karar vermesi.

Bu kapsam farkı önemlidir: Docusign elektronik imza ve anlaşma yönetimi sunar;
OnayFlow ise elektronik imza üretmez, imza doğrulamaz ve hukuken imzalanmış bir
belge oluşturduğunu iddia etmez.

## Fortune 500 ücretli kullanım kanıtı

Fortune'un Estée Lauder şirket profili, şirketi 2026 Fortune 500 içinde
gösterir. Profil 3 Haziran 2026'da güncellenmiştir; 30 Haziran 2025'te biten
mali yıl için 14,326 milyar USD gelir, 48.735 çalışan ve 31 Mart 2026 itibarıyla
25,961 milyar USD piyasa değeri bildirir
([Fortune — Estée Lauder profili](https://fortune.com/company/estee-lauder/)).

Docusign'ın kendi müşteri hikâyesine göre Estée Lauder Companies içindeki farklı
iş birimleri kendi Docusign hesaplarını satın alıp yönetiyordu; yaklaşık 12–15
hesap daha sonra tek kurumsal platformda birleştirilmiştir. Hikâye, üç yılda %20
maliyet tasarrufu ve daha merkezi kullanım görünürlüğü bildirir
([Docusign müşteri hikâyesi](https://www.docusign.com/customer-stories/the-estee-lauder-companies-unifies-agreement-management-across-the-enterprise-with-docusign-iam)).
Bu, ücret tutarını açıklamasa da bir Fortune 500 şirketindeki ücretli Docusign
kullanımına dair doğrudan sağlayıcı kanıtıdır; bağımsız bir etki denetimi
değildir.

Estée Lauder'ın toplam SaaS uygulama sayısı ve yıllık SaaS harcaması bu
kaynaklarda açıklanmamaktadır. Aşağıdaki Zylo rakamları Estée Lauder'a aitmiş
gibi yorumlanmamalıdır.

## Faz 1 — Fortune 500 ekonomik araştırması

Fortune 500 bir değerleme sıralaması değildir. Fortune, ABD'de kurulu ve gerekli
finansal bildirimleri yapan kamu ve özel şirketlerini ilgili mali yıllarındaki
**gelire** göre sıralar. 2026 listesine giriş eşiği en az 7,5 milyar USD
gelirdir; liste 3 Haziran 2026'da yayımlanmıştır
([Fortune'un liste açıklaması](https://fortune.com/article/what-is-a-fortune-500-company-the-story-behind-the-list/)).

### 2026 genel görünüm

| Ölçüt | Doğrulanabilen değer | Kapsam ve yorum |
| --- | ---: | --- |
| Toplam gelir | 21 trilyon USD | 2026 listesindeki 500 şirketin toplamı |
| Toplam kâr | 2,1 trilyon USD | 2026 listesindeki 500 şirketin toplamı |
| Toplam piyasa değeri | 55 trilyon USD | Fortune'un 2026 toplulaştırması; bütün üyeler için tek tek piyasa değeri olduğu anlamına gelmez |
| En yüksek piyasa değeri | Nvidia, yaklaşık 4,2 trilyon USD | Fortune'un 2026 liste değerlendirmesindeki doğrulanmış üst uç |
| En düşük piyasa değeri | **Kamuya açık kaynaklarla doğrulanamadı** | Listede özel şirketler de vardır; özel şirketlerin borsada oluşan piyasa değeri yoktur. Fortune'un eksiksiz şirket bazlı veri seti ücretlidir |
| Çalışan sayısı | 603 ile yaklaşık 2,1 milyon arasında doğrulanmış uç örnekler | Fortune, BitGo için 603; Walmart için yaklaşık 2,1 milyon çalışan bildirir. Kamuya açık makale BitGo'yu açıkça “listenin en küçüğü” diye adlandırmadığından 603 kesin istatistiksel alt sınır olarak sunulmamıştır |
| Toplam çalışan | 30,5 milyon | 2026 Fortune 500 toplamı |

Toplamlar, çalışan uç örnekleri ve Nvidia'nın piyasa değeri için kaynaklar:
[Fortune 500 2026](https://fortune.com/ranking/fortune500/),
[Fortune ekonomik değerlendirmesi](https://fortune.com/2026/06/19/fortune-500-employment-profits-revenue-hiring-jobs-ai/),
[Fortune 2026 liste analizi](https://fortune.com/2026/06/03/fortune-500-2026-takeaways-nvidia-amazon-walmart/),
[BitGo profili](https://fortune.com/company/bitgo-holdings/) ve
[Walmart profili](https://fortune.com/company/walmart/).

“Değerleme”, “piyasa değeri” ve “gelir” aynı kavramlar değildir. Gelir bir
dönemdeki satış büyüklüğüdür. Piyasa değeri, halka açık şirkette hisse fiyatı
ile pay sayısının çarpımıdır. Özel şirket değerlemesi ise bir finansman veya
değerleme çalışmasının sonucudur. Bu nedenle 7,5 milyar USD gelir eşiği,
Fortune 500'ün en düşük piyasa değeri olarak kullanılamaz.

### Yaklaşık SaaS portföyü ve harcaması

Zylo'nun 2026 SaaS Management Index sayfası, kendi gerçek kullanım veri setinde
şu kurumsal benchmarkları bildirir:

| Ölçüt | Ortalama | Medyan |
| --- | ---: | ---: |
| SaaS uygulama sayısı | 305 | 240 |
| Yıllık SaaS harcaması | 55,7 milyon USD | 20,6 milyon USD |

Kaynak, 40 milyondan fazla lisans ve sınıflandırılmış 100 milyar USD'den fazla
AI, SaaS ve bulut harcamasına dayandığını belirtir
([Zylo 2026 SaaS Management Index](https://zylo.com/2026-saas-management-index),
18 Ekim 2026'da erişildi). Bunlar **Fortune 500 alt/üst sınırları değildir**;
örneklemdeki kuruluşların ortalama ve medyan değerleridir. Fortune 500
şirketleri için eksiksiz, şirket bazlı SaaS uygulama ve harcama veri seti
bulunmadığından en dürüst yaklaşık referans olarak verilmiştir.

## Faz 2 — Kod büyüklüğü ve coding agent maliyeti

### Docusign kod büyüklüğü tahmini

Docusign kapalı kaynaklıdır; gerçek kaynak satırı (LOC/SLOC) sayısı kamuya açık
değildir. Aşağıdaki değerler şirket verisi değil, kapsam tabanlı **Fermi
tahminidir**. Üçüncü taraf bağımlılıklar ve otomatik üretilmiş dosyalar hariç;
web/mobil istemciler, API'ler, imzalama, PDF işleme, kimlik ve yetki, şablonlar,
bildirimler, entegrasyonlar, denetim, test ve dağıtım kodu birlikte düşünülür.

| Senaryo | Varsayım | Tahmini kaynak satırı |
| --- | --- | ---: |
| Düşük | 20 ana alt sistem × 15–35 bin satır | 300 bin–700 bin |
| Orta | 30–50 alt sistem × 50–80 bin satır | 1,5–4 milyon |
| Yüksek | 60–100 alt sistem × 100–150 bin satır | 6–15 milyon |

Aralıkların geniş olması bilinçlidir: mikroservis sayısı, şirket içi platformlar,
eski sistemler, mobil kod, test oranı ve üretilmiş kod bilinmemektedir. Tahmin,
Docusign'ın gerçek LOC sayısı olarak alıntılanamaz.

Sabit sürümlü kapsam kontrolü olarak, açık kaynaklı Docusign alternatifi
[Documenso v2.18.0](https://documenso.com/changelog) (9 Eylül 2026) ve
[Documenso kaynak deposu](https://github.com/documenso/documenso) incelenmiştir.
Bu proje PDF imzalama, alıcılar, şablonlar, e-posta, API ve self-hosting gibi
OnayFlow'da bulunmayan bileşenleri içerir. Dil ve mimari farkı nedeniyle bu
deponun satır sayısı Docusign'a doğrudan ölçeklenmemiş; yalnızca alt sistem
listesinin makul olup olmadığını sınamak için kullanılmıştır.

Karşılaştırma amacıyla OnayFlow'da 18 Ekim 2026 tarihinde `app`, `config`,
`lib` ve `db` altındaki `.rb`, `.erb`, `.css` ve `.js` dosyalarında (üretilmiş
`db/schema.rb` hariç) 43 dosya ve 3.516 boş olmayan satır ölçülmüştür. Bu sayı
açıklamaları ve Rails yapılandırmasını içerir; üretkenlik ölçüsü değildir.
OnayFlow'un tek onay akışı ile tam bir elektronik imza platformu arasındaki
kapsam farkını görünür kılmak için verilmiştir.

### Coding agent ile çekirdek geliştirme senaryosu

Aşağıdaki hesap, tam Docusign kopyası için değil, OnayFlow'un mevcut çekirdek
kapsamını sıfırdan üretip test etmek için varsayımsal bir senaryodur. Formül:
`tahmini faturalandırılan token / 1.000.000 × varsayılan harmanlanmış USD oranı`.
Belirli bir sağlayıcının güncel fiyatı veya bu projede gerçekleşmiş harcama
olarak sunulmamıştır.

| Senaryo | Faturalandırılan token varsayımı | Harmanlanmış oran varsayımı | Agent maliyeti | Takvim süresi |
| --- | ---: | ---: | ---: | ---: |
| Düşük | 1,5 milyon | 5 USD / 1M | 7,50 USD | 3–5 gün |
| Orta | 4 milyon | 10 USD / 1M | 40 USD | 1–2 hafta |
| Yüksek | 8 milyon | 15 USD / 1M | 120 USD | 2–4 hafta |

Varsayımlar: deneyimli bir geliştirici agent çıktısını gözden geçirir; teknoloji
yığını önceden seçilidir; kapsam oturum açma, iki rol, belge CRUD, onay/ret,
SLA, test, temel güvenlik ve dağıtım hazırlığıyla sınırlıdır. İnsan emeği,
abonelik, barındırma, vergi, bakım ve aşağıdaki eksik özelliklerin geliştirilmesi
bu dolar hesabına dahil değildir. Takvim süresi; inceleme, hata düzeltme ve test
sürelerini içerir, kesintisiz agent çalışma süresi değildir.

### Gerçekleşen süre ve maliyet

Bu bölümdeki gerçekleşen değerler yukarıdaki varsayımsal coding agent
senaryolarından ayrıdır. Süreler otomatik olarak ölçülmemiştir; kullanıcının
18 Ekim 2026 tarihinde verdiği geriye dönük tahmindir.

| Aşama | Gerçekleşen süre tahmini |
| --- | ---: |
| Araştırma ve planlama | Yaklaşık 1 saat |
| İlk çalışan Rails uygulamasını geliştirme | Yaklaşık 2 saat |
| İlk çalışan prototipe ulaşma | Toplam yaklaşık 3 saat |

Buradaki **3 saat yalnızca ilk çalışan prototipe ulaşma süresidir; projenin
toplam geliştirme süresi değildir**. Arayüz geliştirme, ek testler, hata
düzeltmeleri, GitHub ve Render işlemleri için sonradan ayrıca zaman harcanmış,
ancak bu çalışmaların kesin süre kaydı tutulmamıştır. Bu nedenle projenin toplam
gerçekleşen süresi güvenilir biçimde hesaplanamamaktadır.

Codex, kullanıcının mevcut ücretli ChatGPT aboneliği üzerinden kullanılmıştır.
Proje için ayrıca API/token bazlı ücret ödenmemiştir; **ek API maliyeti 0
USD'dir**. Bununla birlikte kullanılan toplam token sayısı ölçülmemiş, abonelik
tutarı paylaşılmamış ve abonelik bedelinin bu projeye düşen payı
hesaplanmamıştır. Dolayısıyla ek API maliyeti sıfır olsa da projenin toplam agent
maliyeti **0 USD** olarak gösterilemez ve bilinmeyen abonelik payı için sayı
uydurulmamıştır.

## Aort dilimi ve durum akışı

Bu projede “aort dilimi”, sistemin değer üreten en küçük uçtan uca akışı olarak
ele alınmıştır: kimliği doğrulanmış çalışan belgeyi hazırlar, yöneticiye yollar
ve atanmış yönetici kararı tamamlar. Bu dilim model, veritabanı, yetkilendirme,
arayüz ve test katmanlarının tamamından geçer.

```text
Taslak --çalışan gönderir--> Onay Bekliyor --atanmış yönetici--> Onaylandı
                                      └----gerekçeli ret-------> Reddedildi
```

- Yeni belge `draft` (Taslak) durumunda oluşur.
- Yalnızca belgeyi oluşturan çalışan taslağı düzenleyebilir ve gönderebilir.
- Gönderim `draft → pending` geçişini yapar; `submitted_at` ve `due_at` atanır.
- Yalnızca atanmış yönetici `pending → approved` veya `pending → rejected`
  geçişini yapabilir.
- Ret gerekçesi zorunludur. Onaylanan veya reddedilen belge yeniden değiştirilemez.
- Geçersiz geçişler model doğrulamaları ve veritabanı kısıtlarıyla engellenir.

## 48 saatlik zaman kuralı

Belge onaya gönderildiği anda son tarih `Time.current + 48.hours` olarak
hesaplanır. Bekleyen belge için öncelik sınıfları şöyledir:

- Son tarih geçmişse **Gecikmiş**.
- Son tarihe 6 saat veya daha az kalmışsa **Acil**.
- Daha fazla süre varsa **Normal**.

Uygulama zamanı `Istanbul` (`UTC+03:00`) bölgesinde gösterir; veritabanında
zamanlar UTC tutulur. Model davranışı `travel_to` kullanan sınır testleriyle
doğrulanır.

## Sıradaki İşlem ve gerçek G2 kullanıcı yorumu

[G2 Docusign değerlendirmeleri](https://www.g2.com/products/docusign/reviews)
sayfasında Vinay K. (Site Reliability Engineer, Enterprise, Current User,
Validated Reviewer) tarafından 29 Eylül 2026'da yayımlanan “Simple,
Time-Saving E-Signatures with Easy Tracking and Notifications” başlıklı
değerlendirme, bildirimlerin bazen kafa karıştırabildiğini ve gerekli eylemi
anlamanın zaman alabildiğini belirtir. Yorum 18 Ekim 2026'da kaynak sayfada
doğrulanmıştır; G2 ayrı ve kalıcı bir yorum URL'si göstermediği için yazar,
tarih ve başlık birlikte verilmiştir.

OnayFlow bu sorunun yalnızca iç onay kuyruğu bölümünü hedefler:

- Yalnızca oturum açmış yöneticiye atanmış bekleyen belgeleri gösterir.
- Kuyruğu **Gecikmiş → Acil → Normal**, ardından en yakın son tarih sırasıyla
  düzenler.
- Kalan veya geçen süreyi doğrudan gösterir.
- Yönetici belge detayından onay veya gerekçeli ret işlemine ulaşır.

OnayFlow e-posta bildirimi üretmez ve Docusign'ın elektronik imza problemini
çözmüş olduğunu iddia etmez. Çözüm, yönetici uygulamaya girdiğinde “şimdi ne
yapmalıyım?” sorusunu daha açık cevaplamaktır.

## Mimari ve teknoloji yığını

- Ruby 3.4.7 ve Rails 8.0.5.1
- Sunucu tarafında ERB, Propshaft ve import maps
- Oturum tabanlı kimlik doğrulama, CSRF koruması ve `has_secure_password`
- Development/test için SQLite; production için `DATABASE_URL` üzerinden PostgreSQL
- Model merkezli durum geçişleri ve 48 saatlik son tarih
- Çalışan ve atanmış yönetici sınırlarını koruyan controller yetkilendirmesi
- Minitest model, controller, helper ve system testleri
- Render Blueprint, Puma ve `/up` sağlık kontrolü

İlk sürüm Solid Cache, Solid Queue ve Solid Cable kullanmaz. Depoya özgü mimari
kararlar ile çalışma kuralları [AGENT.md](AGENT.md) dosyasındadır.

## Yerel kurulum

Windows PowerShell üzerinde:

```powershell
bundle config set --local without production
bundle install
ruby bin/rails db:prepare
ruby bin/rails db:seed
ruby bin/rails server
```

Ardından `http://localhost:3000` adresini açın. Development seed hesapları
yalnızca yerel kullanım içindir; production ortamında kullanılmamalıdır.

## Test ve kalite komutları

```powershell
ruby bin/rails test
ruby bin/rubocop --cache false
ruby bin/importmap audit
ruby bin/brakeman --no-pager --except EOLRails
ruby bin/brakeman --no-pager --only EOLRails --no-exit-on-warn
```

`rails test`, durum geçişleri, rol/yetki sınırları, gerekçeli ret, 48 saatlik
SLA, 6 saatlik acil sınır ve Sıradaki İşlem sıralamasını kapsar. GitHub Actions
aynı depoda güvenlik taraması, JavaScript bağımlılık denetimi, RuboCop ve test
işlerini çalıştırır: [CI workflow](.github/workflows/ci.yml).

## Render production

Depodaki `render.yaml` şu yapılandırmayı tanımlar:

- Build: `bash bin/render-build.sh`
- Start: `bundle exec puma -C config/puma.rb`
- Health check: `/up`
- PostgreSQL: Render'ın özel `DATABASE_URL` değeri
- Rails credentials: Render Dashboard'da secret olarak tutulan `RAILS_MASTER_KEY`

Build betiği production bağımlılıklarını kurar, asset'leri derler ve idempotent
`db:prepare` görevini çalıştırır. `config/master.key`, `.env` dosyaları, parola,
veritabanı dosyaları ve üretilmiş asset'ler Git'e eklenmemelidir.

### Production demo hesapları

Production seed işlemi kullanıcı oluşturmaz. Sunum için hesap gerekiyorsa mevcut
güvenli mekanizma kullanılmalıdır:

1. Render'da geçici secret değişkenler olarak
   `ONAYFLOW_ALLOW_PRODUCTION_DEMO=true`,
   `ONAYFLOW_DEMO_EMPLOYEE_EMAIL`, `ONAYFLOW_DEMO_EMPLOYEE_PASSWORD`,
   `ONAYFLOW_DEMO_MANAGER_EMAIL` ve `ONAYFLOW_DEMO_MANAGER_PASSWORD` tanımlanır.
   İki farklı, en az 16 karakterli parola kullanılmalıdır.
2. Tek bir manuel deploy sırasında build betiği
   `bundle exec rails onayflow:provision_demo` görevini çalıştırır.
3. Hesaplar oluşunca beş geçici değişken kaldırılır ve çalışan serviste sır
   kalmaması için yeniden deploy edilir.
4. Parolalar başka sistemlerde kullanılmaz ve sonraki sunumdan önce döndürülür.

Görev production dışı ortamda, açık opt-in olmadan veya güçlü bilgiler
verilmeden çalışmayı reddeder ve parolaları yazdırmaz.

## Yapamadıklarım / kapsam dışı kalanlar

Aşağıdaki özellikler mevcut uygulamada **yoktur**:

- Elektronik veya dijital imza ve imza kimliği doğrulama
- Dosya/PDF yükleme, saklama, görüntüleme ve PDF üzerine alan yerleştirme
- Bir belgede sıralı ya da paralel çoklu imzacı/onaycı
- E-posta, SMS veya push bildirimi
- Her olayı değiştirilemez biçimde kaydeden tam denetim izi
- Docusign düzeyinde şablon, entegrasyon, API, mobil istemci ve çok kiracılı yapı

Mevcut sürümde oturum açma/çıkış, belge oluşturma, taslak düzenleme, onaya
gönderme, atanmış yöneticinin onayı, gerekçeli ret, durum geçişleri, 48 saatlik
SLA ve Sıradaki İşlem sıralaması uygulanmıştır; bunlar eksik özellik olarak
gösterilmemiştir.

## Kaynaklar ve erişim tarihi

Tüm dış kaynaklar 18 Ekim 2026 tarihinde kontrol edilmiştir:

- [Fortune — Estée Lauder şirket profili](https://fortune.com/company/estee-lauder/)
- [Fortune — Fortune 500 nedir ve 2026 giriş eşiği](https://fortune.com/article/what-is-a-fortune-500-company-the-story-behind-the-list/)
- [Fortune — 2026 Fortune 500 listesi](https://fortune.com/ranking/fortune500/)
- [Fortune — 2026 ekonomik ve çalışan görünümü](https://fortune.com/2026/06/19/fortune-500-employment-profits-revenue-hiring-jobs-ai/)
- [Fortune — 2026 liste analizi](https://fortune.com/2026/06/03/fortune-500-2026-takeaways-nvidia-amazon-walmart/)
- [Fortune — BitGo profili](https://fortune.com/company/bitgo-holdings/)
- [Fortune — Walmart profili](https://fortune.com/company/walmart/)
- [Docusign — Estée Lauder müşteri hikâyesi](https://www.docusign.com/customer-stories/the-estee-lauder-companies-unifies-agreement-management-across-the-enterprise-with-docusign-iam)
- [Zylo — 2026 SaaS Management Index](https://zylo.com/2026-saas-management-index)
- [G2 — Docusign kullanıcı değerlendirmeleri](https://www.g2.com/products/docusign/reviews)
- [Documenso — v2.18.0 changelog](https://documenso.com/changelog)
- [Documenso — açık kaynak deposu](https://github.com/documenso/documenso)

## Güvenlik ve bakım notu

CI tam Brakeman taramasını çalıştırır. Rails yaşam döngüsü kontrolü ayrı raporlanır;
Rails 8.0 desteği 7 Kasım 2026'da sona ereceğinden bu tarihten önce desteklenen
bir Rails sürümüne yükseltme planlanmalıdır.


## İkinci aşama — Agent ile satın alma talebi

Yeni **Agent talepleri** ekranında çalışan doğal dille satın alma talebi başlatır.
Groq LLM eksik bilgileri sorar; tamamlanınca agent mevcut model kurallarıyla
belge oluşturup atanmış yöneticiye gönderir. Son karar insandadır. Çelişki,
insan talebi veya servis hatası yöneticinin devralabildiği bir konuşma oluşturur.
Onay/ret durumu konuşma ekranında doğrudan veritabanından gösterilir.

Gerekli secret: `GROQ_API_KEY`. İsteğe bağlı: `GROQ_MODEL` (varsayılan
`openai/gpt-oss-120b`). Anahtar yoksa LLM başarılıymış gibi gösterilmez;
talep insan incelemesine devredilir. Gerçek sağlayıcı/canlı demo henüz yapılmamıştır.

- [İkinci aşama günlüğü](CHALLENGE_LOG.md)
- [Kurulum ve sunum senaryosu](docs/STAGE2_DEMO.md)
- [Coding agent kuralları](AGENTS.md)
