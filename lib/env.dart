import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'GOOGLE_ANDROID_API_KEY', obfuscate: true)
  static final String googleAndroidApiKey = _Env.googleAndroidApiKey;

  @EnviedField(varName: 'GOOGLE_IOS_API_KEY', obfuscate: true)
  static final String googleIosApiKey = _Env.googleIosApiKey;

  @EnviedField(varName: 'OPENAI_API_KEY', obfuscate: true)
  static final String openAIApiKey = _Env.openAIApiKey;

  @EnviedField(varName: 'GOOGLE_MAPS_API_KEY', obfuscate: true)
  static final String googleMapsApiKey = _Env.googleMapsApiKey;

  @EnviedField(varName: 'REVENUECAT_IOS_KEY', obfuscate: true)
  static final String revenueCatIosKey = _Env.revenueCatIosKey;

  @EnviedField(varName: 'REVENUECAT_ANDROID_KEY', obfuscate: true)
  static final String revenueCatAndroidKey = _Env.revenueCatAndroidKey;
}
