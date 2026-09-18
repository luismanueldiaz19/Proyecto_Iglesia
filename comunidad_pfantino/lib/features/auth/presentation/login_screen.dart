import 'package:flutter/material.dart';
import '../../../../core/theme/church_colors.dart';
import 'widgets/login_form_panel.dart';
import 'widgets/login_image_panel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 25, 
                vertical: isMobile ? 16 : 25,
              ),
              constraints: BoxConstraints(
                maxWidth: isMobile ? 380 : 800,
              ),
              height: isMobile ? null : 450,
              decoration: BoxDecoration(
                color: ChurchColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: isMobile
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: LoginImagePanel(),
                        ),
                        LoginFormPanel(),
                      ],
                    )
                  : const Flex(
                      direction: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: LoginImagePanel()),
                        Expanded(child: LoginFormPanel()),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
