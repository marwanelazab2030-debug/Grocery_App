import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_details_screen.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';

const Color kOrdersBg = Color(0xFFF7F8FA);
const Color kBrandGreen = Color(0xFF3BB54A);

class MyOrdersScreen extends StatefulWidget {
  final bool showBack; // 👈 THIS controls the arrow

  const MyOrdersScreen({super.key, this.showBack = false});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  
  // 🔥 Elite Performance: Use ValueNotifier for tab switching
  final ValueNotifier<String> _selectedTabNotifier = ValueNotifier('current');
  
  // 🔥 Elite Performance: Memoize stream to prevent re-connections
  late final Stream<QuerySnapshot> _ordersStream;

  static final TextStyle _font = GoogleFonts.tajawal();

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      _ordersStream = FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _ordersStream = const Stream.empty();
    }
  }

  @override
  void dispose() {
    _selectedTabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final isArabic = languageController.isArabic;

    return Scaffold(
      backgroundColor: kOrdersBg,

      // 🔥 ONLY SHOW BACK BUTTON IF showBack = true
      appBar: widget.showBack
          ? AppBar(
              backgroundColor: kOrdersBg,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  isArabic ? Icons.arrow_back_ios_new : Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                strings.myOrdersLabel,
                style: _font.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
          : PreferredSize(
              // ← بديل AppBar في وضع التاب
              preferredSize: const Size.fromHeight(56),
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      strings.myOrdersLabel,
                      style: _font.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),

      body: _user == null
          ? Center(
              child: Text(
                strings.myOrdersLoginRequired,
                style: _font,
              ),
            )
          : Column(
              children: [
                // 🔹 segmented buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _selectedTabNotifier,
                      builder: (context, selectedTab, _) {
                        return Row(
                          children: [
                            _SegmentButton(
                              label: strings.ordersTabCurrent,
                              value: "current",
                              isSelected: selectedTab == "current",
                              onTap: () => _selectedTabNotifier.value = "current",
                            ),
                            _SegmentButton(
                              label: strings.ordersTabPast,
                              value: "past",
                              isSelected: selectedTab == "past",
                              onTap: () => _selectedTabNotifier.value = "past",
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // 🔹 orders list
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _ordersStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: kBrandGreen),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            strings.ordersLoadError,
                            style: _font.copyWith(color: Colors.red),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      
                      // 🔥 Elite Performance: Filter inside ValueListenableBuilder
                      return ValueListenableBuilder<String>(
                        valueListenable: _selectedTabNotifier,
                        builder: (context, selectedTab, _) {
                          if (docs.isEmpty) {
                            return _EmptyState(
                              strings: strings,
                              isCurrent: selectedTab == "current",
                            );
                          }

                          final visible = docs.where((doc) {
                            final status = (doc['status'] ?? '').toString().toLowerCase();
                            final isCurrentStatus = status == "pending" || status == "out_for_delivery";
                            
                            if (selectedTab == "current") {
                              return isCurrentStatus;
                            } else {
                              // Past orders
                              return !isCurrentStatus; // Simplification: if not current, it's past (delivered/cancelled)
                            }
                          }).toList();

                          if (visible.isEmpty) {
                            return _EmptyState(
                              strings: strings,
                              isCurrent: selectedTab == "current",
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: visible.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final data = visible[index].data() as Map<String, dynamic>;
                              final createdAt = data["createdAt"];
                              final date = createdAt is Timestamp
                                  ? createdAt.toDate()
                                  : DateTime.now();

                              return _OrderCard(
                                strings: strings,
                                orderId: data["orderId"] ?? visible[index].id,
                                status: data["status"] ?? "pending",
                                total: (data["total"] ?? 0).toDouble(),
                                date: date,
                                userId: _user!.uid,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ░░░ SEGMENT BUTTON ░░░
class _SegmentButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ░░░ ORDER CARD ░░░
class _OrderCard extends StatelessWidget {
  final AppLocalizations strings;
  final String orderId;
  final String status;
  final double total;
  final DateTime date;
  final String userId;

  const _OrderCard({
    required this.strings,
    required this.orderId,
    required this.status,
    required this.total,
    required this.date,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final s = _StatusHelper.getInfo(status, strings);
    final dateText =
        "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // 🟢 Fix: Keep Expanded for width constraint
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.orderNumberPrefix + orderId,
                      // 🟢 Fix: Removed maxLines/ellipsis to allow wrapping
                      style: GoogleFonts.tajawal(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                          fontSize: 12, color: Colors.grey.shade600),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8), // Spacing
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: s.bgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  s.label,
                  style: GoogleFonts.tajawal(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: s.textColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // 🟢 Fix: Wrap in Expanded
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.ordersTotalLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      strings.currencyValue(total.toStringAsFixed(2)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              
              const SizedBox(width: 8), // Spacing

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsScreen(
                        userId: userId,
                        orderId: orderId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == "delivered"
                      ? Colors.grey.shade100
                      : kBrandGreen,
                  foregroundColor:
                      status == "delivered" ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  minimumSize: const Size(90, 38),
                ),
                child: Text(
                  status == "delivered"
                      ? strings.ordersActionReorder
                      : strings.ordersActionDetails,
                  style: GoogleFonts.tajawal(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ░░░ EMPTY STATE ░░░
class _EmptyState extends StatelessWidget {
  final AppLocalizations strings;
  final bool isCurrent;

  const _EmptyState({required this.strings, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_basket_outlined,
                size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isCurrent
                  ? strings.ordersEmptyCurrent
                  : strings.ordersEmptyPast,
              style: GoogleFonts.tajawal(
                  fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              strings.ordersEmptyHint,
              style: GoogleFonts.tajawal(
                  fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

// ░░░ STATUS INFO HELPER ░░░
class _StatusInfo {
  final String label;
  final Color bgColor;
  final Color textColor;
  _StatusInfo(
      {required this.label, required this.bgColor, required this.textColor});
}

class _StatusHelper {
  static _StatusInfo getInfo(String status, AppLocalizations strings) {
    final s = status.toLowerCase();

    if (s == "pending") {
      return _StatusInfo(
        label: strings.orderStatusPreparing,
        bgColor: const Color(0xFFFEF3C7),
        textColor: const Color(0xFF92400E),
      );
    }

    if (s == "out_for_delivery") {
      return _StatusInfo(
        label: strings.orderStatusOutForDelivery,
        bgColor: const Color(0xFFE0ECFF),
        textColor: const Color(0xFF2563EB),
      );
    }

    if (s == "delivered") {
      return _StatusInfo(
        label: strings.orderStatusCompleted,
        bgColor: const Color(0xFFD1FAE5),
        textColor: const Color(0xFF059669),
      );
    }

    if (s == "cancelled" || s == "canceled") {
      return _StatusInfo(
        label: strings.orderStatusCancelled,
        bgColor: const Color(0xFFFEE2E2),
        textColor: const Color(0xFFDC2626),
      );
    }

    return _StatusInfo(
      label: status,
      bgColor: Colors.grey.shade200,
      textColor: Colors.grey.shade600,
    );
  }
}
