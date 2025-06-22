// ignore_for_file: deprecated_member_use, unused_local_variable, library_private_types_in_public_api

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart' as zxing;

// Sidebar harmonisée avec "Transaction"
class ResponsiveSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  const ResponsiveSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<ResponsiveSidebar> createState() => _ResponsiveSidebarState();
}

class _ResponsiveSidebarState extends State<ResponsiveSidebar> {
  bool _isHovered = false;

  final List<_NavItem> navItems = const [
    _NavItem(Icons.space_dashboard_outlined, "Dashboard", '/dashboard'),
    _NavItem(Icons.qr_code_2_rounded, "Scan", '/scan'),
    _NavItem(Icons.account_circle_outlined, "Utilisateur", '/user'),
    _NavItem(Icons.inventory_2_outlined, "Produits", '/product'),
    _NavItem(Icons.swap_horiz, "Transaction", '/transaction'),
    _NavItem(Icons.notifications_active_outlined, "Alertes", '/alerts'),
    _NavItem(Icons.settings, "Paramètres", '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final sidebarWidth = _isHovered || isMobile ? 220.0 : 80.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: sidebarWidth,
        constraints: BoxConstraints(maxWidth: sidebarWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.10),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 28),
            // Logo centré
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6FC9).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.security, color: Color(0xFF1A6FC9), size: 28),
              ),
            ),
            if (_isHovered || isMobile)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text(
                  "SecureScan",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: const Color(0xFF1A6FC9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            // Menu vertical, icônes centrés
            ...List.generate(navItems.length, (i) {
              final item = navItems[i];
              final isActive = widget.selectedIndex == i;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => widget.onItemSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: _isHovered || isMobile ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1A6FC9).withOpacity(0.13)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône parfaitement centrée dans un carré
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1A6FC9).withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: isActive
                              ? const Color(0xFF1A6FC9)
                              : const Color(0xFFB3B8C8),
                          size: 26,
                        ),
                      ),
                      if (_isHovered || isMobile)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            item.label,
                            style: GoogleFonts.montserrat(
                              color: isActive
                                  ? const Color(0xFF1A6FC9)
                                  : const Color(0xFFB3B8C8),
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            // Profil utilisateur centré
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A6FC9).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF1A6FC9), size: 26),
                    ),
                    if (_isHovered || isMobile)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin",
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF1A6FC9),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "Administrateur",
                              style: GoogleFonts.montserrat(
                                color: Colors.blueGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.label, this.route);
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  int selectedIndex = 1;

  String? _scanResult;

  void _onSidebarItemSelected(int i) {
    setState(() => selectedIndex = i);
    switch (i) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/dashboard');
        break;
      case 1:
        // Déjà sur scan
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/user');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/product');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/transaction');
        break;
      case 5:
        Navigator.of(context).pushReplacementNamed('/alerts');
        break;
      case 6:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }

  void _startScan() async {
    // Simule un scan (remplace par ta logique réelle)
    setState(() => _scanResult = null);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _scanResult =
        "Produit : Paracétamol 500mg\nLot : 2024A\nStatut : Authentique");
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      drawer: isMobile
          ? ResponsiveSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) {
                Navigator.of(context).pop();
                _onSidebarItemSelected(i);
              },
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            ResponsiveSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: _onSidebarItemSelected,
            ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF5F5F7), Color(0xFFEAEAEC)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12.0 : 32.0),
                child: Column(
                  children: [
                    // Bannière style dashboard
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A6FC9), Color(0xFF16213E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        "Scan de Produit",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Zone centrale de scan
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_scanner,
                                size: 90, color: Color(0xFF4E4FEB)),
                            const SizedBox(height: 24),
                            Text(
                              "Scanner un produit",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Appuyez sur le bouton ci-dessous pour démarrer le scan.",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: const Color(0xFF6B6B6B),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4E4FEB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                              onPressed: _startScan,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Démarrer le scan"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Zone résultat du scan
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _scanResult == null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Résultat du scan",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Aucun scan effectué pour le moment.",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      color: const Color(0xFF6B6B6B),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Résultat du scan",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _scanResult!,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 17,
                                      color: const Color(0xFF4E4FEB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductScanPage extends StatefulWidget {
  const ProductScanPage({super.key});

  @override
  State<ProductScanPage> createState() => _ProductScanPageState();
}

class _ProductScanPageState extends State<ProductScanPage> {
  CameraController? _cameraController;
  bool _isLoading = true;
  bool _isTorchOn = false;
  String? _errorMessage;
  bool _isWebScanning = false;

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
        final bytes = await image.readAsBytes(); // Ceci est déjà un Uint8List
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

  Future<String?> _decodeQRFromImage(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Obtenir les bytes RGBA (ou RGB selon la version)
      final pixels = image.getBytes(); // ou image.getBytes(order: img.ChannelOrder.rgba);

      final luminanceSource = zxing.RGBLuminanceSource(
        image.width,
        image.height,
        pixels.buffer.asInt32List(),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Scanner un produit', style: TextStyle(color: Color(0xFF16213E))),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cadre caméra stylé avec overlay
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
              _buildScannerOverlay(),
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

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ScanProduitPage extends StatefulWidget {
  const ScanProduitPage({super.key});

  @override
  State<ScanProduitPage> createState() => _ScanProduitPageState();
}

class _ScanProduitPageState extends State<ScanProduitPage> {
  CameraController? _cameraController;
  bool _isLoading = false;
  String? _scanResult;
  bool _isScanning = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _startCamera() async {
    setState(() {
      _isLoading = true;
      _scanResult = null;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _isLoading = false;
        _scanResult = "Permission caméra refusée";
      });
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _isLoading = false;
        _scanResult = "Aucune caméra trouvée";
      });
      return;
    }

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() {
      _isLoading = false;
      _isScanning = true;
    });
    _scanLoop();
  }

  Future<void> _scanLoop() async {
    while (_isScanning && mounted) {
      try {
        final image = await _cameraController!.takePicture();
        final bytes = await image.readAsBytes();
        final result = await _decodeQRFromImage(bytes);
        if (result != null && result.isNotEmpty) {
          setState(() {
            _scanResult = result;
            _isScanning = false;
          });
          break;
        }
      } catch (e) {
        // Ignore errors, continue scanning
      }
      await Future.delayed(const Duration(milliseconds: 700));
    }
  }

  Future<String?> _decodeQRFromImage(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final pixels = image.getBytes();
      final luminanceSource = zxing.RGBLuminanceSource(
        image.width,
        image.height,
        pixels.buffer.asInt32List(),
      );
      final reader = zxing.QRCodeReader();
      final result = reader.decode(zxing.BinaryBitmap(zxing.HybridBinarizer(luminanceSource)));
      return result.text;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanner un produit")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scanner un produit"),
              onPressed: _isLoading || _isScanning ? null : _startCamera,
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_cameraController != null && _cameraController!.value.isInitialized && _isScanning)
              AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            const SizedBox(height: 24),
            if (_scanResult != null)
              Column(
                children: [
                  const Text("Résultat du scan :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_scanResult!, style: const TextStyle(fontSize: 18, color: Colors.green)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
