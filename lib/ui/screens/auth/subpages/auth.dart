import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serv_expert_webclient/core/validators.dart';
import 'package:serv_expert_webclient/ui/screens/auth/auth_screen.dart';

class AuthSubpage extends ConsumerStatefulWidget {
  const AuthSubpage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<AuthSubpage> createState() => _AuthSubpageState();
}

class _AuthSubpageState extends ConsumerState<AuthSubpage> {
  final formKey = GlobalKey<FormState>();
  String phone = '';

  onContinue() {
    bool? valid = formKey.currentState?.validate();
    if (valid == true) {
      ref.read(authScreenControllerProvider.notifier).signInWithPhone(phone: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'LOG IN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          SizedBox(
            width: 600,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                keyboardType: TextInputType.phone,
                maxLength: 20,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone';
                  }

                  if (!AppValidators.isValidPhone(value)) {
                    return 'Please enter correct phone';
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  onContinue();
                },
                onChanged: (value) {
                  phone = value;
                },
                decoration: InputDecoration(
                    counter: const SizedBox(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey[800]),
                    labelText: "Phone number",
                    fillColor: Colors.white70),
              ),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          SizedBox(
            width: 600,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  onContinue();
                },
                child: Ink(
                  // width: 600,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}