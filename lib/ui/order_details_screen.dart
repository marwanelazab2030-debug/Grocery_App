import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';
import 'package:khodarkom_app/utils/product_localization.dart';
import 'package:flutter/services.dart';

const Color kOrdersBg = Color(0xFFF7F8FA);
const Color kBrandGreen = Color(0xFF3BB54A);

class OrderDetailsScreen extends StatefulWidget {
  final String userId;
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.userId,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // 🔥 Elite Performance: Memoize future to prevent re-fetching on rebuilds
  late final Future<DocumentSnapshot> _orderFuture;
  
  static final TextStyle _font = GoogleFonts.tajawal();

  @override
  void initState() {
    super.initState();
    _orderFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('orders')
        .doc(widget.orderId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final isArabic = languageController.isArabic;

    return Scaffold(
      backgroundColor: kOrdersBg,
      appBar: AppBar(
        backgroundColor: kOrdersBg,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        // ✅ في العربي السهم يكون فوق يمين ويشير لليمين
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_back_ios_new : Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings.orderDetailsTitle,
          style: _font.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kBrandGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                strings.orderLoadError,
                style: _font.copyWith(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                strings.orderNotFound,
                style: _font,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final createdAt = data['createdAt'];
          final DateTime date = createdAt is Timestamp
              ? createdAt.toDate()
              : DateTime.now();

          final String status = (data['status'] ?? 'pending').toString();

          final List<dynamic> items = (data['items'] as List<dynamic>? ?? []);

          // 🔢 نحسب المجموع الفرعي من المنتجات
          double subtotal = 0;
          for (final item in items) {
            final pRaw = item['price'] ?? 0;
            final qRaw = item['quantity'] ?? 1;

            double price;
            if (pRaw is int) {
              price = pRaw.toDouble();
            } else if (pRaw is double) {
              price = pRaw;
            } else {
              price = double.tryParse(pRaw.toString()) ?? 0;
            }

            int quantity;
            if (qRaw is int) {
              quantity = qRaw;
            } else {
              quantity = int.tryParse(qRaw.toString()) ?? 1;
            }

            subtotal += price * quantity;
          }

          // 💰 رسوم توصيل ثابتة الآن (تقدر تطلعها من الإعدادات لاحقًا)
          const double deliveryFee = 10.0;

          final double docTotal;
          final tRaw = data['total'] ?? 0;
          if (tRaw is int) {
            docTotal = tRaw.toDouble();
          } else if (tRaw is double) {
            docTotal = tRaw;
          } else {
            docTotal = double.tryParse(tRaw.toString()) ?? 0;
          }

          final double calcTotal = subtotal + deliveryFee;
          final double total = docTotal == 0 ? calcTotal : docTotal;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrderHeaderCard(
                  font: _font,
                  strings: strings,
                  orderId: widget.orderId,
                  date: date,
                  total: total,
                  status: status,
                ),
                const SizedBox(height: 18),
                Text(
                  strings.orderProductsSection,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: _font.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                ...items.map((item) {
                  final itemData = (item as Map).cast<String, dynamic>();
                  final localizedName =
                      localizedProductName(itemData, isArabic: isArabic);
                  final displayName = localizedName.isNotEmpty
                      ? localizedName
                      : (itemData['name']?.toString() ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OrderItemTile(
                      font: _font,
                      strings: strings,
                      name: displayName,
                      unit: itemData['unit']?.toString() ?? '',
                      quantity: itemData['quantity']?.toString() ?? '1',
                      price: (itemData['price'] is num)
                          ? (itemData['price'] as num).toDouble()
                          : double.tryParse(
                                  itemData['price']?.toString() ?? '0') ??
                              0,
                      imageUrl: itemData['imageUrl']?.toString() ?? '',
                    ),
                  );
                }).toList(),
                const SizedBox(height: 18),
                _OrderSummaryCard(
                  font: _font,
                  strings: strings,
                  subtotal: subtotal,
                  deliveryFee: deliveryFee,
                  total: total,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ░░░ HEADER CARD + STATUS TIMELINE ░░░

class _OrderHeaderCard extends StatelessWidget {
  final TextStyle font;
  final AppLocalizations strings;
  final String orderId;
  final DateTime date;
  final double total;
  final String status;

  const _OrderHeaderCard({
    required this.font,
    required this.strings,
    required this.orderId,
    required this.date,
    required this.total,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded( // 🟢 Fix: Keep Expanded
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 Elite Feature: Tap to Copy Order ID
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: orderId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(strings.orderIdCopied ?? "Order ID Copied"), // Fallback if string missing
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.black87,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        strings.orderNumberLabel(orderId),
                        style: font.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: font.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8), // Spacing
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    strings.currencyValue(total.toStringAsFixed(2)),
                    style: font.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.orderSummaryLabel,
                    style: font.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatusTimeline(
            font: font,
            strings: strings,
            status: status,
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final TextStyle font;
  final AppLocalizations strings;
  final String status;

  const _StatusTimeline({
    required this.font,
    required this.strings,
    required this.status,
  });

  int _currentStep() {
    final s = status.toLowerCase();

    if (s == 'cancelled' || s == 'canceled') return 0;
    if (s == 'pending') return 1;
    if (s == 'out_for_delivery') return 2;
    if (s == 'delivered') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final languageController = LanguageScope.of(context);
    final isRTL = languageController.isArabic;
    final s = status.toLowerCase();
    final bool isCancelled = (s == 'cancelled' || s == 'canceled');
    final int step = _currentStep();

    // progress: 0 → 1 but reversed if RTL
    double progress;
    if (isCancelled || step == 0) {
      progress = 0.0;
    } else if (step == 1) {
      progress = 1 / 3;
    } else if (step == 2) {
      progress = 2 / 3;
    } else {
      progress = 1.0;
    }

    return SizedBox(
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // gray background line
          Positioned.fill(
            top: 32,
            bottom: 32,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),

          // green progress line (RTL FIX)
          if (!isCancelled && progress > 0)
            Positioned.fill(
              top: 32,
              bottom: 32,
              child: Align(
                alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: kBrandGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),

          // steps — RTL = reversed order
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: isRTL
                ? [
                    _StatusStep(
                      font: font,
                      label: strings.orderStatusReceived,
                      icon: Icons.receipt_long,
                      isActive: step >= 1,
                      isCurrent: step == 1,
                    ),
                    _StatusStep(
                      font: font,
                      label: strings.orderStatusOnTheWay,
                      icon: Icons.local_shipping,
                      isActive: step >= 2,
                      isCurrent: step == 2,
                    ),
                    _StatusStep(
                      font: font,
                      label: strings.orderStatusDelivered,
                      icon: Icons.task_alt,
                      isActive: step >= 3,
                      isCurrent: step == 3,
                    ),
                  ]
                : [
                    _StatusStep(
                      font: font,
                      label: strings.orderStatusReceived,
                      icon: Icons.receipt_long,
                      isActive: step >= 1,
                      isCurrent: step == 1,
                    ),
                    _StatusStep(
                      font: font,
                      label: strings.orderStatusOnTheWay,
                      icon: Icons.local_shipping,
                      isActive: step >= 2,
                      isCurrent: step == 2,
                    ),
                    _StatusStep(
                      font: font,
                      label: strings.orderStatusDelivered,
                      icon: Icons.task_alt,
                      isActive: step >= 3,
                      isCurrent: step == 3,
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}


class _StatusStep extends StatelessWidget {
  final TextStyle font;
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isCurrent;

  const _StatusStep({
    required this.font,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = kBrandGreen;
    final Color inactiveColor = Colors.grey.shade400;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : inactiveColor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: font.copyWith(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

/// ░░░ PRODUCT TILE ░░░

class _OrderItemTile extends StatelessWidget {
  final TextStyle font;
  final AppLocalizations strings;
  final String name;
  final String unit;
  final String quantity;
  final double price;
  final String imageUrl;

  const _OrderItemTile({
    required this.font,
    required this.strings,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isEmpty
                ? const Icon(Icons.image_outlined, size: 26, color: Colors.grey)
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    // 🔥 Elite Performance: Cache small thumbnail size
                    memCacheWidth: 200,
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2, // 🟢 Fix: Limit lines
                  overflow: TextOverflow.ellipsis, // 🟢 Fix: Ellipsis
                  style: font.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.quantityWithUnit(quantity, strings.translateUnit(unit)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: font.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            strings.currencyValue(price.toStringAsFixed(2)),
            style: font.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ░░░ SUMMARY CARD ░░░

class _OrderSummaryCard extends StatelessWidget {
  final TextStyle font;
  final AppLocalizations strings;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const _OrderSummaryCard({
    required this.font,
    required this.strings,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.subtotalLabel,
                style: font.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                strings.currencyValue(subtotal.toStringAsFixed(2)),
                style: font.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.deliveryFeeLabel,
                style: font.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                strings.currencyValue(deliveryFee.toStringAsFixed(2)),
                style: font.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.totalLabel,
                style: font.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                strings.currencyValue(total.toStringAsFixed(2)),
                style: font.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
