import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/core/controllers/global_app_controller.dart';
import 'app/core/lang/app_translations.dart';
import 'app/core/widgets/custom_chip.dart';
import 'app/core/widgets/error_state_widget.dart';
import 'app/core/widgets/section_card.dart';
import 'app/di.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();
  Get.put(GlobalAppController(), permanent: true);
  if (kDebugMode) {
    debugProfileBuildsEnabled = false;
    debugPaintSizeEnabled = false;
  }
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.SPLASH,
        getPages: AppPages.routes,
        translations: AppTranslations(),
        locale: const Locale('vi', 'VN'),
        fallbackLocale: const Locale('en', 'US'),
        title: 'app_title'.tr,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0; // mặc định -> 1 -> +1 -> ++
  // bấm nút là ++
  // => tăng biến -> _counter ++ -> tạo 1 hàm tăng biến -> bấm nút > là hành động gọi hàm
  void _incrementCounter() {
    setState(() {
      _counter++; // tạo 1 giao diện có thể hiển thị chữ -> gắn _counter cho cái giao diện thể hiện chữ đó
    });
    print("counter sau khi baams nuit la $_counter");
  }

  final RxSet<String> selectedItems = RxSet<String>();
  final List<String> options = ['Option 1', 'Option 2', 'Option 3'];

  final String title = "Title";
  final Widget child = ColumInformation(counter: 0);

  @override
  Widget build(BuildContext context) {
    print("vẽ giao diện để hiển thị lên");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          CustomChoiceChipGroup(selectedItems: selectedItems, options: options),
          Container(height: 20),
          SectionCard(
            title: title,
            child: CustomChoiceChipGroup(
              selectedItems: selectedItems,
              options: options,
            ),
          ),
          ErrorStateWidget(
            onRetry: () {
              //navigate with back
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Test ScrollToTop Demo
          // Get.put(DemoScrollToTopController());
          // Get.to(() => const DemoScrollToTopView());
        },
        tooltip: 'Test ScrollToTop',
        child: const Icon(Icons.arrow_upward),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ColumInformation extends StatelessWidget {
  const ColumInformation({super.key, required int counter})
    : _counter = counter;

  final int _counter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('You have pushed the button this many times: hello hihihi '),
        Text(
          'biến đó là $_counter',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
