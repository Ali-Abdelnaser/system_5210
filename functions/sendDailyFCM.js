/**
 * Scheduled FCM — isolated module so deploy discovery loads less code in one pass.
 */
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

exports.sendDaily5210ReminderFCM = onSchedule(
  {
    schedule: "0 10 * * *",
    timeZone: "Africa/Cairo",
    region: "us-central1",
    memory: "512MiB",
    timeoutSeconds: 540,
  },
  async (event) => {
    const db = admin.firestore();
    const title = "5210 — تذكير يومي";
    const body = "كمل يومك الصحي مع 5210. افتح التطبيق وتابع تحديك!";
    const dataRoute = "/home";

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

      const tokens = [];
      for (const doc of snap.docs) {
        const d = doc.data();
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
          tokens.push(d.fcmToken);
        }
      }

      const unique = [...new Set(tokens)];
      for (const part of chunk(unique, 500)) {
        try {
          const resp = await admin.messaging().sendEachForMulticast({
            tokens: part,
            notification: {title, body},
            data: {
              route: dataRoute,
              category: "daily",
            },
          });
          totalAttempted += resp.successCount;
          if (resp.failureCount > 0) {
            console.warn(
              "sendDaily5210ReminderFCM: failures",
              resp.failureCount,
              resp.responses?.slice(0, 3),
            );
          }
        } catch (err) {
          console.error("sendDaily5210ReminderFCM multicast error", err);
        }
      }

      lastDoc = snap.docs[snap.docs.length - 1];
      if (snap.size < batchSize) {
        break;
      }
    }

    console.log("sendDaily5210ReminderFCM done, approx success:", totalAttempted);
  },
);
