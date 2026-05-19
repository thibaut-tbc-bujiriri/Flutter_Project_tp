import 'package:flutter/material.dart';

void main() {
  runApp(const ExpensesApp());
}

enum ExpenseCategory {
  food,
  transport,
  home,
  health,
  leisure,
  shopping,
  bills,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Alimentation';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.home:
        return 'Maison';
      case ExpenseCategory.health:
        return 'Santé';
      case ExpenseCategory.leisure:
        return 'Loisirs';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Factures';
      case ExpenseCategory.other:
        return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_rounded;
      case ExpenseCategory.home:
        return Icons.home_rounded;
      case ExpenseCategory.health:
        return Icons.favorite_rounded;
      case ExpenseCategory.leisure:
        return Icons.sports_esports_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFF16A34A);
      case ExpenseCategory.transport:
        return const Color(0xFF2563EB);
      case ExpenseCategory.home:
        return const Color(0xFF8B5CF6);
      case ExpenseCategory.health:
        return const Color(0xFFEF4444);
      case ExpenseCategory.leisure:
        return const Color(0xFFF59E0B);
      case ExpenseCategory.shopping:
        return const Color(0xFFEC4899);
      case ExpenseCategory.bills:
        return const Color(0xFF14B8A6);
      case ExpenseCategory.other:
        return const Color(0xFF64748B);
    }
  }
}

class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String note;

  ExpenseEntry copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return ExpenseEntry(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

class ExpenseDraft {
  const ExpenseDraft({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String note;
}

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestionnaire de dépenses',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      home: const ExpensesHome(),
    );
  }
}

class ExpensesHome extends StatefulWidget {
  const ExpensesHome({super.key});

  @override
  State<ExpensesHome> createState() => _ExpensesHomeState();
}

class _ExpensesHomeState extends State<ExpensesHome> {
  final TextEditingController _searchController = TextEditingController();
  final List<ExpenseEntry> _items = [];

  String _query = '';
  ExpenseCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseEntry> get _filteredItems {
    final normalizedQuery = _query.trim().toLowerCase();
    return _items.where((item) {
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesQuery = normalizedQuery.isEmpty ||
          item.title.toLowerCase().contains(normalizedQuery) ||
          item.note.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  double get _total => _items.fold(0.0, (sum, item) => sum + item.amount);

  double get _filteredTotal =>
      _filteredItems.fold(0.0, (sum, item) => sum + item.amount);

  double get _monthTotal {
    final now = DateTime.now();
    return _items.where((item) {
      return item.date.year == now.year && item.date.month == now.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  Map<ExpenseCategory, double> get _categoryTotals {
    final totals = <ExpenseCategory, double>{};
    for (final category in ExpenseCategory.values) {
      totals[category] = 0;
    }
    for (final item in _items) {
      totals[item.category] = (totals[item.category] ?? 0) + item.amount;
    }
    return totals;
  }

  Future<void> _openExpenseSheet({ExpenseEntry? item}) async {
    final draft = await showModalBottomSheet<ExpenseDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseFormSheet(existing: item),
    );

    if (draft == null) {
      return;
    }

    setState(() {
      if (item == null) {
        _items.insert(
          0,
          ExpenseEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: draft.title,
            amount: draft.amount,
            category: draft.category,
            date: draft.date,
            note: draft.note,
          ),
        );
      } else {
        final index = _items.indexWhere((entry) => entry.id == item.id);
        if (index != -1) {
          _items[index] = item.copyWith(
            title: draft.title,
            amount: draft.amount,
            category: draft.category,
            date: draft.date,
            note: draft.note,
          );
        }
      }
    });
  }

  Future<void> _deleteExpense(ExpenseEntry item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la dépense ?'),
          content: Text('"${item.title}" sera supprimée définitivement.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _items.removeWhere((entry) => entry.id == item.id);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} supprimée'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            setState(() {
              _items.insert(0, item);
            });
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _currency(double amount) => '${amount.toStringAsFixed(2)} €';

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ExpenseCategory? category) {
    final selected = _selectedCategory == category;
    final label = category == null ? 'Toutes' : category.label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = category;
        });
      },
      side: BorderSide(color: selected ? Colors.transparent : const Color(0xFFE2E8F0)),
      selectedColor: const Color(0xFF0F766E).withValues(alpha: 0.14),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF0F766E) : const Color(0xFF334155),
        fontWeight: FontWeight.w600,
      ),
      avatar: category == null
          ? const Icon(Icons.tune_rounded, size: 18)
          : Icon(category.icon, size: 18, color: category.color),
    );
  }

  Widget _buildCategorySummary() {
    final totals = _categoryTotals.entries.where((entry) => entry.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (totals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition par catégorie',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          for (final entry in totals.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(entry.key.icon, size: 18, color: entry.key.color),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.key.label)),
                      Text(_currency(entry.value)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: _total == 0 ? 0 : entry.value / _total,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(entry.key.color),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 30,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF60A5FA)],
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucune dépense pour le moment',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoute une première dépense pour démarrer ton suivi budgétaire.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => _openExpenseSheet(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Ajouter une dépense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseEntry item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade700],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        confirmDismiss: (_) => _deleteExpense(item).then((value) => false),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: item.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(item.category.icon, color: item.category.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            _currency(item.amount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Tag(label: item.category.label, color: item.category.color),
                          _Tag(label: _formatDate(item.date), color: const Color(0xFF334155)),
                        ],
                      ),
                      if (item.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.note,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      tooltip: 'Modifier',
                      onPressed: () => _openExpenseSheet(item: item),
                      icon: const Icon(Icons.edit_rounded),
                    ),
                    IconButton(
                      tooltip: 'Supprimer',
                      onPressed: () => _deleteExpense(item),
                      icon: const Icon(Icons.delete_outline_rounded),
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

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openExpenseSheet(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FDFA), Color(0xFFF7F7FB), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 210,
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                title: const Text('Gestionnaire de dépenses'),
                actions: [
                  IconButton(
                    tooltip: 'Nouvelle dépense',
                    onPressed: () => _openExpenseSheet(),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Options',
                    onSelected: (value) {
                      if (value == 'reset') {
                        setState(() {
                          _items.clear();
                          _selectedCategory = null;
                          _query = '';
                          _searchController.clear();
                        });
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'reset',
                        child: Text('Tout effacer'),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F766E), Color(0xFF1D4ED8), Color(0xFF312E81)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -48,
                          top: 24,
                          child: _HeaderGlow(size: 120, color: Color(0x33FFFFFF)),
                        ),
                        Positioned(
                          left: -32,
                          bottom: -20,
                          child: _HeaderGlow(size: 90, color: Color(0x22FFFFFF)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          label: 'Total',
                          value: _currency(_total),
                          icon: Icons.account_balance_wallet_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          label: 'Ce mois',
                          value: _currency(_monthTotal),
                          icon: Icons.calendar_month_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          key: const Key('expense-search'),
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            hintText: 'Rechercher une dépense',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCategoryChip(null),
                              const SizedBox(width: 8),
                              for (final category in ExpenseCategory.values) ...[
                                _buildCategoryChip(category),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${filteredItems.length} dépense(s) affichée(s)',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              'Filtré: ${_currency(_filteredTotal)}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildCategorySummary()),
              if (filteredItems.isEmpty)
                _buildEmptyState()
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildExpenseItem(filteredItems[index]),
                      childCount: filteredItems.length,
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

class ExpenseFormSheet extends StatefulWidget {
  const ExpenseFormSheet({super.key, this.existing});

  final ExpenseEntry? existing;

  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late ExpenseCategory _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _amountController = TextEditingController(
      text: widget.existing == null ? '' : widget.existing!.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: widget.existing?.note ?? '');
    _selectedCategory = widget.existing?.category ?? ExpenseCategory.other;
    _selectedDate = widget.existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    Navigator.of(context).pop(
      ExpenseDraft(
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.existing == null ? 'Ajouter une dépense' : 'Modifier la dépense',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remplis les champs ci-dessous pour enregistrer la dépense.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('expense-form-title'),
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      prefixIcon: Icon(Icons.label_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le titre est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const Key('expense-form-amount'),
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Montant',
                      prefixIcon: Icon(Icons.euro_rounded),
                    ),
                    validator: (value) {
                      final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) {
                        return 'Entrez un montant valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<ExpenseCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: ExpenseCategory.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const Key('expense-form-note'),
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Note (optionnel)',
                      prefixIcon: Icon(Icons.notes_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range_rounded),
                    label: Text('Date: ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}'),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('expense-form-submit'),
                      onPressed: _submit,
                      icon: Icon(widget.existing == null ? Icons.add_rounded : Icons.save_rounded),
                      label: Text(widget.existing == null ? 'Ajouter' : 'Enregistrer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderGlow extends StatelessWidget {
  const _HeaderGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
