@override
void initState() {
  super.initState();
  _initializeWeeks();
  _loadCourses();
  _loadSemester();
  _initializeAnimation();
  _initializePageController();
}

/// 初始化周次
void _initializeWeeks() {
  _curWeek = WeekManager.calculateCurrentWeek(_currentSemester);
  _week = _curWeek;
}
