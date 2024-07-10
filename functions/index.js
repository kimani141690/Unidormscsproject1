const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const bodyParser = require('body-parser');

admin.initializeApp();
const db = admin.firestore();

const app = express();
app.use(bodyParser.json());

app.post('/mpesa-callback/:bookingId', async (req, res) => {
  const { Body } = req.body;
  const { stkCallback } = Body;
  const bookingId = req.params.bookingId;

  if (stkCallback && stkCallback.CallbackMetadata) {
    const { Item } = stkCallback.CallbackMetadata;
    const resultCode = stkCallback.ResultCode;

    const bookingRef = db.collection('bookings').doc(bookingId);
    const bookingDoc = await bookingRef.get();
    const bookingData = bookingDoc.data();
    const userId = bookingData.userId;

    if (resultCode === 0) {
      // Update booking status to confirmed
      await bookingRef.update({
        status: 'confirmed'
      });
      await sendNotification(userId, "Booking Successful", "Your booking has been confirmed.");
      res.status(200).send('Booking confirmed');
    } else {
      // Handle payment failure
      await bookingRef.update({
        status: 'failed'
      });
      await sendNotification(userId, "Booking Failed", "Your booking could not be completed. Please try again.");
      res.status(200).send('Booking failed');
    }
  } else {
    res.status(400).send('Invalid callback data');
  }
});

async function sendNotification(userId, title, body) {
  const userDoc = await db.collection('users').doc(userId).get();
  const fcmToken = userDoc.get('fcmToken');

  if (fcmToken) {
    const payload = {
      notification: {
        title: title,
        body: body,
      },
      token: fcmToken,
    };

    await admin.messaging().send(payload);
  }
}

exports.api = functions.https.onRequest(app);
