/**
 * صباحًا (10:00 Cairo): نصيحة للأم + تسجيل في Firestore لقائمة التطبيق والـ badge.
 */
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const {PARENT_TIPS} = require("./parentTipsData");
const {
  cairoDateString,
  writePersonalScheduledNotifications,
  INVALID_FCM_TOKEN_ERRORS,
  clearInvalidFcmTokens,
} = require("./scheduledNotificationFirestore");

exports.sendParentMorningTipFCM = onSchedule(
  {
    schedule: "0 10 * * *",
    timeZone: "Africa/Cairo",
    region: "us-central1",
    memory: "512MiB",
    timeoutSeconds: 540,
  },
  async () => {
    const db = admin.firestore();
    const dataRoute = "/home";
    const dateStr = cairoDateString();
    const notifDocId = `parent_tip_${dateStr}`;

    const dayIndex = cairoDayIndex();
    const tip = PARENT_TIPS[dayIndex % PARENT_TIPS.length];
    const title = tip.title;
    const body = truncateBody(tip.description, 220);

    const batchSize = 400;
    let lastDoc = null;
    let totalAttempted = 0;

    const chunk = (arr, size) => {
      const out = [];
      for (let i = 0; i < arr.length; i += size) {
        out.push(arr.slice(i, i + size));
      }
      return out;
    };

    for (;;) {
      let q = db
        .collection("users")
        .where("fcmToken", ">", "")
        .orderBy("fcmToken")
        .limit(batchSize);
      if (lastDoc) {
        q = q.startAfter(lastDoc);
      }
      const snap = await q.get();
      if (snap.empty) {
        break;
      }

      const tokenToUids = new Map();
      for (const doc of snap.docs) {
        const d = doc.data();
        if (d.role !== "parent") {
          continue;
        }
        if (d.fcmDailyPushEnabled === false) {
          continue;
        }
        if (
          d.fcmNotifyStreak === false &&
          d.fcmNotifyTasks === false &&
          d.fcmNotifyInsights === false
        ) {
          continue;
        }
        if (typeof d.fcmToken === "string" && d.fcmToken.length > 0) {
          const t = d.fcmToken;
          const current = tokenToUids.get(t) || [];
          current.push(doc.id);
          tokenToUids.set(t, current);
        }
      }

      const unique = [...tokenToUids.keys()];
      const successfulUids = new Set();
      const invalidTokens = new Set();
      for (const part of chunk(unique, 500)) {
        try {
          const resp = await admin.messaging().sendEachForMulticast({
            tokens: part,
            notification: {
              title: "نصيحة الصباح: " + title,
              body,
            },
            data: {
              route: dataRoute,
              category: "daily",
              type: "parent_tip",
            },
          });
          totalAttempted += resp.successCount;
          resp.responses?.forEach((r, i) => {
            const sentToken = part[i];
            if (r.success) {
              const mapped = tokenToUids.get(sentToken) || [];
              for (const uid of mapped) {
                successfulUids.add(uid);
              }
              return;
            }

            const code = r.error?.code;
            if (INVALID_FCM_TOKEN_ERRORS.has(code)) {
              invalidTokens.add(sentToken);
            }
          });
          if (resp.failureCount > 0) {
            console.warn(
              "sendParentMorningTipFCM: failures",
              resp.failureCount,
            );
          }
        } catch (err) {
          console.error("sendParentMorningTipFCM multicast error", err);
        }
      }

      await clearInvalidFcmTokens(db, [...invalidTokens]);

      await writePersonalScheduledNotifications(db, [...successfulUids], {
        docId: notifDocId,
        titleAr: title,
        bodyAr: body,
        type: "parent_tip",
        actionUrl: `route:${dataRoute}`,
      });

      lastDoc = snap.docs[snap.docs.length - 1];
      if (snap.size < batchSize) {
        break;
      }
    }

    console.log(
      "sendParentMorningTipFCM done, dayIndex",
      dayIndex,
      "approx success:",
      totalAttempted,
    );
  },
);

function cairoDayIndex() {
  const now = new Date();
  const parts = new Intl.DateTimeFormat("en", {
    timeZone: "Africa/Cairo",
    year: "numeric",
    month: "numeric",
    day: "numeric",
  }).formatToParts(now);
  const y = +parts.find((p) => p.type === "year").value;
  const m = +parts.find((p) => p.type === "month").value;
  const d = +parts.find((p) => p.type === "day").value;
  const utc = Date.UTC(y, m - 1, d);
  const startYear = Date.UTC(y, 0, 1);
  return Math.floor((utc - startYear) / 86400000);
}

function truncateBody(s, max) {
  if (!s || s.length <= max) {
    return s || "";
  }
  return s.slice(0, max - 1) + "…";
}
