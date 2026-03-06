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

class AppTipsData {
  static const List<AppTip> parentTips = [
    AppTip(
      title: "الحقيقة اللي محدش قالهالك",
      description:
          "راعي نفسية طفلك، وشجعيه بالألعاب الرياضيه بدل النقد عند التعامل مع وزنه الزائد.",
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
      descriptionEn: "Make sure to prepare a breakfast rich in fiber and low in sugar.",
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

  static const List<AppTip> childTips = [
    AppTip(
      title: "قوس قزح في طبقك 🌈",
      description:
          "حاول تاكل فواكه وخضروات بألوان مختلفة كل يوم (أحمر، أخضر، أصفر..) عشان جسمك ياخد كل الفيتامينات.",
      titleEn: "A Rainbow on Your Plate 🌈",
      descriptionEn:
          "Try to eat fruits and vegetables of different colors every day (red, green, yellow...) so your body gets all the vitamins.",
    ),
    AppTip(
      title: "أبطال الحبوب الكاملة 🌾",
      description:
          "الشوفان والأرز البني والقمح بيخلوك شبعان لفترة طويلة وبيدوك طاقة قوية للعب.",
      titleEn: "Whole Grain Heroes 🌾",
      descriptionEn:
          "Oats, brown rice, and wheat keep you full for a long time and give you strong energy for playing.",
    ),
    AppTip(
      title: "مصنع العضلات 💪",
      description:
          "السمك والبيض واللحمة والحليب هم اللي بيبنوا عضلاتك القوية.. اختار منهم نوع كل يوم.",
      titleEn: "Muscle Factory 💪",
      descriptionEn:
          "Fish, eggs, meat, and milk build your strong muscles. Choose one of them every day.",
    ),
    AppTip(
      title: "سناك الأبطال الأذكياء 🧠",
      description:
          "لما تجوع بين الوجبات، اختار خيار وجزر مكسرات مش مملحة.. دي تسالي الأذكياء!",
      titleEn: "Smart Heroes' Snack 🧠",
      descriptionEn:
          "When you get hungry between meals, choose cucumbers, carrots, and unsalted nuts. These are smart snacks!",
    ),
    AppTip(
      title: "سر الملح المخفي 🧂",
      description: "قلل الملح في أكلك عشان قلبك وجسمك يفضلوا بصحة ممتازة.",
      titleEn: "Hidden Salt Secret 🧂",
      descriptionEn:
          "Reduce the salt in your food for your heart and body to stay in excellent health.",
    ),
    AppTip(
      title: "اختار الخفيف والمفيد 🐟",
      description:
          "السمك والفراخ المشوية أخف بكتير على معدتك وبيدوك نشاط أكتر من المقليات.",
      titleEn: "Choose Light and Useful 🐟",
      descriptionEn:
          "Grilled fish and chicken are much lighter on your stomach and give you more energy than fried foods.",
    ),
    AppTip(
      title: "كوب الحيوية 🥛",
      description: "اشرب كوب لبن كل يوم عشان عضمك وسنانك يبقوا زي الحديد.",
      titleEn: "Vitality Cup 🥛",
      descriptionEn: "Drink a cup of milk every day for your bones and teeth to stay strong like iron.",
    ),
    AppTip(
      title: "ابعد عن المصنعات 🛑",
      description:
          "اللانشون والأكل المصنع بيتعب جسمك.. خليك دايمًا في الأكل الطبيعي اللي مامي بتعمله.",
      titleEn: "Stay Away from Processed Foods 🛑",
      descriptionEn:
          "Lunch meat and processed food tire your body. Always stick to the natural food your mommy makes.",
    ),
    AppTip(
      title: "عدو النشاط الصامت 🍭",
      description:
          "الحلويات والمشروبات الغازية بتهبط طاقتك بسرعة.. استبدلها بعصير طبيعي أو فاكهة.",
    ),
    AppTip(
      title: "حلوى من الطبيعة 🍎",
      description:
          "الفاكهة هي أحسن حلويات ممكن تاكلها.. طعمها أحلى وبتقوي مناعتك.",
    ),
    AppTip(
      title: "كميات صغيرة لطاقة كبيرة 🍫",
      description:
          "لو أكلت حلويات، خليها كميات صغيرة جداً عشان طاقتك تدوم طول اليوم.",
    ),
    AppTip(
      title: "وقت الفاكهة الصح ⏰",
      description:
          "متآكلش فاكهة أو حلويات بعد الأكل مباشرة.. استنى شوية عشان معدتك تهضم الأكل صح.",
    ),
    AppTip(
      title: "صديقك الوفي: الماء 💧",
      description:
          "المياه هي أهم مشروب لجسمك.. خليك دايمًا حريص إنك تشرب مياه كتير.",
    ),
    AppTip(
      title: "المشروب الأرخص والأصح 🚰",
      description:
          "مياه الحنفية النظيفة هي أكتر حاجة صحية ومفيدة لجسمك.. جربها بدل العصائر الجاهزة.",
    ),
    AppTip(
      title: "وداعاً للسكر 🚫",
      description:
          "لو عطشت، اشرب مياه بدل المشروبات السكرية.. دي أسهل طريقة تحافظ بيها على صحتك.",
    ),
    AppTip(
      title: "درع النظافة 🧼",
      description:
          "اغسل إيدك بالماء والصابون لمدة 20 ثانية (زي ما بتغني أغنيتك المفضلة) عشان تقتل الجراثيم.",
    ),
    AppTip(
      title: "الحركة بركة 🏃‍♂️",
      description:
          "العب واتحرك واجري.. النشاط بيخليك بطل حقيقي ومزاجك دايمًا رايق.",
    ),
    AppTip(
      title: "غذي عقلك بالقراءة 📚",
      description:
          "بدل الموبيل، جرب تقرأ قصة النهاردة.. القراءة بتفتح مخك وتخليك تتخيل حاجات مذهلة.",
    ),
    AppTip(
      title: "فطار الأبطال 🥙",
      description:
          "ابدأ يومك بوجبة إفطار متوازنة فيها بروتين وألياف عشان جسمك يفضل نشيط طول اليوم.",
    ),
    AppTip(
      title: "إوعى تنسى الفطار! ☀️",
      description:
          "الفطار هو أهم وجبة، بلاش تفوته عشان متجوعش بزيادة وبطريقة مش صحية بعدين.",
    ),
    AppTip(
      title: "تقسيمة بطل 🔢",
      description:
          "قسّم أكلك لـ 3 وجبات أساسية و2 سناك صحي في النص، عشان جسمك يفضل شغال بكفاءة.",
    ),
    AppTip(
      title: "على مهلك يا بطل 🐢",
      description:
          "كل براحة وامضغ الأكل كويس، ده بيساعد معدتك تهضم الأكل أحسن وبيريحك كتير.",
    ),
    AppTip(
      title: "إشارة الوقوف 🛑",
      description:
          "ركز مع جسمك، وأول ما تحس إنك شبعت وقف أكل.. جسمك أدرى باحتياجه.",
    ),
    AppTip(
      title: "احترام المواعيد ⏰",
      description:
          "ثبت مواعيد أكلك كل يوم، ده بيظبط ساعتك البيولوجية وبيخلي جسمك في أحسن حالاته.",
    ),
    AppTip(
      title: "شيف المستقبل 👨‍🍳",
      description:
          "أكل البيت هو الأضمن! حاول تساعد في تحضير وجباتك عشان تظبط المكونات والكميات اللي جسمك محتاجها.",
    ),
    AppTip(
      title: "الاختيار الأسمر 🍞",
      description:
          "بدل العيش الأبيض بالعيش الأسمر أو الحبوب الكاملة.. فايدة أكتر وشبع أطول.",
    ),
    AppTip(
      title: "صديق الوجبات 🥦",
      description:
          "خلي الخضار ضيف دايم في كل وجبة أساسية، هو اللي بيديك الفيتامينات اللي ناقصاك.",
    ),
    AppTip(
      title: "لوحة فنية صحية 🎨",
      description:
          "خلي طبقك ملون بخضروات مختلفة.. كل لون فيه سحر وفائدة معينة لجسمك.",
    ),
    AppTip(
      title: "منجم طاقة صغير 🥜",
      description:
          "شوية مكسرات صغيرة كل يوم بتفرق جداً في نشاط عقلك وصحة قلبك.",
    ),
    AppTip(
      title: "رفيقك المبلل 💧",
      description:
          "خلي إزازة الماية جنبك دايمًا، عشان متنساش تشرب وتفضل جسمك رطب ومفرفش.",
    ),
    AppTip(
      title: "قبل العطش! 🌊",
      description:
          "مستناش لما تعطش عشان تشرب، العطش إشارة إن جسمك بدأ ينشف.. خليك سابق بخطوة.",
    ),
    AppTip(
      title: "خطر سريع 🍔",
      description:
          "الوجبات السريعة طعمها بيغري بس أضرارها كتير.. قللها على قد ما تقدر لسلامة جسمك.",
    ),
    AppTip(
      title: "زبادي طبيعي ومفيد 🥛",
      description:
          "اختار الزبادي السادة وضيف عليه فاكهة طبيعية أحسن بكتير من الزبادي المحلى بالصناعات.",
    ),
    AppTip(
      title: "غذاء الأذكياء 🐟",
      description:
          "السمك مرتين في الأسبوع بيخلي عقلك يشتغل زي الكمبيوتر ويقوي قلبك.",
    ),
    AppTip(
      title: "بيضة بطل 🥚",
      description:
          "البيض مصدر ممتاز للبروتين.. كُل بيض باعتدال عشان تبني عضلاتك صح.",
    ),
    AppTip(
      title: "خدعة الطبق الصغير 🍽️",
      description:
          "ستقبل طبق أصغر شوية، ده بيساعدك تتحكم في الكمية اللي بتاكلها من غير ما تحس بالحرمان.",
    ),
    AppTip(
      title: "سناك الطوارئ 🍏",
      description:
          "وانت خارج، خد معاك فاكهة أو مكسرات، عشان لما تجوع متضطرش تاكل حاجة مش صحية.",
    ),
    AppTip(
      title: "وداعاً للزيوت 🍟",
      description:
          "المقليات فيها دهون تقيلة على جسمك.. جرب المشوي أو المسلوق هتحس بفرق كبير في نشاطك.",
    ),
    AppTip(
      title: "ألبان خفيفة 🥛",
      description:
          "الألبان قليلة الدسم بتديك الكالسيوم اللي محتاجه من غير الدهون الزيادة.",
    ),
    AppTip(
      title: "بذور القوة 🌱",
      description:
          "رشة بذور شيا أو كتان على أكلك بتضيفلك أوميجا 3 وألياف مهمة جداً.",
    ),
    AppTip(
      title: "طاقة الشوفان 🥣",
      description:
          "الشوفان فطار مثالي بيديك طاقة بتكمل معاك لنص اليوم وبيريح معدتك.",
    ),
    AppTip(
      title: "مغامرة المطبخ 🥗",
      description:
          "جرب وصفات صحية جديدة كل أسبوع عشان متزهقش من نظامك وتستمتع بالأكل الصحي.",
    ),
    AppTip(
      title: "دلع بعقل 🍬",
      description:
          "مش لازم تحرم نفسك من اللي بتحبه، بس كل منه كميات صغنتوتة وعلى فترات بعيدة.",
    ),
    AppTip(
      title: "البداية الخضراء 🥗",
      description:
          "ابدأ وجبتك بالسلطة، بتشبعك أسرع وبتحسن الهضم قبل ما تاكل الأكل التقيل.",
    ),
    AppTip(
      title: "نوم هادي 😴",
      description:
          "بلاش تاكل وجبات تقيلة قبل النوم مباشرة، سيب وقت لمعدتك ترتاح عشان تنام نوم عميق.",
    ),
    AppTip(
      title: "صديقة الشمس ☀️",
      description:
          "اخرج في الشمس شوية كل يوم عشان جسمك يصنع فيتامين د اللي بيقوي عضمك.",
    ),
    AppTip(
      title: "سناك الفاكهة 🍎",
      description:
          "لما تحس بجوع خفيف بين الوجبات، خلي اختيارك الأول هو الفاكهة الطازجة.",
    ),
    AppTip(
      title: "بروتينات مشكلة 🍗",
      description:
          "نوع في مصادر البروتين (فراخ، سمك، بقوليات) عشان تاخد كل الأحماض الأمينية اللي جسمك محتاجها.",
    ),
    AppTip(
      title: "إنعاش الصباح 💧",
      description:
          "أول ما تصحى اشرب كوباية ماية، بتغسل جسمك من السموم وبتنشط أعضاءك.",
    ),
    AppTip(
      title: "بعيد عن العين 🍪",
      description:
          "خلي الحلويات في مكان بعيد ومستخبي، عشان متضعفش وتاكلها كل ما تشوفها.",
    ),
    AppTip(
      title: "قانون النص 🥦",
      description:
          "خلي نص طبقك دايمًا خضار، الربع بروتين والربع نشويات.. دي المعادلة المثالية.",
    ),
    AppTip(
      title: "الأكل أكل 🍕",
      description:
          "المشروبات مش بديل للأكل، جسمك محتاج ألياف وعناصر موجودة في الأكل الصلب بس.",
    ),
    AppTip(
      title: "طريق طويل وصح 🏃",
      description:
          "بلاش تنجرف وراء الأنظمة السريعة والوهمية، الصحة مشوار محتاج صبر واستمرار.",
    ),
    AppTip(
      title: "تمر الطاقة 🌴",
      description:
          "التمر سناك عبقري وبيديك طاقة فورية.. كُل وحدات قليلة منه في اليوم.",
    ),
    AppTip(
      title: "توازن القوى ⚖️",
      description:
          "كل وجبة لازم يكون فيها توازن بين النشويات والبروتين عشان سكر الدم يفضل مضبوط.",
    ),
    AppTip(
      title: "نظافة وأمان 🧼",
      description:
          "اغسل أكلك كويس جداً قبل ما تاكله عشان تحمي نفسك من أي جراثيم أو كيمياويات.",
    ),
    AppTip(
      title: "غذاء العضلات 🦾",
      description:
          "بعد التمرين جسمك بيحتاج بروتين عشان يبني العضلات اللي اشتغلت.. بلاش تفوت الوجبة دي.",
    ),
    AppTip(
      title: "هدفنا الصحة ❤️",
      description:
          "خلي هدفك إنك تكون بصحة كويسة ونشاط عالي، والوزن المثالي هييجي لوحده كنتيجة.",
    ),
    AppTip(
      title: "قوة العيلة 👨‍👩‍👧‍👦",
      description:
          "شجع أهلك وأصحابك ياكلوا صحي معاك، الجماعة بتدي قوة وبتخلي الأكل طعمه أحلى.",
    ),
    AppTip(
      title: "مكافأة غير الأكل 🎁",
      description:
          "لما تنجح في حاجة، كافئ نفسك بخروجة أو لعبة جديدة، مش لازم المكافأة تكون أكل دسم.",
    ),
    AppTip(
      title: "يوم بدون صودا 🚫",
      description:
          "تحدى نفسك وخصص يوم (وبعدين أيام) مفيش فيه أي مشروبات غازية خالص.",
    ),
    AppTip(
      title: "حركة خفيفة 🚶",
      description:
          "لو قضيت يومك قاعد، اتحرك شوية قبل ما تنام عشان تنشط الدورة الدموية وتريح جسمك.",
    ),
    AppTip(
      title: "اتنفس بعمق 🧘",
      description:
          "لما تتوتر، خد نفس عميق.. التوتر بيخلينا ناكل أكتر من غير ما نحس، والتنفس بيهديك.",
    ),
    AppTip(
      title: "أسلوب حياة ♾️",
      description:
          "الصحة مش فترة وهتخلص، دي رحلة مستمرة معانا طول العمر عشان نعيش بسعادة.",
    ),
  ];
}
