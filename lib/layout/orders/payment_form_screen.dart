import 'package:flutter/material.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../shared/shared/app_localization.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  _PaymentFormScreenState createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  bool saveCard = false;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const MovableFloatingButton(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('CheckOut')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StepIndicator(
                      isActive: true,
                      label:
                          AppLocalizations.of(context).translate('Delivery')),
                  StepIndicator(
                      isActive: true,
                      label: AppLocalizations.of(context).translate('address')),
                  StepIndicator(
                      isActive: false,
                      label: AppLocalizations.of(context).translate('payment')),
                ],
              ),
              const SizedBox(height: 52),
              buildPaymentOptions(),
              const SizedBox(height: 20),
              buildCreditCard(),
              const SizedBox(height: 20),
              buildTextField("Card Holder Name", "Louis Anderson",
                  readOnly: true),
              const SizedBox(height: 10),
              buildTextField("Card Number", "6775 2235 5567 1234",
                  readOnly: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: buildTextField("Month/Year", "Enter here")),
                  const SizedBox(width: 10),
                  Expanded(child: buildTextField("CVV", "Enter here")),
                ],
              ),
              const SizedBox(height: 10),
              buildDropdownField("Country", "Choose your country"),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: saveCard,
                onChanged: (value) {
                  setState(() {
                    saveCard = value!;
                  });
                },
                title: const Text("Save this card"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              defaultButton(
                  function: () {
                    // navigateAndFinish(context, const CartScreen());
                    //navigateAndFinish(context, const RootView());
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  text: 'Save Card')
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentOptions() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PaymentOption(icon: Icons.credit_card, label: "Credit Card"),
        PaymentOption(icon: Icons.paypal, label: "Paypal Method"),
      ],
    );
  }

  Widget buildCreditCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff2372A9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "A Bank",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            "**** **** **** 1234",
            style:
                TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 2),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CARD HOLDER", style: TextStyle(color: Colors.white70)),
              Text("VALID THRU", style: TextStyle(color: Colors.white70)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Louis Anderson", style: TextStyle(color: Colors.white)),
              Text("08/21", style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, String hint, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        defaultFormField(
            controller: controller,
            type: TextInputType.text,
            fillColor: const Color(0xffE3EBF0),
            // validate: () {},
            label: label)
      ],
    );
  }

  Widget buildDropdownField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          items: const [
            DropdownMenuItem(value: "Egypt", child: Text("Egypt")),
          ],
          onChanged: (value) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
          ),
        ),
      ],
    );
  }
}

class StepIndicator extends StatelessWidget {
  final bool isActive;
  final String label;

  const StepIndicator({super.key, required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? const Color(0xff106E29) : Colors.grey,
          child: isActive
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: isActive ? const Color(0xff106E29) : Colors.grey)),
      ],
    );
  }
}

class PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const PaymentOption({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Icon(icon, size: 36, color: const Color(0xff106E29)),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
