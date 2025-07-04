// ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart' as zxing;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:qr_code_tools/qr_code_tools.dart';

class QrScanOrImportPage extends StatefulWidget {
  const QrScanOrImportPage({Key? key}) : super(key: key);

  @override
  State<QrScanOrImportPage> createState() => _QrScanOrImportPageState();
}

class _QrScanOrImportPageState extends State<QrScanOrImportPage> {
  CameraController? _controller;
  bool _isLoading = true;
  bool _isScanning = false;
  bool _isCapturing = false;
  String? _scanResult;
  String? _error;
  XFile? _pickedImage;
  Map<String, dynamic>? _backendResult;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    debugPrint('E-mail récupéré : $email');
    return email;
  }

  Future<void> _initCamera() async {
    try {
      debugPrint('Tentative d\'initialisation de la caméra...');
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('Aucune caméra détectée.');
        setState(() {
          _isLoading = false;
          _error = 'Aucune caméra détectée sur cet appareil.';
        });
        return;
      }
      debugPrint('Caméras disponibles : ${cameras.length}');
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      debugPrint('Caméra sélectionnée : ${backCamera.name}');
      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      debugPrint('Initialisation du CameraController...');
      await _controller!.initialize();
      debugPrint('CameraController initialisé.');
      if (kIsWeb) {
        debugPrint('Vérification de la compatibilité sur le web...');
        if (!_controller!.value.isInitialized) {
          debugPrint('Le CameraController n\'est pas correctement initialisé.');
          setState(() {
            _isLoading = false;
            _error = 'Échec de l\'initialisation de la caméra.';
          });
          return;
        }
      }
      debugPrint('Caméra initialisée avec succès.');
      setState(() {
        _isLoading = false;
        _error = null;
      });
      // Démarrer le scanning continu
      _startScanning();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de la caméra : $e');
      setState(() {
        _isLoading = false;
        _error = 'Erreur caméra : $e';
      });
    }
  }

  void _startScanning() {
    if (_controller == null || !_controller!.value.isInitialized || _isScanning) {
      debugPrint('Scanning impossible : controller=${_controller != null}, initialized=${_controller?.value.isInitialized}, scanning=$_isScanning');
      return;
    }
    debugPrint('Démarrage du scanning continu...');
    setState(() {
      _isScanning = true;
      _scanResult = null;
      _backendResult = null;
    });
    if (kIsWeb) {
      _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!_isScanning || _isCapturing) {
          debugPrint('Scanning ignoré : scanning=$_isScanning, capturing=$_isCapturing');
          return;
        }
        setState(() {
          _isCapturing = true;
        });
        try {
          debugPrint('Capture d\'une image pour le scanning...');
          final image = await _controller!.takePicture();
          debugPrint('Image capturée, lecture des bytes...');
          final bytes = await image.readAsBytes();
          debugPrint('Taille des bytes : ${bytes.length}');
          // Enregistrer l'image pour inspection (pour débogage)
          if (!kIsWeb) {
            final directory = await getTemporaryDirectory();
            final path = '${directory.path}/qr_scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
            await io.File(path).writeAsBytes(bytes);
            debugPrint('Image enregistrée pour inspection : $path');
          }
          final result = await _decodeQr(bytes);
          if (result != null) {
            debugPrint('QR code détecté : $result');
            setState(() {
              _scanResult = result;
              _isScanning = false;
            });
            timer.cancel();
            debugPrint('Scanning arrêté après détection.');
            await _checkBackend(result);
          } else {
            debugPrint('Aucun QR code détecté dans l\'image.');
          }
        } catch (e) {
          debugPrint('Erreur lors du scanning : $e');
        } finally {
          setState(() {
            _isCapturing = false;
          });
        }
      });
    } else {
      _controller!.startImageStream((CameraImage image) async {
        if (!_isScanning || _isCapturing) return;
        setState(() {
          _isCapturing = true;
        });
        try {
          debugPrint('Analyse d\'une image du flux...');
          final bytes = _convertCameraImageToBytes(image);
          if (bytes == null) {
            debugPrint('Échec de la conversion de l\'image.');
            return;
          }
          debugPrint('Taille des bytes : ${bytes.length}');
          final result = await _decodeQr(bytes);
          if (result != null) {
            debugPrint('QR code détecté : $result');
            setState(() {
              _scanResult = result;
              _isScanning = false;
            });
            await _controller!.stopImageStream();
            debugPrint('Flux vidéo arrêté après détection.');
            await _checkBackend(result);
          } else {
            debugPrint('Aucun QR code détecté dans l\'image.');
          }
        } catch (e) {
          debugPrint('Erreur lors du scanning : $e');
        } finally {
          setState(() {
            _isCapturing = false;
          });
        }
      }).catchError((e) {
        debugPrint('Erreur dans le flux vidéo : $e');
        setState(() {
          _isScanning = false;
          _error = 'Erreur dans le flux vidéo : $e';
        });
      });
    }
  }

  void _stopScanning() {
    debugPrint('Arrêt du scanning manuel...');
    setState(() {
      _isScanning = false;
      _isCapturing = false;
    });
    _scanTimer?.cancel();
    if (!kIsWeb) {
      _controller?.stopImageStream();
    }
  }

  Uint8List? _convertCameraImageToBytes(CameraImage image) {
    try {
      if (image.format.group != ImageFormatGroup.yuv420) {
        debugPrint('Format d\'image non pris en charge : ${image.format.group}');
        return null;
      }
      debugPrint('Conversion de l\'image YUV420, taille : ${image.planes[0].bytes.length}');
      return image.planes[0].bytes;
    } catch (e) {
      debugPrint('Erreur lors de la conversion de l\'image : $e');
      return null;
    }
  }

  Future<void> _pickImageAndDecode() async {
    setState(() {
      _isScanning = true;
      _scanResult = null;
      _backendResult = null;
    });
    try {
      debugPrint('Ouverture du sélecteur d\'images...');
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        debugPrint('Aucune image sélectionnée.');
        setState(() {
          _isScanning = false;
          _scanResult = null;
        });
        return;
      }
      debugPrint('Image sélectionnée : ${picked.path}');
      _pickedImage = picked;
      final bytes = await picked.readAsBytes();
      debugPrint('Taille des bytes : ${bytes.length}');
      final result = await _decodeQr(bytes);
      debugPrint('Résultat du décodage : $result');
      setState(() => _scanResult = result ?? "Aucun QR code détecté");
      if (result != null) {
        debugPrint('Vérification avec le backend...');
        await _checkBackend(result);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'importation d\'image : $e');
      setState(() => _scanResult = 'Erreur : $e');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<String?> _decodeQr(Uint8List bytes) async {
    try {
      debugPrint('Début du décodage de l\'image... Taille des bytes : ${bytes.length}');
      if (bytes.isEmpty) {
        debugPrint('Erreur : Les bytes de l\'image sont vides.');
        return null;
      }
      if (kIsWeb) {
        final image = img.decodeImage(bytes);
        if (image == null) {
          debugPrint('Échec du décodage de l\'image : image null.');
          return null;
        }
        debugPrint('Image décodée : largeur=${image.width}, hauteur=${image.height}, format=${image.format}');
        if (image.width < 100 || image.height < 100) {
          debugPrint('Erreur : Image trop petite pour un décodage fiable (largeur=${image.width}, hauteur=${image.height}).');
          return null;
        }
        final rgbInts = Int32List(image.width * image.height);
        for (int y = 0; y < image.height; y++) {
          for (int x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            final r = pixel.r.toInt();
            final g = pixel.g.toInt();
            final b = pixel.b.toInt();
            rgbInts[y * image.width + x] = (r << 16) | (g << 8) | b;
          }
        }
        final luminance = zxing.RGBLuminanceSource(
          image.width,
          image.height,
          rgbInts,
        );
        debugPrint('Source de luminance créée.');
        final bitmap = zxing.BinaryBitmap(zxing.HybridBinarizer(luminance));
        debugPrint('Bitmap créé pour le décodage.');
        final result = zxing.QRCodeReader().decode(bitmap);
        debugPrint('QR code décodé : ${result.text}');
        return result.text;
      } else {
        // Mobile natif : qr_code_tools
        debugPrint('Utilisation de qr_code_tools pour le décodage...');
        final tempDir = await getTemporaryDirectory();
        final tempFile = io.File('${tempDir.path}/qr_temp_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(bytes);
        debugPrint('Image temporaire enregistrée : ${tempFile.path}');
        final result = await QrCodeToolsPlugin.decodeFrom(tempFile.path);
        await tempFile.delete();
        debugPrint('Résultat du décodage : $result');
        return result;
      }
    } catch (e) {
      debugPrint('Erreur lors du décodage du QR code : $e');
      return null;
    }
  }

  Future<void> _checkBackend(String code) async {
    debugPrint('Envoi de la requête au backend pour le code : $code');
    final token = await _getToken();
    final url = Uri.parse('http://localhost:8000/api_produits/unite_produit/scanner/?code=$code');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    debugPrint('Réponse du backend : status=${response.statusCode}, body=${response.body}');
    if (response.statusCode == 200) {
      dynamic backendData = response.body.isNotEmpty ? json.decode(response.body) : {};
     // Si c'est une liste, transforme-la en map
      if (backendData is List && backendData.isNotEmpty) {
        backendData = <String, dynamic>{"message": backendData.first.toString()};
      } else if (backendData is! Map) {
        backendData = <String, dynamic>{"message": backendData.toString()};
      }
      setState(() {
        _backendResult = backendData as Map<String, dynamic>;
      });
      final backendMsg = _backendResult?['message'] ?? _backendResult?['nom'] ?? "Produit reconnu";
      if (backendMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(backendMsg),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } else {
      setState(() {
        _backendResult = {"error": "Produit inconnu ou erreur backend"};
      });
      debugPrint('Erreur backend : ${_backendResult!['error']}');
    }
  }

  Future<void> _envoyerAlerte(String userMessage) async {
  debugPrint('Envoi d\'une alerte...');
  final token = await _getToken();

  String url;
  Map<String, dynamic> body;

  final uuid = _backendResult?['uuid'] ?? _backendResult?['uuid_produit'];
  if (uuid != null && uuid != "null") {
    url = 'http://localhost:8000/api_produits/unite_produit/alerte/?uuid=$uuid';
    body = {
      'message': userMessage,
    };
  } else {
    url = 'http://localhost:8000/api_produits/unite_produit/alerte/';
    body = {
      'code_scanned': _scanResult ?? '',
      'message': userMessage,
    };
  }

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
    body: json.encode(body),
  );
  debugPrint('Réponse de l\'alerte : status=${response.statusCode}, body=${response.body}');
  if (response.statusCode == 200 || response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Alerte envoyée au backend !"), backgroundColor: Colors.green),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur backend : ${response.body}"), backgroundColor: Colors.red),
    );
  }
}

  Future<void> captureAndDecode() async {
    if (_isScanning || _controller == null || !_controller!.value.isInitialized || _isCapturing) {
      debugPrint('Capture impossible : scanning=$_isScanning, controller=${_controller != null}, initialized=${_controller?.value.isInitialized}, capturing=$_isCapturing');
      return;
    }
    setState(() {
      _isScanning = true;
      _isCapturing = true;
      _scanResult = null;
      _backendResult = null;
    });
    try {
      debugPrint('Capture d\'image en cours...');
      final image = await _controller!.takePicture();
      debugPrint('Image capturée, lecture des bytes...');
      final bytes = await image.readAsBytes();
      debugPrint('Taille des bytes : ${bytes.length}');
      final result = await _decodeQr(bytes);
      debugPrint('Résultat du décodage : $result');
      setState(() => _scanResult = result ?? "Aucun QR code détecté");
      if (result != null) {
        debugPrint('Vérification avec le backend...');
        await _checkBackend(result);
      }
    } catch (e) {
      debugPrint('Erreur lors de la capture : $e');
      setState(() => _scanResult = 'Erreur : $e');
    } finally {
      setState(() {
        _isScanning = false;
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    debugPrint('Disposing CameraController...');
    _scanTimer?.cancel();
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner ou Importer un QR Code'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_controller != null && _controller!.value.isInitialized)
                      ? CameraPreview(_controller!)
                      : Center(
                          child: Text(
                            _error ?? "Impossible d'accéder à la caméra.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
            ),
            const SizedBox(height: 10),
            if (_isScanning)
              const Text(
                'Scanning en cours... Pointez la caméra vers un QR code.',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _pickImageAndDecode,
              icon: const Icon(Icons.image),
              label: const Text("Importer une image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading || _isScanning ? null : _startScanning,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scanner avec la caméra"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42A5F5),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _isScanning ? _stopScanning : null,
                    icon: const Icon(Icons.stop),
                    label: const Text("Arrêter le scan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_scanResult != null && _backendResult != null && _backendResult!['error'] == null) ...[
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      const Text(
                        "Résultat du scan :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _scanResult!,
                        style: const TextStyle(fontSize: 18, color: Colors.green),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // 3. DEMANDER UN MESSAGE AVANT ENVOI
                              final TextEditingController msgController = TextEditingController();
                              final result = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Message d'alerte"),
                                  content: TextField(
                                    controller: msgController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: "Saisissez le message à envoyer avec l'alerte",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Annuler"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, msgController.text.trim()),
                                      child: const Text("Envoyer"),
                                    ),
                                  ],
                                ),
                              );
                              if (result != null && result.isNotEmpty) {
                                await _envoyerAlerte(result);
                              }
                            },
                            icon: const Icon(Icons.warning),
                            label: const Text("Alerter"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 2. BOUTON POSITION SI PRODUIT RECONNU
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Récupère le nom de l'utilisateur connecté
                              final prefs = await SharedPreferences.getInstance();
                              final userName = prefs.getString('user_name');
                              if (userName == null || userName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Utilisateur non connecté"), backgroundColor: Colors.red),
                                );
                                return;
                              }

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Mettre à jour la position"),
                                  content: Text("Voulez-vous enregistrer votre nom ($userName) comme position de l'objet ?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text("Annuler"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text("Mettre à jour"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final token = await _getToken();
                                final uuid = _backendResult?['uuid'] ?? _backendResult?['uuid_produit'];
                                if (uuid != null) {
                                  final response = await http.patch(
                                    Uri.parse('http://localhost:8000/api_produits/unite_produit/position/?uuid=$uuid'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      if (token != null) 'Authorization': 'Bearer $token',
                                    },
                                    body: json.encode({'position': userName}),
                                  );
                                  if (response.statusCode == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Position mise à jour !"), backgroundColor: Colors.green),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Erreur : ${response.body}"), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.location_on),
                            label: const Text("Position"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}