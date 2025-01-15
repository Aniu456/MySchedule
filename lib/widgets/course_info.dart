import 'package:flutter/material.dart'; // 引入Flutter的Material包

String getWeeks(List<int> weeks) {
  if (weeks.isEmpty) return '';

  weeks.sort();
  List<String> weekRanges = [];
  int start = weeks.first;
  int end = weeks.first;

  for (int i = 1; i < weeks.length; i++) {
    if (weeks[i] == end + 1) {
      end = weeks[i];
    } else {
      if (start == end) {
        weekRanges.add('$start');
      } else {
        weekRanges.add('$start-$end周');
      }
      start = weeks[i];
      end = weeks[i];
    }
  }
  if (start == end) {
    weekRanges.add('$start');
  } else {
    weekRanges.add('$start-$end周');
  }

  return weekRanges.join(', ');
}

// ... 保持 getWeeks() 函数不变 ...

void getCourseInfo(BuildContext context, Map<String, dynamic> course) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "课程详情",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              _buildInfoRow(Icons.book, "课程名称", course['courseName']),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person, "教师", course['teacherName']),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.calendar_today, "上课周次", getWeeks(course['weeks'])),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.note, "课程备注", course['remarks']),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.teal, size: 24),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    ],
  );
}
