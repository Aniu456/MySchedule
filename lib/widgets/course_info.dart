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

void getCourseInfo(BuildContext context, Map<String, dynamic> course) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: SizedBox(
                height:
                    MediaQuery.of(context).size.height * 0.3, // 设置高度为屏幕高度的30%
                child: AlertDialog(
                    insetPadding: EdgeInsets.zero,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    content: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(children: [
                            const Icon(Icons.book, color: Colors.teal),
                            const SizedBox(width: 10),
                            Text("课程名称：${course['courseName']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))
                          ]),
                          Row(children: [
                            const Icon(Icons.person, color: Colors.lightBlue),
                            const SizedBox(width: 10),
                            Text("教师：${course['teacherName']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))
                          ]),
                          Row(children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 10),
                            Text("上课周次：${getWeeks(course['weeks'])}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))
                          ]),
                          Row(children: [
                            const Icon(Icons.book, color: Colors.amber),
                            const SizedBox(width: 10),
                            Text("课程备注：${course['remarks']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))
                          ])
                        ]))));
      });
}
