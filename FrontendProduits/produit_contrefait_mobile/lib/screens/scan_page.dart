// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart' as zxing;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  String? qrResult;
  bool _isScanning = false;
  String? _error;
  Map<String, dynamic>? _backendResult;
  Color? _backendMsgColor;
  String? _backendMsg;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      setState(() {
        _error = "Impossible d'accéder à la caméra : $e";
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _checkBackend(String code) async {
    setState(() {
      _backendResult = null;
      _backendMsg = null;
      _backendMsgColor = null;
    });
    final token = await _getToken();
    final url = Uri.parse(
      'https://7f12-129-0-103-69.ngrok-free.app/api_produits/unite_produit/scanner/?code=$code',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      dynamic backendData = response.body.isNotEmpty
          ? json.decode(response.body)
          : {};
      if (backendData is List && backendData.isNotEmpty) {
        backendData = <String, dynamic>{
          "message": backendData.first.toString(),
        };
      } else if (backendData is! Map) {
        backendData = <String, dynamic>{"message": backendData.toString()};
      }
      setState(() {
        _backendResult = backendData as Map<String, dynamic>;
        final msg = _backendResult?['message']?.toString().toLowerCase() ?? '';
        if (msg.contains('contacter le support')) {
          _backendMsgColor = Colors.blue;
        } else if (msg.contains('pas reconnu') || msg.contains('erreur lors du scan')) {
          _backendMsgColor = Colors.red;
        } else {
          _backendMsgColor = Colors.green;
        }
        _backendMsg =
            _backendResult?['message'] ??
            _backendResult?['nom'] ??
            "Produit reconnu";
      });
    } else {
      setState(() {
        _backendResult = {"error": "Produit inconnu ou erreur backend"};
        _backendMsgColor = Colors.red;
        _backendMsg = "Produit inconnu ou erreur backend";
      });
    }
  }

  

  Future<void> _showHistorique() async {
    final codeQr = qrResult;
    if (codeQr == null || codeQr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Code QR manquant"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(
        'https://7f12-129-0-103-69.ngrok-free.app/api_produits/unite_produit/historique/?uuid=$codeQr',
      ),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final historique = json.decode(response.body);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Historique du produit"),
          content: SizedBox(
            width: 400,
            height: 350,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: historique.length,
                itemBuilder: (ctx, i) {
                  final h = historique[i];
                  return ListTile(
                    title: Text(h['titre'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h['date'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        ...((h['details'] as List?) ?? [])
                            .map((d) => Text(d.toString())),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Fermer"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur historique : ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndDecodeImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    setState(() {
      _isScanning = true;
      qrResult = null;
      _backendResult = null;
      _error = null;
    });
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked == null) {
        setState(() {
          _isScanning = false;
          _error = "Aucune image sélectionnée.";
        });
        return;
      }
      final bytes = await picked.readAsBytes();
      final code = await _decodeQr(bytes);
      setState(() {
        qrResult = code;
        _isScanning = false;
        _error = code == null ? "Aucun QR code détecté." : null;
      });
      if (code != null) {
        await _checkBackend(code);
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _error = "Erreur lors du décodage : $e";
      });
    }
  }

  Future<String?> _decodeQr(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final rgbInts = Int32List.fromList(
        List<int>.generate(image.width * image.height, (i) {
          final x = i % image.width;
          final y = i ~/ image.width;
          final pixel = image.getPixel(x, y);
          final r = img.getRed(pixel);
          final g = img.getGreen(pixel);
          final b = img.getBlue(pixel);
          return (r << 16) | (g << 8) | b;
        }),
      );
      final luminance = zxing.RGBLuminanceSource(
        image.width,
        image.height,
        rgbInts,
      );
      final bitmap = zxing.BinaryBitmap(zxing.HybridBinarizer(luminance));
      final result = zxing.QRCodeReader().decode(bitmap);
      return result.text;
    } catch (e) {
      return null;
    }
  }

  Future<void> _captureAndDecode() async {
    setState(() {
      _isScanning = true;
      qrResult = null;
      _backendResult = null;
      _error = null;
    });
    try {
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();
      final code = await _decodeQr(bytes);
      setState(() {
        qrResult = code;
        _isScanning = false;
        _error = code == null ? "Aucun QR code détecté." : null;
      });
      if (code != null) {
        await _checkBackend(code);
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _error = "Erreur lors de la capture : $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un QR Code'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 2,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Caméra stylisée
              Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.blue.shade700, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.13),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: (_isCameraReady && _cameraController != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: CameraPreview(_cameraController!),
                      )
                    : Center(
                        child: _error != null
                            ? Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              )
                            : const CircularProgressIndicator(),
                      ),
              ),
              if (kIsWeb)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "La caméra en direct n'est pas supportée sur le web.\nUtilisez l'import d'image.",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 28),
              Text(
                "Scannez le QR Code du produit",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _isScanning
                    ? null
                    : () => _pickAndDecodeImage(source: ImageSource.gallery),
                icon: const Icon(Icons.image_rounded, size: 26),
                label: const Text("Importer une image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 3,
                ),
              ),
              if (_isCameraReady && _cameraController != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _captureAndDecode,
                    icon: const Icon(Icons.camera),
                    label: const Text("Capturer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      elevation: 3,
                    ),
                  ),
                ),
              if (_isScanning)
                const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: CircularProgressIndicator(),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (qrResult != null)
                Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(top: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 18,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Résultat du scan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 40,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SelectableText(
                              qrResult!,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_backendMsg != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: (_backendMsgColor ?? Colors.grey)
                                    .withOpacity(0.11),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _backendMsgColor ?? Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _backendMsgColor == Colors.green
                                        ? Icons.check_circle
                                        : _backendMsgColor == Colors.blue
                                            ? Icons.info
                                            : Icons.error_outline,
                                    color: _backendMsgColor,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 10),
                                  // Scroll vertical et affichage multi-ligne
                                  Expanded(
                                    child: SizedBox(
                                      height: 120, // Augmente la hauteur pour plus de visibilité
                                      child: Scrollbar(
                                        thumbVisibility: true,
                                        child: SingleChildScrollView(
                                          child: Text(
                                            _backendMsg!,
                                            style: TextStyle(
                                              color: _backendMsgColor ?? Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showHistorique,
                              icon: const Icon(Icons.history_rounded),
                              label: const Text("Historique"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
