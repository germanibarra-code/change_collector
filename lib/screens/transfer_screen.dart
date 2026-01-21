import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/wallet_provider.dart';
import '../models/bank_account.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();

  BankType? _selectedBank;
  BankAccount? _selectedAccount;
  bool _isNewAccount = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _rfcController.dispose();
    _curpController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _amountController.text.isEmpty) {
      _showError('Por favor, ingresa un monto');
      return;
    }
    if (_currentPage == 1 && _selectedAccount == null && !_isNewAccount) {
      _showError('Por favor, selecciona una cuenta o crea una nueva');
      return;
    }
    if (_currentPage == 2 && _isNewAccount && _selectedBank == null) {
      _showError('Por favor, selecciona un banco');
      return;
    }
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submitTransfer() async {
    final walletProvider = context.read<WalletProvider>();

    // Validate that we have a valid account
    if (_selectedAccount == null && !_isNewAccount) {
      _showError('Por favor, selecciona una cuenta');
      return;
    }

    try {
      BankAccount accountToUse;

      if (_isNewAccount) {
        if (_rfcController.text.isEmpty ||
            _curpController.text.isEmpty ||
            _accountNumberController.text.isEmpty ||
            _accountHolderController.text.isEmpty ||
            _selectedBank == null) {
          _showError('Por favor, completa todos los datos requeridos');
          return;
        }

        accountToUse = BankAccount(
          id: const Uuid().v4(),
          accountHolder: _accountHolderController.text,
          accountNumber: _accountNumberController.text,
          rfc: _rfcController.text,
          curp: _curpController.text,
          bankType: _selectedBank!,
          bankName: _getBankName(_selectedBank!),
          isDefault: false,
        );

        await walletProvider.addBankAccount(accountToUse);
      } else {
        accountToUse = _selectedAccount!;
      }

      // Process transfer
      await walletProvider.transferToBank(
        double.parse(_amountController.text),
        accountToUse,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transferencia realizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  String _getBankName(BankType type) {
    switch (type) {
      case BankType.banorte:
        return 'Banorte';
      case BankType.banamex:
        return 'Banamex';
      case BankType.bbva:
        return 'BBVA México';
      case BankType.santander:
        return 'Santander';
      case BankType.inbursa:
        return 'Inbursa';
      case BankType.scotiabank:
        return 'Scotiabank';
      case BankType.hsbc:
        return 'HSBC';
      case BankType.otro:
        return 'Otro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferencia Bancaria'),
        elevation: 0,
        backgroundColor: const Color(0xFF10B981),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          _buildAmountPage(),
          _buildAccountSelectionPage(),
          _buildBankSelectionPage(),
          _buildConfirmationPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _currentPage > 0 ? _previousPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text('Anterior'),
            ),
            Text(
              'Paso ${_currentPage + 1} de 4',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _currentPage < 3 ? _nextPage : _submitTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: Text(_currentPage < 3 ? 'Siguiente' : 'Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Monto a Transferir',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '\$0.00',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requisitos legales mexicanos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• RFC válido del titular de la cuenta\n'
                  '• CURP válido del titular\n'
                  '• Número de cuenta bancaria completo\n'
                  '• Comprobante de la transferencia por correo',
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSelectionPage() {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Selecciona una Cuenta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (walletProvider.bankAccounts.isNotEmpty)
                ...walletProvider.bankAccounts.map((account) {
                  return Card(
                    child: ListTile(
                      title: Text(account.accountHolder),
                      subtitle: Text(
                        '${account.bankName} • ****${account.accountNumber.substring(account.accountNumber.length - 4)}',
                      ),
                      trailing: Radio<BankAccount>(
                        value: account,
                        groupValue: _selectedAccount,
                        onChanged: (BankAccount? value) {
                          setState(() {
                            _selectedAccount = value;
                            _isNewAccount = false;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isNewAccount = true;
                    _selectedAccount = null;
                  });
                },
                child: Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.add, color: Colors.green),
                    title: const Text('Agregar Nueva Cuenta'),
                    trailing: Radio<bool>(
                      value: true,
                      groupValue: _isNewAccount ? true : false,
                      onChanged: (bool? value) {
                        setState(() {
                          _isNewAccount = value ?? false;
                          if (_isNewAccount) {
                            _selectedAccount = null;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBankSelectionPage() {
    if (!_isNewAccount) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  size: 80, color: Colors.green.shade400),
              const SizedBox(height: 24),
              const Text(
                'Cuenta Seleccionada',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(_selectedAccount?.bankName ?? 'N/A'),
              const SizedBox(height: 8),
              Text(_selectedAccount?.accountHolder ?? 'N/A'),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Datos de la Cuenta Bancaria',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Selecciona tu Banco',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BankType>(
            value: _selectedBank,
            items: BankType.values.map((bank) {
              return DropdownMenuItem(
                value: bank,
                child: Text(_getBankName(bank)),
              );
            }).toList(),
            onChanged: (BankType? value) {
              setState(() {
                _selectedBank = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'RFC (Registro Federal de Contribuyentes)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rfcController,
            decoration: InputDecoration(
              hintText: 'Ej: ABC123456XYZ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'CURP (Clave Única de Registro de Población)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _curpController,
            decoration: InputDecoration(
              hintText: 'Ej: ABC123456HDFRML00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Número de Cuenta Bancaria',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _accountNumberController,
            decoration: InputDecoration(
              hintText: '0123456789012345678',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Titular de la Cuenta',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _accountHolderController,
            decoration: InputDecoration(
              hintText: 'Nombre completo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationPage() {
    final isValidForConfirmation =
        (_selectedAccount != null) ||
        (_isNewAccount &&
            _rfcController.text.isNotEmpty &&
            _curpController.text.isNotEmpty &&
            _accountNumberController.text.isNotEmpty &&
            _accountHolderController.text.isNotEmpty &&
            _selectedBank != null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Confirmar Transferencia',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          if (!isValidForConfirmation)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: Completa todos los datos requeridos',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monto:'),
                        Text(
                          '\$${_amountController.text}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Banco:'),
                        Flexible(
                          child: Text(
                            _selectedAccount?.bankName ??
                                _getBankName(_selectedBank ?? BankType.otro),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Titular:'),
                        Flexible(
                          child: Text(
                            _selectedAccount?.accountHolder ??
                                _accountHolderController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('RFC:'),
                        Flexible(
                          child: Text(
                            _selectedAccount?.rfc ?? _rfcController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CURP:'),
                        Flexible(
                          child: Text(
                            _selectedAccount?.curp ?? _curpController.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aviso Importante:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Por regulación de la Ley de Protección de Datos Personales en Posesión de Sujetos Obligados, '
                  'recibirás un comprobante de la transferencia en tu correo registrado. '
                  'Conserva este comprobante como respaldo legal.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
