/// Central location for all app constants and static data
/// This makes it easy to modify options and maintain consistency
class AppConstants {
  // User level options for Step 1
  static const List<String> userLevels = [
    'Năm 1-2',
    'Năm 3',
    'Năm cuối',
    'Fresher',
    'Junior',
    'Tự học',
  ];

  // Interest categories for Step 1
  static const List<String> interests = [
    'Game',
    'Thể thao',
    'Âm nhạc',
    'Du lịch',
    'Giáo dục',
    'Y tế',
    'Tài chính',
    'Nghệ thuật',
    'Nấu ăn',
    'Phim ảnh',
  ];

  // Main goal options for later steps
  static const List<String> mainGoals = [
    'Qua môn',
    'Điểm cao/Portfolio',
    'Học công nghệ mới',
    'Khởi nghiệp',
  ];

  // Technology categories for later steps
  static const List<String> technologies = [
    // Mobile Development
    'Flutter',
    'React Native',
    'SwiftUI',
    'Kotlin',
    'Java',

    // Web Frontend
    'ReactJS',
    'VueJS',
    'Angular',
    'Svelte',

    // Backend Development
    'NodeJS',
    'Python (Django/FastAPI)',
    'Golang',
    'Java Spring',
    'PHP',

    // Database Technologies
    'Firebase',
    'MongoDB',
    'PostgreSQL',
    'MySQL',

    // DevOps & Cloud
    'Docker',
    'Kubernetes',
    'AWS',
    'Google Cloud',
  ];

  // Product types for Step 2
  static const List<String> productTypes = [
    'Mobile App',
    'Web App',
    'API Backend',
    'OpenSource',
    '3rd Lib',
    'Demo',
  ];

  // Step titles for navigation
  static const List<String> stepTitles = [
    'Thông tin cơ bản',
    'Tinh chỉnh',
    'Đề xuất dự án',
    'Chi tiết dự án',
  ];

  // Validation messages
  static const String validationIncompleteData = 'Thông tin chưa đầy đủ';
  static const String validationSelectLevel = 'Vui lòng chọn trình độ hiện tại';
  static const String validationSelectInterests =
      'Vui lòng chọn ít nhất một lĩnh vực sở thích';
  static const String validationSelectGoal = 'Vui lòng chọn mục tiêu chính';
  static const String validationSelectTechnologies =
      'Vui lòng chọn ít nhất một công nghệ';
  static const String validationSelectProductTypes =
      'Vui lòng chọn ít nhất một loại hình sản phẩm';
  static const String validationInvalidTeamSize =
      'Số thành viên phải từ 1 đến 10 người';
  static const String validationMissingRequiredFields =
      'Vui lòng điền tất cả các mục bắt buộc trước khi tiếp tục';

  // Button texts
  static const String buttonContinueAndRefine = 'Tiếp tục & Tinh chỉnh';
  static const String buttonNext = 'Tiếp theo';
  static const String buttonComplete = 'Hoàn thành';
  static const String buttonBack = 'Quay lại';
  static const String buttonGenerateSuggestions = 'Tạo gợi ý đề tài';

  // Section titles for Step 1
  static const String sectionCurrentLevel = 'Trình độ hiện tại';
  static const String sectionInterests = 'Lĩnh vực sở thích';
  static const String sectionMainGoal = 'Mục tiêu chính';
  static const String sectionTechnologies = 'Công nghệ muốn dùng/học';
  static const String sectionLevelDescription =
      'Chọn trình độ phù hợp với bạn nhất';
  static const String sectionInterestsDescription =
      'Chọn các lĩnh vực bạn quan tâm (có thể chọn nhiều)';
  static const String sectionMainGoalDescription =
      'Chọn mục tiêu chính của bạn';
  static const String sectionTechnologiesDescription =
      'Chọn các công nghệ bạn muốn sử dụng hoặc học (có thể chọn nhiều)';

  // Section titles for Step 2 (Refinement)
  static const String refinementTitle = 'Tinh Chỉnh Đề Tài';
  static const String refinementSubtitle =
      'Cung cấp thêm chi tiết để Minda hiểu bạn hơn';
  static const String sectionProjectScale = 'Xác định quy mô dự án';
  static const String sectionProductType = 'Loại hình sản phẩm';
  static const String sectionTeamSize = 'Nguồn lực nhóm';
  static const String sectionSpecialRequirements =
      'Yêu cầu đặc biệt của giảng viên';
  static const String sectionProblemToSolve = 'Vấn đề bạn muốn giải quyết';

  static const String sectionProjectScaleDescription =
      'Thời gian dự kiến hoàn thành dự án';
  static const String sectionProductTypeDescription =
      'Chọn loại hình sản phẩm bạn muốn tạo';
  static const String sectionTeamSizeDescription =
      'Số thành viên tham gia dự án (bao gồm bạn)';
  static const String sectionSpecialRequirementsDescription =
      'Mô tả các yêu cầu đặc biệt từ giảng viên hoặc khóa học';
  static const String sectionProblemToSolveDescription =
      'Vấn đề cụ thể mà dự án của bạn sẽ giải quyết';

  // Placeholder texts for Step 2
  static const String hintSpecialRequirements =
      'Ví dụ: Phải dùng công nghệ X, phải có chức năng Y, báo cáo phải đạt 20 trang...';
  static const String hintProblemToSolve =
      'Bạn có thấy vấn đề nào thú vị trong cuộc sống mà công nghệ có thể giải quyết không? Hãy mô tả ở đây...';

  // Team size configurations
  static const int minTeamSize = 1;
  static const int maxTeamSize = 10;
  static const int defaultTeamSize = 1;

  // Team size labels for UI
  static const List<String> teamSizeLabels = [
    'Solo (1 người)',
    'Đôi (2 người)',
    'Nhóm nhỏ (3-4 người)',
    'Nhóm lớn (5+ người)',
  ];

  // Slider labels for project duration
  static const List<String> projectDurationLabels = [
    'Nhanh',
    '3 tháng',
    '6+ tháng',
  ];

  // Dialog texts for custom input
  static const String dialogAddOther = 'Thêm khác';
  static const String dialogAddMainGoal = 'Thêm mục tiêu khác';
  static const String dialogAddTechnology = 'Thêm công nghệ khác';
  static const String dialogAddProductType = 'Thêm loại hình sản phẩm khác';
  static const String dialogHintMainGoal = 'Nhập mục tiêu của bạn...';
  static const String dialogHintTechnology = 'Nhập tên công nghệ...';
  static const String dialogHintProductType = 'Nhập loại hình sản phẩm...';
  static const String dialogButtonAdd = 'Thêm';
  static const String dialogButtonCancel = 'Hủy';

  // AI Thinking screen messages
  static const List<String> aiThinkingMessages = [
    'Đang phân tích hồ sơ của bạn...',
    'Kết hợp các công nghệ và sở thích...',
    'Tìm kiếm trong kho ý tưởng khổng lồ...',
    'Sáng tạo những đề tài đột phá...',
    'Đang tinh chỉnh chi tiết dự án...',
    'Tối ưu hóa độ phù hợp...',
    'Sắp hoàn thành rồi, chờ một chút nhé!',
  ];

  static const String aiProcessingHint =
      'AI đang xử lý thông tin của bạn\nVui lòng đợi trong giây lát...';
  static const String aiProcessingError =
      'Đã có lỗi xảy ra trong quá trình xử lý. Vui lòng thử lại.';
}
