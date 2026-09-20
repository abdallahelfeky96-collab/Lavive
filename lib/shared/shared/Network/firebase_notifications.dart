import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:short_navigation/short_navigation.dart';
import 'package:vegesea/layout/chat/chat_screen.dart';
import 'package:vegesea/layout/orders/orders_screen.dart';

class FirebaseNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Request permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and store device token
    String? deviceToken = await _firebaseMessaging.getToken();
    if (deviceToken != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("device_token", deviceToken);
      log("Device Token: $deviceToken");
    }

    // Initialize local notifications
    _initializeLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final Map<String, dynamic> notificationJson = {
        'data': message.data,
        'notification': message.notification != null
            ? {
                'title': message.notification!.title,
                'body': message.notification!.body,
              }
            : null,
      };
      log("🔔 Foreground Notification Received (JSON): ${jsonEncode(notificationJson)}");

      if (message.notification != null) {
        _showNotification(message);
      }
    });

    _handleBackgroundNotification();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Local Notification Clicked: ${response.payload}");

        if (response.payload != null) {
          try {
            if (response.payload == 'chat') {
              Go.to(const OrdersScreen());
              return;
            }

            if (response.payload!.startsWith('order_')) {
              String orderIdOrCode = response.payload!.substring(6);
              log("Local Notification: Navigating to order $orderIdOrCode");
              // Numeric ID or alphanumeric Code
              dynamic targetId = int.tryParse(orderIdOrCode) ?? orderIdOrCode;
              Go.toName("order_details_page", arguments: targetId);
              return;
            }

            if (response.payload!.startsWith('product_')) {
              int? productId = int.tryParse(response.payload!.substring(8));
              if (productId != null) {
                Go.toName("product_details_page", arguments: productId);
                return;
              }
            }

            if (response.payload!.startsWith('category_')) {
              int? categoryId = int.tryParse(response.payload!.substring(9));
              if (categoryId != null) {
                Go.toName("sub_categories_page", arguments: categoryId);
                return;
              }
            }
          } catch (e) {
            log("Error handling notification response: $e");
          }
        }

        // Default navigation
        Go.to(const OrdersScreen());
      },
    );
  }

  Future<void> _showNotification(RemoteMessage message) async {
    log("Showing notification for message: ${message.data}");

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'message_channel_id',
      'Message Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Determine payload based on message data or body
    dynamic orderIdOrCode = _getOrderIdOrCode(message);
    String payload = 'chat';
    
    if (orderIdOrCode != null && orderIdOrCode.toString().isNotEmpty) {
      payload = 'order_$orderIdOrCode';
    } else if (message.data['type'] == 'chat') {
      payload = 'chat';
    } else if (message.data.containsKey('product_id') && message.data['product_id'].toString().isNotEmpty) {
      payload = 'product_${message.data['product_id']}';
    } else if (message.data.containsKey('category_id') && message.data['category_id'].toString().isNotEmpty) {
      payload = 'category_${message.data['category_id']}';
    }

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().microsecondsSinceEpoch % 1000000, // Better Unique ID
      message.notification?.title ?? "New Message",
      message.notification?.body ?? "You have received a message",
      notificationDetails,
      payload: payload,
    );
  }

  dynamic _getOrderIdOrCode(RemoteMessage message) {
    // 1. Try to get from data payload
    if (message.data.containsKey('order_id')) {
      final value = message.data['order_id'];
      if (value != null && value.toString().isNotEmpty) {
        return int.tryParse(value.toString()) ?? value;
      }
    }
    if (message.data.containsKey('id')) {
      final value = message.data['id'];
      if (value != null && value.toString().isNotEmpty) {
        return int.tryParse(value.toString()) ?? value;
      }
    }

    // 2. Try to extract from notification body (e.g., "Your order #27_1_6.1889 has been confirmed.")
    final String? body = message.notification?.body;
    if (body != null) {
      log("Attempting to extract Order ID from body: $body");
      // Matches # followed by digits (Order ID)
      // We take only the numeric part because alphanumeric codes (like 27_1_6.1889) 
      // are not supported by the fetchOrder API, but their ID part (27) is.
      final RegExp orderRegExp = RegExp(r'#(\d+)');
      final match = orderRegExp.firstMatch(body);
      if (match != null) {
        final extracted = match.group(1);
        log("Extracted order ID from body: $extracted");
        return int.tryParse(extracted!) ?? extracted;
      }
    }
    return null;
  }

  void _handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    // Convert message info to JSON for debugging
    final Map<String, dynamic> notificationJson = {
      'data': message.data,
      'notification': message.notification != null
          ? {
              'title': message.notification!.title,
              'body': message.notification!.body,
            }
          : null,
    };
    log("🚀 Notification Clicked/Opened (JSON): ${jsonEncode(notificationJson)}");

    log("Notification Data: ${message.data}");
    log("Notification Title: ${message.notification?.title}");
    log("Notification Body: ${message.notification?.body}");

    // Better chat check: either by title or a 'type' field in data
    bool isChat = message.notification?.title == "لديك رسالة جديدة" ||
        message.notification?.title == "New Message" ||
        message.data['type'] == 'chat';

    if (isChat) {
      log("Opening Chat Screen from notification");
      Go.to(const ChatScreen());
      return;
    }

    int? categoryID =
        int.tryParse(message.data['category_id']?.toString() ?? '');
    int? productID = int.tryParse(message.data['product_id']?.toString() ?? '');
    dynamic orderIDOrCode = _getOrderIdOrCode(message);

    log("IDs extracted - categoryID: $categoryID, productID: $productID, orderID/Code: $orderIDOrCode");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (categoryID != null) prefs.setInt("category_id", categoryID);
    if (productID != null) prefs.setInt("product_id", productID);
    if (orderIDOrCode != null) {
      if (orderIDOrCode is int) {
        prefs.setInt("order_id", orderIDOrCode);
      } else {
        prefs.setString("order_id", orderIDOrCode.toString());
      }
    }

    if (orderIDOrCode != null && orderIDOrCode.toString().isNotEmpty) {
      log("Navigating to order details for ID/Code: $orderIDOrCode");
      Go.toName("order_details_page", arguments: orderIDOrCode);
      return;
    }

    if (productID != null) {
      log("Navigating to product details for ID: $productID");
      Go.toName("product_details_page", arguments: productID);
      return;
    }

    if (categoryID != null) {
      log("Navigating to sub categories for ID: $categoryID");
      Go.toName("sub_categories_page", arguments: categoryID);
      return;
    }

    log("No specific ID found, navigating to root_view");
    Go.toName("root_view");
  }

  Future<void> _handleBackgroundNotification() async {
    // When the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        log("App opened from terminated state via notification");
        _handleMessage(message);
      }
    });

    // When the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("App opened from background via notification");
      _handleMessage(message);
    });
  }
}
