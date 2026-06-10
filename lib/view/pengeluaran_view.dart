import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../model/pengeluaran_model.dart';
import '../viewmodel/pengeluaran_viewmodel.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../core/widgets/admin_only_widget.dart';

class PengeluaranView extends StatelessWidget {
  const PengeluaranView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PengeluaranViewModel>();
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1598A3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: const Text(
          'Pengeluaran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white, size: 28),
            onPressed: () => context.read<PengeluaranViewModel>().loadAll(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'pengeluaran_fab',
        backgroundColor: const Color(0xFFB32626),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () => _showFormDialog(context),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB32626),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.trending_down, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TOTAL PENGELUARAN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmt.format(vm.totalPengeluaran),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildList(context, vm, fmt)),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    PengeluaranViewModel vm,
    NumberFormat fmt,
  ) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF4444)),
      );
    }
    if (vm.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(
              vm.errorMessage ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<PengeluaranViewModel>().loadAll(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (vm.list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.white30),
            SizedBox(height: 12),
            Text(
              'Belum ada data pengeluaran',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88, left: 16, right: 16),
      itemCount: vm.list.length,
      itemBuilder: (_, i) {
        final item = vm.list[i];
        return _PengeluaranCard(
          item: item,
          fmt: fmt,
          onEdit: () => _showFormDialog(context, item: item),
          onDelete: () => _confirmDelete(context, item.id!),
          onViewBukti: (url) => _viewBukti(context, url),
        );
      },
    );
  }

  Future<void> _showFormDialog(
    BuildContext context, {
    PengeluaranModel? item,
  }) async {
    final namaBarangCtrl = TextEditingController(text: item?.namaBarang);
    final nominalCtrl = TextEditingController(
      text: item != null ? _formatRibuan(item.nominal.toStringAsFixed(0)) : '',
    );
    final keteranganCtrl = TextEditingController(text: item?.keterangan);
    final tanggalCtrl = TextEditingController(
      text: item?.tanggal ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final formKey = GlobalKey<FormState>();

    Uint8List? selectedFileBytes;
    String? selectedFileName;
    bool deleteExistingBukti = false;
    final String? existingBuktiUrl = item?.buktiUrl;

    Future<void> pickFile(BuildContext pickerCtx, StateSetter setModalState) async {
      final source = await showModalBottomSheet<String>(
        context: pickerCtx,
        backgroundColor: const Color(0xFF1C1C1C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Bukti Transaksi',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1598A3)),
                title: const Text('Kamera (Ambil Foto)', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1598A3)),
                title: const Text('Galeri (Pilih Foto)', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF1598A3)),
                title: const Text('Dokumen (Pilih PDF)', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      try {
        if (source == 'camera' || source == 'gallery') {
          final picker = ImagePicker();
          final image = await picker.pickImage(
            source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
            imageQuality: 70,
          );
          if (image != null) {
            final bytes = await image.readAsBytes();
            setModalState(() {
              selectedFileBytes = bytes;
              selectedFileName = image.name;
              deleteExistingBukti = true;
            });
          }
        } else if (source == 'pdf') {
          final result = await FilePicker.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            withData: true,
          );
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.first;
            if (file.bytes != null) {
              setModalState(() {
                selectedFileBytes = file.bytes;
                selectedFileName = file.name;
                deleteExistingBukti = true;
              });
            }
          }
        }
      } catch (e) {
        if (pickerCtx.mounted) {
          ScaffoldMessenger.of(pickerCtx).showSnackBar(
            SnackBar(
              content: Text('Gagal memilih file: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }

    final categories = [
      'Operasional',
      'Gaji Karyawan',
      'Inventaris / Alat',
      'Sewa Tempat',
      'Utilitas (Listrik/Air/Internet)',
      'Bahan Baku / Stok',
      'Lainnya',
    ];

    String selectedKategori = item?.kategori ?? 'Operasional';
    if (!categories.contains(selectedKategori)) {
      selectedKategori = 'Operasional';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setModalState) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(sheetCtx),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    _formField(
                      namaBarangCtrl,
                      'Nama Barang',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nama barang wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    // ── Kategori Dropdown ──────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Kategori',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedKategori,
                          dropdownColor: const Color(0xFF1C1C1C),
                          style: const TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          iconEnabledColor: const Color(0xFF1E1E1E),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1598A3),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
                          ),
                          selectedItemBuilder: (BuildContext context) {
                            return categories.map((cat) {
                              return Text(
                                cat,
                                style: const TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedKategori = val);
                            }
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Kategori wajib dipilih' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    _formField(
                      nominalCtrl,
                      'Nominal',
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Nominal wajib diisi';
                        final raw = v.replaceAll('.', '');
                        if (double.tryParse(raw) == null) return 'Angka tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Tanggal Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tanggal (YYYY-MM-DD)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: tanggalCtrl,
                          style: const TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1598A3),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: sheetCtx,
                              initialDate: DateTime.tryParse(tanggalCtrl.text) ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              tanggalCtrl.text = DateFormat('yyyy-MM-dd').format(date);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _formField(keteranganCtrl, 'Keterangan (opsional)'),
                    const SizedBox(height: 12),

                    // ── Bukti Transaksi File Picker ────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Bukti Transaksi (Nota / PDF)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if ((selectedFileBytes != null || (existingBuktiUrl != null && !deleteExistingBukti)))
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: [
                                // Preview Thumbnail
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: selectedFileBytes != null
                                      ? (selectedFileName?.toLowerCase().endsWith('.pdf') == true
                                          ? const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36)
                                          : Image.memory(
                                              selectedFileBytes!,
                                              fit: BoxFit.cover,
                                            ))
                                      : (existingBuktiUrl!.toLowerCase().contains('.pdf') || existingBuktiUrl.contains('pdf')
                                          ? const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36)
                                          : Image.network(
                                              existingBuktiUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white30),
                                            )),
                                ),
                                const SizedBox(width: 12),
                                // File details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedFileName ?? (existingBuktiUrl != null && (existingBuktiUrl.toLowerCase().contains('.pdf') || existingBuktiUrl.contains('pdf')) ? 'Nota_Transaksi.pdf' : 'Nota_Transaksi.jpg'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedFileBytes != null
                                            ? '${(selectedFileBytes!.length / 1024).toStringAsFixed(1)} KB (Baru)'
                                            : 'Tersimpan di Cloud',
                                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                // Remove button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                                  onPressed: () {
                                    setModalState(() {
                                      selectedFileBytes = null;
                                      selectedFileName = null;
                                      deleteExistingBukti = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        else
                          InkWell(
                            onTap: () => pickFile(context, setModalState),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white24,
                                  style: BorderStyle.solid,
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined, color: Color(0xFF1598A3)),
                                  SizedBox(width: 10),
                                  Text(
                                    'Unggah Foto Nota atau File PDF',
                                    style: TextStyle(
                                      color: Color(0xFF1598A3),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<PengeluaranViewModel>(
                      builder: (ctx, vm, _) => ElevatedButton(
                        onPressed: vm.isMutating
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final pengeluaranVm = ctx.read<PengeluaranViewModel>();
                                final data = PengeluaranModel(
                                  id: item?.id,
                                  namaBarang: namaBarangCtrl.text.trim(),
                                  nominal: double.parse(nominalCtrl.text.replaceAll('.', '')),
                                  kategori: selectedKategori,
                                  keterangan: keteranganCtrl.text.trim().isEmpty
                                      ? null
                                      : keteranganCtrl.text.trim(),
                                  tanggal: tanggalCtrl.text,
                                );
                                final success = item == null
                                    ? await pengeluaranVm.create(
                                        data,
                                        fileBytes: selectedFileBytes,
                                        fileName: selectedFileName,
                                      )
                                    : await pengeluaranVm.update(
                                        item.id!,
                                        data,
                                        fileBytes: selectedFileBytes,
                                        fileName: selectedFileName,
                                        deleteExistingBukti: deleteExistingBukti,
                                      );
                                if (sheetCtx.mounted) {
                                  Navigator.pop(sheetCtx);
                                  if (success) {
                                    sheetCtx.read<DashboardViewModel>().loadDashboard();
                                  } else {
                                    ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                      SnackBar(
                                        content: Text(vm.errorMessage ?? 'Gagal menyimpan'),
                                        backgroundColor: const Color(0xFFEF4444),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1598A3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: vm.isMutating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                item == null ? 'Simpan' : 'Perbarui',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Hapus Pengeluaran',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data ini?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final success = await context.read<PengeluaranViewModel>().delete(id);
      if (success && context.mounted) {
        context.read<DashboardViewModel>().loadDashboard();
      }
    }
  }

  void _viewBukti(BuildContext context, String url) {
    final isPdf = url.toLowerCase().contains('.pdf') || url.contains('pdf');
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bukti Transaksi',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                ],
              ),
            ),
            if (isPdf)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 72),
                    const SizedBox(height: 16),
                    const Text(
                      'Dokumen Bukti Transaksi (PDF)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Salin tautan di bawah ini untuk melihat dokumen PDF nota:',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      url,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF1598A3), fontSize: 12, decoration: TextDecoration.underline),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Salin Tautan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1598A3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tautan berhasil disalin!'), backgroundColor: Colors.green),
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF1598A3)),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text('Gagal memuat gambar', style: TextStyle(color: Colors.white54)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _formField(
  TextEditingController ctrl,
  String label, {
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        cursorColor: const Color(0xFF1E1E1E),
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF1598A3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
      ),
    ],
  );
}

class _PengeluaranCard extends StatelessWidget {
  final PengeluaranModel item;
  final NumberFormat fmt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String) onViewBukti;

  const _PengeluaranCard({
    required this.item,
    required this.fmt,
    required this.onEdit,
    required this.onDelete,
    required this.onViewBukti,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2D1F21),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: Color(0xFFEF4444),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaBarang,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.kategori != null && item.kategori!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1598A3).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF1598A3).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          item.kategori!,
                          style: const TextStyle(
                            color: Color(0xFF1598A3),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (item.buktiUrl != null && item.buktiUrl!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => onViewBukti(item.buktiUrl!),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (item.buktiUrl!.toLowerCase().contains('.pdf') || item.buktiUrl!.contains('pdf'))
                                    ? Icons.picture_as_pdf
                                    : Icons.receipt_long,
                                color: const Color(0xFF22C55E),
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (item.buktiUrl!.toLowerCase().contains('.pdf') || item.buktiUrl!.contains('pdf')) ? 'PDF Nota' : 'Nota',
                                style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'TGL: ${item.tanggal} • OLEH: ${item.createdBy ?? '1'}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.keterangan!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- ${fmt.format(item.nominal)}',
                style: const TextStyle(
                  color: Color(0xFFEF5350),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Tombol EDIT - Admin & Operator bisa
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.white54,
                    ),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  const SizedBox(width: 4),
                  // Tombol DELETE - Hanya Admin
                  DeleteOnlyWidget(
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final double? parsed = double.tryParse(cleanText);
    if (parsed == null) {
      return oldValue;
    }

    final String reversed = cleanText.split('').reversed.join('');
    final List<String> chunks = [];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.substring(i, i + 3 < reversed.length ? i + 3 : reversed.length));
    }
    final String formatted = chunks.join('.').split('').reversed.join('');

    int selectionIndex = newValue.selection.end;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < selectionIndex && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    int newSelectionIndex = 0;
    int digitCount = 0;
    while (digitCount < digitsBeforeCursor && newSelectionIndex < formatted.length) {
      if (RegExp(r'[0-9]').hasMatch(formatted[newSelectionIndex])) {
        digitCount++;
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}

String _formatRibuan(String s) {
  final clean = s.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.isEmpty) return '';
  final reversed = clean.split('').reversed.join('');
  final List<String> chunks = [];
  for (int i = 0; i < reversed.length; i += 3) {
    chunks.add(reversed.substring(i, i + 3 < reversed.length ? i + 3 : reversed.length));
  }
  return chunks.join('.').split('').reversed.join('');
}
