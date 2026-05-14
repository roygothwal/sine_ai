import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static const Map<String, List<String>> dialogues = {
    'Motivational 🔥': [
      'Uth jaa! Kab tak soyega? Zindagi bahut choti hai!',
      'Maa baap ke sapne hain tere — uth aur kuch kar!',
      'Har subah ek naya mauka hai — mat chuk ise!',
      'Log uthke kaam kar rahe hain — tu abhi tak so raha hai?',
      'Reels scroll mat kar — uth ja aur kuch kar!',
      'Winner log itna nahi sote — uth champion!',
      'Aaj ka din tera hai — uth aur jagat mein chhap chhod!',
      'Time nikal raha hai haath se — abhi uth ja!',
      'Sapne dekhna band kar — unhe poora karne uth!',
      'Teri zindagi teri marzi — lekin sote rehne se kuch nahi milta!',
      'Ek din aayega jab tu khud pe proud hoga — aaj se shuru kar!',
      'Duniya aage nikal rahi hai — tu abhi bhi bistar mein hai?',
      'Mehnat karo aaj — kal results khud bolenge!',
      'Apne future self ke liye uth — wo tera shukriya adaa karega!',
      'Teri taakat teri mehnat mein hai — uth aur dikha!',
      'Aaj kuch aisa kar ki kal teri story sunne waale hon!',
      'Uth jaa — duniya tujhe dekh rahi hai!',
      'Safalta uthne waalon ko milti hai — so jaane waalon ko nahi!',
      'Jo kal nahi kar paaya — aaj kar! Uth jaaa!',
      'Teri maa ki duaaein hain tere saath — unhe waste mat kar!',
    ],
    'Attitude 😤': [
      'Oye! Log kaam pe ja chuke — tu abhi bhi so raha hai?',
      'Attitude rakhta hai? Toh uth aur prove kar!',
      'Winner kabhi itna nahi sote — tu kya hai decide kar!',
      'Duniya ne tujhe ignore kiya — uth aur unhe galat sabit kar!',
      'Tere dushman abhi kaam kar rahe hain — tu so raha hai?',
      'Baat karne se nahi hota — uthke kaam karne se hota hai!',
      'Loser so jaate hain — winner uthte hain!',
      'Real attitude wale sone mein waqt barbaad nahi karte — UTH!',
      'Prove karna hai na? Toh bistar se uth pehle!',
      'King log uthke game khelte hain — sote nahi rehte!',
      'Rona band kar — uthna shuru kar!',
      'Tu deserve karta hai best — toh best ban pehle!',
      'Log hasenge — hasne de — uth aur dikha!',
      'Tujhe prove karna hai — toh uth aur kar!',
      'Real ones never quit — uth ja abhi!',
    ],
    'Funny 😂': [
      'Oye neend ki dukaan band kar — grahak aa gaye!',
      'Tera bistar bol raha hai — please mujhe chhod do!',
      'Alarm ne teri dukaan kholi — ab kaam pe ja!',
      'Teri neend ka contractor aa gaya — contract khatam!',
      'Subah ho gayi bhai — suraj bhi sharmaaya teri neend dekh ke!',
      'Uth ja warna pizza delivery wala bhi chala jaayega!',
      'Neend poori ho gayi — ab zindagi poori karne uth!',
      'Tu itna sota hai ki neend bhi thak jaati hai!',
      'Uth ja bhai — chai thandi ho rahi hai!',
      'Bhai uth — warna din mein raat ho jaayegi!',
    ],
    'Spiritual 🙏': [
      'Har subah ek naya gift hai — uth aur ise khol!',
      'Ishwar ne aaj ka din diya hai — shukriya ada kar uthke!',
      'Zindagi bahut khoobsurat hai — uth aur dekh!',
      'Shukraan kar is subah ka — bahut log kal nahi uthe!',
      'Ek ek pal keemti hai — waste mat kar!',
      'Teri rooh jaag gayi — ab jism ko bhi jagaa!',
      'Bhagwan ne mauka diya hai — uth aur use kar!',
      'Dil se uth — aur dil se kaam kar!',
      'Aaj ka din phir nahi aayega — uth aur jeele!',
      'Mann mein shakti hai — uth aur jagaa use!',
    ],
    'Aggressive 🔥': [
      'UTH JAA ABHI! Koi nahi aayega teri zindagi jeene!',
      'Ye waqt nahi aayega dobara — UTH!',
      'Bistar teri qabar nahi hai — UTH JA!',
      'Ab bas! Bahut so liya — UTHNA HAI ABHI!',
      'Competition tujhe dekh raha hai — UTH YA HAAR JA!',
      'Ruk mat — uth aur tod de saari hadein!',
      'Dar mat — uth aur saamna kar!',
      'Haar nahi maanenge — UTH JA!',
      'Zindagi ek baar milti hai — BARBAAD MAT KAR!',
      'No excuses — UTH JA!',
    ],
    'Caring ❤️': [
      'Good morning — uth ja pyaar se!',
      'Neend poori hui? Uth ja dheerey dheerey!',
      'Aaj bhi ek sundar din hai — uth aur enjoy kar!',
      'Apna khayal rakh — uth aur nashta kar pehle!',
      'Tu bahut mehnat karta hai — aaj bhi best dena!',
      'Health pehle — uth aur paani pi!',
      'Tujhse pyaar karne waalon ke liye uth!',
      'Teri smile se din roshan hota hai — uth aur muskuraa!',
      'Chhota sa alarm — bada sa din hai aage!',
      'Tera din bahut achha hoga — bas uth ja!',
    ],
    'Gentle 🌙': [
      'Dheerey dheerey uth ja — subah ho gayi!',
      'Aankhein khol — din shuru ho gaya!',
      'Ek gehri saans le — aur uth ja!',
      'Kal ki thakaan bhool ja — aaj naya din hai!',
      'Din tumhara intezaar kar raha hai — uth ja!',
      'Subah ki tazgi feel kar — uth ja!',
      'Aankhein khol — sab theek hai — uth ja!',
      'Aaj ka din tera hai — uth aur jeele!',
      'Khud ko waqt de — phir uth ja!',
      'Soft sa din hai aaj — uth ja!',
    ],
  };

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _initialized = true;
  }

  static Future<void> speakDialogue(String mood) async {
    await init();
    final list = dialogues[mood] ?? dialogues['Motivational 🔥']!;
    final dialogue = list[Random().nextInt(list.length)];
    await _tts.speak(dialogue);
  }

  static Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  static Future<void> scheduleAlarm({
    required int id,
    required String time,
    required String label,
    required String mood,
    required List<bool> days,
  }) async {
    await init();

    final dialogue = _getDialogue(mood);

    final androidDetails = AndroidNotificationDetails(
      'sine_alarm_channel',
      'SINE Alarms',
      channelDescription: 'SINE AI Smart Alarms',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, '⏰ $label', dialogue, details);

    // TTS bhi bolega
    await speakDialogue(mood);
  }

  static Future<void> scheduleReminder({
    required int id,
    required String time,
    required String label,
    required String message,
  }) async {
    await init();

    final androidDetails = AndroidNotificationDetails(
  'sine_alarm_channel',
  'SINE Alarms',
  channelDescription: 'SINE AI Smart Alarms',
  importance: Importance.max,
  priority: Priority.max,
  fullScreenIntent: true,
  category: AndroidNotificationCategory.alarm,
  visibility: NotificationVisibility.public,
  playSound: true,
  enableVibration: true,
  vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
);

const iosDetails = DarwinNotificationDetails(
  presentAlert: true,
  presentBadge: true,
  presentSound: true,
);

final details = NotificationDetails(
  android: androidDetails,
  iOS: iosDetails,
);

    await _plugin.show(id, '🔔 $label', message, details);
  }

  static String _getDialogue(String mood) {
    final list = dialogues[mood] ?? dialogues['Motivational 🔥']!;
    return list[Random().nextInt(list.length)];
  }

  static Future<void> cancelAlarm(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}