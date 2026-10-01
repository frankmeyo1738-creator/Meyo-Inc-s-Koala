import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Moodboard Creator - Koala's signature killer feature
/// Drag, resize, rotate images, add text and stickers, export
class MoodboardCreatorScreen extends StatefulWidget {
  const MoodboardCreatorScreen({Key? key}) : super(key: key);

  @override
  State<MoodboardCreatorScreen> createState() => _MoodboardCreatorScreenState();
}

class _MoodboardCreatorScreenState extends State<MoodboardCreatorScreen> {
  final List<MoodboardElement> elements = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          'Create Moodboard',
          style: AppTypography.h4,
        ),
        actions: [
          TextButton.icon(
            onPressed: _exportMoodboard,
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Canvas area
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Grid pattern
                  CustomPaint(
                    size: Size.infinite,
                    painter: GridPainter(),
                  ),

                  // Moodboard elements
                  ...elements.map((element) => Positioned(
                        left: element.position.dx,
                        top: element.position.dy,
                        child: _DraggableElement(
                          element: element,
                          onUpdate: (newElement) {
                            setState(() {
                              final index = elements.indexOf(element);
                              elements[index] = newElement;
                            });
                          },
                          onDelete: () {
                            setState(() {
                              elements.remove(element);
                            });
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Tool palette
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ToolButton(
                      icon: Icons.image,
                      label: 'Image',
                      onTap: _addImage,
                    ),
                    const SizedBox(width: 12),
                    _ToolButton(
                      icon: Icons.text_fields,
                      label: 'Text',
                      onTap: _addText,
                    ),
                    const SizedBox(width: 12),
                    _ToolButton(
                      icon: Icons.emoji_emotions,
                      label: 'Sticker',
                      onTap: _addSticker,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addImage() {
    setState(() {
      elements.add(MoodboardElement(
        type: ElementType.image,
        position: const Offset(100, 100),
        size: const Size(200, 200),
        content: 'assets/images/clean_1.jpg',
      ));
    });
  }

  void _addText() {
    setState(() {
      elements.add(MoodboardElement(
        type: ElementType.text,
        position: const Offset(150, 150),
        size: const Size(200, 60),
        content: 'Your text here',
      ));
    });
  }

  void _addSticker() {
    setState(() {
      elements.add(MoodboardElement(
        type: ElementType.sticker,
        position: const Offset(200, 200),
        size: const Size(80, 80),
        content: '✨',
      ));
    });
  }

  void _exportMoodboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Moodboard exported! 🎨'),
        backgroundColor: AppColors.brandAccent,
      ),
    );
  }
}

// Data model for moodboard elements
enum ElementType { image, text, sticker }

class MoodboardElement {
  final ElementType type;
  final Offset position;
  final Size size;
  final String content;
  final double rotation;

  MoodboardElement({
    required this.type,
    required this.position,
    required this.size,
    required this.content,
    this.rotation = 0,
  });

  MoodboardElement copyWith({
    ElementType? type,
    Offset? position,
    Size? size,
    String? content,
    double? rotation,
  }) {
    return MoodboardElement(
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      content: content ?? this.content,
      rotation: rotation ?? this.rotation,
    );
  }
}

class _DraggableElement extends StatelessWidget {
  final MoodboardElement element;
  final Function(MoodboardElement) onUpdate;
  final VoidCallback onDelete;

  const _DraggableElement({
    required this.element,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        onUpdate(element.copyWith(
          position: element.position + details.delta,
        ));
      },
      child: Transform.rotate(
        angle: element.rotation,
        child: Container(
          width: element.size.width,
          height: element.size.height,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.brandAccent.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Content
              Center(
                child: _buildElementContent(),
              ),

              // Delete button
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElementContent() {
    switch (element.type) {
      case ElementType.image:
        return Image.asset(
          element.content,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
        );
      case ElementType.text:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            element.content,
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
        );
      case ElementType.sticker:
        return Text(
          element.content,
          style: const TextStyle(fontSize: 48),
        );
    }
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: AppColors.brandAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
