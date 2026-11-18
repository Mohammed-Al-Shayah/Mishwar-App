# مشوار (Mishwar) — مواصفات تطبيق طلب المشاوير

> اسم مؤقت، بنقدر نغيّره بعدين.
> هذا الملف هو المرجع الأساسي للمشروع. **Codex** بينفّذ المهام بالترتيب، و**Claude** بيعطي الأوامر وبيراجع كل مهمة قبل ما ننتقل للي بعدها.

---

## 1. فكرة التطبيق

تطبيق لطلب المشاوير: الراكب بيحدد مكان الانطلاق والوجهة، وبيشوف السعر التقديري، وبيطلب سيارة. بعدها بيوصل الطلب لأقرب سائق متصل، والسائق بيقبله، والراكب بيتتبعه على الخريطة لحد ما يخلص المشوار ويقيّمه.

### تطبيق واحد بثلاث أوضاع
الراكب والسائق بيستخدموا **نفس التطبيق**. بعد تسجيل الدخول، المستخدم بيختار "راكب" أو "سائق"، وبيقدر يحوّل بينهم من الملف الشخصي. وضع السائق بيشتغل بس بعد ما يسجّل سيارته ويوافق عليه الأدمن.

| الوضع | مكانه بالكود | شو بيعمل |
|---|---|---|
| الراكب (Rider) | `lib/features/rider/` | يطلب مشوار، يتتبع السائق، يدفع كاش، يقيّم |
| السائق (Driver) | `lib/features/driver/` | يصير متصل أو غير متصل، يستقبل الطلبات ويقبلها، يحدّث حالة المشوار |
| الأدمن (Admin) | `lib/features/admin/` (نفس التطبيق على **Web**) | يوافق على السائقين، يتابع المشاوير، يعدّل الأسعار |

- صلاحية الموقع بالخلفية بتنطلب **بس** لما المستخدم يفعّل وضع السائق، مش وقت فتح التطبيق.
- واجهة الأدمن ما بتظهر إلا لحساب عنده Custom Claim `admin=true`، وبتشتغل على نسخة الويب بس.

---

## 2. التقنيات (Tech Stack)

| المجال | الأداة |
|---|---|
| الإطار | Flutter (آخر إصدار stable) + Dart 3 |
| المعمارية | **Clean Architecture** (Presentation ← Domain ← Data) |
| إدارة الحالة | **`flutter_bloc`**: نستخدم **Cubit** للحالات البسيطة و**Bloc** للتدفقات المعقدة اللي فيها أحداث (Events) |
| حقن الاعتماديات (DI) | **`get_it`** + **`injectable`** (code-gen) |
| تجاوب الشاشات | **`flutter_screenutil`** (تصميم أساسي `375 × 812`) |
| التنقل | `go_router` |
| الموديلات | `freezed` + `json_serializable` |
| مقارنة الحالات | `equatable` (أو freezed للـ States) |
| معالجة الأخطاء | `dartz` أو `fpdart` (`Either<Failure, T>`) |
| الاختبارات | `bloc_test` + `mocktail` |
| تسجيل الدخول | Firebase Auth (رقم الجوال + OTP) |
| قاعدة البيانات | Cloud Firestore (تحديثات لحظية) |
| منطق السيرفر | Cloud Functions for Firebase (TypeScript) |
| الإشعارات | Firebase Cloud Messaging |
| الخرائط | `google_maps_flutter` |
| الموقع | `geolocator` |
| البحث عن أماكن والمسارات | Google Places API + Directions API (من خلال Cloud Function عشان المفتاح ما يكون جوا التطبيق) |
| البحث الجغرافي | `geoflutterfire_plus` (Geohash) |
| اللغات | عربي (افتراضي، RTL) + إنجليزي باستخدام `flutter_localizations` + ملفات `arb` |
| التطوير المحلي | Firebase Emulator Suite |

---

## 3. هيكل المشروع (تطبيق Flutter واحد)

```
mishwar/
├── AGENTS.md                 # تعليمات لـ Codex (قواعد الكود والأوامر)
├── PROJECT_SPEC.md           # هذا الملف
├── .fvmrc                    # نسخة Flutter (FVM: stable 3.44)
├── pubspec.yaml              # package: mishwar — Android id: com.shayah.mishwar
├── android/ ios/ web/
├── lib/
│   ├── main.dart             # configureDependencies() + runApp
│   ├── app/
│   │   ├── app.dart          # ScreenUtilInit + MaterialApp.router + MultiBlocProvider العامة
│   │   ├── router/           # go_router: /auth, /role, /rider/*, /driver/*, /admin/*
│   │   └── di/               # injection.dart + injection.config.dart (generated)
│   ├── core/
│   │   ├── di/               # FirebaseModule (@module)
│   │   ├── error/            # Failure, Exceptions
│   │   ├── usecase/          # UseCase<Type, Params> الأساسي
│   │   ├── network/          # فحص الاتصال
│   │   ├── theme/            # الألوان والخطوط (بقيم ScreenUtil)
│   │   ├── l10n/             # الترجمة (arb)
│   │   └── widgets/          # أزرار، كروت، خريطة مشتركة
│   └── features/
│       ├── common/           # مشترك بين كل الأوضاع
│       │   ├── auth/         # OTP، حالة الدخول، اختيار الوضع
│       │   ├── ride/         # RideEntity + RideRepository (الراكب والسائق بيستخدموه)
│       │   ├── location/     # الموقع الحالي، الصلاحيات
│       │   ├── pricing/      # حساب السعر
│       │   └── profile/      # الملف الشخصي، تبديل الوضع، اللغة
│       ├── rider/            # شاشات ومنطق الراكب (home, search, confirm, tracking, history)
│       ├── driver/           # شاشات ومنطق السائق (onboarding, home, offer, active_ride, earnings)
│       └── admin/            # لوحة الأدمن (Web)
├── test/                     # نفس هيكل lib/
└── firebase/
    ├── firestore.rules
    ├── firestore.indexes.json
    └── functions/            # Cloud Functions (TypeScript)
```

### هيكل كل feature (Clean Architecture)
```
lib/features/
└── rider/ride_request/
        ├── domain/                     # Dart صافي، بدون Flutter أو Firebase
        │   ├── entities/               # RideEntity, PlaceEntity
        │   ├── repositories/           # abstract class RideRepository
        │   └── usecases/               # RequestRide, CancelRide, WatchRide
        ├── data/
        │   ├── models/                 # RideModel (freezed + json) + toEntity()
        │   ├── datasources/            # RideRemoteDataSource (Firestore / Functions)
        │   └── repositories/           # RideRepositoryImpl implements RideRepository
        └── presentation/
            ├── cubit/  أو  bloc/       # RideRequestCubit + RideRequestState
            ├── screens/
            └── widgets/
```

### قواعد الطبقات
| الطبقة | بتعتمد على | ممنوع |
|---|---|---|
| **Domain** | ولا إشي (Dart صافي) | `flutter`، `firebase`، `json` |
| **Data** | Domain | استيراد أي إشي من Presentation |
| **Presentation** | Domain (UseCases بس) | استدعاء Firebase أو DataSource مباشرة |

- كل UseCase فيه دالة وحدة `call()` وبيرجّع `Future<Either<Failure, T>>` أو `Stream<Either<Failure, T>>`.
- الـ Repository Impl بيلتقط الـ Exceptions وبيحولها لـ `Failure`.
- التسجيل بالـ DI:
  - `@lazySingleton`: الـ DataSources والـ Repositories والـ UseCases
  - `@injectable` (factory): الـ Cubits والـ Blocs، وبتنعمل جديدة لكل شاشة
  - `@module`: لتسجيل `FirebaseAuth.instance` و `FirebaseFirestore.instance` و `FirebaseFunctions.instance` و `FirebaseMessaging.instance`
- الـ Cubit أو الـ Bloc بيستقبل UseCases بس بالـ constructor، وبيجيبه `BlocProvider(create: (_) => getIt<RideRequestCubit>())`.

### متى Cubit ومتى Bloc؟
| الحالة | الاختيار |
|---|---|
| تسجيل الدخول، الملف الشخصي، الإعدادات، اختيار نوع السيارة | **Cubit** |
| البحث عن مكان (debounce للأحداث) | **Bloc** (`transformer: debounce`) |
| دورة حياة المشوار عند الراكب والسائق (أحداث كثيرة + Stream) | **Bloc** |
| تتبع موقع السائق، وعداد الطلب الجديد | **Bloc** |

### ScreenUtil
- `ScreenUtilInit(designSize: Size(375, 812), minTextAdapt: true, splitScreenMode: true)` بـ `app.dart`.
- كل الأبعاد بالـ UI: `.w` `.h` `.r` `.sp`. ممنوع أرقام ثابتة للمقاسات والخطوط.
- الخطوط والمسافات بتتعرّف مرة وحدة بـ `core/theme` (مثلاً `AppSpacing.md = 16.w`، و `AppTextStyles.title = 18.sp`).

---

## 4. قاعدة البيانات (Firestore)

### `users/{uid}`
```json
{
  "name": "string",
  "phone": "+9627XXXXXXXX",
  "role": "rider | driver | admin",
  "photoUrl": "string?",
  "rating": 4.9,
  "ratingCount": 12,
  "fcmToken": "string?",
  "createdAt": "timestamp"
}
```

### `drivers/{uid}`
```json
{
  "status": "pending | approved | rejected | suspended",
  "isOnline": false,
  "currentRideId": "string?",
  "vehicle": { "type": "economy | comfort | van", "make": "Toyota", "model": "Corolla", "color": "أبيض", "plate": "12-34567" },
  "location": { "geohash": "string", "geopoint": "GeoPoint" },
  "heading": 0,
  "lastSeenAt": "timestamp"
}
```

### `rides/{rideId}`
```json
{
  "riderId": "uid",
  "driverId": "uid?",
  "status": "searching | accepted | arriving | arrived | in_progress | completed | cancelled | no_drivers",
  "vehicleType": "economy",
  "pickup":  { "address": "string", "geopoint": "GeoPoint" },
  "dropoff": { "address": "string", "geopoint": "GeoPoint" },
  "route":   { "polyline": "string", "distanceMeters": 0, "durationSeconds": 0 },
  "fare":    { "estimated": 0, "final": 0, "currency": "JOD" },
  "paymentMethod": "cash",
  "offeredTo": "driverUid?",
  "declinedBy": ["uid"],
  "cancelledBy": "rider | driver | system ?",
  "riderRating": null,
  "driverRating": null,
  "createdAt": "timestamp",
  "acceptedAt": "timestamp?",
  "startedAt": "timestamp?",
  "completedAt": "timestamp?"
}
```

### `config/pricing`
```json
{
  "economy": { "base": 0.50, "perKm": 0.30, "perMin": 0.05, "minimum": 1.50 },
  "comfort": { "base": 0.80, "perKm": 0.45, "perMin": 0.07, "minimum": 2.50 },
  "van":     { "base": 1.00, "perKm": 0.55, "perMin": 0.08, "minimum": 3.00 }
}
```

### إضافات المرحلتين 6 و 7

**`users/{uid}/savedPlaces/{placeId}`**
```json
{ "label": "home | work | other", "name": "البيت", "address": "string", "geopoint": "GeoPoint", "updatedAt": "timestamp" }
```

**`users/{uid}/trustedContacts/{id}`**
```json
{ "name": "string", "phone": "+962..." }
```

**حقول جديدة على `rides/{rideId}`**
```json
{
  "serviceType": "ride | parcel | airport",
  "scheduledFor": "timestamp?",
  "promo": { "code": "WELCOME50", "discount": 1.70 },
  "fare": { "estimated": 0, "final": 0, "discount": 0, "cancellationFee": 0, "waitingFee": 0, "currency": "JOD" },
  "parcel": { "recipientName": "string", "recipientPhone": "+962...", "description": "string", "photoUrl": "string?", "deliveryCode": "4 digits (hashed)" },
  "airport": { "flightNumber": "RJ 182?", "direction": "to_airport | from_airport", "fixedFare": true },
  "shareToken": "string?",
  "report": { "reason": "string", "details": "string", "status": "open | resolved" }
}
```
حالة جديدة بالـ state machine: `scheduled` (قبل `searching`).

**`promos/{code}`**
```json
{ "type": "percent | fixed", "value": 50, "maxDiscount": 2.00, "minFare": 1.50, "firstRideOnly": true,
  "usageLimit": 1000, "perUserLimit": 1, "usedCount": 0, "validFrom": "timestamp", "validUntil": "timestamp", "active": true }
```
`promos/{code}/redemptions/{uid}`: بتسجل مين استخدم الكود.

**`banners/{id}`**
```json
{ "title": "خصم 50% على أول مشوار", "subtitle": "string", "imageUrl": "string", "promoCode": "string?",
  "action": "open_search | open_promo | url", "order": 1, "validUntil": "timestamp", "active": true }
```

**`config/app`** (feature flags والخدمات)
```json
{
  "services": [
    { "id": "ride", "enabled": true, "order": 1 },
    { "id": "schedule", "enabled": false, "order": 2 },
    { "id": "parcel", "enabled": false, "order": 3 },
    { "id": "airport", "enabled": false, "order": 4 }
  ],
  "cancellationFee": { "afterSeconds": 120, "amount": 0.50 },
  "waitingFee": { "freeMinutes": 3, "perMinute": 0.05 },
  "airport": { "zone": "GeoJSON polygon", "fixedFares": { "economy": 12.0, "comfort": 16.0, "van": 20.0 } },
  "scheduling": { "minLeadMinutes": 30, "maxDaysAhead": 30, "dispatchBeforeMinutes": 15 }
}
```

**`supportTickets/{id}`**
```json
{ "uid": "string", "rideId": "string?", "category": "lost_item | fare | safety | other", "message": "string", "status": "open | in_progress | closed", "createdAt": "timestamp" }
```

---

## 5. دورة حياة المشوار (State Machine)

```
searching ──(سائق قبل)──► accepted ──► arriving ──► arrived ──► in_progress ──► completed
    │                        │            │           │
    │                        └────────────┴───────────┴──► cancelled
    ├──(ما في سائقين خلال 2 دقيقة)──► no_drivers
    └──(الراكب لغى)──► cancelled
```

**قواعد:**
- الانتقال بين الحالات بيصير **فقط** من خلال Cloud Functions أو حسب قواعد الأمان (السائق ما بيقدر يرجع الحالة لورا).
- الراكب بيقدر يلغي قبل `in_progress` بس.
- السعر النهائي بينحسب بالسيرفر وقت `completed`.

### توزيع الطلبات على السائقين (Matching)
1. Cloud Function `onRideCreated`: بتدور على السائقين اللي `isOnline=true` و`status=approved` ومش معهم مشوار، ضمن نصف قطر 5 كم، بنفس نوع السيارة.
2. بترتبهم حسب المسافة وبتعرض الطلب على الأقرب (`offeredTo`) وبتبعتله إشعار FCM.
3. السائق معه **15 ثانية** يقبل. إذا رفض أو ما رد، بينضاف على `declinedBy` والطلب بيروح للي بعده.
4. القبول بيصير بـ **Transaction** عشان ما يقبل المشوار سائقين بنفس الوقت.

### حساب السعر
```
fare = max(minimum, base + perKm × km + perMin × minutes)
```

---

## 6. الشاشات

### مشترك (أول ما يفتح التطبيق)
1. Splash ← Onboarding (أول مرة)
2. تسجيل الدخول: رقم الجوال ← رمز OTP ← الاسم (أول مرة)
3. **اختيار الوضع:** "بدي أطلب مشوار" (راكب) أو "بدي أشتغل سائق". الاختيار بينحفظ، وبيتغير من الملف الشخصي.

### وضع الراكب
3. **الرئيسية:** شوف التفاصيل تحت ("الشاشة الرئيسية للراكب")
4. البحث عن وجهة (Places Autocomplete + اختيار من الخريطة)
5. تأكيد المشوار: المسار على الخريطة، ونوع السيارة والسعر لكل نوع، وطريقة الدفع، وزر "اطلب"
6. جاري البحث عن سائق (أنيميشن + زر إلغاء)
7. السائق جاي: معلومات السائق والسيارة، وموقعه اللحظي، والوقت المتوقع، وزر اتصال وزر إلغاء
8. خلال المشوار: التتبع على الخريطة
9. نهاية المشوار: السعر النهائي + تقييم السائق (نجوم + تعليق)
10. سجل المشاوير، والملف الشخصي، والإعدادات (اللغة)

### الشاشة الرئيسية للراكب (من فوق لتحت)

> الشكل حسب `DESIGN_SYSTEM.md` (قسم 9). العناصر اللي مرحلتها 6 أو 7 بتنبني من المرحلة 2 كـ placeholder "قريباً"، وبتتفعّل لما توصل مرحلتها.
> كل عنصر بيتحكم بظهوره من `config/app` (feature flags)، يعني الأدمن بيخفيه أو بيظهره بدون تحديث للتطبيق.

| # | العنصر | الوظيفة | المرحلة |
|---|---|---|---|
| 1 | **الهيدر** | "مشوار" أو تحية حسب الوقت ("صباح الخير، محمد") + أيقونة إشعارات مع نقطة لما يكون في جديد | 1 (الإشعارات 5) |
| 2 | **كرت المشوار الحالي** | بيظهر بس لما يكون في مشوار شغال: الحالة، والوقت، والسيارة، واللوحة. الضغط عليه بيرجعك لشاشة التتبع | 4 |
| 3 | **"وين رايح؟"** | بيفتح شاشة البحث | 2 |
| 4 | **زر "لاحقاً"** | حجز مشوار مسبق (من 30 دقيقة لحد 30 يوم لقدام) | 6 |
| 5 | **الأماكن الأخيرة** | آخر مكانين. الضغط عليهم بيروح لاختيار السيارة مباشرة | 2 |
| 6 | **البيت والشغل** | أماكن محفوظة، بتتعدل من الحساب | 6 |
| 7 | **الاقتراحات** | 4 مربعات (رحلة، احجز، طرد، مطار) + زر "الكل". الترتيب والظهور من `config/app.services` | رحلة 2 · احجز 6 · طرد ومطار 7 |
| 8 | **البانر الترويجي** | Carousel لعروض من `banners`، وكل عرض إله صورة ونص وكود وتاريخ انتهاء | 6 |
| 9 | **"طرق أكثر للتنقل"** | صفوف بتعرّف بالخدمات (المطار، والطرد، و"اشتغل سائق معنا")، بتظهر تحت البانر | 7 ("اشتغل سائق" من 3) |
| 10 | **شريط التنقل** | الرئيسية · النشاط · الحساب | 1 |

**عند السحب لتحت:** الهيدر بيصغر لشريط فيه اسم "مشوار" بالنص.

**تبويب النشاط:** المشاوير الجاية (المحجوزة، مع زر إلغاء) والسابقة، وفاتورة كل مشوار، و"اطلب نفس المشوار"، و"الإبلاغ عن مشكلة".
**تبويب الحساب:** الملف الشخصي، والأماكن المحفوظة، وطرق الدفع، والأمان (جهات الاتصال الموثوقة)، واللغة، و**"اشتغل سائق معنا"** (تحويل الوضع)، والدعم، وتسجيل الخروج.

### وضع السائق
1. أول مرة بيختار وضع السائق: التسجيل كسائق (بيانات السيارة + صورة الرخصة) ← بانتظار موافقة الأدمن
2. **الرئيسية:** خريطة + زر "متصل / غير متصل" + أرباح اليوم
3. طلب جديد (Bottom sheet): المسافة لعند الراكب، والوجهة، والسعر، وعداد 15 ثانية، وزرّين قبول ورفض
4. في الطريق للراكب: زر "فتح بخرائط Google" + "وصلت"
5. "بدء المشوار" ← "إنهاء المشوار" ← استلام المبلغ كاش ← تقييم الراكب
6. سجل المشاوير والأرباح

### لوحة الأدمن (Web)
- تسجيل دخول الأدمن
- السائقين: قائمة بالسائقين الجدد مع زر موافقة أو رفض
- المشاوير: قائمة + فلترة حسب الحالة
- خريطة السائقين المتصلين
- تعديل الأسعار (`config/pricing`)

---

## 7. الأمان (Firestore Rules) — الأساسيات
- كل مستخدم بيقرأ ويعدّل `users/{uid}` تبعه بس (ما بيقدر يغيّر `role`).
- السائق بيحدّث `location` و`isOnline` تبعه بس، وما بيقدر يغيّر `status`.
- الراكب بيقرأ المشاوير اللي هو `riderId` فيها، والسائق بيقرأ المشاوير اللي هو `driverId` أو `offeredTo` فيها.
- تغيير `status` و`fare.final` و`driverId` بيصير من Cloud Functions بس.
- الأدمن (Custom Claim `admin=true`) بيقرأ كل إشي.

---

## 8. خطة التنفيذ (مهام Codex)

> كل مهمة بتنتهي بـ: `flutter analyze` بدون أخطاء + الاختبارات ناجحة + **مراجعة Claude** قبل ما نبلش اللي بعدها.

### المرحلة 0 — التجهيز
- [x] **T0.1** إنشاء تطبيق Flutter واحد (`mishwar`, Android/iOS/Web) + هيكل المجلدات + شاشة اختيار وضع مؤقتة + FVM
- [x] **T0.2** إضافة الحزم الأساسية (flutter_bloc, get_it, injectable, flutter_screenutil, go_router, freezed, fpdart, equatable, very_good_analysis) + `analysis_options.yaml` صارم
- [x] **T0.2b** أساس Clean Architecture في `core`: `Failure`، `UseCase`، `configureDependencies()`، `FirebaseModule`، و `AppBlocObserver` للـ logging
- [x] **T0.3** الثيم (ألوان، خطوط عربية مثل Cairo أو Tajawal، مقاسات بـ ScreenUtil) + دعم RTL + ملفات الترجمة
- [x] **T0.4** ربط Firebase (`flutterfire configure`) + تشغيل Emulators محلياً
- [x] **T0.5** كتابة `AGENTS.md`

**معيار القبول:** التطبيق بيشتغل على المحاكي، وبتطلع شاشة Splash ثم اختيار الوضع بالعربي.

### المرحلة 1 — تسجيل الدخول والخريطة
- [x] **T1.1** Entities (`UserEntity`, `DriverEntity`, `VehicleEntity`) بالـ domain + Models (freezed) بالـ data
- [x] **T1.2** feature `auth` كامل: `AuthRemoteDataSource` ← `AuthRepositoryImpl` ← UseCases (`SendOtp`, `VerifyOtp`, `SignOut`, `WatchAuthState`) + اختبارات
- [x] **T1.3** `AuthCubit` + `OtpCubit` + شاشات تسجيل الدخول (رقم ← OTP ← الاسم) + حماية المسارات بـ go_router
- [x] **T1.4** شاشة الخريطة الرئيسية + صلاحية الموقع + زر "موقعي"
- [x] **T1.5** تسجيل السائق (بيانات السيارة) + شاشة "بانتظار الموافقة"

**معيار القبول:** مستخدم بيسجل دخول برقم تجريبي على الـ Emulator وبيشوف موقعه على الخريطة.

### المرحلة 2 — طلب المشوار (الراكب)
- [x] **T2.1** Cloud Functions: `placesAutocomplete`, `placeDetails`, `getRoute`
- [x] **T2.2** شاشة البحث عن وجهة
- [x] **T2.3** دالة حساب السعر (في `core` + نسخة بالسيرفر) + اختبارات Unit
- [x] **T2.4** شاشة تأكيد المشوار (المسار + أنواع السيارات + الأسعار)
- [x] **T2.5** `RideRepository.requestRide()` + شاشة "جاري البحث"

**معيار القبول:** بينعمل مستند `rides` بحالة `searching` والمسار مرسوم صح.

### المرحلة 3 — السائق والتوزيع
- [x] **T3.1** زر متصل وغير متصل + إرسال الموقع كل 5 ثواني (geohash)
- [x] **T3.2** Cloud Function `onRideCreated` (Matching) + المهلة + الانتقال للسائق اللي بعده
- [x] **T3.3** Callable `acceptRide` / `declineRide` (Transaction)
- [x] **T3.4** Bottom sheet الطلب الجديد مع العداد
- [x] **T3.5** إشعارات FCM للطلبات الجديدة

**معيار القبول:** على الـ Emulator، راكب بيطلب، والسائق الأقرب بيوصله الطلب وبيقبله، والراكب بيشوف معلومات السائق.

### المرحلة 4 — تنفيذ المشوار
- [x] **T4.1** Callable `updateRideStatus` (arriving / arrived / in_progress / completed) مع التحقق من الانتقال الصحيح
- [x] **T4.2** تتبع السائق لحظياً عند الراكب (Marker متحرك + تدوير)
- [x] **T4.3** شاشات السائق: وصلت، بدء، إنهاء، وفتح Google Maps
- [x] **T4.4** الإلغاء من الطرفين + القواعد
- [x] **T4.5** التقييم المتبادل + تحديث متوسط التقييم (Function)

**معيار القبول:** مشوار كامل من الطلب للتقييم بيشتغل بين جهازين أو محاكيين.

### المرحلة 5 — التكميل
- [x] **T5.1** سجل المشاوير (للراكب والسائق) + أرباح السائق
- [x] **T5.2** الملف الشخصي والإعدادات وتغيير اللغة
- [x] **T5.3** لوحة الأدمن (Flutter Web): السائقين، المشاوير، الأسعار، الخريطة
- [x] **T5.4** Firestore Rules كاملة + اختبارات rules
- [x] **T5.5** تجهيز الإصدار: الأيقونات، Splash، أسماء الحزم، وبناء APK

### المرحلة 6 — الراحة والأمان والعروض
- [x] **T6.1** الأماكن المحفوظة (البيت، الشغل، غيرهم): إضافة وتعديل وحذف من الحساب + ظهورها بالرئيسية وبالبحث
- [x] **T6.2** الحجز المسبق:
  - زر "لاحقاً" + شاشة "متى تريد المغادرة؟" (تاريخ ووقت)
  - حالة `scheduled`
  - Cloud Function مجدولة كل دقيقة بتبلش البحث عن سائق قبل الموعد بـ `dispatchBeforeMinutes`
  - تذكير بإشعار قبل الموعد
  - إلغاء من تبويب النشاط
- [x] **T6.3** أكواد الخصم:
  - إدخال الكود بشاشة اختيار السيارة
  - Callable `validatePromo` بتتحقق من الصلاحية والحدود والمشوار الأول
  - الخصم بينحسب بالسيرفر وقت `completed` (Transaction على `usedCount`)
- [x] **T6.4** البانر الترويجي: Carousel من `banners` + أكشن لكل بانر + إدارتها من لوحة الأدمن
- [x] **T6.5** شبكة الخدمات بالرئيسية من `config/app.services` + "قريباً" للخدمات المقفلة + شاشة "الكل"
- [ ] **T6.6** رسوم الإلغاء والانتظار: بتنحسب بالسيرفر حسب `config/app`، وبتظهر للراكب قبل ما يأكد الإلغاء، وبتنضاف على الفاتورة
- [ ] **T6.7** أدوات الأمان:
  - مشاركة المشوار برابط تتبع (`shareToken` + صفحة ويب بسيطة)
  - زر الطوارئ (اتصال بـ 911 + إرسال الموقع لجهات الاتصال الموثوقة)
  - إدارة جهات الاتصال الموثوقة
- [ ] **T6.8** تبويب النشاط كامل: الجاية والسابقة، والفاتورة، و"اطلب نفس المشوار"، و"الإبلاغ عن مشكلة" (`supportTickets`)
- [ ] **T6.9** الدعم: تذاكر من التطبيق (أغراض منسية، سعر، أمان) + إدارتها والرد عليها من لوحة الأدمن

**معيار القبول:** راكب بيحجز مشوار لبعد ساعة بكود خصم، وبيوصله تذكير، وبيتوزع على سائق بالوقت الصح، والفاتورة فيها الخصم. ومشاركة المشوار بتفتح صفحة تتبع شغالة.

### المرحلة 7 — الخدمات الإضافية
- [ ] **T7.1** خدمة الطرد:
  - شاشة "طرد": المستلم ورقمه، والوصف، وصورة الغرض
  - رمز تسليم من 4 أرقام بيوصل للمستلم بـ SMS، والسائق بيدخله عشان ينهي التوصيل
  - شاشات السائق الخاصة بالطرد
- [ ] **T7.2** خدمة المطار:
  - كشف منطقة المطار (`airport.zone`) وسعر ثابت (`fixedFares`)
  - رحلة "للمطار" و"من المطار" مع رقم الرحلة
  - نقاط انطلاق مقترحة بالمطار
- [ ] **T7.3** تأكيد نقطة الانطلاق: نقاط مقترحة على الخريطة + "أكّد موقع الانطلاق" + سحب الدبوس
- [ ] **T7.4** لوحة الأدمن للخدمات: تفعيل وترتيب الخدمات، وأسعار المطار، ورسوم الإلغاء والانتظار، والأكواد، والبانرات (كلها بتعدّل `config/app`)
- [ ] **T7.5** تقارير الأدمن: عدد المشاوير وإيرادها يومياً، وكم كود استُخدم، ونسبة الإلغاء

**معيار القبول:** طرد بيتوصّل وبيتأكد استلامه برمز التسليم، ومشوار من المطار بياخذ السعر الثابت، والأدمن بيفعّل خدمة من اللوحة وبتظهر بالتطبيق بدون تحديث.

---

## 9. طريقة الشغل (Claude ↔ Codex)

1. **Claude** بيكتب أمر المهمة لـ Codex: رقم المهمة، والملفات، والمطلوب، ومعيار القبول.
2. **Codex** بينفّذ وبيشغّل `dart format .` و`flutter analyze` و`flutter test`.
3. **Claude** بيراجع الكود (صحة المنطق، الأمان، التزامه بهذا الملف) وبيرجّع الملاحظات.
4. بعد ما تخلص الملاحظات بنعمل commit برسالة: `feat(T2.3): fare calculation`.
5. بنعلّم المهمة ✅ بهذا الملف وبننتقل للي بعدها.

### قواعد الكود
- ممنوع أي مفتاح API أو سر داخل كود التطبيق. المفاتيح بتنحط بـ `--dart-define` أو بالـ Functions.
- كل نص بيطلع للمستخدم لازم يكون من ملفات الترجمة (ممنوع نصوص ثابتة بالكود).
- الالتزام بقواعد طبقات Clean Architecture (قسم 3). الـ widgets بتعرض بس وبتبعت أحداث للـ Cubit أو الـ Bloc.
- ممنوع `getIt<>()` جوا الـ widgets إلا بـ `BlocProvider(create:)` أو بالـ router.
- بعد أي تعديل على `@injectable` أو freezed: `dart run build_runner build`.
- كل الأبعاد بـ ScreenUtil (`.w .h .r .sp`).
- أي منطق حساس (سعر، حالة، قبول) لازم يكون بالسيرفر.
- اختبارات: Unit للـ UseCases والسعر، `bloc_test` لكل Cubit وBloc، و`mocktail` للـ Repositories.

---

## 10. المتطلبات على الجهاز

- [x] Flutter SDK عن طريق **FVM** (`stable` = 3.44.0، مثبّت بـ `.fvmrc`). الأوامر بتنكتب `fvm flutter ...`
- [x] Android Studio + Android SDK (موجود)
- [x] Node.js (موجود، للـ Cloud Functions و Firebase CLI)
- [x] Git (موجود)
- [ ] Firebase CLI: `npm i -g firebase-tools`
- [ ] FlutterFire CLI: `dart pub global activate flutterfire_cli`
- [ ] Codex CLI
- [ ] مشروع Firebase + مفتاح Google Maps (من حسابك)
