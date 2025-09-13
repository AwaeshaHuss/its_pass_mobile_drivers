import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/trip_models.dart';
import '../utils/app_logger.dart';

// Top-level function for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.notification('Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Notification callbacks
  final Map<String, Function(Map<String, dynamic>)> _notificationHandlers = {};
  
  bool _isInitialized = false;
  String? _fcmToken;

  /// Initialize push notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.info('User granted provisional permission');
      } else {
        AppLogger.warning('User declined or has not accepted permission');
        return false;
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      AppLogger.info('FCM Token: $_fcmToken');

      // Configure message handlers
      _configureMessageHandlers();

      _isInitialized = true;
      return true;
    } catch (e) {
      AppLogger.error('Error initializing push notifications', e);
      return false;
    }
  }

  /// Configure Firebase message handlers
  void _configureMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle notification taps when app is terminated
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.notification('Got a message whilst in the foreground!');
    AppLogger.notification('Message data: ${message.data}');

    if (message.notification != null) {
      AppLogger.notification('Message also contained a notification: ${message.notification}');
    }

    // Handle custom data
    _processNotificationData(message.data);
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.notification('Message clicked!');
    _processNotificationData(message.data);
  }

  /// Process notification data and trigger callbacks
  void _processNotificationData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type != null && _notificationHandlers.containsKey(type)) {
      _notificationHandlers[type]!(data);
    }
  }

  /// Show trip request notification (Firebase only)
  Future<void> showTripRequestNotification({
    required String title,
    required String body,
    required Map<String, dynamic> tripData,
  }) async {
    // For Firebase-only implementation, we rely on server-sent notifications
    // The actual notification display is handled by the Firebase SDK
    AppLogger.notification('Trip request notification: $title - $body');
    _processNotificationData(tripData);
  }

  /// Register notification handler
  void registerNotificationHandler(String type, Function(Map<String, dynamic>) handler) {
    _notificationHandlers[type] = handler;
  }

  /// Unregister notification handler
  void unregisterNotificationHandler(String type) {
    _notificationHandlers.remove(type);
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Show trip request notification
  void showTripRequest(Trip trip) {
    showTripRequestNotification(
      title: 'New Trip Request',
      body: 'From ${trip.pickupAddress} to ${trip.destinationAddress}',
      tripData: trip.toJson(),
    );
  }

  /// Show trip status update notification
  void showTripStatusUpdate(String status, Trip trip) {
    final data = {
      'type': 'trip_update',
      'status': status,
      'trip': trip.toJson(),
    };
    _processNotificationData(data);
  }

  /// Show earnings notification
  void showEarningsUpdate(double amount) {
    final data = {
      'type': 'earnings',
      'amount': amount,
    };
    _processNotificationData(data);
  }

  /// Show system notification
  void showSystemNotification(String title, String message) {
    final data = {
      'type': 'system',
      'title': title,
      'message': message,
    };
    _processNotificationData(data);
  }
}
