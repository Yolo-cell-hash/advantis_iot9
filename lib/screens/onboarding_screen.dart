import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advantis_iot/screens/home_screen.dart';
import 'package:advantis_iot/widgets/ble_prompt_stack.dart';
import 'package:advantis_iot/widgets/brand_logo_name.dart';
import 'package:advantis_iot/widgets/privacy_conditions_hyper.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const BrandLogoName(),
                const PrivacyConditionsHyper(),
              ],
            ),
            Visibility(
              visible: true,
              child: Positioned(
                top: MediaQuery.of(context).size.height * 0.2,
                left: 0,
                right: 0,
                child: BlePromptStack(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
