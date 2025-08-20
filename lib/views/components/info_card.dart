import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final Widget title;
  final List<Widget>? children;
  final String date;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoCard({
    super.key,
    required this.title,
    this.date = '',
    this.children,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListTile(
        title: title,
        onTap: onTap,
        trailing: trailing,
        subtitle: date.isNotEmpty || (children?.isNotEmpty ?? false)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...?children,
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              )
            : null,
      ),
    );
  }
}
