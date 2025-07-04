import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img; // Pour le traitement d'image
import 'package:zxing2/qrcode.dart' as zxing; // Pour le décodage QR
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _cameraController;
  bool _isLoading = true;
  bool _isTorchOn = false;
  String? _errorMessage;
  bool _isWebScanning = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          setState(() {
            _errorMessage = 'Camera permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras found');
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (kIsWeb) {
        // Démarrer la capture périodique pour le web
        _startWebQRScan();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _startWebQRScan() async {
    setState(() => _isWebScanning = true);
    
    while (_isWebScanning && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        final image = await _cameraController!.takePicture();
        final bytes = await image.readAsBytes();
        final result = await _decodeQRFromImage(bytes);
        
        if (result != null && mounted) {
          Navigator.pop(context, result);
          break;
        }
      } catch (e) {
        debugPrint('QR scan error: $e');
      }
    }
  }

  Future<String?> _decodeQRFromImage(List<int> bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      
      final luminanceSource = zxing.RGBLuminanceSource(
        image.width,
        image.height,
        image.getBytes(format: img.Format.abgr).buffer.asInt32List(),
      );
      
      final reader = zxing.QRCodeReader();
      final result = reader.decode(zxing.BinaryBitmap(zxing.HybridBinarizer(luminanceSource)));
      
      return result.text;
    } catch (e) {
      debugPrint('QR decode error: $e');
      return null;
    }
  }

  Future<void> _toggleTorch() async {
    try {
      if (_cameraController?.value.isInitialized ?? false) {
        await _cameraController!.setFlashMode(
          _isTorchOn ? FlashMode.off : FlashMode.torch,
        );
        setState(() => _isTorchOn = !_isTorchOn);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Torch error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _isWebScanning = false;
    _cameraController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('QR Scanner', style: TextStyle(color: Color(0xFF16213E))),
        iconTheme: const IconThemeData(color: Color(0xFF16213E)),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off, color: const Color(0xFF16213E)),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: _buildScannerContent(),
    );
  }

  Widget _buildScannerContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (kIsWeb) {
      return _buildWebScanner();
    } else {
      return _buildMobileScanner();
    }
  }

  Widget _buildWebScanner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF4E4FEB),
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _cameraController != null && _cameraController!.value.isInitialized
                      ? CameraPreview(_cameraController!)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
              _buildScannerOverlay(300),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            "Alignez le QR code dans le cadre",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileScanner() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.green,
              borderRadius: 12,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(qrResult ?? "Scannez un code QR"),
          ),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrResult = scanData.code;
      });
      // Tu peux faire Navigator.pop(context, scanData.code); pour retourner le résultat
    });
  }

  // Modifie l'overlay pour prendre la même taille que la caméra
  Widget _buildScannerOverlay(double size) {
    return Center(
      child: Container(
        width: size * 0.83,
        height: size * 0.83,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}