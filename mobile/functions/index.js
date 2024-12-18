/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.onUserRecordCreated = onDocumentCreated("UserRecords/{recordId}", async (event) => {
  const snapshot = event.data;
  const recordId = event.params.recordId;
  const record = snapshot.data();
  if (!record) return;

  const userId = record.user_id;
  const distance = record.distance || 0;
  const totalTime = record.total_time || 0;
  const startTime = record.start_time;

  if (!userId || !startTime) return;

  const userStatsRef = db.collection("UserStats").doc(userId);
  const userStatsDoc = await userStatsRef.get();

  const stats = {
    total_run_count: 0,
    total_run_days: 0,
    longest_streak: 0,
    current_streak: 0,
    total_distance: 0,
    total_time: 0,
    last_run_date: null,
  };

  if (userStatsDoc.exists) {
    const existingData = userStatsDoc.data() || {};
    stats.total_run_count = existingData.total_run_count || 0;
    stats.total_run_days = existingData.total_run_days || 0;
    stats.longest_streak = existingData.longest_streak || 0;
    stats.current_streak = existingData.current_streak || 0;
    stats.total_distance = existingData.total_distance || 0;
    stats.total_time = existingData.total_time || 0;
    stats.last_run_date = existingData.last_run_date || null;
  }

  // 누적 통계 업데이트
  stats.total_run_count += 1;
  stats.total_distance += distance;
  stats.total_time += totalTime;

  const currentDate = startTime.toDate();
  const runDateStr = currentDate.toISOString().split("T")[0]; // "yyyy-MM-dd"
  const [year, month] = runDateStr.split("-");
  const lastRunDate = stats.last_run_date ? stats.last_run_date.toDate() : null;

  // 연속 달리기 계산
  if (!lastRunDate) {
    // 첫 기록
    stats.total_run_days = 1;
    stats.current_streak = 1;
  } else {
    const lastRunDateStr = lastRunDate.toISOString().split("T")[0];
    if (lastRunDateStr === runDateStr) {
      // 같은 날 이미 달린 기록이 있는 경우, total_run_days 변화 없음
    } else {
      const oneDayMillis = 24 * 60 * 60 * 1000;
      const diffDays = Math.floor((currentDate.getTime() - lastRunDate.getTime()) / oneDayMillis);

      if (diffDays === 1) {
        // 연속 +1일
        stats.current_streak += 1;
        stats.total_run_days += 1;
      } else {
        // 연속 끊김
        stats.current_streak = 1;
        stats.total_run_days += 1;
      }
    }
  }

  // 최장 연속일수 갱신
  if (stats.current_streak > stats.longest_streak) {
    stats.longest_streak = stats.current_streak;
  }

  // 마지막 달린 날짜 갱신
  stats.last_run_date = admin.firestore.Timestamp.fromDate(currentDate);

  // UserStats 문서 업데이트
  await userStatsRef.set(stats, {merge: true});

  // 월별/일별 기록 문서 업데이트
  const monthKey = `${year}-${month}`; // 예: "2024-12"
  const dailyRecordRef = userStatsRef
      .collection(monthKey) // "2024-12"
      .doc(runDateStr); // "2024-12-10"

  await dailyRecordRef.set({
    date: runDateStr,
    records: admin.firestore.FieldValue.arrayUnion({
      record_id: recordId,
    }),
  }, {merge: true});

  console.log(`UserStats & ${year}-${month}/${runDateStr} updated for user: ${userId}`);
});
