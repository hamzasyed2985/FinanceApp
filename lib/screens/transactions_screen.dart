import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  // Function to delete a transaction
  Future<void> _deleteTransaction(String transactionId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  // Function to modify a transaction (this will be a placeholder for now)
  void _modifyTransaction(BuildContext context, String transactionId,
      Map<String, dynamic> transactionData) {
    // Passing the transaction data to AddTransactionScreen for editing
    Navigator.pushNamed(context, '/addTransaction', arguments: {
      'transactionId': transactionId, // Ensure the transactionId is passed
      'amount': transactionData['amount'],
      'type': transactionData['type'],
      'category': transactionData['category'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transactions')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('transactions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!.docs;

          if (transactions.isEmpty) {
            return Center(child: Text('No transactions added.'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final data = transaction.data() as Map<String, dynamic>;
              final amount = data['amount'] ?? 0.0;
              final type = data['type'] ?? '';
              final category = data['category'] ?? '';
              final color = type == 'Income' ? Colors.green : Colors.red;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Icon(
                    type == 'Income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: Colors.white,
                  ),
                ),
                title: Text(category,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(type),
                trailing: Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                onTap: null, // No action for tap
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Modify or Delete'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              _modifyTransaction(
                                  context, transaction.id, data); // Modify
                            },
                            child: Text('Edit'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              _deleteTransaction(transaction.id); // Delete
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
