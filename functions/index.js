const admin = require("firebase-admin");
const {onSchedule} = require("firebase-functions/v2/scheduler");

admin.initializeApp();

exports.refreshWeeklyRecommendations = onSchedule(
  {
    schedule: "every monday 06:00",
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
    retryCount: 1,
  },
  async () => {
    const now = admin.firestore.Timestamp.now();
    const snapshot = await admin.firestore().collection("tasteProfiles").limit(100).get();
    const batch = admin.firestore().batch();

    snapshot.docs.forEach((doc) => {
      const data = doc.data();
      const genres = Array.isArray(data.genres) ? data.genres.slice(0, 12) : [];
      const topArtists = Array.isArray(data.topArtists) ? data.topArtists.slice(0, 12) : [];
      const topTracks = Array.isArray(data.topTracks) ? data.topTracks.slice(0, 12) : [];
      batch.set(
        admin.firestore().collection("recommendationJobs").doc(doc.id),
        {
          basis: "spotify-taste-profile",
          genres,
          topArtists,
          topTracks,
          refreshedAt: now,
          status: "ready-for-client-refresh",
        },
        {merge: true},
      );
    });

    await batch.commit();
  },
);
