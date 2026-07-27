import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_result.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save linked mobile number to user profile
  Future<void> updateUserMobile(String uid, String mobileNumber) async {
    try {
      await _db.collection('users').doc(uid).set({
        'mobileNumber': mobileNumber,
        'isSubscribed': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignore errors
    }
  }

  // Update name and email profile info
  Future<void> updateUserProfile(String uid, String name, String email) async {
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignore errors
    }
  }

  // Update subscription status in Firestore
  Future<void> updateSubscriptionStatus(String uid, bool isSubscribed) async {
    try {
      await _db.collection('users').doc(uid).set({
        'isSubscribed': isSubscribed,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignore errors
    }
  }

  // Get list of seen question IDs for a subscriber/user
  Future<Set<String>> getSeenQuestionIds(String identifier) async {
    if (identifier.isEmpty) return {};
    try {
      final doc = await _db.collection('user_seen_questions').doc(identifier).get();
      if (doc.exists) {
        final List<dynamic> ids = doc.data()?['seenIds'] ?? [];
        return ids.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
    return {};
  }

  // Add question IDs to user's seen list in Firestore so they never repeat
  Future<void> markQuestionsAsSeen(String identifier, List<String> questionIds) async {
    if (identifier.isEmpty || questionIds.isEmpty) return;
    try {
      await _db.collection('user_seen_questions').doc(identifier).set({
        'seenIds': FieldValue.arrayUnion(questionIds),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  // Save exam result to user's history and update leaderboard
  Future<void> saveExamResult(String uid, String userName, String userEmail, QuizResult result) async {
    try {
      final historyRef = _db.collection('users').doc(uid).collection('exam_history');
      await historyRef.add({
        'totalScore': result.totalScore,
        'maxScore': result.maxScore,
        'correctAnswers': result.correctAnswers,
        'totalQuestions': result.totalQuestions,
        'percentage': result.percentage,
        'grade': result.grade,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update global leaderboard
      final leaderboardRef = _db.collection('leaderboard').doc(uid);
      final doc = await leaderboardRef.get();
      if (doc.exists) {
        final currentHigh = doc.data()?['highScore'] ?? 0;
        if (result.totalScore > currentHigh) {
          await leaderboardRef.set({
            'uid': uid,
            'name': userName,
            'email': userEmail,
            'highScore': result.totalScore,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } else {
        await leaderboardRef.set({
          'uid': uid,
          'name': userName,
          'email': userEmail,
          'highScore': result.totalScore,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  // Fetch exam history for a user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserExamHistory(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('exam_history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Fetch top leaderboard
  Stream<QuerySnapshot<Map<String, dynamic>>> getLeaderboard() {
    return _db
        .collection('leaderboard')
        .orderBy('highScore', descending: true)
        .limit(20)
        .snapshots();
  }
}
