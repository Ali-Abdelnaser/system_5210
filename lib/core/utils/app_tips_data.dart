import 'dart:ui' show Locale;

class AppTip {
  final String title;
  final String description;
  final String? titleEn;
  final String? descriptionEn;

  const AppTip({
    required this.title,
    required this.description,
    this.titleEn,
    this.descriptionEn,
  });
}

class ChildTip {
  const ChildTip({required this.text, this.textEn});

  final String text;
  final String? textEn;

  String localizedText(Locale locale) {
    if (locale.languageCode == 'en' &&
        textEn != null &&
        textEn!.isNotEmpty) {
      return textEn!;
    }
    return text;
  }
}

class AppTipsData {
  static const List<AppTip> parentTips = [
    AppTip(
      title: "الحقيقة اللي محدش قالهالك",
      description:
          "راعي نفسية طفلك، ويه بالألعاب الرياضيه بدل النقد عند التعامل مع وزنه الزائد.",
      titleEn: "The Truth No One Told You",
      descriptionEn:
          "Take care of your child's mental health, and encourage them with sports instead of criticism when dealing with their weight.",
    ),
    AppTip(
      title: "الحركة بتغيّر كل المعادلة",
      description:
          "احرصي على إشراك طفلك في نشاط رياضي مستمر ومتوسط القوة ويفضل أن يكون نشاط جماعي.",
      titleEn: "Movement Changes Everything",
      descriptionEn:
          "Make sure to involve your child in continuous, moderate-intensity physical activity, preferably a group activity.",
    ),
    AppTip(
      title: "بداية اليوم بتحدد النتيجة",
      description: "احرصي على إعداد وجبة إفطار غنية بالألياف ومنخفضة السكر.",
      titleEn: "The Start of the Day Sets the Result",
      descriptionEn:
          "Make sure to prepare a breakfast rich in fiber and low in sugar.",
    ),
    AppTip(
      title: "اختاري صح",
      description:
          "خلي الاختيارات المتاحة وقت الجوع صحية قدر الإمكان (مثل: تقديم الخضروات والفواكه بطرق شهية مختلفة).",
      titleEn: "Choose Right",
      descriptionEn:
          "Make the available choices when hungry as healthy as possible (e.g., serving vegetables and fruits in different appetizing ways).",
    ),
    AppTip(
      title: "٨٠٠٠٠٠ سعره..!!!!!!!!",
      description:
          "قومي بحساب الاحتياج اليومي من السعرات وتدريبهم على متابعة القيمة الغذائية للمأكولات.",
      titleEn: "800,000 Calories..!!!!!!!!",
      descriptionEn:
          "Calculate daily calorie needs and train them to monitor the nutritional value of foods.",
    ),
    AppTip(
      title: "نظام… مش عشوائية",
      description:
          "قسمي الوجبات اليومية إلى خمس وجبات صغيرة متفرقة، وتناولها في مواعيد ثابتة.",
      titleEn: "System... Not Randomness",
      descriptionEn:
          "Divide daily meals into five small, scattered meals, and eat them at fixed times.",
    ),
    AppTip(
      title: "درع ضد الجوع",
      description:
          "احرصي علي أن يتناولون الألياف الكاملة الموجودة في: الشوفان وحبوب القمح والأرز البني والحمص.",
      titleEn: "Hunger Shield",
      descriptionEn:
          "Make sure they eat whole fibers found in: oats, wheat grains, brown rice, and chickpeas.",
    ),
    AppTip(
      title: "المفتاح السري",
      description: "قدمي لاطفالك كوبين من الماء قبل الأكل.",
      titleEn: "The Secret Key",
      descriptionEn: "Give your children two cups of water before eating.",
    ),
    AppTip(
      title: "خاف من عدوك ..!!",
      description: "احرصي علي تقليل كمية السكر بالمشروبات تدريجيًا.",
    ),
    AppTip(
      title: "اختيارك غلط !",
      description:
          "منتجات الألبان قليلة الدسم بتدي نفس الكالسيوم والبروتين، لكن بسعرات ودهون أقل… وده بيساعد في تنظيم الوزن.",
    ),
    AppTip(
      title: "تفصيلة صغيرة بتفرق",
      description: "احرصي على عدم تناولهم نوعين من النشويات في نفس الوجبة.",
    ),
    AppTip(
      title: "الاختيار الذكي",
      description: "قدمي لهم العصائر الطبيعية الغنية بالألياف.",
    ),
    AppTip(
      title: "مشروب… ولا مشكلة؟",
      description:
          "احرصي على توعيتهم عن خطورة المشروبات الغازية ومشروبات الطاقة، وضرورة الامتناع عنها.",
    ),
    AppTip(
      title: "كلمة ممكن تبوّظ كل حاجة",
      description: "لا تقومي باستخدام مصطلح \"حمية غذائية\" أو \" رجيم\".",
    ),
    AppTip(
      title: "البيت هو البداية",
      description: "اجعلي كل المحيطين بالطفل يتبعون نفس العادات الصحية.",
    ),
    AppTip(
      title: "نفس الطعم… سعرات أقل",
      description:
          "استخدمي الوسائل الصحية للطبخ (كالقلاية الكهربائية) لتوفير الأكل الذي يفضله الطفل بأقل سعرات حرارية.",
    ),
    AppTip(
      title: "دلع بس بحدود",
      description: "قومي بالسماح للطفل بتناول ما يشتهي مرة أو مرتين أسبوعيا.",
    ),
    AppTip(
      title: "التوقيت بيفرق",
      description:
          "احرصي علي أن تناول الوجبات السريعة في حالات الاستثناء صباحاً فقط.",
    ),
    AppTip(
      title: "امتى نوزن؟",
      description: "قومي بالمتابعة المستمرة للميزان مرة كل عشرة أيام.",
    ),
    AppTip(
      title: "مين بياخد وقته؟",
      description:
          "حددي وقت الشاشات سواء كانت هواتف محمولة، أو أجهزة أيباد أو حتى شاشات تلفزيون.",
    ),
    AppTip(
      title: "نوم مضبوط = شهية مضبوطة",
      description: "قومي بتحديد روتين للاستيقاظ والنوم في أوقات محددة.",
    ),
    AppTip(
      title: "الفأر الطباخ",
      description:
          "قومي بإشراك اطفالك في إعداد الطعام مع ابتكار وجبات صحية لذيذة وجديدة.",
    ),
    AppTip(
      title: "الروتين = أمان",
      description:
          "حددي الروتين مع الأطفال بصورة يومية أو أسبوعية عبر تحضير قائمة المهام.",
    ),
    AppTip(
      title: "دقايق بتفرق",
      description:
          "اجلسوا معًا كعائلة أثناء تناول الوجبات، دون استخدام أي شاشات.",
    ),
    AppTip(
      title: "خلّيه يحبّه",
      description:
          "اجعلي تناول الأطعمة الصحية أمرًا ممتعًا، عن طريق تقديمها بأشكال جذابة.",
    ),
    AppTip(
      title: "البيئة أقوى من الإراده",
      description: "حددي كمية الأطعمة غير الصحية التى تحتفظي بها فى المنزل.",
    ),
    AppTip(
      title: "الحلو بعدين",
      description:
          "ابتعدي عن تقديم الحلويات ما بين الوجبات حتى لا يفقد الطفل شهيته للوجبة الرئيسية.",
    ),
    AppTip(
      title: "مين علمه كده؟",
      description: "تجنبي استخدام الطعام للمكافأة أو العقاب.",
    ),
    AppTip(
      title: "هو جعان بجد؟",
      description:
          "ساعدي طفلك على فهم ما إذا كان جائعاً حقا وذلك لفهم احتياجات جسمه.",
    ),
    AppTip(
      title: "تحذيررر..!",
      description: "لا تقومي بإجبار الطفل على إكمال الطبق.",
    ),
    AppTip(
      title: "الإفراط بيبدأ من هنا ⚠️",
      description: "قومي بتعليم أطفالك كمية الطعام التي يجب وضعها على الطبق.",
    ),
    AppTip(
      title: "خلي بالك يا مامي!",
      description:
          "حاولي التخطيط لأنشطة أسرية يشترك فيها الجميع في الحركة، مثل المشي.",
    ),
    AppTip(
      title: "مايه = صحه",
      description:
          "احرصي علي تقديم الماء بطرق ممتعة كاستخدام أكواب ملونة و جذابة.",
    ),
    AppTip(
      title: "صدقيني هتفرق",
      description: "اضيفي المنكهات الطبيعية للماء كشرائح البرتقال أو الليمون.",
    ),
    AppTip(
      title: "استني شويه",
      description:
          "اهتمي إن طفلك ياكل ببطء ويمضغ كويس… الإحساس بالشبع بيحتاج وقت.",
    ),
    AppTip(
      title: "الطبق الذهبي",
      description: "خلي طبق طفلك نصه خضار دايمًا 🥗",
    ),
    AppTip(
      title: "ملك البروتين",
      description:
          "قدّمي البروتين في كل وجبة (بيض، عدس، فراخ، تونة…) عشان يحس بالشبع فترة أطول.",
    ),
    AppTip(
      title: "مش منع... تبديل",
      description: "استبدلي الخبز الأبيض بالخبز الأسمر تدريجيًا.",
    ),
    AppTip(
      title: "\"الخطر بين الوجبتين\" ⚠️",
      description:
          "خليه ياخد سناك فيه بروتين بدل بسكويت (زي زبادي أو مكسرات مطحونة حسب العمر).",
    ),
    AppTip(
      title: "مش في أي حتة! ⚠️",
      description: "اهتمي إن طفلك ياكل على الترابيزة مش وهو واقف أو ماشي.",
    ),
    AppTip(
      title: "الفواصل مهمة ⚠️",
      description:
          "خليكي دايما حريصه ان يبقي في بين الوجبة والتانية 2–3 ساعات بدون أكل عشوائي.",
    ),
    AppTip(
      title: "لو رفض… جرّبي تاني",
      description:
          "لو طفلك رفض نوع أكل… جربي تقديمه بطريقة مختلفة بعد كام يوم.",
    ),
    AppTip(
      title: "الحجم بيخدع",
      description:
          "راقبي حجم الطبق اللي طفلك بيأكله… الأطباق الكبيرة بتخليه ياكل أكتر من احتياجه.",
    ),
    AppTip(
      title: "ابدئي صح",
      description:
          "ابدئي وجبه طفلك بشوربة خفيفة أو سلطة عشان تقللي الكمية الأساسية.",
    ),
    AppTip(
      title: "المشوي يكسب",
      description: "يفضل تختاري اللحوم المشوية أو المسلوقة بدل المقلية.",
    ),
    AppTip(
      title: "جهزيها قدامه",
      description: "متنسيش تخلي الفاكهة متقطعة وجاهزة في التلاجة دايمًا 🍎",
    ),
    AppTip(
      title: "القرار في مطبخك",
      description: "لو طفلك بيحب الحلويات، جربي تعمليها في البيت بمكونات أخف.",
    ),
    AppTip(
      title: "الفاكهة تكسب",
      description:
          "من الأفضل انك تبدلي العصير بالفواكه الكاملة عشان ألياف أكتر.",
    ),
    AppTip(
      title: "عشاء خفيف = نوم أهدى",
      description: "خلي عشاء طفلك خفيف وقبل النوم بساعتين على الأقل.",
    ),
    AppTip(
      title: "امدحيه صح",
      description: "امدحي مجهود طفلك في الرياضة مش شكله 💛",
    ),
    AppTip(
      title: "خليه يختار لعبته",
      description: "خلي طفلك يختار نوع الرياضة اللي يحبها عشان يستمر.",
    ),
    AppTip(
      title: "20 دقيقة = فرق كبير",
      description:
          "خليكي حريصه علي تخصيص وقت يومي للحركة لطفلك حتى لو 20 دقيقة ونزود بالتدريج.",
    ),
    AppTip(
      title: "اللعب مش رفاهية",
      description: "جربي مع طفلك ألعاب حركية في البيت بدل القعدة الطويلة.",
    ),
    AppTip(
      title: "السهر عدو صامت",
      description: "اهتمي إن طفلك ينام بدري عشان هرمونات النمو تشتغل كويس 😴",
    ),
    AppTip(
      title: "اول قرار",
      description: "علمي طفلك يشرب مياه أول ما يصحى من النوم.",
    ),
    AppTip(
      title: "قراراتك بتفرق",
      description:
          "خليكي حريصه ان طفلك يساعدك في ترتيب السفرة… حركة بسيطة مفيدة.",
    ),
    AppTip(
      title: "المقارنة بتكسر",
      description:
          "تجنبي المقارنه بين طفلك و طفل تاني لان قدرات البشر مختلفه 💖",
    ),
    AppTip(
      title: "الأم الأذكى تكسب",
      description:
          "خلي طفلك دايما يكتب أو يرسم أهدافه سواء اهداف صحيه او غيرها.",
    ),
    AppTip(
      title: "إيه في شنطته؟",
      description: "احرصي علي توفير سناك صحي في شنطة المدرسة.",
    ),
    AppTip(
      title: "اختاري صح",
      description: "لو طفلك بيحب الكورن فليكس، اختاري نوع قليل السكر.",
    ),
    AppTip(
      title: "هو شاف الشمس؟",
      description: "اتأكدي إن طفلك بياخد كفاية فيتامين د والتعرض للشمس 🌤",
    ),
    AppTip(
      title: "لو نسيتيها… ضاع مجهودك ⚠️",
      description: "اهتمي بوجبة بعد التمرين فيها بروتين لطفلك.",
    ),
    AppTip(
      title: "\"إوعي الإجازة تبوّظ كل حاجة\" ⚠️",
      description: "خليكي حريصه ان مواعيد الأكل تكون منتظمة حتى في الإجازة.",
    ),
    AppTip(
      title: "الحلو ليه يومه",
      description: "خليكي حريصه ان اكل الحلويات يكون في أيام محددة.",
    ),
    AppTip(
      title: "نفسيته أهم",
      description: "اهتمي بصحه طفلك النفسية… التوتر ممكن يزود الأكل.",
    ),
    AppTip(
      title: "صحته اهم",
      description:
          "دايمًا فكّريه إننا بنغير عادات عشان صحته وسعادته مش عشان شكله 💛✨",
    ),
    AppTip(
      title: "هو بيقلدك مش بيسمعك",
      description: "قدوتك أقوى من أي نصيحة… لما يشوفك بتاكلي صحي، هيتعلم منك.",
    ),
    AppTip(
      title: "التغيير بياخد وقت",
      description: "التعود على الأكل الصحي بياخد وقت… كرري بهدوء من غير ضغط.",
    ),
    AppTip(
      title: "المحاولة أهم من الكمية",
      description: "امدحي المحاولة مش الكمية… خطوة صغيرة تعتبر نجاح.",
    ),
    AppTip(
      title: "علاقة مش معركة",
      description: "ركزي على بناء علاقة صحية مع الأكل، مش على إنه يخلص الطبق.",
    ),
    AppTip(
      title: "التنوع سر الاستمرار",
      description: "التنوع أهم من الكمية… جربي طرق تقديم مختلفة لنفس النوع.",
    ),
  ];


  static const List<ChildTip> childTips = [
    ChildTip(
      text: "ابدأ يومك بوجبة إفطار متوازنة تحتوي على بروتين وألياف.",
    ),
    ChildTip(
      text: "لا تتخطى وجبة الإفطار حتى لا تشعر بالجوع الشديد فيما بعد.",
    ),
    ChildTip(
      text: "قسّم وجباتك إلى 3 وجبات رئيسية و2 سناك.",
    ),
    ChildTip(
      text: "تناول الطعام ببطء وامضغه جيدًا لتحسين الهضم.",
    ),
    ChildTip(
      text: "استمع لإشارات الشبع وتوقف عن الأكل عند الشعور بالاكتفاء.",
    ),
    ChildTip(
      text: "احرص على تناول وجباتك في مواعيد منتظمة يوميًا.",
    ),
    ChildTip(
      text: "اصنع وجباتك في المنزل لتتحكم في المكونات والكميات.",
    ),
    ChildTip(
      text: "استبدل الخبز الأبيض بالخبز الأسمر أو خبز الحبوب الكاملة.",
    ),
    ChildTip(
      text: "أضف الخضروات إلى كل وجبة رئيسية.",
    ),
    ChildTip(
      text: "نوّع من الخضار أو الفواكه لتحصل على عناصر غذائية مختلفة.",
    ),
    ChildTip(
      text: "تناول القليل من المكسرات يوميًا.",
    ),
    ChildTip(
      text: "احتفظ بزجاجة ماء بجانبك طوال اليوم.",
    ),
    ChildTip(
      text: "احرص على شرب الماء قبل الشعور بالعطش.",
    ),
    ChildTip(
      text: "قلل من تناول الوجبات السريعة قدر الإمكان.",
    ),
    ChildTip(
      text: "اختر الزبادي الطبيعي بدلًا من الزبادي المُحلى.",
    ),
    ChildTip(
      text: "احرص على تناول السمك مرتين أسبوعيًا.",
    ),
    ChildTip(
      text: "تناول البيض باعتدال وضمن نظام متوازن.",
    ),
    ChildTip(
      text: "استخدم أطباق أصغر للتحكم في حجم الوجبة.",
    ),
    ChildTip(
      text: "جهّز سناك صحي معك عند الخروج من المنزل.",
    ),
    ChildTip(
      text: "قلل من استهلاك الأطعمة المقلية.",
    ),
    ChildTip(
      text: "اختر منتجات الألبان قليلة الدسم.",
    ),
    ChildTip(
      text: "أضف بذور مثل الشيا أو الكتان إلى وجباتك.",
    ),
    ChildTip(
      text: "تناول الشوفان كخيار صحي للإفطار.",
    ),
    ChildTip(
      text: "جرّب وصفات صحية جديدة لتجنب الملل.",
    ),
    ChildTip(
      text:
          "لا تحرم نفسك تمامًا من الأطعمة التي تحبها، ولكن بكميات معقولة.",
    ),
    ChildTip(
      text: "تناول طبق سلطة قبل الوجبة الرئيسية.",
    ),
    ChildTip(
      text: "تجنب الأكل المتأخر جدًا قبل النوم.",
    ),
    ChildTip(
      text: "احرص على التعرض للشمس لدعم فيتامين د.",
    ),
    ChildTip(
      text: "تناول الفاكهة كوجبة خفيفة بين الوجبات.",
    ),
    ChildTip(
      text: "احرص على تنويع مصادر البروتين.",
    ),
    ChildTip(
      text: "اشرب كوب ماء بعد الاستيقاظ مباشرة.",
    ),
    ChildTip(
      text: "تجنب وضع الحلويات في متناول يدك.",
    ),
    ChildTip(
      text: "اجعل نصف طبقك من الخضروات.",
    ),
    ChildTip(
      text: "لا تستبدل الوجبات بالمشروبات فقط.",
    ),
    ChildTip(
      text: "لا تعتمد على الأنظمة الغذائية السريعة.",
    ),
    ChildTip(
      text: "تناول التمر كمصدر طاقة طبيعي.",
    ),
    ChildTip(
      text:
          "احرص على التوازن بين الكربوهيدرات والبروتين في كل وجبة.",
    ),
    ChildTip(
      text: "اغسل الخضروات والفاكهة جيدًا قبل تناولها.",
    ),
    ChildTip(
      text: "احرص على تناول وجبة بعد التمرين تحتوي على بروتين.",
    ),
    ChildTip(
      text: "اجعل هدفك تحسين صحتك لا مجرد إنقاص الوزن.",
    ),
    ChildTip(
      text: "شارك عائلتك في تناول وجبات صحية.",
    ),
    ChildTip(
      text: "لا تكافئ نفسك بالطعام فقط.",
    ),
    ChildTip(
      text: "خصص يومًا خاليًا من المشروبات الغازية.",
    ),
    ChildTip(
      text:
          "احرص على الحركة قبل النوم إذا كنت تجلس لفترات طويلة.",
    ),
    ChildTip(
      text: "مارس تمارين التنفس لتقليل التوتر.",
    ),
    ChildTip(
      text: "اجعل أسلوب حياتك صحيًا بشكل مستمر وليس مؤقتًا.",
    ),
  ];
}
