import 'dart:ui';
import 'package:simple_3d/simple_3d.dart';

///
/// (en)A simple light for shooting Sp3dObj.
///
/// (ja)Sp3dWorldの撮影用のシンプルなライトです。
///
/// Author Masahide Mori
///
/// First edition creation date 2021-09-30 21:17:02
///
class Sp3dLight {
  final String className = 'Sp3dLight';
  final String version = '2';
  Sp3dV3D direction;
  double minBrightness;
  bool applyStroke;
  bool syncCam;

  /// Constructor
  /// * [direction] : Light direction(must normalized).
  /// * [minBrightness] : Minimum value of brightness magnification. value is 0.0~1.0.
  /// * [applyStroke] : If true, apply light to wire frame. Default is false.
  /// * [syncCam] : If true, the light is always from the same direction as the camera.
  Sp3dLight(this.direction,
      {this.minBrightness = 0.0,
      this.applyStroke = false,
      this.syncCam = true});

  /// (en)Deep copy the object.
  ///
  /// (ja)このオブジェクトをディープコピーします。
  ///
  Sp3dLight deepCopy() {
    return Sp3dLight(this.direction,
        minBrightness: this.minBrightness,
        applyStroke: this.applyStroke,
        syncCam: this.syncCam);
  }

  /// (en)Convert the object to a dictionary.
  ///
  /// (ja)このオブジェクトを辞書に変換します。
  ///
  Map<String, dynamic> toDict() {
    Map<String, dynamic> d = {};
    d['class_name'] = this.className;
    d['version'] = this.version;
    d['direction'] = this.direction.toDict();
    d['min_brightness'] = this.minBrightness;
    d['apply_stroke'] = this.applyStroke;
    d['sync_cam'] = this.syncCam;
    return d;
  }

  /// (en)Restore this object from the dictionary.
  ///
  /// (ja)辞書からオブジェクトを復元します。
  ///
  /// * [src] : A dictionary made with to_dict of this class.
  static Sp3dLight fromDict(Map<String, dynamic> src) {
    return Sp3dLight(Sp3dV3D.fromDict(src['direction']),
        minBrightness: src['is_absolute_position'],
        applyStroke: src['apply_stroke'],
        syncCam: src['sync_cam']);
  }

  /// (en)Returns the color as a result of this light being applied to a particular surface.
  ///
  /// (ja)特定の面にこのライトが適用された結果としての色を返します。
  ///
  /// * [nsn] : The normalized surface normal vector.
  /// * [camTheta] : With this, the light is always from the same direction as the camera.
  /// * [material] : The material to which light is applied.
  ///
  /// Returns : [Color(bg),Color(stroke)].
  List<Color> apply(Sp3dV3D nsn, double camTheta, Sp3dMaterial material) {
    List<Color> r = [];
    // 光の計算
    // 正規化されたベクトル同士の内積を取ると結果がcosΘになるので、そこから光の拡散度合い（光の強さ）に変換する。
    // RGB値に掛け合わせて明度を変化させるために、内積をさらに0~1の範囲に補正。
    late double brightness;
    if (this.syncCam) {
      brightness = camTheta.clamp(0.0, 1.0);
    } else {
      brightness = Sp3dV3D.dot(nsn, this.direction).clamp(0.0, 1.0);
    }
    if (brightness < this.minBrightness) {
      brightness = this.minBrightness;
    }
    // ライトを適用
    Color bg = material.bg;
    r.add(Color.fromARGB(bg.alpha, (brightness * bg.red).toInt(),
        (brightness * bg.green).toInt(), (brightness * bg.blue).toInt()));
    Color sc = material.strokeColor;
    if (this.applyStroke) {
      r.add(Color.fromARGB(sc.alpha, (brightness * sc.red).toInt(),
          (brightness * sc.green).toInt(), (brightness * sc.blue).toInt()));
    } else {
      r.add(sc);
    }
    return r;
  }
}
