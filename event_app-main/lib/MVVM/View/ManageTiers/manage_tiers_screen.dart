import 'dart:ui';
import 'package:event_app/MVVM/body_model/ticket_tier_model.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

// ─── Quick-pick presets ───────────────────────────────────────────────────────
const _kPresets = [
  {'label': 'Adult', 'emoji': '🎫', 'desc': ''},
  {'label': 'Child', 'emoji': '👶', 'desc': 'Ages 12 and under'},
  {'label': 'VIP', 'emoji': '⭐', 'desc': 'Premium experience'},
  {'label': 'Senior 55+', 'emoji': '🏅', 'desc': 'Ages 55 and above'},
  {'label': 'Student', 'emoji': '🎓', 'desc': 'Valid student ID required'},
  {'label': 'Early Bird', 'emoji': '🐦', 'desc': 'Limited availability'},
  {'label': 'General', 'emoji': '🎟️', 'desc': ''},
];

class ManageTiersScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const ManageTiersScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<ManageTiersScreen> createState() => _ManageTiersScreenState();
}

class _ManageTiersScreenState extends State<ManageTiersScreen>
    with SingleTickerProviderStateMixin {
  final EventController _ctrl = Get.find<EventController>();
  bool _busy = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    await _ctrl.fetchEventTiers(widget.eventId);
    if (mounted) setState(() => _busy = false);
  }

  // ── Sheet helpers ────────────────────────────────────────────────────────────
  void _openAddSheet() {
    HapticUtils.buttonPress();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TierFormSheet(
        eventId: widget.eventId,
        onSave: (name, price, cap, desc) async {
          Navigator.pop(context);
          setState(() => _busy = true);
          final ok = await _ctrl.createTier(
            eventId: widget.eventId,
            tierName: name,
            price: price,
            quantityCap: cap,
            description: desc,
          );
          if (ok && mounted) {
            HapticUtils.success();
            Get.snackbar(
              'Tier Added',
              '"$name" tier created successfully.',
              backgroundColor: AppColors.blueColor,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          if (mounted) setState(() => _busy = false);
        },
      ),
    );
  }

  void _openEditSheet(TicketTier tier) {
    HapticUtils.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TierFormSheet(
        eventId: widget.eventId,
        existingTier: tier,
        onSave: (name, price, cap, desc) async {
          Navigator.pop(context);
          setState(() => _busy = true);
          final ok = await _ctrl.editTier(
            eventId: widget.eventId,
            tierId: tier.tierId,
            tierName: name,
            price: price,
            quantityCap: cap,
            description: desc,
          );
          if (ok && mounted) {
            HapticUtils.success();
            Get.snackbar(
              'Tier Updated',
              '"$name" tier updated.',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          if (mounted) setState(() => _busy = false);
        },
      ),
    );
  }



  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Ambient glows
          Positioned(
            top: -10.h,
            right: -15.w,
            child: _Glow(color: AppColors.blueColor.withValues(alpha: 0.07), size: 55.w),
          ),
          Positioned(
            bottom: -5.h,
            left: -10.w,
            child: _Glow(color: Colors.purpleAccent.withValues(alpha: 0.05), size: 40.w),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.blueColor,
        elevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Tier',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.07), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticUtils.navigation();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(1.2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 15.sp),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Ticket Tiers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      widget.eventTitle,
                      style: TextStyle(
                          color: Colors.white38, fontSize: 9.5.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (_busy)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.blueColor,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      final tiers = _ctrl.tiers;

      if (_ctrl.tiersLoading.value && tiers.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                    color: AppColors.blueColor, strokeWidth: 2),
              ),
              SizedBox(height: 2.h),
              Text('Loading tiers…',
                  style:
                      TextStyle(color: Colors.white38, fontSize: 11.sp)),
            ],
          ),
        );
      }

      if (tiers.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        color: AppColors.blueColor,
        backgroundColor: AppColors.signinoptioncolor,
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
          children: [
            // Info banner
            _buildInfoBanner(tiers.length),
            SizedBox(height: 2.h),

            // Tier cards
            ...tiers.map((t) => _buildTierCard(t)),
          ],
        ),
      );
    });
  }

  Widget _buildInfoBanner(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: AppColors.blueColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(color: AppColors.blueColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.blueColor, size: 13.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              '$count active tier${count == 1 ? '' : 's'} · Tap a card to edit, swipe left to delete.',
              style: TextStyle(
                  color: Colors.white60, fontSize: 9.5.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppColors.blueColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.blueColor.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text('🎫', style: TextStyle(fontSize: 26.sp)),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'No ticket tiers yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Add tiers like Adult, Child, VIP,\nor Senior 55+ so attendees can pick\nwhat they need.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11.sp, height: 1.5),
            ),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: _openAddSheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.8.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.blueColor, AppColors.lightColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4.h),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueColor.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white),
                    SizedBox(width: 2.w),
                    Text(
                      'Add Your First Tier',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
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

  // ── Tier Card ───────────────────────────────────────────────────────────────
  Widget _buildTierCard(TicketTier tier) {
    final isFree = tier.price == 0;

    return Dismissible(
      key: ValueKey(tier.tierId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => _ConfirmDeleteDialog(tierName: tier.tierName),
        );
        return confirmed == true;
      },
      onDismissed: (_) async {
        setState(() => _busy = true);
        final ok = await _ctrl.removeTier(
            eventId: widget.eventId, tierId: tier.tierId);
        if (ok && mounted) {
          HapticUtils.success();
          Get.snackbar(
            'Removed',
            '"${tier.tierName}" tier removed.',
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        if (mounted) setState(() => _busy = false);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 1.8.h),
        padding: EdgeInsets.only(right: 5.w),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(2.2.h),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.red, size: 20.sp),
            SizedBox(height: 0.3.h),
            Text('Delete',
                style: TextStyle(color: Colors.red, fontSize: 8.5.sp)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => _openEditSheet(tier),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.only(bottom: 1.8.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(2.2.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.09),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.2.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    // Emoji icon
                    Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1.4.h),
                      ),
                      child: Center(
                        child: Text(tier.tierEmoji,
                            style: TextStyle(fontSize: 16.sp)),
                      ),
                    ),

                    SizedBox(width: 3.5.w),

                    // Name + description + capacity
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.tierName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (tier.description != null &&
                              tier.description!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 0.3.h),
                              child: Text(
                                tier.description!,
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9.sp),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(top: 0.5.h),
                            child: Row(
                              children: [
                                _pill(
                                  tier.quantityCap != null
                                      ? '${tier.available}/${tier.quantityCap} left'
                                      : 'Unlimited',
                                  Colors.white24,
                                ),
                                if (tier.quantitySold > 0) ...[
                                  SizedBox(width: 1.5.w),
                                  _pill(
                                    '${tier.quantitySold} sold',
                                    Colors.green.withValues(alpha: 0.6),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price + edit hint
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isFree
                              ? 'FREE'
                              : '\$${tier.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isFree
                                ? Colors.greenAccent
                                : Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.4.h),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(0.8.h),
                            border: Border.all(
                                color: AppColors.blueColor
                                    .withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded,
                                  color: AppColors.blueColor,
                                  size: 9.sp),
                              SizedBox(width: 1.w),
                              Text('Edit',
                                  style: TextStyle(
                                      color: AppColors.blueColor,
                                      fontSize: 8.5.sp,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
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

  Widget _pill(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.8.w, vertical: 0.25.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(1.h),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 8.sp)),
    );
  }
}

// ─── Glow helper ─────────────────────────────────────────────────────────────
class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

// ─── Add / Edit Tier Bottom Sheet ─────────────────────────────────────────────
class _TierFormSheet extends StatefulWidget {
  final int eventId;
  final TicketTier? existingTier;
  final void Function(String name, double price, int? cap, String? desc) onSave;

  const _TierFormSheet({
    required this.eventId,
    this.existingTier,
    required this.onSave,
  });

  @override
  State<_TierFormSheet> createState() => _TierFormSheetState();
}

class _TierFormSheetState extends State<_TierFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _capCtrl;
  late TextEditingController _descCtrl;
  bool _isSaving = false;
  bool _hasCapLimit = false;

  bool get _isEditing => widget.existingTier != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTier;
    _nameCtrl = TextEditingController(text: t?.tierName ?? '');
    _priceCtrl = TextEditingController(
        text: t != null ? t.price.toStringAsFixed(2) : '');
    _capCtrl = TextEditingController(
        text: t?.quantityCap != null ? '${t!.quantityCap}' : '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _hasCapLimit = t?.quantityCap != null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _capCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _nameCtrl.text = preset['label'] as String;
      if ((preset['desc'] as String).isNotEmpty) {
        _descCtrl.text = preset['desc'] as String;
      }
    });
    HapticUtils.light();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final cap =
        _hasCapLimit ? (int.tryParse(_capCtrl.text.trim())) : null;
    final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    setState(() => _isSaving = true);
    widget.onSave(name, price, cap, desc);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.h)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor.withValues(alpha: 0.96),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(4.h)),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 10.w,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Title
                    Text(
                      _isEditing ? 'Edit Tier' : 'Add Ticket Tier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _isEditing
                          ? 'Update the details for this tier.'
                          : 'Define who can buy this tier and at what price.',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 10.sp),
                    ),

                    // Preset chips (only on add)
                    if (!_isEditing) ...[
                      SizedBox(height: 2.h),
                      Text('QUICK PICK',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: _kPresets
                            .map((p) => _PresetChip(
                                  label: '${p['emoji']} ${p['label']}',
                                  onTap: () => _applyPreset(p),
                                ))
                            .toList(),
                      ),
                    ],

                    SizedBox(height: 2.5.h),

                    // Tier name
                    _label('TIER NAME'),
                    SizedBox(height: 0.8.h),
                    _field(
                      controller: _nameCtrl,
                      hint: 'e.g. Adult, VIP, Child, Senior 55+',
                      icon: Icons.label_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Tier name is required'
                              : null,
                    ),

                    SizedBox(height: 2.h),

                    // Price
                    _label('PRICE (USD)'),
                    SizedBox(height: 0.8.h),
                    _field(
                      controller: _priceCtrl,
                      hint: '0.00  (set 0 for free)',
                      icon: Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final n = double.tryParse(v.trim());
                        if (n == null || n < 0) return 'Enter a valid price';
                        return null;
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Quantity cap toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('LIMIT QUANTITY'),
                            Text('Set max tickets for this tier',
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 8.5.sp)),
                          ],
                        ),
                        Switch(
                          value: _hasCapLimit,
                          activeThumbColor: AppColors.blueColor,
                          onChanged: (v) =>
                              setState(() => _hasCapLimit = v),
                        ),
                      ],
                    ),

                    if (_hasCapLimit) ...[
                      SizedBox(height: 1.h),
                      _field(
                        controller: _capCtrl,
                        hint: 'e.g. 100',
                        icon: Icons.people_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (!_hasCapLimit) return null;
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter a quantity';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 1) {
                            return 'Must be at least 1';
                          }
                          return null;
                        },
                      ),
                    ],

                    SizedBox(height: 2.h),

                    // Description (optional)
                    _label('DESCRIPTION  (optional)'),
                    SizedBox(height: 0.8.h),
                    _field(
                      controller: _descCtrl,
                      hint: 'e.g. Ages 12 and under, Valid ID required…',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),

                    SizedBox(height: 3.h),

                    // Save button
                    GestureDetector(
                      onTap: _isSaving ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          gradient: _isSaving
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    AppColors.blueColor,
                                    AppColors.lightColor
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: _isSaving
                              ? Colors.white.withValues(alpha: 0.06)
                              : null,
                          borderRadius: BorderRadius.circular(4.h),
                          boxShadow: _isSaving
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.blueColor
                                        .withValues(alpha: 0.4),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _isSaving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isEditing
                                      ? 'Save Changes'
                                      : 'Add Tier',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    letterSpacing: 0.3,
                                  ),
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

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white, fontSize: 12.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white24, fontSize: 11.sp),
        prefixIcon:
            Icon(icon, color: AppColors.blueColor, size: 14.sp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide:
              const BorderSide(color: AppColors.blueColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide: BorderSide(
              color: Colors.red.withValues(alpha: 0.6), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide:
              const BorderSide(color: Colors.red, width: 1.5),
        ),
        errorStyle: TextStyle(color: Colors.red, fontSize: 9.sp),
      ),
    );
  }
}

// ─── Preset chip ─────────────────────────────────────────────────────────────
class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
        decoration: BoxDecoration(
          color: AppColors.blueColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3.h),
          border: Border.all(
              color: AppColors.blueColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Confirm delete dialog ────────────────────────────────────────────────────
class _ConfirmDeleteDialog extends StatelessWidget {
  final String tierName;
  const _ConfirmDeleteDialog({required this.tierName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.h),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(3.h),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_rounded,
                      color: Colors.red, size: 20.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Remove Tier?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '"$tierName" will be deactivated.\nExisting bookings are not affected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white54, fontSize: 10.sp, height: 1.5),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(3.h),
                            border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Center(
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3.h),
                            border: Border.all(
                                color:
                                    Colors.red.withValues(alpha: 0.4)),
                          ),
                          child: Center(
                            child: Text('Remove',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
