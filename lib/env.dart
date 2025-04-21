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
}
