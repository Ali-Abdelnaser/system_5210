const {onCall, HttpsError} = require("firebase-functions/v2/https");
const functions = require("firebase-functions/v1"); // Explicitly use v1 for Auth triggers
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configuration
const APP_COLOR = "#2D3142"; // Dark Navy (Premium & Professional)

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "alinaserhema60@gmail.com",
    pass: "zbll etpa bdej osag",
  },
});

/**
 * 1. Send Password Reset OTP
 */
exports.sendPasswordResetOTP = onCall(async (request) => {
  const email = request.data.email;
  if (!email) throw new HttpsError("invalid-argument", "Email required.");

  const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
  const expiry = Date.now() + 10 * 60 * 1000;

  await admin.firestore().collection("password_resets").doc(email).set({
    code: otpCode,
    expiresAt: expiry,
  });

  const mailOptions = {
    from: "\"5210EG\" <no-reply@system5210.com>",
    to: email,
    subject: "Reset your password - 5210EG",
    html: `
    <div style="background-color: #f9f9f9; padding: 50px 0; font-family: sans-serif;">
      <div style="max-width: 500px; margin: auto; background-color: #ffffff; border-radius: 20px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.05);">
        <img src="https://i.ibb.co/hxkPYM2S/app-logo.png" alt="5210EG" style="height: 140px; margin-bottom: 25px;">
        <h2 style="color: #1a1a1a; font-size: 24px;">Password Reset</h2>
        <p style="color: #666; font-size: 16px;">Use the code below to reset your password:</p>
        <div style="background-color: #f0f2f5; border: 1px solid ${APP_COLOR}; border-radius: 12px; padding: 25px; margin: 30px 0; display: inline-block;">
          <span style="font-size: 36px; font-weight: 800; color: ${APP_COLOR}; letter-spacing: 8px;">${otpCode}</span>
        </div>
        <p style="color: #999; font-size: 13px;">This code expires in 10 minutes.</p>
      </div>
    </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return {success: true};
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 2. Verify OTP
 */
exports.verifyOTP = onCall(async (request) => {
  const {email, code} = request.data;
  const doc = await admin.firestore().collection("password_resets").doc(email).get();

  if (!doc.exists || doc.data().code !== code) {
    throw new HttpsError("not-found", "Invalid code.");
  }
  if (Date.now() > doc.data().expiresAt) {
    throw new HttpsError("deadline-exceeded", "Code expired.");
  }
  return {success: true};
});

/**
 * 3. Reset Password with OTP
 */
exports.resetPasswordWithOTP = onCall(async (request) => {
  const {email, newPassword} = request.data;
  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().updateUser(user.uid, {password: newPassword});
    await admin.firestore().collection("password_resets").doc(email).delete();
    return {success: true};
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 4. Send Email Verification OTP
 */
exports.sendEmailVerificationOTP = onCall(async (request) => {
  const email = request.data.email;
  const name = request.data.name || "Hero";
  if (!email) throw new HttpsError("invalid-argument", "Email required.");

  const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
  const expiry = Date.now() + 15 * 60 * 1000;

  await admin.firestore().collection("email_verifications").doc(email).set({
    code: otpCode,
    expiresAt: expiry,
  });

  const mailOptions = {
    from: "\"5210EG\" <no-reply@system5210.com>",
    to: email,
    subject: "Activate your account - 5210EG",
    html: `
    <div style="margin: 0; padding: 0; background-color: #ffffff; font-family: sans-serif;">
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td align="center" style="padding: 40px 0;">
            <div style="max-width: 500px; width: 100%; border: 1px solid #f0f0f0; border-radius: 24px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.03);">
              <div style="padding: 40px 40px 20px 40px; text-align: center;">
                <img src="https://i.ibb.co/hxkPYM2S/app-logo.png" alt="5210EG" style="height: 140px; margin-bottom: 25px;">
                <h1 style="color: #1a1a1a; font-size: 28px; font-weight: 700;">Account Activation</h1>
                <p style="color: #666; font-size: 16px; margin: 20px 0 30px 0;">Hello ${name}, use the code below to verify your email.</p>
                <div style="background-color: #f0f2f5; border: 2px solid ${APP_COLOR}; border-radius: 16px; padding: 25px; display: inline-block;">
                  <span style="font-size: 42px; font-weight: 800; color: ${APP_COLOR}; letter-spacing: 12px;">${otpCode}</span>
                </div>
                <p style="color: #999; font-size: 13px; margin-top: 30px;">Expiration: 15 minutes.</p>
              </div>
            </div>
          </td>
        </tr>
      </table>
    </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return {success: true};
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 5. Verify Email OTP
 */
exports.verifyEmailOTP = onCall(async (request) => {
  const {email, code} = request.data;
  const doc = await admin.firestore().collection("email_verifications").doc(email).get();

  if (!doc.exists || doc.data().code !== code) {
    throw new HttpsError("permission-denied", "Invalid code.");
  }
  if (Date.now() > doc.data().expiresAt) {
    throw new HttpsError("deadline-exceeded", "Code expired.");
  }

  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().updateUser(user.uid, {emailVerified: true});
    await admin.firestore().collection("email_verifications").doc(email).delete();
    return {success: true};
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 6. Welcome Email (V1)
 */
exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
  const email = user.email;
  const name = user.displayName || "Hero";
  if (!email) return null;

  const mailOptions = {
    from: "\"5210EG\" <no-reply@system5210.com>",
    to: email,
    subject: "Welcome to 5210EG Movement!",
    html: `
    <div style="margin: 0; padding: 0; background-color: #ffffff; font-family: sans-serif;">
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td align="center" style="padding: 40px 0;">
            <div style="max-width: 600px; width: 100%; border: 1px solid #f0f0f0; border-radius: 20px; overflow: hidden;">
              <div style="padding: 40px; text-align: center;">
                <img src="https://i.ibb.co/hxkPYM2S/app-logo.png" alt="5210EG" style="height: 140px; margin-bottom: 25px;">
                <h1 style="color: #1a1a1a; font-size: 28px;">Welcome, ${name}!</h1>
                <p style="color: #666; margin-top: 15px;">Your healthy journey starts now.</p>
              </div>
              <div style="padding: 0 40px 40px 40px;">
                <div style="background-color: #f0f2f5; border-radius: 20px; padding: 30px; text-align: center;">
                  <h2 style="color: ${APP_COLOR}; font-size: 18px; margin-top: 0;">5-2-1-0 Principles</h2>
                  <p style="color: #444; font-size: 15px; line-height: 1.6;">
                    🍎 5 Fruits & Veggies | 📺 2h Screen Max<br>
                    🏃 1h Activity | 💧 0 Sugary Drinks
                  </p>
                </div>
              </div>
            </div>
          </td>
        </tr>
      </table>
    </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error("Error sending welcome email:", error);
  }
  return null;
});

/**
 * 7. Security Alerts (V1)
 * Detects Password Changes or Email Changes
 */
// exports.onUserAccountUpdate = functions.auth.user().onUpdate(async (change) => {
//   const before = change.before;
//   const after = change.after;
//
//   // A. Password Changed
//   if (before.passwordHash !== after.passwordHash) {
//     const email = after.email;
//     if (email) {
//       const mailOptions = {
//         from: "\"5210EG Security\" <no-reply@system5210.com>",
//         to: email,
//         subject: "Security Alert: Password Changed",
//         html: `
//         <div style="background-color: #f9f9f9; padding: 50px 0; font-family: sans-serif;">
//           <div style="max-width: 500px; margin: auto; background-color: #ffffff; border-radius: 20px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.05);">
//             <img src="https://i.ibb.co/hxkPYM2S/app-logo.png" alt="5210EG" style="height: 140px; margin-bottom: 25px;">
//             <h2 style="color: ${APP_COLOR}; font-size: 24px;">Password Changed</h2>
//             <p style="color: #666; font-size: 16px;">Your password was successfully updated.</p>
//             <div style="margin: 30px 0;">
//               <p style="color: #999; font-size: 13px;">If you didn't make this change, please recover your account immediately.</p>
//             </div>
//           </div>
//         </div>
//         `,
//       };
//       await transporter.sendMail(mailOptions);
//     }
//   }
//
//   // B. Email Changed
//   if (before.email !== after.email) {
//     // Notify OLD email
//     if (before.email) {
//       const mailOptions = {
//         from: "\"5210EG Security\" <no-reply@system5210.com>",
//         to: before.email,
//         subject: "Security Alert: Email Changed",
//         html: `
//         <div style="background-color: #f9f9f9; padding: 50px 0; font-family: sans-serif;">
//           <div style="max-width: 500px; margin: auto; background-color: #ffffff; border-radius: 20px; padding: 40px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.05);">
//             <img src="https://i.ibb.co/hxkPYM2S/app-logo.png" alt="5210EG" style="height: 140px; margin-bottom: 25px;">
//             <h2 style="color: ${APP_COLOR}; font-size: 24px;">Email Changed</h2>
//             <p style="color: #666; font-size: 16px;">Your account email was changed to <b>${after.email}</b>.</p>
//             <div style="margin: 30px 0;">
//               <p style="color: #fb3f35; font-size: 14px; font-weight: bold;">If you didn't do this, secure your account now.</p>
//             </div>
//           </div>
//         </div>
//         `,
//       };
//       await transporter.sendMail(mailOptions);
//     }
//   }
// });
