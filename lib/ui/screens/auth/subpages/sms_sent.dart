import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:serv_expert_webclient/ui/screens/auth/auth_screen.dart';

class SmsSentSubpage extends ConsumerStatefulWidget {
  const SmsSentSubpage({
    Key? key,
    required this.phone,
  }) : super(key: key);

  final String phone;

  @override
  ConsumerState<SmsSentSubpage> createState() => _SmsSentSubpageState();
}

class _SmsSentSubpageState extends ConsumerState<SmsSentSubpage> {
  final formKey = GlobalKey<FormState>();
  String smsCode = '';

  onContinue() {
    bool? valid = formKey.currentState?.validate();
    if (valid == true) {
      ref.read(authScreenControllerProvider.notifier).confirmSmsCode(smsCode: smsCode);
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
            'SMS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          SizedBox(
            child: Pinput(
              length: 6,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some numbers';
                }
                return null;
              },
              onChanged: (value) {
                smsCode = value;
              },
              onSubmitted: (value) {
                onContinue();
              },
              onCompleted: (value) {
                onContinue();
              },
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