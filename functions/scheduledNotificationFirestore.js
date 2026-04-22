/**
 * Writes one doc per user under users/{uid}/notifications/{docId}
 * so the in-app list + badge stay in sync with scheduled FCM.
 */
const admin = require("firebase-admin");

/** YYYY-MM-DD in Africa/Cairo (same day bucket as schedulers). */
function cairoDateString(d = new Date()) {
  const parts = new Intl.DateTimeFormat("en", {
    timeZone: "Africa/Cairo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(d);
  const y = parts.find((p) => p.type === "year")?.value;
  const m = parts.find((p) => p.type === "month")?.value;
  const day = parts.find((p) => p.type === "day")?.value;
  return `${y}-${m}-${day}`;
}

/**
 * @param {FirebaseFirestore.Firestore} db
 * @param {string[]} uids
 * @param {{ docId: string, titleAr: string, bodyAr: string, type: string, actionUrl?: string }} payload
 */
async function writePersonalScheduledNotifications(db, uids, payload) {
  const {docId, titleAr, bodyAr, type, actionUrl = "route:/home"} = payload;
  if (!uids.length) {
    return;
  }

  const fields = {
    titleAr,
    bodyAr,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    // Keep isRead untouched on re-runs (same docId/day) to avoid flipping read -> unread.
    type,
    actionUrl,
  };

  let batch = db.batch();
  let n = 0;
  for (const uid of uids) {
    const ref = db
      .collection("users")
      .doc(uid)
      .collection("notifications")
      .doc(docId);
    batch.set(ref, fields, {merge: true});
    n++;
    if (n >= 450) {
      await batch.commit();
      batch = db.batch();
      n = 0;
    }
  }
  if (n > 0) {
    await batch.commit();
  }
}

const INVALID_FCM_TOKEN_ERRORS = new Set([
  "messaging/invalid-registration-token",
  "messaging/registration-token-not-registered",
]);

/**
 * Deletes invalid FCM tokens from users docs to avoid repeated send failures.
 * @param {FirebaseFirestore.Firestore} db
 * @param {string[]} tokens
 */
async function clearInvalidFcmTokens(db, tokens) {
  const unique = [...new Set(tokens)].filter(Boolean);
  if (!unique.length) {
    return;
  }

  let batch = db.batch();
  let n = 0;
  for (const token of unique) {
    const snap = await db
      .collection("users")
      .where("fcmToken", "==", token)
      .limit(50)
      .get();

    for (const doc of snap.docs) {
      batch.set(
        doc.ref,
        {
          fcmToken: admin.firestore.FieldValue.delete(),
          fcmTokenUpdatedAt: admin.firestore.FieldValue.delete(),
        },
        {merge: true},
      );
      n++;
      if (n >= 450) {
        await batch.commit();
        batch = db.batch();
        n = 0;
      }
    }
  }

  if (n > 0) {
    await batch.commit();
  }
}

module.exports = {
  cairoDateString,
  writePersonalScheduledNotifications,
  INVALID_FCM_TOKEN_ERRORS,
  clearInvalidFcmTokens,
};
