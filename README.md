# OnayFlow

OnayFlow is a full-stack Rails application for document approval workflows.
Employees create and submit documents, and the assigned manager approves or
rejects them. The first version intentionally does not use Solid Cache, Solid
Queue, or Solid Cable.

## Stack

- Ruby 3.4.7
- Rails 8.0.5.1
- Rails ERB and import maps
- SQLite for development and test
- PostgreSQL for production
- Minitest

## Local development

On Windows PowerShell, prepare and run the application with:

```powershell
bundle config set --local without production
bundle install
ruby bin/rails db:prepare
ruby bin/rails db:seed
ruby bin/rails server
```

Open `http://localhost:3000`. Development-only seed credentials are printed in
the project delivery report and must never be used in production.

Run the complete test and quality suite with:

```powershell
ruby bin/rails test
ruby bin/rubocop --cache false
ruby bin/importmap audit
ruby bin/brakeman --no-pager --except EOLRails
ruby bin/brakeman --no-pager --only EOLRails --no-exit-on-warn
```

The complete `rails test` command includes the approval state-transition and
48-hour `travel_to` tests under `test/models/approval_document_test.rb`.

## Gerçek Kullanıcı Problemi ve Çözümümüz

OnayFlow'un ürün ilhamı DocuSign'dır; OnayFlow bağımsız bir belge onay
uygulamasıdır ve elektronik imza ürünü olduğunu iddia etmez.

### Doğrulanmış kullanıcı yorumu

- **Kaynak:** [G2 — Docusign Reviews](https://www.g2.com/products/docusign/reviews)
- **Değerlendiren:** Vinay K., Site Reliability Engineer, kurumsal ölçekli
  şirket kullanıcısı
- **Tarih ve başlık:** 29 Eylül 2026 — “Simple, Time-Saving E-Signatures with
  Easy Tracking and Notifications”
- **G2 bilgisi:** Current User, Validated Reviewer; G2 davetiyle ve teşvikli
  olarak toplanmış değerlendirme
- **Şikâyet:** Kullanıcı, bildirimlerin zaman zaman kafa karıştırdığını ve hangi
  işlemin gerektiğini anlamanın zaman aldığını belirtiyor.

G2'nin erişilebilir ürün değerlendirmeleri sayfası bu değerlendirme için ayrı,
kalıcı bir yorum bağlantısı göstermiyor. Bu nedenle kaynak bağlantısı; yazar,
tarih ve değerlendirme başlığıyla birlikte verilmiştir. Yorum 17 Ekim 2026
tarihinde kaynak sayfada doğrulanmıştır.

### OnayFlow'un çözdüğü kısım

OnayFlow e-posta bildirimi üretmez ve kaynak yorumdaki bütün DocuSign
sorunlarını çözme iddiasında değildir. Bunun yerine yöneticinin uygulamaya
girdiğinde **hangi onay işlemine önce yönelmesi gerektiğini** açıklaştırır:

- Yalnızca yöneticiye atanmış ve bekleyen belgeler kuyruğa girer.
- Belgeler “Gecikmiş”, son 6 saatteyse “Acil”, diğer durumlarda “Normal” olarak
  sınıflandırılır.
- Sıradaki İşlem kuyruğu önce öncelik grubuna, sonra en yakın son tarihe göre
  sıralanır; kalan veya geçen süre doğrudan gösterilir.
- Yönetici kuyruktan belge detayına geçerek onay veya gerekçeli ret kararı verir.

Öncelik ve süre hesabı `app/models/approval_document.rb`, yöneticiye özel veri
hazırlığı `app/controllers/approval_documents_controller.rb`, süre/tarih sunumu
`app/helpers/application_helper.rb`, kuyruk ve karar arayüzleri ise
`app/views/approval_documents/pending.html.erb` ile
`app/views/approval_documents/show.html.erb` içinde uygulanmıştır.

**Sunum cümlesi:** “OnayFlow, yöneticinin kendisine atanmış bekleyen belgeler
arasında sıradaki işlemi son tarih ve aciliyet bilgisiyle tek bakışta görmesini
sağlar.”

## Render production

The repository contains a Render Blueprint in `render.yaml`. It uses:

- Build command: `bash bin/render-build.sh`
- Start command: `bundle exec puma -C config/puma.rb`
- Health check: `/up`
- PostgreSQL through Render's private `DATABASE_URL`
- `RAILS_MASTER_KEY` supplied as a secret in the Render dashboard

The build script installs production dependencies, compiles assets, and runs
the idempotent `db:prepare` task. Do not commit `config/master.key`, `.env`
files, database files, or generated assets.

### Production demo access

Production seeds intentionally create no users. Provision dedicated demo users
only when a presentation requires them:

1. Set the following values as temporary secret environment variables in
   Render. Use unique email addresses and two different generated passwords of
   at least 16 characters:
   `ONAYFLOW_ALLOW_PRODUCTION_DEMO=true`,
   `ONAYFLOW_DEMO_EMPLOYEE_EMAIL`, `ONAYFLOW_DEMO_EMPLOYEE_PASSWORD`,
   `ONAYFLOW_DEMO_MANAGER_EMAIL`, and `ONAYFLOW_DEMO_MANAGER_PASSWORD`.
2. Trigger one manual deploy. The build script runs
   `bundle exec rails onayflow:provision_demo` only while the opt-in is true.
3. Remove the five temporary environment variables and deploy again so they are
   no longer available to the running web service.
4. Rotate the passwords by repeating the process before a later presentation.

The task never prints passwords and refuses to run outside production or when
the explicit opt-in and strong credentials are missing. Do not reuse these
credentials for real users.

## Security maintenance

Brakeman runs every security check in CI. Its Rails lifecycle check is reported
separately because Rails 8.0 support ends on 2026-11-07; it is not silently
ignored. Upgrade planning to a supported Rails release is required before that
date.
