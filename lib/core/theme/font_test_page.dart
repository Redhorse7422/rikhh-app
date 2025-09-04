import 'package:flutter/material.dart';
import 'sf_pro_fonts.dart';

/// Test page to verify SF Pro font implementation and fallbacks
/// This page can be used to test different text styles and font families
class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SF Pro Font Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme-based text styles
            _buildSection(
              'Theme Text Styles',
              [
                _buildTextSample('Display Large', Theme.of(context).textTheme.displayLarge!),
                _buildTextSample('Display Medium', Theme.of(context).textTheme.displayMedium!),
                _buildTextSample('Display Small', Theme.of(context).textTheme.displaySmall!),
                _buildTextSample('Headline Large', Theme.of(context).textTheme.headlineLarge!),
                _buildTextSample('Headline Medium', Theme.of(context).textTheme.headlineMedium!),
                _buildTextSample('Headline Small', Theme.of(context).textTheme.headlineSmall!),
                _buildTextSample('Title Large', Theme.of(context).textTheme.titleLarge!),
                _buildTextSample('Title Medium', Theme.of(context).textTheme.titleMedium!),
                _buildTextSample('Title Small', Theme.of(context).textTheme.titleSmall!),
                _buildTextSample('Body Large', Theme.of(context).textTheme.bodyLarge!),
                _buildTextSample('Body Medium', Theme.of(context).textTheme.bodyMedium!),
                _buildTextSample('Body Small', Theme.of(context).textTheme.bodySmall!),
                _buildTextSample('Label Large', Theme.of(context).textTheme.labelLarge!),
                _buildTextSample('Label Medium', Theme.of(context).textTheme.labelMedium!),
                _buildTextSample('Label Small', Theme.of(context).textTheme.labelSmall!),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // SF Pro helper class styles
            _buildSection(
              'SF Pro Helper Styles',
              [
                _buildTextSample('Display Large', SFProFonts.displayLarge()),
                _buildTextSample('Display Medium', SFProFonts.displayMedium()),
                _buildTextSample('Display Small', SFProFonts.displaySmall()),
                _buildTextSample('Headline Large', SFProFonts.headlineLarge()),
                _buildTextSample('Headline Medium', SFProFonts.headlineMedium()),
                _buildTextSample('Headline Small', SFProFonts.headlineSmall()),
                _buildTextSample('Title Large', SFProFonts.titleLarge()),
                _buildTextSample('Title Medium', SFProFonts.titleMedium()),
                _buildTextSample('Title Small', SFProFonts.titleSmall()),
                _buildTextSample('Body Large', SFProFonts.bodyLarge()),
                _buildTextSample('Body Medium', SFProFonts.bodyMedium()),
                _buildTextSample('Body Small', SFProFonts.bodySmall()),
                _buildTextSample('Button Style', SFProFonts.button()),
                _buildTextSample('Caption Style', SFProFonts.caption()),
                _buildTextSample('Overline Style', SFProFonts.overline()),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Custom styled examples
            _buildSection(
              'Custom Styled Examples',
              [
                _buildTextSample(
                  'Custom Blue Headline',
                  SFProFonts.headlineLarge(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                _buildTextSample(
                  'Custom Green Body',
                  SFProFonts.bodyMedium(color: Colors.green, fontSize: 18),
                ),
                _buildTextSample(
                  'Custom Red Button',
                  SFProFonts.button(color: Colors.red, fontSize: 20),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Font family information
            _buildSection(
              'Font Information',
              [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Font Status:',
                        style: SFProFonts.titleMedium(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• SF Pro Display: ${SFProFonts.display}',
                        style: SFProFonts.bodyMedium(),
                      ),
                      Text(
                        '• SF Pro Text: ${SFProFonts.text}',
                        style: SFProFonts.bodyMedium(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Note: If SF Pro fonts are not available, the system will automatically fallback to default system fonts (Roboto on Android, San Francisco on iOS).',
                        style: SFProFonts.bodySmall(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SFProFonts.headlineMedium(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextSample(String label, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: SFProFonts.bodySmall(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              'The quick brown fox jumps over the lazy dog',
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
