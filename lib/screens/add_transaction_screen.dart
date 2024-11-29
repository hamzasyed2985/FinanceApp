import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String _type = 'Income';
  String _category = 'Salary'; // Default value for income category
  String? _transactionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      _transactionId = arguments['transactionId'];
      _amount = arguments['amount'];
      _type = arguments['type'];
      _category = arguments['category'] ??
          (_type == 'Income' ? 'Salary' : 'Food'); // Handle null category
      print("Loaded transaction: "
          "ID=$_transactionId, Amount=$_amount, Type=$_type, Category=$_category");
    }
  }

  // Save the transaction (either create or update)
  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print("Saving transaction: Amount=$_amount, Type=$_type, Category=$_category");

      Map<String, dynamic> transactionData = {
        'amount': _amount,
        'type': _type,
        'category': _category,
        'date': Timestamp.now(),
      };

      if (_transactionId == null) {
        print("Adding new transaction to Firestore.");
        await FirebaseFirestore.instance
            .collection('transactions')
            .add(transactionData);
      } else {
        print("Updating transaction with ID=$_transactionId in Firestore.");
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(_transactionId)
            .update(transactionData);
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      print("Transaction saved successfully and screen popped.");
    } else {
      print("Form validation failed. Please check the inputs.");
    }
  }

  // Get category options based on transaction type
  List<DropdownMenuItem<String>> _getCategoryOptions() {
    print("Getting category options for Type=$_type");
    if (_type == 'Income') {
      return [
        DropdownMenuItem<String>(
          value: 'Salary',
          child: Row(
            children: [
              Icon(Icons.money, color: Colors.green),
              SizedBox(width: 8),
              Text('Salary'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Business',
          child: Row(
            children: [
              Icon(Icons.business_center, color: Colors.blue),
              SizedBox(width: 8),
              Text('Business'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Investment',
          child: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.purple),
              SizedBox(width: 8),
              Text('Investment'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Other Income',
          child: Row(
            children: [
              Icon(Icons.miscellaneous_services, color: Colors.grey),
              SizedBox(width: 8),
              Text('Other Income'),
            ],
          ),
        ),
      ];
    } else {
      return [
        DropdownMenuItem<String>(
          value: 'Food',
          child: Row(
            children: [
              Icon(Icons.fastfood, color: Colors.orange),
              SizedBox(width: 8),
              Text('Food'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Transport',
          child: Row(
            children: [
              Icon(Icons.directions_car, color: Colors.blue),
              SizedBox(width: 8),
              Text('Transport'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Shopping',
          child: Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.green),
              SizedBox(width: 8),
              Text('Shopping'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Entertainment',
          child: Row(
            children: [
              Icon(Icons.movie, color: Colors.purple),
              SizedBox(width: 8),
              Text('Entertainment'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Others',
          child: Row(
            children: [
              Icon(Icons.miscellaneous_services, color: Colors.grey),
              SizedBox(width: 8),
              Text('Others'),
            ],
          ),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _transactionId == null ? 'Add Transaction' : 'Edit Transaction',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _amount != null ? _amount.toString() : '',
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter an amount' : null,
                onSaved: (value) {
                  _amount = double.tryParse(value!);
                  print("Amount entered: $_amount");
                },
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _type = 'Income';
                        _category = 'Salary'; // Reset category for income
                        print("Type set to: $_type, Category reset to: $_category");
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _type == 'Income' ? Colors.green : Colors.grey,
                    ),
                    child: Text('Income'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _type = 'Expense';
                        _category = 'Food'; // Reset category for expense
                        print("Type set to: $_type, Category reset to: $_category");
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _type == 'Expense' ? Colors.red : Colors.grey,
                    ),
                    child: Text('Expense'),
                  ),
                ],
              ),

              // Dropdown with icons for categories
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                value: _category,
                items: _getCategoryOptions(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                    print("Category changed to: $_category");
                  });
                },
                onSaved: (value) {
                  _category = value!;
                  print("Category saved as: $_category");
                },
                validator: (value) {
                  return value == null || value.isEmpty
                      ? 'Select a category'
                      : null;
                },
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text(_transactionId == null ? 'Save' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
