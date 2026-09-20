# Lavive – تقرير تعديلات حملة تثبيت التطبيق (Meta + Instagram)

التاريخ: 17 يونيو 2026
الريبو: مشروع Flutter (package vegesea / com.vegesea.app)

## ملخص سريع
اتنقل كل إعداد Facebook من الـ App ID القديم (1383135986010794) للجديد (2384874368648435) على المنصتين، واتضاف ATT و SKAdNetwork لـ iOS، وأحداث CompleteRegistration و Purchase، و deep linking عبر ChottuLink (custom scheme كامل + App Links بـ placeholder للدومين).

بحث على الريبو كله: مفيش أي وجود متبقي لـ 1383135986010794 ولا fb1383135986010794 ولا التوكن القديم في أي ملف.

## أ. الملفات اللي اتعدّلت (كود)

### 1. android/app/src/main/res/values/strings.xml
- facebook_app_id: 1383135986010794 -> 2384874368648435
- facebook_client_token: التوكن القديم -> f43b2a39dd0347ab49b03fd351d15db5
- fb_login_protocol_scheme: fb1383135986010794 -> fb2384874368648435

### 2. android/app/src/main/AndroidManifest.xml
- الـ meta-data بتاع ApplicationId و ClientToken كانوا بيشاوروا على @string (مش هاردكود)، فاتصلحوا تلقائياً من strings.xml. مفيش scheme هاردكود في الـ Facebook activity، هو كمان @string.
- اتضافت intent-filters على MainActivity:
  - custom scheme lavive:// بـ host: product, category, offer
  - App Links (https) بـ android:autoVerify="true" على host = CHOTTULINK_DOMAIN (placeholder)
- إعداد التوقيع (keystore) في build.gradle اتساب زي ما هو، ماتلمسش.

### 3. ios/Runner/Info.plist  (اتعاد بناؤه)
مهم: الملف كان مكسور structurally. الـ root dict كان ناقص، وكل المفاتيح كانت متحطوطة بالغلط جوه dict بتاع NSAppTransportSecurity. ده بيخلي الملف غير صالح، وغالباً نسخة iOS ماكانتش اتبنت قبل كده. اتعاد بناء الملف صح، واتأكد إنه valid plist (25 مفتاح).
المضاف:
- FacebookAppID = 2384874368648435، FacebookClientToken = f43b2a39dd0347ab49b03fd351d15db5، FacebookDisplayName = LAVIVE
- CFBundleURLTypes: scheme fb2384874368648435 + scheme lavive
- LSApplicationQueriesSchemes لتسجيل دخول فيسبوك
- NSUserTrackingUsageDescription (نص شاشة ATT)
- SKAdNetworkItems: v9wttpbfk9.skadnetwork (Facebook) و n38lu8286q.skadnetwork (Instagram)

### 4. ios/Runner/Runner.entitlements  (ملف جديد)
- com.apple.developer.associated-domains = applinks:CHOTTULINK_DOMAIN (placeholder)

### 5. pubspec.yaml
اتضاف:
- facebook_app_events: ">=0.19.7 <1.0.0"
- app_tracking_transparency: ^2.0.0
- chottu_link: ^1.1.1

### 6. lib/services/marketing_service.dart  (ملف جديد)
كلاس MarketingService فيه:
- init(): يهيّئ ChottuLink، يبدأ الاستماع للروابط، يطلب ATT ويمرّر النتيجة لـ setAdvertiserTracking في FB.
- توجيه الروابط لـ product و category و offer عبر نفس نظام التنقّل الموجود (Go.toName)، مع انتظار جاهزية الـ navigator عشان الروابط المؤجلة وقت الـ cold start.
- logCompleteRegistration() و logPurchase(amount, currency).

### 7. lib/main.dart
- استدعاء await MarketingService.instance.init() قبل runApp مباشرة.

### 8. lib/cubits/auth_cubit/auth_cubit.dart
- عند نجاح التسجيل (RegAuthSuccess) بيتسجّل MarketingService.instance.logCompleteRegistration().

### 9. lib/layout/cart/cart_screen.dart
- عند نجاح الأوردر بيتسجّل MarketingService.instance.logPurchase(totalBeforeWallet, currency: 'EGP'). الـ totalBeforeWallet هو إجمالي الأوردر (subtotal ناقص الخصم زائد التوصيل).

## ب. حاجات لقيتها

1. Info.plist كان مكسور (شرح فوق). اتصلح.
2. iOS أصلاً ماكانش فيه أي إعداد Facebook خالص. اتضاف كامل دلوقتي.
3. في AndroidManifest فيه meta-data مكرر لـ com.facebook.sdk.ApplicationId (مرتين بنفس القيمة). مش بيكسر البناء وسبته زي ما هو عشان ماغيّرش سلوك قائم، بس ممكن تشيل المكرر لاحقاً لو حبيت تنضّف.
4. التطبيق بيستخدم flutter_facebook_auth لتسجيل الدخول بس، وماكانش فيه facebook_app_events. يعني أحداث Purchase و CompleteRegistration ماكانتش بتتبعت خالص قبل كده. اتضافت دلوقتي.

## ج. قيم ChottuLink (اتملت)
اتحطت قيمتين من حساب ChottuLink:
- Mobile SDK Integration Key (c_app_...) في lib/services/marketing_service.dart
- Domain lavive.chottu.link في marketing_service.dart و AndroidManifest.xml (host بتاع App Links) و Runner.entitlements (applinks)

ملاحظة: استُخدم الـ Mobile SDK key مش الـ Rest API key. والمفتاح اتكتب من صورة، فأكده بالنسخ المباشر من ChottuLink > Keys.

## د. خطوات يدوية بره الكود (مش هقدر أعملها أنا)

المطور:
- flutter pub get. أنا ماقدرتش أعمله هنا (مفيش نت/SDK)، فلو في تعارض نسخ، بمب الـ package للأحدث على pub.dev.
- iOS في Xcode: target Runner > Signing & Capabilities > أضف Associated Domains، وتأكد إن CODE_SIGN_ENTITLEMENTS بيشاور على Runner/Runner.entitlements.
- بناء وتوقيع ورفع (بالـ keystore الموجود، نفس المفتاح المنشور).

انت:
- ChottuLink > Platforms: ضيف منصة Android (package com.vegesea.app + بصمة SHA256 من Play App Signing) ومنصة iOS (Bundle ID). من غير ده، التحقق بتاع App Links / Universal Links مش هيشتغل حتى لو الـ SDK اشتغل.
- Apple Developer portal: فعّل Associated Domains على الـ App ID وأعد توليد الـ provisioning profile.
- ChottuLink: اعمل حساب مجاني، خد الـ api key والدومين، واملا الـ placeholders.
- لوحة Meta على app 2384874368648435: أضف منصة Android (package com.vegesea.app + key hash من Play App Signing)، أضف منصة iOS (Bundle ID)، اربط Business Manager 1606605023787024، ادي صلاحية Ad Account 2166041790838434، فعّل Aggregated Event Measurement.
- حوّل الـ app من Development (غير منشور) لـ Live. ده مهم: من غيره القياس هيفضل صفر للمستخدمين العاديين حتى بعد كل ده.
- SKAdNetwork: لو هتستخدم Audience Network أو شركاء زيادة، اسحب القائمة الكاملة الحالية من Events Manager.

## هـ. تحذير مهم
ماقدرتش أعمل build ولا flutter pub get ولا أكمبايل في البيئة دي. الكود مكتوب على واجهات الـ packages الرسمية الحالية، بس المطور لازم يعمل build ويختبر فعلياً قبل النشر، خصوصاً:
- توجيه الـ deep link (اختبره برابط حقيقي بعد ما تملا دومين ChottuLink).
- ظهور أحداث CompleteRegistration و Purchase في Events Manager.
