import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final void Function(DateTime? startDate, DateTime? endDate) onFilter;
  final VoidCallback? onReset;

  const DateRangeFilter({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onFilter,
    this.onReset,
  });

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  void didUpdateWidget(covariant DateRangeFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStartDate != widget.initialStartDate ||
        oldWidget.initialEndDate != widget.initialEndDate) {
      _startDate = widget.initialStartDate;
      _endDate = widget.initialEndDate;
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? _endDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1598A3),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _clearDate({required bool isStart}) {
    setState(() {
      if (isStart) {
        _startDate = null;
      } else {
        _endDate = null;
      }
    });
  }

  void _handleFilter() {
    widget.onFilter(_startDate, _endDate);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isFiltered = _startDate != null || _endDate != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Date Inputs Row ───────────────────────────────────────────────
          Row(
            children: [
              // "DARI" column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DARI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDateField(
                      dateText: _startDate != null
                          ? dateFormat.format(_startDate!)
                          : 'dd/MM/yyyy',
                      isSelected: _startDate != null,
                      onTap: () => _pickDate(isStart: true),
                      onClear: _startDate != null
                          ? () => _clearDate(isStart: true)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // "SAMPAI" column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SAMPAI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDateField(
                      dateText: _endDate != null
                          ? dateFormat.format(_endDate!)
                          : 'dd/MM/yyyy',
                      isSelected: _endDate != null,
                      onTap: () => _pickDate(isStart: false),
                      onClear: _endDate != null
                          ? () => _clearDate(isStart: false)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Filter Button ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 44,
            child: Material(
              color: const Color(0xFF141517),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: _handleFilter,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isFiltered) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1598A3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String dateText,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return Material(
      color: const Color(0xFF141517),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  dateText,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white70,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
