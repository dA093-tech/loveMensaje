'use strict';

const { onValueWritten } = require('firebase-functions/v2/database');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { initializeApp } = require('firebase-admin/app');

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

/**
 * When a new stroke is written to RTDB, find the partner
 * and send them an FCM notification.
 */
exports.onNewStroke = onValueWritten(
  {
    ref: '/drawings/{pairId}/strokes/{strokeId}',
    region: 'us-central1',
  },
  async (event) => {
    const { pairId, strokeId } = event.params;
    const data = event.data.after.val();

    if (!data) return;

    const userId = data.userId;

    try {
      const pairDoc = await db.collection('pairs').doc(pairId).get();
      if (!pairDoc.exists) return;

      const pair = pairDoc.data();
      const partnerId = pair.user1Id === userId ? pair.user2Id : pair.user1Id;

      const partnerDoc = await db.collection('users').doc(partnerId).get();
      if (!partnerDoc.exists) return;

      const partner = partnerDoc.data();
      const fcmToken = partner.fcmToken;
      if (!fcmToken) return;

      const senderDoc = await db.collection('users').doc(userId).get();
      const senderName = senderDoc.exists
        ? senderDoc.data().displayName || 'Tu pareja'
        : 'Tu pareja';

      const message = {
        token: fcmToken,
        notification: {
          title: 'Nuevo dibujo',
          body: `${senderName} está dibujando contigo`,
        },
        data: {
          type: 'drawing',
          pairId: pairId,
          strokeId: strokeId,
          userId: userId,
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'hooklove_drawing',
            priority: 'high',
            vibrateTimingsMillis: [0, 100, 50, 100],
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
      };

      await messaging.send(message);
    } catch (error) {
      console.error('Error sending stroke notification:', error);
    }
  }
);

/**
 * When presence changes to 'drawing', notify partner via FCM.
 */
exports.onPresenceChanged = onValueWritten(
  {
    ref: '/drawings/{pairId}/presence/{userId}',
    region: 'us-central1',
  },
  async (event) => {
    const { pairId, userId } = event.params;
    const newStatus = event.data.after.val();
    const oldStatus = event.data.before.val();

    if (newStatus === oldStatus) return;
    if (newStatus !== 'drawing') return;

    try {
      const pairDoc = await db.collection('pairs').doc(pairId).get();
      if (!pairDoc.exists) return;

      const pair = pairDoc.data();
      const partnerId = pair.user1Id === userId ? pair.user2Id : pair.user1Id;

      const partnerDoc = await db.collection('users').doc(partnerId).get();
      if (!partnerDoc.exists) return;

      const partner = partnerDoc.data();
      const fcmToken = partner.fcmToken;
      if (!fcmToken) return;

      const senderDoc = await db.collection('users').doc(userId).get();
      const senderName = senderDoc.exists
        ? senderDoc.data().displayName || 'Tu pareja'
        : 'Tu pareja';

      const message = {
        token: fcmToken,
        notification: {
          title: 'Dibujando ahora',
          body: `${senderName} empezó a dibujar`,
        },
        data: {
          type: 'presence',
          pairId: pairId,
          userId: userId,
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'hooklove_drawing',
            priority: 'high',
            vibrateTimingsMillis: [0, 50],
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
      };

      await messaging.send(message);
    } catch (error) {
      console.error('Error sending presence notification:', error);
    }
  }
);
